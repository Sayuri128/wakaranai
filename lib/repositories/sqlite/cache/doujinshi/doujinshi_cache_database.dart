import 'dart:convert';

import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_doujinshi/cached_doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/image/image_cache_database.dart';
import 'package:sqflite/sqflite.dart';

import '../cache_database_exception.dart';

class DoujinshiCacheDatabase {
  static const tableName = 'doujinshi_cache_data';

  static const idColumn = 'id';
  static const doujinshiColumn = 'doujinshi_json';
  static const thumbnailColumn = 'cached_thumbnail_id';
  static const coverColumn = 'cached_cover_id';
  static const pageItemColumn = 'cached_page_item_ids_json';
  static const sourceItemColumn = 'cached_source_ids_json';
  static const mediaIdColumn = 'cached_doujinshi_media_id';

  final Database? database;
  final ImageCacheDataBase imageCacheDataBase;

  DoujinshiCacheDatabase({this.database, required this.imageCacheDataBase});

  Future<void> saveDoujinshi(
      {required Doujinshi doujinshi,
      required CachedImageData thumbnail,
      required CachedImageData cover,
      required List<CachedImageData> pageItems,
      required List<CachedImageData> sourceItems}) async {
    await database?.transaction((txn) async => txn.rawInsert('''INSERT INTO $tableName (
           $doujinshiColumn,
           $thumbnailColumn,
           $coverColumn,
           $pageItemColumn,
           $sourceItemColumn,
           $mediaIdColumn
         )
         VALUES(?,?,?,?,?,?)''', [
          jsonEncode(doujinshi),
          thumbnail.id,
          cover.id,
          pageItems.map((e) => escape(jsonEncode(e))).toList().toString(),
          sourceItems.map((e) => escape(jsonEncode(e))).toList().toString(),
          doujinshi.mediaId
        ]));
  }

  Future<Map<String, dynamic>> _mapResult(Map<String, dynamic> result) async => {
        idColumn: result[idColumn],
        doujinshiColumn: jsonDecode(result[doujinshiColumn] as String? ?? ''),
        thumbnailColumn:
            (await imageCacheDataBase.getById(id: result[thumbnailColumn] as int)).toJson(),
        coverColumn: (await imageCacheDataBase.getById(id: result[coverColumn] as int)).toJson(),
        pageItemColumn: jsonDecode(result[pageItemColumn] as String? ?? ''),
        sourceItemColumn: jsonDecode(result[sourceItemColumn] as String? ?? ''),
        mediaIdColumn: result[mediaIdColumn] as String
      };

  Future<List<CachedDoujinshi>> getAll() async {
    return Future.wait(
        (await database?.transaction((txn) async => txn.rawQuery('SELECT * FROM $tableName')))
                ?.map((e) async => CachedDoujinshi.fromJson(await _mapResult(e)))
                .toList() ??
            []);
  }

  Future<CachedDoujinshi> getByMediaId(String mediaId) async {
    final result = (await database!.transaction((txn) async =>
        txn.rawQuery('SELECT * FROM $tableName WHERE $mediaIdColumn = \'$mediaId\'')));
    if (result.isNotEmpty) {
      return CachedDoujinshi.fromJson(await _mapResult(result.first));
    } else {
      throw CacheDatabaseException(
          cause:
              'CachedDoujinshi with $mediaIdColumn = \'$mediaId\' does not exist in the database');
    }
  }
}

String escape(String content) {
  return content.replaceAll('\'', '\\\'');
}
