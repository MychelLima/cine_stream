import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'busca_screen.dart';
import 'minha_lista_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceAtual = 0;
  final GlobalKey<MinhaListaScreenState> _minhaListaKey = GlobalKey();

  late final List<Widget> _telas = [
    const HomeScreen(),
    const BuscaScreen(),
    MinhaListaScreen(key: _minhaListaKey),
  ];

  void _aoTrocarAba(int indice) {
    setState(() => _indiceAtual = indice);

    // Sempre que a aba "Minha Lista" for aberta, recarrega os favoritos
    if (indice == 2) {
      _minhaListaKey.currentState?.carregarFavoritos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceAtual, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: _aoTrocarAba,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Minha Lista'),
        ],
      ),
    );
  }
}