import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/discover/anilist_discover_client.dart';
import 'package:wakaranai/services/discover/discover_models.dart';

class DiscoverFeedState {
  const DiscoverFeedState({
    this.items = const <DiscoverMedia>[],
    this.page = 0,
    this.hasNextPage = true,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.loadMoreFailed = false,
  });

  final List<DiscoverMedia> items;
  final int page;
  final bool hasNextPage;
  final bool loading;
  final bool loadingMore;
  final Object? error;
  final bool loadMoreFailed;

  bool get started => page > 0 || loading || error != null;

  bool get canLoadMore =>
      page > 0 && hasNextPage && !loading && !loadingMore && !loadMoreFailed;

  DiscoverFeedState copyWith({
    List<DiscoverMedia>? items,
    int? page,
    bool? hasNextPage,
    bool? loading,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) {
    return DiscoverFeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

class DiscoverFeedCubit extends Cubit<DiscoverFeedState> {
  DiscoverFeedCubit({
    required this.client,
    required this.category,
    this.includeAdult = false,
  }) : super(const DiscoverFeedState());

  final DiscoverClient client;
  final DiscoverCategory category;
  final bool includeAdult;

  Future<void> start() async {
    if (state.started) {
      return;
    }
    await load();
  }

  Future<void> load() async {
    if (state.loading) {
      return;
    }
    emit(const DiscoverFeedState(loading: true));
    try {
      final DiscoverMediaPage page = await client.fetch(
        category,
        page: 1,
        includeAdult: includeAdult,
      );
      if (isClosed) {
        return;
      }
      emit(DiscoverFeedState(
        items: page.media,
        page: 1,
        hasNextPage: page.hasNextPage,
      ));
    } catch (error) {
      logger.w('Discover failed to load ${category.name}: $error');
      if (isClosed) {
        return;
      }
      emit(DiscoverFeedState(error: error));
    }
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) {
      return;
    }
    final int nextPage = state.page + 1;
    emit(state.copyWith(loadingMore: true));
    try {
      final DiscoverMediaPage page = await client.fetch(
        category,
        page: nextPage,
        includeAdult: includeAdult,
      );
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        items: appendUnique(state.items, page.media),
        page: nextPage,
        hasNextPage: page.hasNextPage && page.media.isNotEmpty,
        loadingMore: false,
      ));
    } catch (error) {
      logger.w('Discover failed to load more ${category.name}: $error');
      if (isClosed) {
        return;
      }
      emit(state.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }

  Future<void> retryMore() async {
    emit(state.copyWith(loadMoreFailed: false));
    await loadMore();
  }

  static List<DiscoverMedia> appendUnique(
    List<DiscoverMedia> current,
    List<DiscoverMedia> next,
  ) {
    final Set<int> seen =
        current.map((DiscoverMedia media) => media.id).toSet();
    return List<DiscoverMedia>.unmodifiable(<DiscoverMedia>[
      ...current,
      ...next.where((DiscoverMedia media) => seen.add(media.id)),
    ]);
  }
}
