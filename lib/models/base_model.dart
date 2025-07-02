import 'package:flutter_eloquent/src/database_helper.dart';

abstract class BaseModel {
  String get table;
  String get createTableQuery;

  /// Convert model to insertable/updatable map
  Map<String, dynamic> toMap();

  /// Used internally to insert timestamps if needed
  Map<String, dynamic> _addTimestamps(
    Map<String, dynamic> data, {
    bool isCreate = false,
  }) {
    final now = DateTime.now().toIso8601String();
    if (isCreate) data['created_at'] = now;
    data['updated_at'] = now;
    return data;
  }

  // === CRUD-LIKE OPERATIONS === //

  Future<List<Map<String, dynamic>>> all() async {
    final db = await DatabaseHelper.database();
    return db.query(table);
  }

  Future<Map<String, dynamic>?> find(int id) async {
    final db = await DatabaseHelper.database();
    final res = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> where(String field, dynamic value) async {
    final db = await DatabaseHelper.database();
    return db.query(table, where: '$field = ?', whereArgs: [value]);
  }

  Future<int> create() async {
    final db = await DatabaseHelper.database();
    final data = _addTimestamps(toMap(), isCreate: true);
    return await db.insert(table, data);
  }

  Future<int> update(int id) async {
    final db = await DatabaseHelper.database();
    final data = _addTimestamps(toMap());
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.database();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // === RELATIONSHIPS === //

  Future<List<Map<String, dynamic>>> hasMany({
    required String relatedTable,
    required String foreignKey,
    required dynamic localKeyValue,
  }) async {
    final db = await DatabaseHelper.database();
    return db.query(
      relatedTable,
      where: '$foreignKey = ?',
      whereArgs: [localKeyValue],
    );
  }

  Future<Map<String, dynamic>?> hasOne({
    required String relatedTable,
    required String foreignKey,
    required dynamic localKeyValue,
  }) async {
    final db = await DatabaseHelper.database();
    final res = await db.query(
      relatedTable,
      where: '$foreignKey = ?',
      whereArgs: [localKeyValue],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> belongsTo({
    required String relatedTable,
    required int foreignId,
  }) async {
    final db = await DatabaseHelper.database();
    final res = await db.query(
      relatedTable,
      where: 'id = ?',
      whereArgs: [foreignId],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }
}
