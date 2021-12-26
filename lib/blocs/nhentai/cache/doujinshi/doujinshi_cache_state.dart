part of 'doujinshi_cache_cubit.dart';

@immutable
abstract class DoujinshiCacheState {}

class DoujinshiCacheInitial extends DoujinshiCacheState {}

class DoujinshiCacheReceived extends DoujinshiCacheState {
  final List<CachedDoujinshi> doujinshi;

  DoujinshiCacheReceived({
    required this.doujinshi,
  });
}

class DoujinshiCacheSaved extends DoujinshiCacheState {}
