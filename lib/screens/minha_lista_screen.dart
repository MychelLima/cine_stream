import 'package:flutter/material.dart';
import '../models/filme.dart';
import '../services/database_service.dart';
import 'detalhes_screen.dart';
import '../services/sessao_usuario.dart';

class MinhaListaScreen extends StatefulWidget {
  const MinhaListaScreen({super.key});

  @override
  State<MinhaListaScreen> createState() => MinhaListaScreenState();
}

class MinhaListaScreenState extends State<MinhaListaScreen> {
  final DatabaseService _bancoService = DatabaseService();
  List<Filme> _favoritos = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

    Future<void> carregarFavoritos() async {
    final usuarioId = SessaoUsuario.usuarioIdLogado!;
    final favoritos = await _bancoService.buscarFavoritos(usuarioId);
    setState(() => _favoritos = favoritos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Minha Lista', style: TextStyle(color: Colors.white)),
      ),
      body: _favoritos.isEmpty
          ? const Center(
              child: Text(
                'Você ainda não adicionou nenhum filme.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _favoritos.length,
              itemBuilder: (context, index) {
                final filme = _favoritos[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesScreen(filme: filme),
                      ),
                    );
                    // Ao voltar da tela de detalhes, recarrega
                    // (caso o usuário tenha removido o filme de lá)
                    carregarFavoritos();
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