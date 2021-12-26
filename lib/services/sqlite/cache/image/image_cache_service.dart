import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database.dart';
import 'package:h_reader/repositories/sqlite/cache/image/image_cache_database.dart';

class ImageCacheService {
  final CacheDataBase _cacheDataBase = CacheDataBase();

  Future<void> saveImage({required String url}) async {
    await (await _getDb()).saveCacheUrl(url: url);
  }

  Future<List<CachedImageData>> getAll() async {
    return await (await _getDb()).getAll();
  }

  Future<ImageCacheDataBase> _getDb() async => (await _cacheDataBase.getImageCacheDataBase());

  Future<List<CachedImageData>> getByUrl({required String url}) async {
    return await (await _getDb()).getByUrl(url: url);
  }

  Future<void> delete({required String cacheKey}) async {
    await (await _getDb()).deleteByUrl(url: cacheKey);
  }

  Future<void> clear() async {
    await (await _getDb()).clear();
  }

  Future<void> close() async {
    await _cacheDataBase.close();
  }
}
