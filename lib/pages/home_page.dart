import 'package:app/pages/carteira_page.dart';
import 'package:app/pages/configuracoes_page.dart';
import 'package:app/pages/favoritas_page.dart';
import 'package:app/pages/moedas_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  int paginaAtual = 0;
  late PageController pc;

  setPaginaAtual(pagina){
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  void initState() {   //aqui é onde controla a página do "slide" 
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          MoedasPage(),
          FavoritasPage(),
          CarteiraPage(),
          ConfiguracoesPage(),
        ],
        onPageChanged: setPaginaAtual, 
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        type: BottomNavigationBarType.fixed ,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list),label: 'Todas'),
          BottomNavigationBarItem(icon: Icon(Icons.star),label: 'Favoritas'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet),label: 'Carteira'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'Conta'),

        ],
        onTap: (pagina){
          pc.animateToPage(pagina, duration: Duration(milliseconds: 400), curve: Curves.ease);
        },
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}