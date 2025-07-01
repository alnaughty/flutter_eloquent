import 'package:flutter_eloquent/models/base_model.dart';
import 'package:flutter_eloquent/src/database_helper.dart';

class QueryBuilder<T extends BaseModel> {
  final T model;
  final List<String> _whereClauses = [];
  final List<dynamic> _whereArgs = [];
  String? _orderBy;
  int? _limit;
  final Map<String, Future<List<dynamic>> Function(List<Map<String, dynamic>>)>
  _relations = {};

  QueryBuilder(this.model);

  // Enhanced where: accepts 2 or 3 arguments
  QueryBuilder<T> where(String field, dynamic opOrVal, [dynamic? value]) {
    String op;
    dynamic val;

    if (value == null) {
      op = '=';
      val = opOrVal;
    } else {
      op = opOrVal.toString();
      val = value;
    }

    _whereClauses.add('$field $op ?');
    _whereArgs.add(val);
    return this;
  }

  QueryBuilder<T> orderBy(String field, {bool descending = false}) {
    _orderBy = '$field ${descending ? 'DESC' : 'ASC'}';
    return this;
  }

  QueryBuilder<T> limit(int count) {
    _limit = count;
    return this;
  }

  QueryBuilder<T> cWith(
    String relationName,
    Future<List<dynamic>> Function(List<Map<String, dynamic>>) loader,
  ) {
    _relations[relationName] = loader;
    return this;
  }

  // QueryBuilder<T> with(
  // String relationName,
  // Future<List<dynamic>> Function(List<Map<String, dynamic>>) loader,
  // ) {
  // _relations[relationName] = loader;
  // return this;
  // }

  Future<List<Map<String, dynamic>>> getRaw() async {
    final db = await DatabaseHelper.database();
    return db.query(
      model.table,
      where: _whereClauses.isNotEmpty ? _whereClauses.join(' AND ') : null,
      whereArgs: _whereArgs,
      orderBy: _orderBy,
      limit: _limit,
    );
  }

  Future<List<T>> get(
    List<T> Function(List<Map<String, dynamic>>) mapper,
  ) async {
    final raw = await getRaw();
    final withRelations = await _applyRelations(raw);
    return mapper(withRelations);
  }

  Future<List<Map<String, dynamic>>> _applyRelations(
    List<Map<String, dynamic>> parents,
  ) async {
    for (final entry in _relations.entries) {
      final relationName = entry.key;
      final loader = entry.value;
      final related = await loader(parents);

      // Attach matching related data by foreign key
      for (var parent in parents) {
        final parentId = parent['id'];
        parent[relationName] = related
            .where((item) => item['${model.table}_id'] == parentId)
            .toList();
      }
    }
    return parents;
  }
}
