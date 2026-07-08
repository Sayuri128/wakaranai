part of 'library_cubit.dart';

class LibraryState {
  final List<LibraryEntryDomain> entries;
  final List<CategoryDomain> categories;
  final LibrarySort sort;
  final bool loading;

  const LibraryState({
    this.entries = const <LibraryEntryDomain>[],
    this.categories = const <CategoryDomain>[],
    this.sort = LibrarySort.addedNewest,
    this.loading = true,
  });

  List<LibraryEntryDomain> sortedEntries(List<LibraryEntryDomain> source) {
    final List<LibraryEntryDomain> list = List<LibraryEntryDomain>.of(source);
    switch (sort) {
      case LibrarySort.addedNewest:
        list.sort((LibraryEntryDomain a, LibraryEntryDomain b) =>
            b.createdAt.compareTo(a.createdAt));
      case LibrarySort.addedOldest:
        list.sort((LibraryEntryDomain a, LibraryEntryDomain b) =>
            a.createdAt.compareTo(b.createdAt));
      case LibrarySort.title:
        list.sort((LibraryEntryDomain a, LibraryEntryDomain b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case LibrarySort.lastRead:
        list.sort((LibraryEntryDomain a, LibraryEntryDomain b) =>
            (b.lastReadAt ?? b.createdAt).compareTo(a.lastReadAt ?? a.createdAt));
    }
    return list;
  }

  LibraryState copyWith({
    List<LibraryEntryDomain>? entries,
    List<CategoryDomain>? categories,
    LibrarySort? sort,
    bool? loading,
  }) {
    return LibraryState(
      entries: entries ?? this.entries,
      categories: categories ?? this.categories,
      sort: sort ?? this.sort,
      loading: loading ?? this.loading,
    );
  }
}
