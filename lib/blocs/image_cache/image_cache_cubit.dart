import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:bloc/bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:h_reader/services/sqlite/image_cache/image_cache_service.dart';
import 'package:meta/meta.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system_io.dart';

part 'image_cache_state.dart';

class ImageCacheCubit extends Cubit<ImageCacheState> {
  ImageCacheCubit({required this.isPrimary}) : super(ImageCacheInitial());

  final bool isPrimary;

  static const key = 'DoujinshiCacheKey';
  static CacheManager instance = CacheManager(Config(key,
      stalePeriod: const Duration(days: 365),
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService()));

  final ImageCacheService _imageCacheService = ImageCacheService();

  void saveCacheIfNotExist({required String url}) async {
    final cachedFile = await instance.getFileFromCache(url);
    if (cachedFile == null) {
      final newFile = await instance.putFile(url, (await http.get(Uri.parse(url))).bodyBytes);
      await _imageCacheService.saveImage(cacheKey: url);
      emit(ImageCacheSaved(data: newFile.readAsBytesSync()));
    } else {
      emit(ImageCacheSaved(data: cachedFile.file.readAsBytesSync()));
    }
  }

  void getAll() async {
    emit(ImageCacheReceivedAll(data: await _imageCacheService.getAll()));
  }

  @override
  Future<void> close() async {
    if(isPrimary) {
      await _imageCacheService.close();
    }
    return super.close();
  }
}
