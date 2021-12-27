import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_doujinshi/cached_doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database_exception.dart';
import 'package:h_reader/repositories/sqlite/cache/doujinshi/doujinshi_cache_database.dart';

class DoujinshiCacheService {
  final CacheDataBase _cacheDataBase = CacheDataBase();

  Future<DoujinshiCacheDatabase> _getDb() async =>
      (await _cacheDataBase.getDoujinshiCacheDatabase());

  Future<CachedDoujinshi> save(
      {required Doujinshi doujinshi,
      required CachedImageData thumbnail,
      required CachedImageData cover,
      required List<CachedImageData> pageItems,
      required List<CachedImageData> sourceItems}) async {
    (await _getDb()).saveDoujinshi(
        doujinshi: doujinshi,
        thumbnail: thumbnail,
        cover: cover,
        pageItems: pageItems,
        sourceItems: sourceItems);
    return (await getByMediaId(mediaId: doujinshi.mediaId))!;
  }

  Future<void> delete(int id) async {
    await (await _getDb()).deleteById(id);
  }

  Future<List<CachedDoujinshi>> getAll() async {
    return (await _getDb()).getAll();
  }

  Future<CachedDoujinshi?> getByMediaId({required String mediaId}) async {
    try {
      final result = (await _getDb()).getByMediaId(mediaId);
      return await result;
    } on CacheDatabaseException catch (_) {
      return null;
    }
  }
}
