import 'dart:async';
import 'package:flutter/material.dart';
import '../models/filme.dart';
import '../services/tmdb_service.dart';
import '../widgets/carrossel_filmes.dart';
import 'detalhes_screen.dart';
import 'login_screen.dart';
import '../services/sessao_usuario.dart';
import 'categoria_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TmdbService _service = TmdbService();

  final Map<String, int> _categorias = {
    'Ação': 28,
    'Comédia': 35,
    'Terror': 27,
    'Romance': 10749,
    'Drama': 18,
    'Animação': 16,
  };

  List<Filme> _emAlta = [];
  final Map<String, List<Filme>> _filmesPorCategoria = {};
  bool _carregando = true;

  int _indiceBanner = 0;
  Timer? _timerBanner;

  @override
  void initState() {
    super.initState();
    _carregarFilmes();
  }

  @override
  void dispose() {
    _timerBanner?.cancel();
    super.dispose();
  }

  Future<void> _carregarFilmes() async {
    try {
      final emAlta = await _service.buscarEmAlta();

      final resultados = await Future.wait(
        _categorias.entries.map((categoria) async {
          final filmes = await _service.buscarPorGenero(categoria.value);
          return MapEntry(categoria.key, filmes);
        }),
      );

      setState(() {
        _emAlta = emAlta;
        _filmesPorCategoria.addEntries(resultados);
        _carregando = false;
      });

      _iniciarRotacaoBanner();
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar filmes: $e')),
        );
      }
    }
  }

  void _iniciarRotacaoBanner() {
    _timerBanner?.cancel();

    // Usa só os 5 primeiros "Em alta" pro banner, pra não ficar rodando muitos
    final quantidadeParaRotacionar = _emAlta.length > 5 ? 5 : _emAlta.length;
    if (quantidadeParaRotacionar <= 1) return;

    _timerBanner = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        _indiceBanner = (_indiceBanner + 1) % quantidadeParaRotacionar;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CineStream',
          style: TextStyle(
            color: Color(0xFFE50914),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmarLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
            onRefresh: _carregarFilmes,
            color: const Color(0xFFE50914),
            backgroundColor: const Color(0xFF1F1F1F),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_emAlta.isNotEmpty)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        child: _bannerDestaque(
                          _emAlta[_indiceBanner],
                          key: ValueKey(_emAlta[_indiceBanner].id),
                        ),
                      ),
                    if (_emAlta.isNotEmpty) _indicadoresBanner(),
                    const SizedBox(height: 16),
                    CarrosselFilmes(
                      titulo: 'Em alta',
                      filmes: _emAlta,
                      aoClicarFilme: (filme) => _abrirDetalhes(context, filme),
                      aoVerTudo: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriaScreen(
                            titulo: 'Em alta',
                            buscarFilmes: _service.buscarEmAlta,
                          ),
                        ),
                      ),
                    ),
                    ..._categorias.entries.map((categoria) {
                      final filmes = _filmesPorCategoria[categoria.key] ?? [];
                      if (filmes.isEmpty) return const SizedBox.shrink();
                      return CarrosselFilmes(
                        titulo: categoria.key,
                        filmes: filmes,
                        aoClicarFilme: (filme) => _abrirDetalhes(context, filme),
                        aoVerTudo: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriaScreen(
                              titulo: categoria.key,
                              buscarFilmes: () => _service.buscarPorGenero(categoria.value),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ),
    );
  }

  Widget _indicadoresBanner() {
    final quantidade = _emAlta.length > 5 ? 5 : _emAlta.length;
    if (quantidade <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(quantidade, (index) {
          final selecionado = index == _indiceBanner;
          return GestureDetector(
            onTap: () {
              setState(() => _indiceBanner = index);
              _iniciarRotacaoBanner(); // reinicia a contagem do timer ao trocar manualmente
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: selecionado ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selecionado ? const Color(0xFFE50914) : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _bannerDestaque(Filme filme, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: () => _abrirDetalhes(context, filme),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          image: filme.urlPoster.isNotEmpty
              ? DecorationImage(image: NetworkImage(filme.urlPoster), fit: BoxFit.cover)
              : null,
          color: const Color(0xFF1F1F1F),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.only(top: 60),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xFF141414)],
            ),
          ),
          child: Text(
            filme.titulo,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _abrirDetalhes(BuildContext context, Filme filme) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalhesScreen(filme: filme)),
    );
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Sair', style: TextStyle(color: Colors.white)),
        content: const Text('Deseja realmente sair da sua conta?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              SessaoUsuario.usuarioIdLogado = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (rota) => false,
              );
            },
            child: const Text('Sair', style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
  }
}