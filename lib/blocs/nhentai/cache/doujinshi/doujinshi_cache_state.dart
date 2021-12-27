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

class DoujinshiCacheReceivedSingle extends DoujinshiCacheState {
  final CachedDoujinshi? doujinshi;

  DoujinshiCacheReceivedSingle({
    this.doujinshi,
  });
}

class DoujinshiCacheSaving extends DoujinshiCacheState {}

class DoujinshiCacheVerifyInProgress extends DoujinshiCacheState {}

class DoujinshiCacheVerifiedResult extends DoujinshiCacheState {
  final bool result;

  DoujinshiCacheVerifiedResult({
    required this.result,
  });
}

class DoujinshiCacheDeleting extends DoujinshiCacheState {}

class DoujinshiCacheDeleteResult extends DoujinshiCacheState {}
