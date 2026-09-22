import 'package:flutter/material.dart';
import '../models/filme.dart';
import '../services/tmdb_service.dart';
import 'detalhes_screen.dart';

class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final TmdbService _service = TmdbService();
  final TextEditingController _controller = TextEditingController();
  List<Filme> _resultados = [];
  bool _carregando = false;

  Future<void> _pesquisar(String texto) async {
    if (texto.trim().isEmpty) {
      setState(() => _resultados = []);
      return;
    }

    setState(() => _carregando = true);
    final resultados = await _service.pesquisar(texto);
    setState(() {
      _resultados = resultados;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar filmes...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: _pesquisar,
          onChanged: (texto) {
            if (texto.length > 2) _pesquisar(texto);
          },
        ),
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
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final filme = _resultados[index];
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