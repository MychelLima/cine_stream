import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/filme.dart';

class DatabaseService {
  static Database? _banco;

  Future<Database> get banco async {
    if (_banco != null) return _banco!;
    _banco = await _inicializarBanco();
    return _banco!;
  }

  Future<Database> _inicializarBanco() async {
    final caminho = join(await getDatabasesPath(), 'cine_stream.db');
    return openDatabase(
      caminho,
      version: 3,
      onCreate: (db, versao) async {
        await _criarTabelaFavoritos(db);
        await _criarTabelaUsuarios(db);
      },
      onUpgrade: (db, versaoAntiga, versaoNova) async {
        if (versaoAntiga < 2) {
          await _criarTabelaUsuarios(db);
        }
        if (versaoAntiga < 3) {
          // Apaga os favoritos antigos (não tinham dono) e recria a tabela já com usuarioId
          await db.execute('DROP TABLE IF EXISTS favoritos');
          await _criarTabelaFavoritos(db);
        }
      },
    );
  }

  Future<void> _criarTabelaFavoritos(Database db) async {
    await db.execute('''
      CREATE TABLE favoritos (
        id INTEGER NOT NULL,
        usuarioId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        sinopse TEXT,
        caminhoPoster TEXT,
        notaMedia REAL,
        dataLancamento TEXT,
        PRIMARY KEY (id, usuarioId)
      )
    ''');
  }

  Future<void> _criarTabelaUsuarios(Database db) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeUsuario TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');
  }

  // ---------- Favoritos (agora vinculados ao usuário) ----------

  Future<void> adicionarFavorito(Filme filme, int usuarioId) async {
    final db = await banco;
    await db.insert(
      'favoritos',
      {
        'id': filme.id,
        'usuarioId': usuarioId,
        'titulo': filme.titulo,
        'sinopse': filme.sinopse,
        'caminhoPoster': filme.caminhoPoster,
        'notaMedia': filme.notaMedia,
        'dataLancamento': filme.dataLancamento,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removerFavorito(int id, int usuarioId) async {
    final db = await banco;
    await db.delete(
      'favoritos',
      where: 'id = ? AND usuarioId = ?',
      whereArgs: [id, usuarioId],
    );
  }

  Future<bool> ehFavorito(int id, int usuarioId) async {
    final db = await banco;
    final resultado = await db.query(
      'favoritos',
      where: 'id = ? AND usuarioId = ?',
      whereArgs: [id, usuarioId],
    );
    return resultado.isNotEmpty;
  }

  Future<List<Filme>> buscarFavoritos(int usuarioId) async {
    final db = await banco;
    final resultado = await db.query(
      'favoritos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );

    return resultado.map((linha) {
      return Filme(
        id: linha['id'] as int,
        titulo: linha['titulo'] as String,
        sinopse: linha['sinopse'] as String? ?? '',
        caminhoPoster: linha['caminhoPoster'] as String?,
        notaMedia: (linha['notaMedia'] as num?)?.toDouble() ?? 0,
        dataLancamento: linha['dataLancamento'] as String? ?? '',
      );
    }).toList();
  }

  // ---------- Usuários ----------

  Future<bool> cadastrarUsuario(String nomeUsuario, String senha) async {
    final db = await banco;
    try {
      await db.insert('usuarios', {'nomeUsuario': nomeUsuario, 'senha': senha});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Agora devolve o Id do usuário (ou null se inválido), em vez de só true/false
  Future<int?> validarLogin(String nomeUsuario, String senha) async {
    final db = await banco;
    final resultado = await db.query(
      'usuarios',
      where: 'nomeUsuario = ? AND senha = ?',
      whereArgs: [nomeUsuario, senha],
    );
    if (resultado.isEmpty) return null;
    return resultado.first['id'] as int;
  }

  Future<String?> buscarNomeUsuario(int usuarioId) async {
    final db = await banco;
    final resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
    if (resultado.isEmpty) return null;
    return resultado.first['nomeUsuario'] as String;
  }
  
}