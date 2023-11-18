
import 'package:app/configs/app_settings.dart';
import 'package:app/repositories/conta_repository.dart';
import 'package:app/repositories/favoritas_repository.dart';
import 'package:app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meu_aplicativo.dart';

void main() async {

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MoedaRepository(),
          lazy: false,
        ),
        ChangeNotifierProvider(
            create: (context) => ContaRepository(
                  moedas: context.read<MoedaRepository>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(
          create: (context) => FavoritasRepository(
          ),
        ),
      ],
      child: const MeuAplicativo(),
    ),
  );
}