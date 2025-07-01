import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> database([String dbName = 'app.db']) async {
    if (_db != null) return _db!;
    _db = await _initDB(dbName);
    return _db!;
  }

  static Future<Database> _initDB(String name) async {
    final path = join(await getDatabasesPath(), name);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT
      )
    ''');
  }
}
