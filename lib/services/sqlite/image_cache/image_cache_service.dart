import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/image_cache/image_cache_database.dart';

class ImageCacheService {
  final ImageCacheDataBase _cacheDataBase = ImageCacheDataBase();

  Future<void> saveImage({required String cacheKey}) async {
    await _cacheDataBase.saveCacheKey(cacheKey: cacheKey);
  }

  Future<List<CachedImageData>> getAll() async {
    return await _cacheDataBase.getAll();
  }

  Future<void> clear() async {
    await _cacheDataBase.clear();
  }

  Future<void> close() async {
    await _cacheDataBase.close();
  }
}
