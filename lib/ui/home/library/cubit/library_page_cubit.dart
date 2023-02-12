import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/model/services/library_items_service.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';

part 'library_page_state.dart';

class LibraryPageCubit extends Cubit<LibraryPageState> {
  LibraryPageCubit() : super(LibraryPageInitial());

  final LibraryItemsService _libraryItemsService = LibraryItemsService.instance;

  static const libraryPageLimit = 20;

  void init() async {
    emit(LibraryPageLoading());
    final int mangaTotal =
        await _libraryItemsService.count(type: LocalApiClientType.MANGA);
    final int animeTotal =
        await _libraryItemsService.count(type: LocalApiClientType.ANIME);
    final List<LibraryItem> initialMangaItems =
        await _libraryItemsService.query(
            limit: libraryPageLimit, offset: 0, type: LocalApiClientType.MANGA);
    final List<LibraryItem> initialAnimeItems =
        await _libraryItemsService.query(
            limit: libraryPageLimit, offset: 0, type: LocalApiClientType.ANIME);

    emit(LibraryPageLoaded(
        animeItems: initialAnimeItems,
        animeTotalCount: animeTotal,
        mangaItem: initialMangaItems,
        mangaTotalCount: mangaTotal));
  }

  void reloadPage(LocalApiClientType type) async {
    Future.wait([
      _libraryItemsService.count(type: type),
      _libraryItemsService.query(limit: libraryPageLimit, offset: 0, type: type)
    ]).then((value) {
      switch (type) {
        case LocalApiClientType.ANIME:
          emit((state as LibraryPageLoaded).copyWith(
              animeTotalCount: value[0] as int,
              animeItems: value[1] as List<LibraryItem>));
          break;
        case LocalApiClientType.MANGA:
          emit((state as LibraryPageLoaded).copyWith(
              mangaTotalCount: value[0] as int,
              mangaItems: value[1] as List<LibraryItem>));
          break;
      }
    });
  }

  void _loadNextPage(
      {required List<LibraryItem> currentList,
      required int total,
      required LocalApiClientType type,
      required void Function(List<LibraryItem>) onLoaded}) async {
    if (currentList.length >= total) {
      return;
    }
    await _libraryItemsService
        .query(limit: libraryPageLimit, offset: currentList.length, type: type)
        .then((value) {
      onLoaded(value);
    });
  }

  void loadNextMangaPage() async {
    if (state is LibraryPageLoaded) {
      _loadNextPage(
        currentList: (state as LibraryPageLoaded).mangaItem,
        total: (state as LibraryPageLoaded).mangaTotalCount,
        type: LocalApiClientType.MANGA,
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
      _loadNextPage(
        currentList: (state as LibraryPageLoaded).animeItems,
        total: (state as LibraryPageLoaded).animeTotalCount,
        type: LocalApiClientType.ANIME,
        onLoaded: (newItems) {
          emit((state as LibraryPageLoaded).copyWith(animeItems: [
            ...(state as LibraryPageLoaded).mangaItem,
            ...newItems
          ]));
        },
      );
    }
  }

  void delete(LibraryItem item, VoidCallback onDone) async {
    await _libraryItemsService.delete(item.id!);

    switch (item.type) {
      case LocalApiClientType.MANGA:
        emit((state as LibraryPageLoaded).copyWith(
            mangaItems: (state as LibraryPageLoaded).mangaItem..remove(item),
            mangaTotalCount: (state as LibraryPageLoaded).mangaTotalCount - 1));
        break;
      case LocalApiClientType.ANIME:
        emit((state as LibraryPageLoaded).copyWith(
            animeItems: (state as LibraryPageLoaded).animeItems..remove(item),
            animeTotalCount: (state as LibraryPageLoaded).animeTotalCount - 1));
        break;
    }

    onDone();
  }
}
