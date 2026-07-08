part of 'library_cubit.dart';

class LibraryState {
  final List<LibraryEntryDomain> entries;
  final List<CategoryDomain> categories;
  final LibrarySort sort;
  final String searchQuery;
  final bool loading;
  final Map<String, Map<String, String>> coverHeaders;

  const LibraryState({
    this.entries = const <LibraryEntryDomain>[],
    this.categories = const <CategoryDomain>[],
    this.sort = LibrarySort.addedNewest,
    this.searchQuery = '',
    this.loading = true,
    this.coverHeaders = const <String, Map<String, String>>{},
  });

  bool get searching => searchQuery.isNotEmpty;

  bool matchesSearch(LibraryEntryDomain entry) {
    if (searchQuery.isEmpty) return true;
    return entry.title.toLowerCase().contains(searchQuery.toLowerCase());
  }

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
    String? searchQuery,
    bool? loading,
    Map<String, Map<String, String>>? coverHeaders,
  }) {
    return LibraryState(
      entries: entries ?? this.entries,
      categories: categories ?? this.categories,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
      coverHeaders: coverHeaders ?? this.coverHeaders,
    );
  }
}
