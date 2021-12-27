import 'package:h_reader/repositories/sqlite/cache/doujinshi/doujinshi_cache_database.dart';
import 'package:h_reader/ui/home/doujinshi_view/doujinshi_source_view.dart';
import 'package:sqflite/sqflite.dart';

import 'image/image_cache_database.dart';

class CacheDataBase {
  static const _dbName = 'image_cache.db';

  late final Database? _database;
  late final ImageCacheDataBase _imageCacheDataBase;
  late final DoujinshiCacheDatabase _doujinshiCacheDatabase;

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

  Future<DoujinshiCacheDatabase> getDoujinshiCacheDatabase() async {
    await _initialization;
    return _doujinshiCacheDatabase;
  }

  Future<String> _getDbName() async => '${await getDatabasesPath()} $_dbName';

  Future<void> _init() async {
    if (!_isInitialized) {
      // await _dropDb();
      _database = await openDatabase(await _getDbName(), version: 1, onCreate: (db, version) async {
        await db.execute('''CREATE TABLE ${ImageCacheDataBase.tableName}
             (${ImageCacheDataBase.idColumn} INTEGER PRIMARY KEY,
              ${ImageCacheDataBase.urlColumn} TEXT UNIQUE,
              ${ImageCacheDataBase.cachedDateColumn} DATETIME DEFAULT CURRENT_TIMESTAMP)
               ''');
        await db.execute('''CREATE TABLE ${DoujinshiCacheDatabase.tableName} 
            (${DoujinshiCacheDatabase.idColumn} INTEGER PRIMARY KEY,
            ${DoujinshiCacheDatabase.doujinshiColumn} TEXT,
            ${DoujinshiCacheDatabase.thumbnailColumn} INTEGER,
            ${DoujinshiCacheDatabase.coverColumn} INTEGER,
            ${DoujinshiCacheDatabase.pageItemColumn} TEXT,
            ${DoujinshiCacheDatabase.sourceItemColumn} TEXT,
            ${DoujinshiCacheDatabase.mediaIdColumn} TEXT,
            FOREIGN KEY(${DoujinshiCacheDatabase.thumbnailColumn})
             REFERENCES ${ImageCacheDataBase.tableName}(${ImageCacheDataBase.idColumn}),
            FOREIGN KEY (${DoujinshiCacheDatabase.coverColumn})
             REFERENCES ${ImageCacheDataBase.tableName}(${ImageCacheDataBase.idColumn}))''');
      });
      _imageCacheDataBase = ImageCacheDataBase(database: _database);
      _doujinshiCacheDatabase =
          DoujinshiCacheDatabase(database: _database, imageCacheDataBase: _imageCacheDataBase);
      _isInitialized = true;
    }
  }

  Future<void> _dropDb() async {
    await _initialization;
    await deleteDatabase(await _getDbName());
  }

  Future<void> close() async {
    await _database!.close();
  }
}
