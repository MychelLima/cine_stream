import 'package:flutter/material.dart';
import '../models/filme.dart';
import 'detalhes_screen.dart';

class CategoriaScreen extends StatefulWidget {
  final String titulo;
  final Future<List<Filme>> Function() buscarFilmes;

  const CategoriaScreen({
    super.key,
    required this.titulo,
    required this.buscarFilmes,
  });

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  List<Filme> _filmes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final filmes = await widget.buscarFilmes();
    setState(() {
      _filmes = filmes;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: Text(widget.titulo, style: const TextStyle(color: Colors.white)),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filmes.length,
              itemBuilder: (context, index) {
                final filme = _filmes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesScreen(filme: filme),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: filme.urlPoster.isNotEmpty
                        ? Image.network(filme.urlPoster, fit: BoxFit.cover)
                        : Container(color: const Color(0xFF1F1F1F)),
                  ),
                );
              },
            ),
    );
  }
}