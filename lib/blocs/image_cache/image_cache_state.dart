part of 'image_cache_cubit.dart';

@immutable
abstract class ImageCacheState {}

class ImageCacheInitial extends ImageCacheState {}

class ImageCacheSaved extends ImageCacheState {

  final Uint8List data;

  ImageCacheSaved({
    required this.data,
  });
}

class ImageCacheReceivedAll extends ImageCacheState {
  final List<CachedImageData> data;

  ImageCacheReceivedAll({
    required this.data,
  });
}
