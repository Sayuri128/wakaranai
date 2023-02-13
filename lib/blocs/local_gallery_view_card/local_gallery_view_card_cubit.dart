import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakaranai/model/services/library_items_service.dart';
import 'package:wakaranai/model/services/local_anime_gallery_view_service.dart';
import 'package:wakaranai/model/services/local_manga_gallery_view_service.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/gallery_view.dart';

part 'local_gallery_view_card_state.dart';

class LocalGalleryViewCardCubit extends Cubit<LocalGalleryViewCardState> {
  LocalGalleryViewCardCubit({required this.uid, required this.type})
      : super(LocalGalleryViewCardInitial());

  final LibraryItemsService _libraryItemsService = LibraryItemsService.instance;

  final LocalAnimeGalleryViewService _localAnimeGalleryViewService =
      LocalAnimeGalleryViewService();
  final LocalMangaGalleryViewService _localMangaGalleryViewService =
      LocalMangaGalleryViewService();

  final String uid;
  final ConfigInfoType type;

  void init() async {
    late final LocalGalleryView localGalleryView;

    try {
      switch (type) {
        case ConfigInfoType.MANGA:
          localGalleryView = await _localMangaGalleryViewService.getByUid(uid);
          break;
        case ConfigInfoType.ANIME:
          localGalleryView = await _localAnimeGalleryViewService.getByUid(uid);
          break;
      }

      final LibraryItem item =
          await _libraryItemsService.get(localGalleryView.libraryItemId!);
      emit(LocalGalleryViewCardLoaded(libraryItem: item));
    } on Exception {
      emit(LocalGalleryViewCardLoaded(libraryItem: null));
    }
  }

  void create(
      {required ApiClient client,
      required GalleryView galleryView,
      required ConfigInfo configInfo,
      required ConfigInfoType type,
      required VoidCallback onDone}) async {
    final id = await _libraryItemsService.add(
        client: client,
        galleryView: galleryView,
        configInfo: configInfo,
        type: type);
    emit(LocalGalleryViewCardLoaded(
        libraryItem: await _libraryItemsService.get(id)));
    onDone();
  }

  void delete(VoidCallback onDone) async {
    if (state is LocalGalleryViewCardLoaded) {
      final item = (state as LocalGalleryViewCardLoaded).libraryItem;
      if (item == null) {
        return;
      }
      await _libraryItemsService.delete(item.id!);
      emit(LocalGalleryViewCardLoaded(libraryItem: null));
      onDone();
    }
  }
}
