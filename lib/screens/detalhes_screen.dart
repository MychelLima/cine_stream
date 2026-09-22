import 'package:flutter/material.dart';
import '../models/filme.dart';
import '../services/database_service.dart';
import '../services/sessao_usuario.dart';
import '../models/ator.dart';
import '../services/tmdb_service.dart';
import '../widgets/ator_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesScreen extends StatefulWidget {
  final Filme filme;

  const DetalhesScreen({super.key, required this.filme});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final DatabaseService _bancoService = DatabaseService();
  bool _favoritado = false;
  String? _chaveTrailer;
  
  final TmdbService _tmdbService = TmdbService();
  List<Ator> _elenco = [];
  bool _carregandoElenco = true;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
    _carregarElenco();
    _carregarTrailer();
  }

  Future<void> _carregarElenco() async {
    try {
      final elenco = await _tmdbService.buscarElenco(widget.filme.id);
      setState(() {
        _elenco = elenco;
        _carregandoElenco = false;
      });
    } catch (e) {
      setState(() => _carregandoElenco = false);
    }
  }

  Future<void> _verificarFavorito() async {
    final usuarioId = SessaoUsuario.usuarioIdLogado!;
    final resultado = await _bancoService.ehFavorito(widget.filme.id, usuarioId);
    setState(() => _favoritado = resultado);
  }

  Future<void> _alternarFavorito() async {
    final usuarioId = SessaoUsuario.usuarioIdLogado!;
    if (_favoritado) {
      await _bancoService.removerFavorito(widget.filme.id, usuarioId);
    } else {
      await _bancoService.adicionarFavorito(widget.filme, usuarioId);
    }
    setState(() => _favoritado = !_favoritado);
  }

  Future<void> _carregarTrailer() async {
    final chave = await _tmdbService.buscarTrailer(widget.filme.id);
    setState(() => _chaveTrailer = chave);
  }

  Future<void> _abrirTrailer() async {
    if (_chaveTrailer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trailer não disponível para este filme.')),
      );
      return;
    }

    final url = Uri.parse('https://www.youtube.com/watch?v=$_chaveTrailer');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o trailer.')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final filme = widget.filme;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: const Color(0xFF141414),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: filme.urlPoster.isNotEmpty
                  ? Image.network(filme.urlPoster, fit: BoxFit.cover)
                  : Container(color: const Color(0xFF1F1F1F)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filme.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        filme.notaMedia.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        filme.dataLancamento.isNotEmpty
                            ? filme.dataLancamento.split('-')[0]
                            : '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _abrirTrailer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Assistir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _alternarFavorito,
                          icon: Icon(
                            _favoritado ? Icons.check : Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            _favoritado ? 'Na Lista' : 'Minha Lista',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filme.sinopse,
                    style: const TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_carregandoElenco)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    )
                  else if (_elenco.isNotEmpty) ...[
                    const Text(
                      'Elenco',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _elenco.length,
                        itemBuilder: (context, index) => AtorCard(ator: _elenco[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}