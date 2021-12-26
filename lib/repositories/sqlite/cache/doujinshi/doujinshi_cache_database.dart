import 'dart:convert';

import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_doujinshi/cached_doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/image/image_cache_database.dart';
import 'package:sqflite/sqflite.dart';

class DoujinshiCacheDatabase {
  static const tableName = 'doujinshi_cache_data';

  static const idColumn = 'id';
  static const doujinshiColumn = 'doujinshi_json';
  static const thumbnailColumn = 'cached_thumbnail_id';
  static const coverColumn = 'cached_cover_id';
  static const pageItemColumn = 'cached_page_item_ids_json';
  static const sourceItemColumn = 'cached_source_ids_json';

  final Database? database;
  final ImageCacheDataBase imageCacheDataBase;

  DoujinshiCacheDatabase({this.database, required this.imageCacheDataBase});

  Future<void> saveDoujinshi(
      {required Doujinshi doujinshi,
      required CachedImageData thumbnail,
      required CachedImageData cover,
      required List<CachedImageData> pageItems,
      required List<CachedImageData> sourceItems}) async {
    await database?.transaction((txn) async => txn.rawQuery('''INSERT INTO $tableName (
           $doujinshiColumn,
           $thumbnailColumn,
           $coverColumn,
           $pageItemColumn,
           $sourceItemColumn
         )
         VALUES(
           '${jsonEncode(doujinshi)}',
           ${thumbnail.id},
           ${cover.id},
           '${pageItems.map((e) => jsonEncode(e)).toList()}',
           '${sourceItems.map((e) => jsonEncode(e)).toList()}'
         )'''));
  }

  Future<List<CachedDoujinshi>> getAll() async {
    return Future.wait(
        (await database?.transaction((txn) async => txn.rawQuery('SELECT * FROM $tableName')))
                ?.map((e) async => CachedDoujinshi.fromJson({
                      idColumn: e[idColumn],
                      doujinshiColumn: jsonDecode(e[doujinshiColumn] as String? ?? ''),
                      thumbnailColumn:
                          (await imageCacheDataBase.getById(id: e[thumbnailColumn] as int))
                              .toJson(),
                      coverColumn:
                          (await imageCacheDataBase.getById(id: e[coverColumn] as int)).toJson(),
                      pageItemColumn: jsonDecode(e[pageItemColumn] as String? ?? ''),
                      sourceItemColumn: jsonDecode(e[sourceItemColumn] as String? ?? '')
                    }))
                .toList() ??
            []);
  }
}
