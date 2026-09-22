import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final DatabaseService _bancoService = DatabaseService();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  String? _mensagemErro;
  bool _carregando = false;

  Future<void> _cadastrar() async {
    setState(() => _mensagemErro = null);

    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => _mensagemErro = 'Preencha usuário e senha.');
      return;
    }

    if (senha != confirmarSenha) {
      setState(() => _mensagemErro = 'As senhas não coincidem.');
      return;
    }

    setState(() => _carregando = true);
    final sucesso = await _bancoService.cadastrarUsuario(usuario, senha);
    setState(() => _carregando = false);

    if (sucesso) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada! Faça login.')),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _mensagemErro = 'Esse nome de usuário já existe.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(backgroundColor: const Color(0xFF141414), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Criar conta',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _campoTexto(_usuarioController, 'Usuário'),
            const SizedBox(height: 14),
            _campoTexto(_senhaController, 'Senha', ehSenha: true),
            const SizedBox(height: 14),
            _campoTexto(_confirmarSenhaController, 'Confirmar senha', ehSenha: true),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 12),
              Text(_mensagemErro!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _carregando ? null : _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
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