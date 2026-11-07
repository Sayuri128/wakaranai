import 'dart:async';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/gallery_feed_memory.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';
import 'package:wakaranai/utils/source_error_description.dart';

part 'service_view_state.dart';

class ServiceViewCubit<T extends ApiClient, G extends GalleryView>
    extends Cubit<ServiceViewState<T, G>> {
  ServiceViewCubit(
    super.initialState, {
    String? feed,
    GalleryFeedMemory? feedMemory,
  })  : _requestedFeed = feed,
        _feedMemory = feedMemory ?? GalleryFeedMemory.session;

  final String? _requestedFeed;
  final GalleryFeedMemory _feedMemory;
  ConfigInfo? _configInfo;
  String? _selectedFeed;
  String _query = '';
  Map<String, FilterData> _filters = const <String, FilterData>{};
  int _generation = 0;

  String? get selectedFeed => _selectedFeed;

  @override
  void emit(ServiceViewState<T, G> state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }

  void init(
    ConfigInfo configInfo, {
    String? query,
    Map<String, FilterData>? filters,
  }) {
    if (query != null) {
      _query = query;
    }
    if (filters != null) {
      _filters = filters;
    }
    unawaited(_load(configInfo));
  }

  Future<void> _load(ConfigInfo configInfo) async {
    _configInfo = configInfo;
    _selectedFeed = _initialFeedFor(configInfo);
    final int generation = ++_generation;
    emit(ServiceViewLoading<T, G>(client: state.client));

    final List<G>? galleryViews = await _getGalleryViews(
        page: 1,
        query: _query.isEmpty ? null : _query,
        filters: _filters.isEmpty ? null : _filters.values.toList(),
        generation: generation,
        retry: () {
          init(configInfo);
        });
    if (generation != _generation) {
      return;
    }
    final Map<String, Map<String, String>> imagesHeaders =
        <String, Map<String, String>>{};
    for (final GalleryView galleryView in (galleryViews ?? <GalleryView>[])) {
      imagesHeaders[galleryView.uid] = await runSerializedOn(
          state.client,
          () => state.client
              .getImageHeaders(uid: galleryView.uid, data: galleryView.data));
    }

    if (galleryViews != null && generation == _generation) {
      emit(ServiceViewInitialized<T, G>(
          client: state.client,
          searchQuery: _query,
          configInfo: configInfo,
          galleryViews: galleryViews,
          galleryViewImagesHeaders: imagesHeaders,
          currentPage: 1,
          selectedFilters: _filters,
          selectedFeed: _selectedFeed,
          loading: false));
    }
  }

  String? _initialFeedFor(ConfigInfo configInfo) {
    if (configInfo.feeds.isEmpty) {
      return null;
    }
    final List<String?> candidates = <String?>[
      _selectedFeed,
      _requestedFeed,
      _feedMemory.feedFor(configInfo.uid),
    ];
    for (final String? candidate in candidates) {
      if (GalleryFeedMemory.offers(configInfo, candidate)) {
        return candidate;
      }
    }
    return configInfo.feeds.first.id;
  }

  String? _feedFor(String? query) {
    if (query != null && query.trim().isNotEmpty) {
      return null;
    }
    return _selectedFeed;
  }

  Future<void> selectFeed(String feedId) async {
    final ConfigInfo? configInfo = _configInfo;
    if (configInfo == null || !GalleryFeedMemory.offers(configInfo, feedId)) {
      return;
    }
    final ServiceViewState<T, G> current = state;
    if (feedId == _selectedFeed && current is! ServiceViewError<T, G>) {
      return;
    }
    _selectedFeed = feedId;
    _feedMemory.remember(configInfo.uid, feedId);

    if (current is! ServiceViewInitialized<T, G>) {
      init(configInfo);
      return;
    }
    if (current.searchQuery.isNotEmpty) {
      emit(current.copyWith(selectedFeed: feedId));
      return;
    }

    _generation++;
    emit(current.copyWith(
      selectedFeed: feedId,
      galleryViews: <G>[],
      galleryViewImagesHeaders: <String, Map<String, String>>{},
      currentPage: 0,
      loading: true,
    ));
    await getGallery();
  }

  Future<List<G>?> _getGalleryViews(
      {required int page,
      required String? query,
      required List<FilterData>? filters,
      required int generation,
      required void Function() retry,
      bool replacesGrid = false}) async {
    List<G>? galleryViews;

    final T client = state.client;
    final String? feed = _feedFor(query);

    try {
      final List<GalleryView> fetched = await runSerializedOn<List<GalleryView>>(
          client,
          () => client.getGallery(
              page: page, query: query, filters: filters, feed: feed));
      galleryViews = fetched as List<G>;
    } catch (exception, stacktrace) {
      logger.e(exception);
      logger.e(stacktrace);
      if (generation == _generation) {
        _reportFailure(exception, retry, replacesGrid: replacesGrid);
      }
    }

    return galleryViews;
  }

  void _reportFailure(
    Object error,
    void Function() retry, {
    required bool replacesGrid,
  }) {
    final ServiceViewState<T, G> current = state;
    if (!replacesGrid &&
        current is ServiceViewInitialized<T, G> &&
        findSourceError(error) != null) {
      emit(current.copyWith(
        failure: ServiceViewFailure(error: error, retry: retry),
      ));
      return;
    }
    emit(ServiceViewError<T, G>(
        message: error.toString(),
        error: error,
        client: state.client,
        retry: _reloadFromError));
  }

  void _reloadFromError() {
    final ConfigInfo? configInfo = _configInfo;
    if (configInfo == null) {
      return;
    }
    init(configInfo);
  }

  /// Reloads the first page while staying in the initialized state, so the
  /// current grid remains visible during a pull-to-refresh.
  Future<void> refresh() async {
    final ServiceViewState<T, G> current = this.state;
    final ConfigInfo? configInfo = _configInfo;
    if (current is ServiceViewError<T, G> && configInfo != null) {
      await _load(configInfo);
      return;
    }
    if (current is! ServiceViewInitialized<T, G>) {
      return;
    }
    final ServiceViewInitialized<T, G> state =
        this.state as ServiceViewInitialized<T, G>;

    final int generation = _generation;
    emit(state.copyWith(loading: true));

    final List<G>? newGalleryViews = await _getGalleryViews(
        page: 1,
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
        filters: state.selectedFilters.values.toList(),
        generation: generation,
        retry: refresh);
    if (generation != _generation) {
      return;
    }

    if (newGalleryViews == null) {
      emit(state.copyWith(loading: false));
      return;
    }

    final Map<String, Map<String, String>> imagesHeaders =
        await _getImageHeaders(newGalleryViews, state);
    if (generation != _generation) {
      return;
    }

    emit(state.copyWith(
      galleryViews: newGalleryViews,
      currentPage: 1,
      galleryViewImagesHeaders: imagesHeaders,
      loading: false,
    ));
  }

  Future<void> getGallery({String? query}) async {
    if (state is ServiceViewInitialized<T, G>) {
      final ServiceViewInitialized<T, G> state =
          this.state as ServiceViewInitialized<T, G>;

      final int generation = _generation;
      emit(state.copyWith(loading: true));

      List<G> galleryViews = <G>[];
      int currentPage = 0;

      galleryViews = state.galleryViews;
      currentPage = state.currentPage;
      final bool loadingFirstPage = currentPage == 0 && galleryViews.isEmpty;

      final List<G>? newGalleryViews = await _getGalleryViews(
          page: currentPage += 1,
          filters: state.selectedFilters.values.toList(),
          query:
              query ?? (state.searchQuery.isEmpty ? null : state.searchQuery),
          generation: generation,
          replacesGrid: loadingFirstPage,
          retry: () {
            getGallery(query: query);
          });
      if (generation != _generation) {
        return;
      }

      if (newGalleryViews == null) {
        if (loadingFirstPage) {
          return;
        }
        emit(
          state.copyWith(
            loading: false,
          ),
        );
        return;
      }

      Map<String, Map<String, String>> imagesHeaders =
          await _getImageHeaders(newGalleryViews, state);
      if (generation != _generation) {
        return;
      }

      galleryViews.addAll(newGalleryViews);

      emit((this.state as ServiceViewInitialized<T, G>).copyWith(
        galleryViews: galleryViews,
        currentPage: currentPage,
        galleryViewImagesHeaders: imagesHeaders,
        loading: false,
      ));
    }
  }

  void search(String? query) async {
    if (this.state is! ServiceViewInitialized<T, G>) {
      return;
    }
    final ServiceViewInitialized<T, G> state =
        this.state as ServiceViewInitialized<T, G>;

    // Stay in the initialized state (with loading: true) so the grid keeps its
    // current content instead of flashing to a full-screen spinner.
    final int generation = ++_generation;
    _query = _searchQueryFrom(query);
    emit(state.copyWith(loading: true));
    if (query == null || query.trim().isEmpty) {
      emit(state.copyWith(
        searchQuery: "",
        currentPage: 0,
        galleryViews: <G>[],
        galleryViewImagesHeaders: <String, Map<String, String>>{},
        loading: true,
      ));
      unawaited(getGallery(query: ""));
      return;
    }

    final List<G> galleryViews = <G>[];
    int currentPage = 0;

    final List<G>? newGalleryViews = await _getGalleryViews(
        page: currentPage,
        query: query,
        filters: state.selectedFilters.values.toList(),
        generation: generation,
        retry: () {
          search(query);
        });
    if (generation != _generation) {
      return;
    }

    if (newGalleryViews == null) {
      emit(state.copyWith(loading: false));
      return;
    }

    galleryViews.addAll(newGalleryViews);

    final Map<String, Map<String, String>> imagesHeaders =
        await _getImageHeaders(newGalleryViews, state);
    if (generation != _generation) {
      return;
    }

    emit(
      state.copyWith(
        galleryViews: galleryViews,
        currentPage: currentPage + 1,
        searchQuery: query,
        galleryViewImagesHeaders: imagesHeaders,
        loading: false,
      ),
    );
  }

  String _searchQueryFrom(String? query) {
    if (query == null || query.trim().isEmpty) {
      return '';
    }
    return query;
  }

  Future<Map<String, Map<String, String>>> _getImageHeaders(
      List<G> galleryViews, ServiceViewInitialized<T, G> state) async {
    final Map<String, Map<String, String>> imagesHeaders =
        <String, Map<String, String>>{};
    for (final GalleryView galleryView in (galleryViews)) {
      imagesHeaders[galleryView.uid] = await runSerializedOn(
          state.client,
          () => state.client
              .getImageHeaders(uid: galleryView.uid, data: galleryView.data));
      await Future<void>.delayed(Duration.zero);
    }
    return imagesHeaders;
  }

  void applyFilters(Map<String, FilterData> filters) {
    _filters = filters;
    final ServiceViewState<T, G> current = state;
    if (current is! ServiceViewInitialized<T, G>) {
      _reloadWithFilters();
      return;
    }

    emit(current.copyWith(selectedFilters: filters));

    search(current.searchQuery.isEmpty ? null : current.searchQuery);
  }

  void _reloadWithFilters() {
    final ConfigInfo? configInfo = _configInfo;
    if (configInfo == null) {
      return;
    }
    init(configInfo);
  }

  void removeFilter(String param) {
    if (state is ServiceViewInitialized<T, G>) {
      final ServiceViewInitialized<T, G> state =
          this.state as ServiceViewInitialized<T, G>;

      final Map<String, FilterData> newFilters = Map.of(state.selectedFilters);
      newFilters.remove(param);

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }

  void onFilterChanged(String param, FilterData data) {
    if (state is ServiceViewInitialized<T, G>) {
      final ServiceViewInitialized<T, G> state =
          this.state as ServiceViewInitialized<T, G>;

      final Map<String, FilterData> newFilters = Map.of(state.selectedFilters);

      newFilters[param] = data;

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }
}
