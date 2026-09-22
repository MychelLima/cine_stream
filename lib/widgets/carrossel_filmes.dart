import 'package:flutter/material.dart';
import '../models/filme.dart';
import 'filme_card.dart';

class CarrosselFilmes extends StatelessWidget {
  final String titulo;
  final List<Filme> filmes;
  final Function(Filme) aoClicarFilme;
  final VoidCallback? aoVerTudo;

  const CarrosselFilmes({
    super.key,
    required this.titulo,
    required this.filmes,
    required this.aoClicarFilme,
    this.aoVerTudo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (aoVerTudo != null)
                TextButton(
                  onPressed: aoVerTudo,
                  child: const Text(
                    'Ver tudo',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: filmes.length,
            itemBuilder: (context, index) {
              final filme = filmes[index];
              return FilmeCard(
                filme: filme,
                aoClicar: () => aoClicarFilme(filme),
              );
            },
          ),
        ),
      ],
    );
  }
}