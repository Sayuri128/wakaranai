import 'package:h_reader/blocs/nhentai/cache/image/image_cache_cubit.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database_exception.dart';
import 'package:h_reader/repositories/sqlite/cache/image/image_cache_database.dart';

class ImageCacheService {
  final CacheDataBase _cacheDataBase = CacheDataBase();

  Future<ImageCacheDataBase> _getDb() async => (await _cacheDataBase.getImageCacheDataBase());

  Future<void> saveImage({required String url}) async {
    await (await _getDb()).saveCacheUrl(url: url);
  }

  Future<List<CachedImageData>> getAll() async {
    return await (await _getDb()).getAll();
  }

  Future<CachedImageData> getById({required int id}) async {
    return await (await _getDb()).getById(id: id);
  }

  Future<CachedImageData> getByUrl({required String url}) async {
    return await (await _getDb()).getByUrl(url: url);
  }

  Future<List<CachedImageData>> getByUrls({required List<String> urls}) async {
    return (await Future.wait(urls.map((e) async => await getByUrl(url: e)))).toList();
  }

  Future<CachedImageData> getByUrlIfNotExistSave({required String url}) async {
    CachedImageData data;
    try {
      data = await getByUrl(url: url);
      if (await ImageCacheCubit.instance.getFileFromCache(data.url) == null) {
        await ImageCacheCubit.instance.downloadFile(url);
      }
    } on CacheDatabaseException {
      await ImageCacheCubit.instance.downloadFile(url);
      await saveImage(url: url);
      data = await getByUrl(url: url);
    }
    return data;
  }

  Future<List<CachedImageData>> getByUrlsIfNotExistSave({required List<String> urls}) async {
    return (await Future.wait(urls.map((e) async => await getByUrlIfNotExistSave(url: e))))
        .toList();
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
