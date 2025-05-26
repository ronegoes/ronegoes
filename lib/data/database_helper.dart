import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;  // Importa para ler o asset
import '../main.dart'; // ou o caminho para sua model Conta

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'contas.db');
    print('📍 Banco está salvo em: $path');
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Carrega o script SQL do arquivo contas.sql
    final script = await rootBundle.loadString('lib/data/scripts/contas.sql');

    // Divide as instruções por ';' para executar cada uma
    final statements = script.split(';');

    for (var statement in statements) {
      final sql = statement.trim();
      if (sql.isNotEmpty) {
        await db.execute(sql);
      }
    }
  }

  Future<int> insertConta(Conta conta) async {
    final db = await database;
    return await db.insert('contas', conta.toMap());
  }

  Future<List<Conta>> getContas() async {
    final db = await database;
    final maps = await db.query('contas');
    return maps.map((map) => Conta.fromMap(map)).toList();
  }

  Future<int> updateConta(Conta conta) async {
    final db = await database;
    return await db.update('contas', conta.toMap(), where: 'id = ?', whereArgs: [conta.id]);
  }

  Future<int> deleteConta(int id) async {
    final db = await database;
    return await db.delete('contas', where: 'id = ?', whereArgs: [id]);
  }
}
