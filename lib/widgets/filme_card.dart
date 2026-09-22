import 'package:flutter/material.dart';
import '../models/filme.dart';

class FilmeCard extends StatelessWidget {
  final Filme filme;
  final VoidCallback aoClicar;

  const FilmeCard({super.key, required this.filme, required this.aoClicar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoClicar,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFF1F1F1F),
        ),
        clipBehavior: Clip.antiAlias,
        child: filme.urlPoster.isNotEmpty
            ? Image.network(
                filme.urlPoster,
                fit: BoxFit.cover,
                height: 160,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.movie, color: Colors.grey, size: 32),
              )
            : const Center(
                child: Icon(Icons.movie, color: Colors.grey, size: 32),
              ),
      ),
    );
  }
}