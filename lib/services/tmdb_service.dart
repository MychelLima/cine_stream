import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filme.dart';
import '../api_config.dart';
import '../models/ator.dart';

class TmdbService {
  // Busca os filmes "em alta" (populares no momento)
  Future<List<Filme>> buscarEmAlta() async {
    return _buscarFilmes('/trending/movie/week');
  }

  // Busca filmes de uma categoria específica (por gênero)
  Future<List<Filme>> buscarPorGenero(int idGenero) async {
    return _buscarFilmes(
      '/discover/movie',
      parametrosExtras: {'with_genres': idGenero.toString()},
    );
  }

  // Busca filmes pelo texto digitado na busca
  Future<List<Filme>> pesquisar(String texto) async {
    return _buscarFilmes(
      '/search/movie',
      parametrosExtras: {'query': texto},
    );
  }

  // Busca o elenco de um filme específico
  Future<List<Ator>> buscarElenco(int filmeId) async {
    final parametros = {'api_key': ApiConfig.tmdbApiKey, 'language': 'pt-BR'};

    final uri = Uri.parse('${ApiConfig.baseUrl}/movie/$filmeId/credits')
        .replace(queryParameters: parametros);

    final resposta = await http.get(uri);

    if (resposta.statusCode == 200) {
      final dados = json.decode(utf8.decode(resposta.bodyBytes));
      final List elenco = dados['cast'];
      // Pega só os 15 primeiros (os mais relevantes, já vêm ordenados pela API)
      return elenco.take(15).map((item) => Ator.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar elenco: ${resposta.statusCode}');
    }
  }

  // Busca a chave do trailer no YouTube (ou null, se não tiver)
  Future<String?> buscarTrailer(int filmeId) async {
    final parametros = {'api_key': ApiConfig.tmdbApiKey, 'language': 'pt-BR'};

    final uri = Uri.parse('${ApiConfig.baseUrl}/movie/$filmeId/videos')
        .replace(queryParameters: parametros);

    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) return null;

    final dados = json.decode(utf8.decode(resposta.bodyBytes));
    final List videos = dados['results'];

    // Procura um vídeo do tipo "Trailer" hospedado no YouTube
    final trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => null,
    );

    // Se não achar em português, tenta buscar sem filtro de idioma (fallback)
    if (trailer == null) {
      final uriSemIdioma = Uri.parse('${ApiConfig.baseUrl}/movie/$filmeId/videos')
          .replace(queryParameters: {'api_key': ApiConfig.tmdbApiKey});
      final respostaFallback = await http.get(uriSemIdioma);
      if (respostaFallback.statusCode == 200) {
        final dadosFallback = json.decode(utf8.decode(respostaFallback.bodyBytes));
        final List videosFallback = dadosFallback['results'];
        final trailerFallback = videosFallback.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );
        return trailerFallback?['key'];
      }
      return null;
    }

    return trailer['key'];
  }

  // Método privado, reaproveitado pelos métodos acima
  Future<List<Filme>> _buscarFilmes(
    String endpoint, {
    Map<String, String>? parametrosExtras,
  }) async {
    final parametros = {
      'api_key': ApiConfig.tmdbApiKey,
      'language': 'pt-BR',
      ...?parametrosExtras,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
        .replace(queryParameters: parametros);

    final resposta = await http.get(uri);

    if (resposta.statusCode == 200) {
      final dados = json.decode(utf8.decode(resposta.bodyBytes));
      final List resultados = dados['results'];
      return resultados.map((item) => Filme.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar filmes: ${resposta.statusCode}');
    }
  }
}