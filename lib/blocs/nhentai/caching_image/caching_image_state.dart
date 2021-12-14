part of 'caching_image_cubit.dart';

@immutable
abstract class CachingImageState extends Equatable {}

class CachingImageInitial extends CachingImageState {
  final CacheManager cacheManager;

  @override
  List<Object?> get props => [cacheManager];

  CachingImageInitial({
    required this.cacheManager,
  });
}
