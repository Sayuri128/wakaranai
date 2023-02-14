import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakaranai/model/services/library_anime_items_service.dart';
import 'package:wakaranai/model/services/library_manga_items_service.dart';
import 'package:wakaranai/model/services/local_anime_gallery_view_service.dart';
import 'package:wakaranai/model/services/local_manga_gallery_view_service.dart';
import 'package:wakaranai/models/data/library_anime_item.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/library_manga_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/gallery_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'local_gallery_view_card_state.dart';

class LocalGalleryViewCardCubit<I extends LibraryItem<G>,
    G extends LocalGalleryView> extends Cubit<LocalGalleryViewCardState<I, G>> {
  LocalGalleryViewCardCubit({required this.uid})
      : super(LocalGalleryViewCardInitial<I, G>());

  final LibraryAnimeItemsService _libraryAnimeItemsService =
      LibraryAnimeItemsService.instance;
  final LibraryMangaItemsService _libraryMangaItemsService =
      LibraryMangaItemsService.instance;

  final LocalAnimeGalleryViewService _localAnimeGalleryViewService =
      LocalAnimeGalleryViewService();
  final LocalMangaGalleryViewService _localMangaGalleryViewService =
      LocalMangaGalleryViewService();

  final String uid;

  void init() async {
    late final LocalGalleryView localGalleryView;

    try {
      if (I == LibraryMangaItem && G == LocalMangaGalleryView) {
        localGalleryView = await _localMangaGalleryViewService.getByUid(uid);
        emit(LocalGalleryViewCardLoaded(
            libraryItem: (await _libraryMangaItemsService
                .getByGalleryId(localGalleryView.id!)) as I?));
      } else if (I == LibraryAnimeItem) {
        localGalleryView = await _localAnimeGalleryViewService.getByUid(uid);
        emit(LocalGalleryViewCardLoaded(
            libraryItem: (await _libraryAnimeItemsService
                .getByGalleryId(localGalleryView.id!)) as I?));
      }
    } on Exception {
      emit(LocalGalleryViewCardLoaded<I, G>(libraryItem: null));
    }
  }

  void create(
      {required ApiClient client,
      required GalleryView galleryView,
      required ConfigInfo configInfo,
      required VoidCallback onDone}) async {
    if (I == LibraryMangaItem) {
      final id = await _libraryMangaItemsService.add(
          client: client as MangaApiClient,
          galleryView: galleryView as MangaGalleryView,
          configInfo: configInfo,
          type: ConfigInfoType.MANGA);
      emit(LocalGalleryViewCardLoaded(
          libraryItem: (await _libraryMangaItemsService.get(id)) as I?));
    } else if (I == LibraryAnimeItem) {
      final id = await _libraryAnimeItemsService.add(
          client: client as AnimeApiClient,
          galleryView: galleryView as AnimeGalleryView,
          configInfo: configInfo);
      emit(LocalGalleryViewCardLoaded(
          libraryItem: (await _libraryAnimeItemsService.get(id)) as I?));
    }

    onDone();
  }

  void delete(VoidCallback onDone) async {
    if (state is LocalGalleryViewCardLoaded) {
      final item = (state as LocalGalleryViewCardLoaded).libraryItem;
      if (item == null) {
        return;
      }
      if (I == LibraryMangaItem) {
        await _libraryMangaItemsService.delete(item.id!);
      } else if (I == LibraryAnimeItem) {
        await _libraryAnimeItemsService.delete(item.id!);
      }
      emit(LocalGalleryViewCardLoaded(libraryItem: null));
      onDone();
    }
  }
}
