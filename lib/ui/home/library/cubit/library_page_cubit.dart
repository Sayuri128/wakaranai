import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/model/services/library/library_anime_items_service.dart';
import 'package:wakaranai/model/services/library/library_manga_items_service.dart';
import 'package:wakaranai/models/data/library/library_anime_item.dart';
import 'package:wakaranai/models/data/library/library_item.dart';
import 'package:wakaranai/models/data/library/library_manga_item.dart';
import 'package:wakascript/models/config_info/config_info.dart';

part 'library_page_state.dart';

class LibraryPageCubit extends Cubit<LibraryPageState> {
  LibraryPageCubit() : super(LibraryPageInitial());

  final LibraryMangaItemsService _libraryMangaItemsService =
      LibraryMangaItemsService.instance;
  final LibraryAnimeItemsService _libraryAnimeItemsService =
      LibraryAnimeItemsService.instance;

  static const libraryPageLimit = 20;

  void init() async {
    emit(LibraryPageLoading());
    final int mangaTotal = await _libraryMangaItemsService.count();
    final int animeTotal = await _libraryAnimeItemsService.count();
    final List<LibraryMangaItem> initialMangaItems =
        await _libraryMangaItemsService.query(
            limit: libraryPageLimit, offset: 0);
    final List<LibraryAnimeItem> initialAnimeItems =
        await _libraryAnimeItemsService.query(
            limit: libraryPageLimit, offset: 0);

    emit(LibraryPageLoaded(
        animeItems: initialAnimeItems,
        animeTotalCount: animeTotal,
        mangaItem: initialMangaItems,
        mangaTotalCount: mangaTotal));
  }

  void reloadPage(ConfigInfoType type) async {
    Future.wait([
      if (type == ConfigInfoType.MANGA) ...[
        _libraryMangaItemsService.count(),
        _libraryMangaItemsService.query(limit: libraryPageLimit, offset: 0)
      ] else if (type == ConfigInfoType.ANIME) ...[
        _libraryAnimeItemsService.count(),
        _libraryAnimeItemsService.query(limit: libraryPageLimit, offset: 0)
      ]
    ]).then((value) {
      switch (type) {
        case ConfigInfoType.ANIME:
          emit((state as LibraryPageLoaded).copyWith(
              animeTotalCount: value[0] as int,
              animeItems: value[1] as List<LibraryAnimeItem>));
          break;
        case ConfigInfoType.MANGA:
          emit((state as LibraryPageLoaded).copyWith(
              mangaTotalCount: value[0] as int,
              mangaItems: value[1] as List<LibraryMangaItem>));
          break;
      }
    });
  }

  void _loadNextPage<I extends LibraryItem>(
      {required List<I> currentList,
      required int total,
      required ConfigInfoType type,
      required void Function(List<I>) onLoaded}) async {
    if (currentList.length >= total) {
      return;
    }
    switch (type) {
      case ConfigInfoType.MANGA:
        await _libraryMangaItemsService
            .query(limit: libraryPageLimit, offset: currentList.length)
            .then((value) {
          onLoaded(value.cast<I>());
        });
        break;
      case ConfigInfoType.ANIME:
        await _libraryAnimeItemsService
            .query(limit: libraryPageLimit, offset: currentList.length)
            .then((value) {
          onLoaded(value.cast<I>());
        });
        break;
    }
  }

  void loadNextMangaPage() async {
    if (state is LibraryPageLoaded) {
      _loadNextPage<LibraryMangaItem>(
        currentList: (state as LibraryPageLoaded).mangaItem,
        total: (state as LibraryPageLoaded).mangaTotalCount,
        type: ConfigInfoType.MANGA,
        onLoaded: (newItems) {
          emit((state as LibraryPageLoaded).copyWith(mangaItems: [
            ...(state as LibraryPageLoaded).mangaItem,
            ...newItems
          ]));
        },
      );
    }
  }

  void loadNextAnimePage() async {
    if (state is LibraryPageLoaded) {
      _loadNextPage<LibraryAnimeItem>(
        currentList: (state as LibraryPageLoaded).animeItems,
        total: (state as LibraryPageLoaded).animeTotalCount,
        type: ConfigInfoType.ANIME,
        onLoaded: (newItems) {
          emit((state as LibraryPageLoaded).copyWith(animeItems: [
            ...(state as LibraryPageLoaded).animeItems,
            ...newItems
          ]));
        },
      );
    }
  }

  void delete(LibraryItem item, VoidCallback onDone) async {

    if(item is LibraryAnimeItem) {
      await _libraryAnimeItemsService.delete(item.id!);
      emit((state as LibraryPageLoaded).copyWith(
          animeItems: (state as LibraryPageLoaded).animeItems..remove(item),
          animeTotalCount: (state as LibraryPageLoaded).animeTotalCount - 1));
    } else if(item is LibraryMangaItem) {
      await _libraryMangaItemsService.delete(item.id!);
      emit((state as LibraryPageLoaded).copyWith(
          mangaItems: (state as LibraryPageLoaded).mangaItem..remove(item),
          mangaTotalCount: (state as LibraryPageLoaded).mangaTotalCount - 1));
    }

    onDone();
  }
}
