import 'package:sqflite/sqflite.dart';
import 'package:wakaranai/models/data/history_manga_item/history_manga_item.dart';

class HistoryService {
  static const dbName = 'history.db';
  static const tableName = 'manga_history';

  Database? _db;

  Future<Database> _open() async {
    return openDatabase('${await getDatabasesPath()}/$dbName', version: 1,
        onCreate: (db, version) async {
      await db.execute(r'''create table manga_history (
                            id integer PRIMARY KEY AUTOINCREMENT,
                            serviceSourceCode text NOT NULL,
                            concreteView text NOT NULL,
                            chapterUid text NOT NULL,
                            timestamp integer NOT NULL
                            );''');
    });
  }

  Future<void> insert(HistoryMangaItem item) async {
    _db ??= await _open();

    item.id = await _db!.insert(tableName, item.toJson());
  }

  Future<HistoryMangaItem> get(int id) async {
    _db ??= await _open();

    List<Map<String, dynamic>> maps =
        await _db!.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return HistoryMangaItem.fromJson(maps.first);
    }
    throw Exception();
  }

  Future<void> delete(int id) async {
    _db ??= await _open();

    await _db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HistoryMangaItem>> getAll() async {
    _db ??= await _open();

    return (await _db!.query(tableName))
        .map((e) => HistoryMangaItem.fromJson(e))
        .toList();
  }
}
