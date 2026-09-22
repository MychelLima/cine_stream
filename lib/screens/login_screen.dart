import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'cadastro_screen.dart';
import 'main_navigation_screen.dart';
import '../services/sessao_usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseService _bancoService = DatabaseService();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _mensagemErro;
  bool _carregando = false;

    Future<void> _entrar() async {
    setState(() => _mensagemErro = null);

    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => _mensagemErro = 'Preencha usuário e senha.');
      return;
    }

    setState(() => _carregando = true);
    final usuarioId = await _bancoService.validarLogin(usuario, senha);
    setState(() => _carregando = false);

    if (usuarioId != null) {
      SessaoUsuario.usuarioIdLogado = usuarioId;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      setState(() => _mensagemErro = 'Usuário ou senha inválidos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CineStream',
                style: TextStyle(
                  color: Color(0xFFE50914),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              _campoTexto(_usuarioController, 'Usuário'),
              const SizedBox(height: 14),
              _campoTexto(_senhaController, 'Senha', ehSenha: true),
              if (_mensagemErro != null) ...[
                const SizedBox(height: 12),
                Text(_mensagemErro!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CadastroScreen()),
                    );
                  },
                  child: const Text(
                    'Não tem conta? Cadastre-se',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String rotulo, {bool ehSenha = false}) {
    return TextField(
      controller: controller,
      obscureText: ehSenha,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: rotulo,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      ),
    );
  }
}