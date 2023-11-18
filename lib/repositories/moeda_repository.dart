import 'dart:async';
import 'dart:convert';

import 'package:app/database/db.dart';
import 'package:app/models/moeda.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:http/http.dart' as http;

class MoedaRepository extends ChangeNotifier {
  List<Moeda> _tabela = [];
  late Timer intervalo;

  List<Moeda> get tabela => _tabela;

  MoedaRepository() {
    _setupMoedasTable();
    _setupDadosTableMoeda();
    _readMoedasTable();
     _refreshPrecos();
  }

   _refreshPrecos() async {
     intervalo = Timer.periodic(Duration(minutes: 5), (_) => checkPrecos());
   }

  getHistoricoMoeda(Moeda moeda) async {
    final response = await http.get(
      Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${moeda.baseId}?base=BRL',
      ),
    );
    List<Map<String, dynamic>> precos = [];

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> moeda = json['data']['prices'];

      precos.add(moeda['hour']);
      precos.add(moeda['day']);
      precos.add(moeda['week']);
      precos.add(moeda['month']);
      precos.add(moeda['year']);
      precos.add(moeda['all']);
    }

    return precos;
  }
  double parseDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0; // ou outro valor padrão
    }

    try {
      return double.parse(value);
    } catch (e) {
      print("Erro ao converter a string para double: $value");
      return 0.0; // ou outro valor padrão
    }
  }

  

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/prices?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];
      Database db = await DB.instance.database;
      Batch batch = db.batch();

      for (var atual in _tabela) {
        for (var novo in moedas) {
          if (atual.baseId == novo['base_id']) {
            final moeda = novo['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            batch.update(
              'moedas',
              {
                'preco': moeda['latest'],
                'timestamp': timestamp.millisecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal': preco['percent_change']['all'].toString()
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        }
      }
      await batch.commit(noResult: true);
      await _readMoedasTable();
    }
  }

 _readMoedasTable() async {
  Database db = await DB.instance.database;
  List resultados = await db.query('moedas');

  _tabela = resultados.map((row) {
    try {
      return Moeda(
        baseId: row['baseId'],
        icone: row['icone'],
        sigla: row['sigla'],
        nome: row['nome'],
        preco: parseDouble(row['preco'].toString()),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        mudancaHora: parseDouble(row['mudancaHora'].toString()),
        mudancaDia: parseDouble(row['mudancaDia'].toString()),
        mudancaSemana: parseDouble(row['mudancaSemana'].toString()),
        mudancaMes: parseDouble(row['mudancaMes'].toString()),
        mudancaAno: parseDouble(row['mudancaAno'].toString()),
        mudancaPeriodoTotal: parseDouble(row['mudancaPeriodoTotal'].toString()),
      );
    } catch (e) {
      print("Erro ao criar objeto Moeda: $e");
      return Moeda(baseId: '0', icone: '', nome: 'nome', sigla: 'sigla', preco: 0.0, timestamp: DateTime.now(), mudancaHora: 0.0, mudancaDia: 0.0, mudancaSemana: 0.0, mudancaMes: 0.0, mudancaAno: 0.0, mudancaPeriodoTotal: 0.0); // ou outro valor padrão
    }
  }).toList();

  notifyListeners();
}

  _moedasTableIsEmpty() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('moedas');
    return resultados.isEmpty;
  }

  _setupDadosTableMoeda() async {
    if (await _moedasTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> moedas = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        for (var moeda in moedas) {
          final preco = moeda['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          batch.insert('moedas', {
            'baseId': moeda['id'],
            'sigla': moeda['symbol'],
            'nome': moeda['name'],
            'icone': moeda['image_url'],
            'preco': parseDouble(moeda['latest']),
            'timestamp': timestamp.millisecondsSinceEpoch,
            'mudancaHora': parseDouble(preco['percent_change']['hour'].toString()),
'mudancaDia': parseDouble(preco['percent_change']['day'].toString()),
'mudancaSemana': parseDouble(preco['percent_change']['week'].toString()),
'mudancaMes': parseDouble(preco['percent_change']['month'].toString()),
'mudancaAno': parseDouble(preco['percent_change']['year'].toString()),
'mudancaPeriodoTotal': parseDouble(preco['percent_change']['all'].toString()),
          });
        }
        await batch.commit(noResult: true);
      }
    }
  }

  _setupMoedasTable() async {
    const String table = '''
      CREATE TABLE IF NOT EXISTS moedas (
        baseId TEXT PRIMARY KEY,
        sigla TEXT,
        nome TEXT,
        icone TEXT,
        preco TEXT,
        timestamp INTEGER,
        mudancaHora TEXT,
        mudancaDia TEXT,
        mudancaSemana TEXT,
        mudancaMes TEXT,
        mudancaAno TEXT,
        mudancaPeriodoTotal TEXT
      );
    ''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}