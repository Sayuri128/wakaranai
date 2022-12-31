import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/models/serializable_object.dart';

abstract class SqfliteService<T extends SerializableObject> {
  Database? _db;
  final String tableName;

  static const String mangaHistoryTableName = 'manga_history';
  static const String configsSourcesTableName = 'configs_sources';

  SqfliteService({required this.tableName});

  Future<Database> _open() async {
    // await deleteDatabase('${await getDatabasesPath()}/${Env.SQFLITE_DB_NAME}');
    return openDatabase('${await getDatabasesPath()}/${Env.SQFLITE_DB_NAME}',
        version: 1, onCreate: (db, version) async {
      await db.execute('''create table $configsSourcesTableName (
                            id integer PRIMARY KEY AUTOINCREMENT,
                            baseUrl text NOT NULL,
                            name text NOT NULL,
                            type text NOT NULL,
                            created DATETIME DEFAULT CURRENT_TIMESTAMP
                            );''');
      await db.execute('''create table $mangaHistoryTableName  (
                            id integer PRIMARY KEY AUTOINCREMENT,
                            serviceSourceCode text NOT NULL,
                            concreteView text NOT NULL,
                            galleryView text NOT NULL,
                            chapterUid text NOT NULL,
                            timestamp integer NOT NULL
                            );''');
    });
  }

  Future<int> insert(T item) async {
    _db ??= await _open();
    return await _db!.insert(tableName, item.toMap());
  }

  Future<T> get(int id, T Function(Map<String, dynamic> json) fromJson) async {
    _db ??= await _open();

    List<Map<String, dynamic>> maps =
        await _db!.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return fromJson(maps.first);
    }
    throw Exception();
  }

  Future<void> delete(int id) async {
    _db ??= await _open();

    await _db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<T>> getAll(T Function(Map<String, dynamic> json) fromJson) async {
    _db ??= await _open();

    return (await _db!.query(tableName)).map((e) => fromJson(e)).toList();
  }

  Future<void> clear() async {
    _db ??= await _open();

    await _db!.delete(tableName);
  }
}
