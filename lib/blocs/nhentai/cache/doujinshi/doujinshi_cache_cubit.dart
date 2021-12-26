import 'package:bloc/bloc.dart';
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

  void save({required Doujinshi doujinshi}) async {
    await _doujinshiCacheService.save(
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
                .toList()));
    emit(DoujinshiCacheSaved());
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
