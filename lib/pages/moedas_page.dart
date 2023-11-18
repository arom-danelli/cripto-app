import 'package:app/configs/app_settings.dart';
import 'package:app/models/moeda.dart';
import 'package:app/pages/moedas_detalhes_page.dart';
import 'package:app/repositories/favoritas_repository.dart';
import 'package:app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedasPage extends StatefulWidget {
  const MoedasPage({super.key});

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  late List<Moeda> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;

 readNumberFormat() {
  loc = context.watch<AppSettings>().locale;
  real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
}


  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['name'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.swap_vert),
            title: Text('Usar $locale'),
            onTap: () {
              context.read<AppSettings>().setLocale(locale, name);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: const Text('Cripto Moedas'),
        /*actions: [
          changeLanguageButton(), //é um botão que vou implementar depois.
        ],*/
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        title: Text(
          '${selecionadas.length} selecionadas',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 207, 214, 255),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedasDetalhesPage(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<FavoritasRepository>(context);
    moedas = Provider.of<MoedaRepository>(context);
    tabela = moedas.tabela;

    readNumberFormat();
    
    return Scaffold(
        appBar: appBarDinamica(),
        body: RefreshIndicator(
          onRefresh: () => moedas.checkPrecos(),
          child: ListView.separated(
            itemBuilder: (BuildContext context, int moeda) {
              return ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
             //   leading: (selecionadas.contains(tabela[moeda]))
             //       ? const CircleAvatar(
               //         child: Icon(Icons
           //                 .check), // aqui está rolando uma condicional. Se rolar um longpress vai alterar a imagem para check.
        //              )
                   // : SizedBox(
                      //  width: 40,
                      //  child: Image.network(tabela[moeda].icone),
                    //  ),
                title: Row(
                  children: [
                    Text(
                      tabela[moeda].nome,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (favoritas.lista.contains(tabela[moeda]))
                      Icon(Icons.star, color: Colors.amber, size: 14),
                  ],
                ),
                trailing: Text(
                  real.format(tabela[moeda].preco),
                ),
                selected: selecionadas.contains(tabela[moeda]),
                selectedTileColor: Colors.indigo[50],
                onLongPress: () {
                  setState(() {
                    (selecionadas.contains(tabela[moeda]))
                        ? selecionadas.remove(tabela[moeda])
                        : selecionadas.add(tabela[moeda]);
                  });
                },
                onTap: () => mostrarDetalhes(tabela[moeda]),
              );
            },
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, ___) => const Divider(),
            itemCount: tabela.length,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: selecionadas.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  favoritas.saveAll(selecionadas);
                  limparSelecionadas();
                },
                icon: const Icon(Icons.star),
                label: const Text(
                  'Favoritar',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null);
  }
}
