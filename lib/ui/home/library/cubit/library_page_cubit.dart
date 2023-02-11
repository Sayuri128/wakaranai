import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/services/library_service/library_service.dart';
import 'package:wakaranai/services/sqflite_service/query_item.dart';

part 'library_page_state.dart';

class LibraryPageCubit extends Cubit<LibraryPageState> {
  LibraryPageCubit({required this.libraryService})
      : super(LibraryPageInitial());

  static const libraryPageLimit = 20;
  static final mangaQuery =
      SqfliteQueryKeyValueItem(key: 'type', value: LibraryItemType.MANGA.index);
  static final animeQuery =
      SqfliteQueryKeyValueItem(key: 'type', value: LibraryItemType.ANIME.index);

  final LibraryService libraryService;

  void init() async {
    emit(LibraryPageLoading());
    final int mangaTotal = await libraryService.count(query: [mangaQuery]);
    final int animeTotal = await libraryService.count(query: [animeQuery]);
    final List<LibraryItem> initialMangaItems = await libraryService
        .query(query: [mangaQuery], limit: libraryPageLimit, offset: 0);
    final List<LibraryItem> initialAnimeItems = await libraryService
        .query(query: [animeQuery], limit: libraryPageLimit, offset: 0);

    emit(LibraryPageLoaded(
        animeItems: initialAnimeItems,
        animeTotalCount: animeTotal,
        mangaItem: initialMangaItems,
        mangaTotalCount: mangaTotal));
  }

  void reloadPage(LibraryItemType type) async {
    Future.wait([
      libraryService.count(
          query: [SqfliteQueryKeyValueItem(key: 'type', value: type.index)]),
      libraryService.query(
          query: [SqfliteQueryKeyValueItem(key: 'type', value: type.index)],
          limit: libraryPageLimit,
          offset: 0)
    ]).then((value) {
      switch (type) {
        case LibraryItemType.ANIME:
          emit((state as LibraryPageLoaded).copyWith(
              animeTotalCount: value[0] as int,
              animeItems: value[1] as List<LibraryItem>));
          break;
        case LibraryItemType.MANGA:
          emit((state as LibraryPageLoaded).copyWith(
              mangaTotalCount: value[0] as int,
              mangaItem: value[1] as List<LibraryItem>));
          break;
      }
    });
  }

  void _loadNextPage(
      {required List<LibraryItem> currentList,
      required int total,
      required LibraryItemType type,
      required void Function(List<LibraryItem>) onLoaded}) async {
    if (currentList.length >= total) {
      return;
    }

    libraryService.query(
        query: [SqfliteQueryKeyValueItem(key: 'type', value: type.index)],
        limit: libraryPageLimit,
        offset: currentList.length).then(onLoaded);
  }

  void loadNextMangaPage() async {
    if (state is LibraryPageLoaded) {
      _loadNextPage(
        currentList: (state as LibraryPageLoaded).mangaItem,
        total: (state as LibraryPageLoaded).mangaTotalCount,
        type: LibraryItemType.MANGA,
        onLoaded: (newItems) {
          emit((state as LibraryPageLoaded).copyWith(mangaItem: [
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
        type: LibraryItemType.ANIME,
        onLoaded: (newItems) {
          emit((state as LibraryPageLoaded).copyWith(animeItems: [
            ...(state as LibraryPageLoaded).mangaItem,
            ...newItems
          ]));
        },
      );
    }
  }
}
