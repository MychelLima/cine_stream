class Ator {
  final int id;
  final String nome;
  final String personagem;
  final String? caminhoFoto;

  Ator({
    required this.id,
    required this.nome,
    required this.personagem,
    required this.caminhoFoto,
  });

  factory Ator.fromJson(Map<String, dynamic> json) {
    return Ator(
      id: json['id'] ?? 0,
      nome: json['name'] ?? 'Desconhecido',
      personagem: json['character'] ?? '',
      caminhoFoto: json['profile_path'],
    );
  }

  String get urlFoto {
    if (caminhoFoto == null) return '';
    return 'https://image.tmdb.org/t/p/w185$caminhoFoto';
  }
}