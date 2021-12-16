import 'package:bloc/bloc.dart';
import 'package:h_reader/models/sqlite/cached_image_data.dart';
import 'package:h_reader/services/sqlite/image_cache/image_cache_service.dart';
import 'package:meta/meta.dart';

part 'image_cache_state.dart';

class ImageCacheCubit extends Cubit<ImageCacheState> {
  ImageCacheCubit() : super(ImageCacheInitial());

  final ImageCacheService _imageCacheService = ImageCacheService();

  void saveCacheIfNotExist({required String cacheKey}) async {
    await _imageCacheService.saveImage(cacheKey: cacheKey);
    emit(ImageCacheSaved());
  }

  void getAll() async {
    emit(ImageCacheReceivedAll(data: await _imageCacheService.getAll()));
  }

  @override
  Future<void> close() async {
    await _imageCacheService.close();
    return super.close();
  }
}
