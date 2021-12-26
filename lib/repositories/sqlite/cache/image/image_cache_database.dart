import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:sqflite/sqflite.dart';

class ImageCacheDataBase {

  static const tableName = 'image_cache_data';

  final Database? database;
  Future? initialization;

  ImageCacheDataBase({
    required this.database,
    required this.initialization
  });

  Future<void> saveCacheUrl({required String url}) async {
    await initialization;
    await database!.transaction((txn) async => await txn.rawInsert(
        'INSERT OR IGNORE INTO $tableName (url) VALUES (\'$url\')'));
  }

  Future<void> deleteByUrl({required String url}) async {
    await initialization;
    await database!.transaction((txn) async =>
    await txn.rawQuery('DELETE FROM $tableName WHERE url = \'$url\''));
  }

  Future<List<CachedImageData>> getByUrl({required String url}) async {
    await initialization;
    return (await database!.transaction(
            (txn) async => txn.rawQuery('SELECT * FROM $tableName WHERE url = \'$url\'')))
        .map((e) => CachedImageData.fromJson(e))
        .toList();
  }

  Future<void> updateCacheKeyByUrl({required String url, required String cacheKey}) async {
    await initialization;
    await database!.transaction((txn) async =>
        txn.rawQuery('UPDATE $tableName SET cache_key = \'$cacheKey\' WHERE url = \'$url\''));
  }

  Future<List<CachedImageData>> getAll() async {
    await initialization;
    return (await database!.transaction((txn) => txn.rawQuery('SELECT * FROM $tableName')))
        .map((e) => CachedImageData.fromJson(e))
        .toList();
  }

  Future<void> clear() async {
    await initialization;
    await database!.transaction((txn) => txn.rawQuery('DELETE FROM $tableName'));
  }

}
