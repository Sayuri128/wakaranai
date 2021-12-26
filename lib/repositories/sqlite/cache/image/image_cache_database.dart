import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:sqflite/sqflite.dart';

import '../cache_database_exception.dart';

class ImageCacheDataBase {
  static const tableName = 'image_cache_data';

  static const idColumn = 'id';
  static const urlColumn = 'url';
  static const cachedDateColumn = 'cached_date';

  final Database? database;

  ImageCacheDataBase({required this.database});

  Future<void> saveCacheUrl({required String url}) async {
    await database!.transaction((txn) async =>
        await txn.rawInsert('INSERT OR IGNORE INTO $tableName ($urlColumn) VALUES (\'$url\')'));
  }

  Future<void> deleteByUrl({required String url}) async {
    await database!.transaction(
        (txn) async => await txn.rawQuery('DELETE FROM $tableName WHERE $urlColumn = \'$url\''));
  }

  Future<CachedImageData> getById({required int id}) async {
    final result = (await database!.transaction(
        (txn) async => await txn.rawQuery('SELECT * FROM $tableName WHERE $idColumn = $id')));
    if (result.isNotEmpty) {
      return CachedImageData.fromJson(result.first);
    } else {
      throw CacheDatabaseException(cause: 'CachedImageData with id = $id does not exist');
    }
  }

  Future<CachedImageData> getByUrl({required String url}) async {
    final result = (await database!.transaction(
        (txn) async => txn.rawQuery('SELECT * FROM $tableName WHERE $urlColumn = \'$url\'')));
    if (result.isNotEmpty) {
      return CachedImageData.fromJson(result.first);
    } else {
      throw CacheDatabaseException(cause: 'CachedImageData with url = $url does not exist');
    }
  }

  Future<void> updateCacheKeyByUrl({required String url, required String cacheKey}) async {
    await database!.transaction((txn) async => txn.rawQuery(
        'UPDATE $tableName SET $cachedDateColumn = \'$cacheKey\' WHERE $urlColumn = \'$url\''));
  }

  Future<List<CachedImageData>> getAll() async {
    return (await database!.transaction((txn) => txn.rawQuery('SELECT * FROM $tableName')))
        .map((e) => CachedImageData.fromJson(e))
        .toList();
  }

  Future<void> clear() async {
    await database!.transaction((txn) => txn.rawQuery('DELETE FROM $tableName'));
  }
}
