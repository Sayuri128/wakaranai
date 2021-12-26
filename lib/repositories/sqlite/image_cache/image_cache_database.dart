import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:sqflite/sqflite.dart';

class ImageCacheDataBase {
  static const _tableName = 'image_cache_data';
  static const _dbName = 'image_cache.db';

  late final Database? database;

  Future? _initialization;
  bool _isInitialized;

  static final ImageCacheDataBase _instance = ImageCacheDataBase._construct();
  ImageCacheDataBase._construct() : _isInitialized = false {
    _initialization = _init();
  }
  factory ImageCacheDataBase() => _instance;

  Future<String> _getDbName() async => '${await getDatabasesPath()} $_dbName';

  Future<void> _init() async {
    if (!_isInitialized) {
      _isInitialized = true;
      database = await openDatabase(await _getDbName(), version: 1, onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, url TEXT UNIQUE, cached_date DATETIME DEFAULT CURRENT_TIMESTAMP)');
      });
    }
  }

  Future<void> saveCacheUrl({required String url}) async {
    await _initialization;
    await database!.transaction((txn) async => await txn.rawInsert(
        'INSERT OR IGNORE INTO $_tableName (url) VALUES (\'$url\')'));
  }

  Future<void> deleteByUrl({required String url}) async {
    await _initialization;
    await database!.transaction((txn) async =>
        await txn.rawQuery('DELETE FROM $_tableName WHERE url = \'$url\''));
  }

  Future<List<CachedImageData>> getByUrl({required String url}) async {
    await _initialization;
    return (await database!.transaction(
            (txn) async => txn.rawQuery('SELECT * FROM $_tableName WHERE url = \'$url\'')))
        .map((e) => CachedImageData.fromJson(e))
        .toList();
  }

  Future<void> updateCacheKeyByUrl({required String url, required String cacheKey}) async {
    await _initialization;
    await database!.transaction((txn) async =>
        txn.rawQuery('UPDATE $_tableName SET cache_key = \'$cacheKey\' WHERE url = \'$url\''));
  }

  Future<List<CachedImageData>> getAll() async {
    await _initialization;
    return (await database!.transaction((txn) => txn.rawQuery('SELECT * FROM $_tableName')))
        .map((e) => CachedImageData.fromJson(e))
        .toList();
  }

  Future<void> clear() async {
    await _initialization;
    await database!.transaction((txn) => txn.rawQuery('DELETE FROM $_tableName'));
  }

  Future<void> _dropDb() async {
    await _initialization;
    deleteDatabase(await _getDbName());
  }

  Future<void> close() async {
    assert(_isInitialized);
    await database!.close();
  }
}
