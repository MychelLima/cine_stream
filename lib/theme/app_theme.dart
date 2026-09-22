import 'package:flutter/material.dart';

class AppTheme {
  static const Color fundoPrincipal = Color(0xFF141414);
  static const Color fundoCard = Color(0xFF1F1F1F);
  static const Color vermelho = Color(0xFFE50914);
  static const Color textoSecundario = Color(0xFFB3B3B3);

  static ThemeData get tema {
    return ThemeData(
      scaffoldBackgroundColor: fundoPrincipal,
      brightness: Brightness.dark,
      primaryColor: vermelho,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: fundoPrincipal,
        elevation: 0,
      ),
    );
  }
}