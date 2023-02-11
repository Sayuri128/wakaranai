part of 'library_page_cubit.dart';

@immutable
abstract class LibraryPageState {
  const LibraryPageState();
}

class LibraryPageInitial extends LibraryPageState {}

class LibraryPageLoading extends LibraryPageState {}

class LibraryPageLoaded extends LibraryPageState {

  final List<LibraryItem> mangaItem;
  final int mangaTotalCount;

  final List<LibraryItem> animeItems;
  final int animeTotalCount;

  const LibraryPageLoaded({
    required this.mangaItem,
    required this.mangaTotalCount,
    required this.animeItems,
    required this.animeTotalCount,
  });

  LibraryPageLoaded copyWith({
    List<LibraryItem>? mangaItem,
    int? mangaTotalCount,
    List<LibraryItem>? animeItems,
    int? animeTotalCount,
  }) {
    return LibraryPageLoaded(
      mangaItem: mangaItem ?? this.mangaItem,
      mangaTotalCount: mangaTotalCount ?? this.mangaTotalCount,
      animeItems: animeItems ?? this.animeItems,
      animeTotalCount: animeTotalCount ?? this.animeTotalCount,
    );
  }
}
