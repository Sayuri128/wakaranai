part of 'global_search_cubit.dart';

enum GlobalSearchRailStatus { loading, loaded, failed, needsSignIn }

class GlobalSearchRail {
  const GlobalSearchRail({
    required this.source,
    required this.status,
    this.items = const <GalleryView>[],
    this.coverHeaders = const <String, Map<String, String>>{},
    this.client,
    this.config,
    this.error,
  });

  const GlobalSearchRail.loading(this.source)
      : status = GlobalSearchRailStatus.loading,
        items = const <GalleryView>[],
        coverHeaders = const <String, Map<String, String>>{},
        client = null,
        config = null,
        error = null;

  final GlobalSearchSource source;
  final GlobalSearchRailStatus status;
  final List<GalleryView> items;
  final Map<String, Map<String, String>> coverHeaders;
  final ApiClient? client;
  final ConfigInfo? config;
  final Object? error;

  bool get isLoading => status == GlobalSearchRailStatus.loading;

  bool get hasResults =>
      status == GlobalSearchRailStatus.loaded && items.isNotEmpty;

  bool get isEmptyResult =>
      status == GlobalSearchRailStatus.loaded && items.isEmpty;

  bool get timedOut => error is TimeoutException;

  int get _rank {
    if (hasResults) {
      return 0;
    }
    switch (status) {
      case GlobalSearchRailStatus.loading:
        return 1;
      case GlobalSearchRailStatus.needsSignIn:
        return 2;
      case GlobalSearchRailStatus.failed:
        return 3;
      case GlobalSearchRailStatus.loaded:
        return 4;
    }
  }
}

class GlobalSearchState {
  const GlobalSearchState({
    this.query = '',
    this.scope = const <GlobalSearchSource>[],
    this.catalog = const <GlobalSearchSource>[],
    this.pinned = const <String>[],
    this.customScope = false,
    this.scopeReady = false,
    this.loadingRepositories = false,
    this.rails = const <String, GlobalSearchRail>{},
    this.history = const <String>[],
  });

  final String query;
  final List<GlobalSearchSource> scope;
  final List<GlobalSearchSource> catalog;
  final List<String> pinned;
  final bool customScope;
  final bool scopeReady;
  final bool loadingRepositories;
  final Map<String, GlobalSearchRail> rails;
  final List<String> history;

  bool get hasQuery => query.isNotEmpty;

  bool get isSearching =>
      rails.values.any((GlobalSearchRail rail) => rail.isLoading);

  Set<String> get scopeUids =>
      scope.map((GlobalSearchSource source) => source.uid).toSet();

  List<GlobalSearchRail> get visibleRails {
    return orderRails(scope, rails)
        .where((GlobalSearchRail rail) => !rail.isEmptyResult)
        .toList(growable: false);
  }

  List<GlobalSearchRail> get emptyRails {
    return orderRails(scope, rails)
        .where((GlobalSearchRail rail) => rail.isEmptyResult)
        .toList(growable: false);
  }

  static List<GlobalSearchRail> orderRails(
    List<GlobalSearchSource> scope,
    Map<String, GlobalSearchRail> rails,
  ) {
    final List<GlobalSearchRail> inScope = <GlobalSearchRail>[
      for (final GlobalSearchSource source in scope)
        if (rails[source.uid] != null) rails[source.uid]!,
    ];
    final List<GlobalSearchRail> sorted = List<GlobalSearchRail>.of(inScope);
    sorted.sort((GlobalSearchRail a, GlobalSearchRail b) {
      final int byRank = a._rank.compareTo(b._rank);
      if (byRank != 0) {
        return byRank;
      }
      return inScope.indexOf(a).compareTo(inScope.indexOf(b));
    });
    return sorted;
  }

  GlobalSearchState copyWith({
    String? query,
    List<GlobalSearchSource>? scope,
    List<GlobalSearchSource>? catalog,
    List<String>? pinned,
    bool? customScope,
    bool? scopeReady,
    bool? loadingRepositories,
    Map<String, GlobalSearchRail>? rails,
    List<String>? history,
  }) {
    return GlobalSearchState(
      query: query ?? this.query,
      scope: scope ?? this.scope,
      catalog: catalog ?? this.catalog,
      pinned: pinned ?? this.pinned,
      customScope: customScope ?? this.customScope,
      scopeReady: scopeReady ?? this.scopeReady,
      loadingRepositories: loadingRepositories ?? this.loadingRepositories,
      rails: rails ?? this.rails,
      history: history ?? this.history,
    );
  }
}
