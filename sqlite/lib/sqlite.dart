import 'package:sqflite/sqflite.dart' as sqlite;

typedef OnCreate = void Function(sqlite.Database db, int version);

class DatabaseHelper {
  static sqlite.Database _db;

  final String path;
  final int version;
  final OnCreate onCreate;
  DatabaseHelper(
    this.path,
    this.version,
    this.onCreate);

  Future<sqlite.Database> get db async => _db == null ? await _init() : _db;
  
  _init() async {
    return await sqlite.openDatabase(
      path,
      version: version,
      onCreate: onCreate);
  }

  Future<List<Map<String, dynamic>>> query(String sql) async {
    return (await db).rawQuery(sql);
  }

  Future<int> insert(String sql) async {
    return (await db).rawInsert(sql);
  }

  Future<int> update(String sql) async {
    return (await db).rawUpdate(sql);
  }

  Future<int> delete(String sql) async {
    return (await db).rawDelete(sql);
  }

  Future<T> transaction<T>(Action<T> action) async {
    return (await db).transaction<T>((t) => action(Executor(t)));
  }

  Future<Executor> getExecutor() async {
    return Executor(await db);
  }
}
typedef Action<T> = Future<T> Function(Executor);

class Executor {
  sqlite.DatabaseExecutor _executor;
  Executor(this._executor);

  Future<List<Map<String, dynamic>>> query(String sql) {
    return _executor.rawQuery(sql);
  }

  Future<int> insert(String sql) {
    return _executor.rawInsert(sql);
  }

  Future<int> update(String sql) {
    return _executor.rawUpdate(sql);
  }

  Future<int> delete(String sql) {
    return _executor.rawDelete(sql);
  }
}