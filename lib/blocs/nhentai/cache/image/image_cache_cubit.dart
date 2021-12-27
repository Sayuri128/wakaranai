import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';
import 'package:h_reader/repositories/sqlite/cache/cache_database_exception.dart';
import 'package:h_reader/services/sqlite/cache/image/image_cache_service.dart';
import 'package:meta/meta.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system_io.dart';

part 'image_cache_state.dart';

class ImageCacheCubit extends Cubit<ImageCacheState> {
  ImageCacheCubit({required this.isPrimary}) : super(ImageCacheInitial());

  final bool isPrimary;

  static const key = 'DoujinshiCacheKey';
  static CacheManager instance = CacheManager(Config(key,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 10000,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService()));

  final ImageCacheService _imageCacheService = ImageCacheService();

  @override
  void emit(ImageCacheState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  void saveCacheIfNotExist({required String url}) async {
    try {
      final cachedFile =
          await instance.getFileFromCache((await _imageCacheService.getByUrl(url: url)).url);
      if (cachedFile == null) {
        final newFile = await instance.downloadFile(url);
        emit(ImageCacheSaved(data: newFile.file.readAsBytesSync()));
      } else {
        emit(ImageCacheSaved(data: cachedFile.file.readAsBytesSync()));
      }
    } on CacheDatabaseException {
      final newFile = await instance.downloadFile(url);
      await _imageCacheService.saveImage(url: url);
      emit(ImageCacheSaved(data: newFile.file.readAsBytesSync()));
    }
  }

  void getAll() async {
    emit(ImageCacheReceivedAll(data: await _imageCacheService.getAll()));
  }

  void syncDbAndCache() async {
    final dbData = await _imageCacheService.getAll();

    var synchronizedCount = 0;

    for (var i = 0; i < dbData.length; i++) {
      if (await instance.getFileFromCache(dbData[i].url) == null) {
        await instance.downloadFile(dbData[i].url);
        synchronizedCount++;
      }
      emit(ImageCacheSyncProgress(percentage: i / dbData.length));
    }

    emit(ImageCacheSyncCompleted(count: synchronizedCount));
    getAll();
  }

  @override
  Future<void> close() async {
    if (isPrimary) {
      await _imageCacheService.close();
    }
    return super.close();
  }
}
