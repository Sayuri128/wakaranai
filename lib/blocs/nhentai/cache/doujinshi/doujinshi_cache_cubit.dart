import 'package:bloc/bloc.dart';
import 'package:h_reader/blocs/nhentai/cache/image/image_cache_cubit.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_doujinshi/cached_doujinshi.dart';
import 'package:h_reader/services/sqlite/cache/doujinshi/doujinshi_cache_service.dart';
import 'package:h_reader/services/sqlite/cache/image/image_cache_service.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:meta/meta.dart';

part 'doujinshi_cache_state.dart';

class DoujinshiCacheCubit extends Cubit<DoujinshiCacheState> {
  DoujinshiCacheCubit() : super(DoujinshiCacheInitial());

  final _doujinshiCacheService = DoujinshiCacheService();
  final _imageCacheService = ImageCacheService();

  Future<bool> _verifyCache(String url) async {
    return await ImageCacheCubit.instance.getFileFromCache(url) != null;
  }

  void deleteCache(CachedDoujinshi doujinshi) async {
    emit(DoujinshiCacheDeleting());
    await _imageCacheService.delete(url: doujinshi.thumbnail.url);
    await _imageCacheService.delete(url: doujinshi.cover.url);
    await Future.wait(
        doujinshi.pageItems.map((e) async => await _imageCacheService.delete(url: e.url)));
    await Future.wait(
        doujinshi.sourceItems.map((e) async => await _imageCacheService.delete(url: e.url)));
    await _doujinshiCacheService.delete(doujinshi.id);
    emit(DoujinshiCacheDeleteResult());
  }

  void verifyCache(CachedDoujinshi doujinshi) async {
    emit(DoujinshiCacheVerifyInProgress());
    emit(DoujinshiCacheVerifiedResult(
        result: (await _doujinshiCacheService.getByMediaId(mediaId: doujinshi.mediaId)) != null &&
            (await _verifyCache(doujinshi.thumbnail.url)) &&
            (await _verifyCache(doujinshi.cover.url)) &&
            !(await Future.wait(doujinshi.pageItems.map((e) => _verifyCache(e.url))))
                .contains(false) &&
            !(await Future.wait(doujinshi.sourceItems.map((e) => _verifyCache(e.url))))
                .contains(false)));
  }

  void getByMediaId({required String mediaId}) async {
    emit(DoujinshiCacheReceivedSingle(
        doujinshi: await _doujinshiCacheService.getByMediaId(mediaId: mediaId)));
  }

  void save({required Doujinshi doujinshi}) async {
    emit(DoujinshiCacheSaving());
    emit(DoujinshiCacheReceivedSingle(
        doujinshi: await _doujinshiCacheService.save(
            doujinshi: doujinshi,
            thumbnail: await _imageCacheService.getByUrlIfNotExistSave(
                url: NHentaiUrls.thumbnailUrl(doujinshi.mediaId, doujinshi.images.thumbnail.t)),
            cover: await _imageCacheService.getByUrlIfNotExistSave(
                url: NHentaiUrls.coverUrl(doujinshi.mediaId, doujinshi.images.cover.t)),
            pageItems: await _imageCacheService.getByUrlsIfNotExistSave(
                urls: doujinshi.images.pages
                    .map((e) => NHentaiUrls.pageItem(
                        doujinshi.mediaId, e.t, doujinshi.images.pages.indexOf(e) + 1))
                    .toList()),
            sourceItems: await _imageCacheService.getByUrlsIfNotExistSave(
                urls: doujinshi.images.pages
                    .map((e) => NHentaiUrls.pageItemSource(
                        doujinshi.mediaId, e.t, doujinshi.images.pages.indexOf(e) + 1))
                    .toList()))));
  }

  @override
  void emit(DoujinshiCacheState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  void getAll() async {
    emit(DoujinshiCacheReceived(doujinshi: await _doujinshiCacheService.getAll()));
  }
}
