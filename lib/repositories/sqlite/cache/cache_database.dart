import 'package:sqflite/sqflite.dart';

import 'image/image_cache_database.dart';

class CacheDataBase {
  static const _dbName = 'image_cache.db';

  late final Database? _database;
  late final ImageCacheDataBase _imageCacheDataBase;

  Future? _initialization;
  bool _isInitialized;

  static final CacheDataBase _instance = CacheDataBase._construct();
  CacheDataBase._construct() : _isInitialized = false {
    _initialization = _init();
  }
  factory CacheDataBase() => _instance;

  Future<ImageCacheDataBase> getImageCacheDataBase() async {
    await _initialization;
    return _imageCacheDataBase;
  }

  Future<String> _getDbName() async => '${await getDatabasesPath()} $_dbName';

  Future<void> _init() async {
    if (!_isInitialized) {
      _database = await openDatabase(await _getDbName(), version: 1, onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE ${ImageCacheDataBase.tableName} (id INTEGER PRIMARY KEY, url TEXT UNIQUE, cached_date DATETIME DEFAULT CURRENT_TIMESTAMP)');
      });
      _imageCacheDataBase = ImageCacheDataBase(database: _database, initialization: _initialization);
      _isInitialized = true;
    }
  }

  Future<void> _dropDb() async {
    await _initialization;
    deleteDatabase(await _getDbName());
  }

  Future<void> close() async {
    assert(_isInitialized);
    await _database!.close();
  }
}
