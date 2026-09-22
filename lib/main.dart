import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CineStreamApp());
}

class CineStreamApp extends StatelessWidget {
  const CineStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineStream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      home: const LoginScreen(),
    );
  }
}