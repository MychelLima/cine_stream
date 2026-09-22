import 'package:flutter/material.dart';
import '../models/ator.dart';

class AtorCard extends StatelessWidget {
  final Ator ator;

  const AtorCard({super.key, required this.ator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF2A2A2A),
            backgroundImage: ator.urlFoto.isNotEmpty
                ? NetworkImage(ator.urlFoto)
                : null,
            child: ator.urlFoto.isEmpty
                ? const Icon(Icons.person, color: Colors.grey, size: 30)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            ator.nome,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ator.personagem,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}