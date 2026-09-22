class Filme {
  final int id;
  final String titulo;
  final String sinopse;
  final String? caminhoPoster;
  final double notaMedia;
  final String dataLancamento;

  Filme({
    required this.id,
    required this.titulo,
    required this.sinopse,
    required this.caminhoPoster,
    required this.notaMedia,
    required this.dataLancamento,
  });

  // Constrói um Filme a partir do JSON que a API do TMDB devolve
  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      id: json['id'] ?? 0,
      titulo: json['title'] ?? 'Sem título',
      sinopse: json['overview'] ?? 'Sem sinopse disponível.',
      caminhoPoster: json['poster_path'],
      notaMedia: (json['vote_average'] ?? 0).toDouble(),
      dataLancamento: json['release_date'] ?? '',
    );
  }

  // URL completa do pôster, pronta pra usar numa imagem
  String get urlPoster {
    if (caminhoPoster == null) return '';
    return 'https://image.tmdb.org/t/p/w500$caminhoPoster';
  }
}