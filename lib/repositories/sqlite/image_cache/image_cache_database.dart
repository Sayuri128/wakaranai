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
            'CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, cache_key TEXT UNIQUE, cached_date DATETIME DEFAULT CURRENT_TIMESTAMP)');
      });
    }
  }

  Future<void> saveCacheKey({required String cacheKey}) async {
    await _initialization;
    await database!.transaction((txn) async => await txn
        .rawInsert('INSERT OR IGNORE INTO $_tableName (cache_key) VALUES (\'$cacheKey\')'));
  }

  Future<List<CachedImageData>> getAll() async {
    await _initialization;
    final result = await database!.transaction((txn) => txn.rawQuery('SELECT * FROM $_tableName'));
    return result.map((e) => CachedImageData.fromJson(e)).toList();
  }

  Future<void> close() async {
    assert(_isInitialized);
    await database!.close();
  }
}
