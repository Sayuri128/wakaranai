import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/gallery_feed_memory.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';

@immutable
class ServiceGalleryState {
  const ServiceGalleryState({
    this.filters = const <String, FilterData>{},
    this.searchQuery = '',
    this.selectedFeedId,
    this.loadedFeedIds = const <String>{},
  });

  final Map<String, FilterData> filters;
  final String searchQuery;
  final String? selectedFeedId;
  final Set<String> loadedFeedIds;

  bool get searching => searchQuery.isNotEmpty;

  ServiceGalleryState copyWith({
    Map<String, FilterData>? filters,
    String? searchQuery,
    String? selectedFeedId,
    Set<String>? loadedFeedIds,
  }) {
    return ServiceGalleryState(
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFeedId: selectedFeedId ?? this.selectedFeedId,
      loadedFeedIds: loadedFeedIds ?? this.loadedFeedIds,
    );
  }
}

class ServiceGalleryCubit<T extends ApiClient, G extends GalleryView>
    extends Cubit<ServiceGalleryState> {
  ServiceGalleryCubit({
    required this.client,
    required this.configInfo,
    GalleryFeedMemory? feedMemory,
  })  : _feedMemory = feedMemory ?? GalleryFeedMemory.session,
        super(ServiceGalleryState(
          selectedFeedId: _initialFeed(
            configInfo,
            feedMemory ?? GalleryFeedMemory.session,
          ),
        )) {
    if (!hasFeeds) {
      _single = _createGallery();
    }
  }

  final T client;
  final ConfigInfo configInfo;
  final GalleryFeedMemory _feedMemory;
  final Map<String, ServiceViewCubit<T, G>> _feedGalleries =
      <String, ServiceViewCubit<T, G>>{};
  ServiceViewCubit<T, G>? _single;
  ServiceViewCubit<T, G>? _search;
  bool _started = false;

  bool get hasFeeds => configInfo.feeds.isNotEmpty;

  List<GalleryFeed> get feeds => configInfo.feeds;

  ServiceViewCubit<T, G>? get singleGallery => _single;

  ServiceViewCubit<T, G>? get searchGallery => _search;

  ServiceViewCubit<T, G>? feedGallery(String feedId) => _feedGalleries[feedId];

  int get selectedFeedIndex {
    final int index = feeds.indexWhere(
      (GalleryFeed feed) => feed.id == state.selectedFeedId,
    );
    if (index < 0) {
      return 0;
    }
    return index;
  }

  ServiceViewCubit<T, G>? get visibleGallery {
    if (!hasFeeds) {
      return _single;
    }
    if (state.searching) {
      return _search;
    }
    final String? selected = state.selectedFeedId;
    if (selected == null) {
      return null;
    }
    return _feedGalleries[selected];
  }

  List<ServiceViewCubit<T, G>> get loadedGalleries {
    final ServiceViewCubit<T, G>? visible = visibleGallery;
    return <ServiceViewCubit<T, G>>[
      if (visible != null) visible,
      if (_single != null && _single != visible) _single!,
      for (final ServiceViewCubit<T, G> gallery in _feedGalleries.values)
        if (gallery != visible) gallery,
      if (_search != null && _search != visible) _search!,
    ];
  }

  static String? _initialFeed(ConfigInfo configInfo, GalleryFeedMemory memory) {
    if (configInfo.feeds.isEmpty) {
      return null;
    }
    final String? remembered = memory.feedFor(configInfo.uid);
    if (GalleryFeedMemory.offers(configInfo, remembered)) {
      return remembered;
    }
    return configInfo.feeds.first.id;
  }

  ServiceViewCubit<T, G> _createGallery({String? feed}) {
    return ServiceViewCubit<T, G>(
      ServiceViewInitial<T, G>(client: client),
      feed: feed,
      feedMemory: _feedMemory,
    );
  }

  void start() {
    _started = true;
    for (final ServiceViewCubit<T, G> gallery in loadedGalleries) {
      gallery.init(configInfo, filters: state.filters);
    }
    _ensureFeedGallery(state.selectedFeedId);
  }

  void selectFeed(String feedId) {
    if (!GalleryFeedMemory.offers(configInfo, feedId)) {
      return;
    }
    _feedMemory.remember(configInfo.uid, feedId);
    if (feedId != state.selectedFeedId) {
      emit(state.copyWith(selectedFeedId: feedId));
    }
    _ensureFeedGallery(feedId);
  }

  void _ensureFeedGallery(String? feedId) {
    if (!_started || feedId == null || _feedGalleries.containsKey(feedId)) {
      return;
    }
    final ServiceViewCubit<T, G> gallery = _createGallery(feed: feedId);
    _feedGalleries[feedId] = gallery;
    gallery.init(configInfo, filters: state.filters);
    emit(state.copyWith(
      loadedFeedIds: <String>{...state.loadedFeedIds, feedId},
    ));
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    final ServiceViewCubit<T, G>? single = _single;
    if (single != null) {
      single.search(query);
      emit(state.copyWith(searchQuery: query));
      return;
    }
    if (!_started) {
      return;
    }
    _searchFeeds(query);
    emit(state.copyWith(searchQuery: query));
  }

  void _searchFeeds(String query) {
    final ServiceViewCubit<T, G>? existing = _search;
    if (existing != null &&
        existing.state is ServiceViewInitialized<T, G>) {
      existing.search(query);
      return;
    }
    final ServiceViewCubit<T, G> gallery = existing ?? _createGallery();
    _search = gallery;
    gallery.init(configInfo, query: query, filters: state.filters);
  }

  void clearSearch() {
    final ServiceViewCubit<T, G>? single = _single;
    if (single != null) {
      single.search('');
    }
    final ServiceViewCubit<T, G>? search = _search;
    _search = null;
    if (search != null) {
      unawaited(search.close());
    }
    if (state.searching) {
      emit(state.copyWith(searchQuery: ''));
    }
  }

  void applyFilters(Map<String, FilterData> filters) {
    emit(state.copyWith(filters: filters));
    for (final ServiceViewCubit<T, G> gallery in loadedGalleries) {
      gallery.applyFilters(filters);
    }
  }

  Future<void> reloadLoadedGalleries() async {
    if (!_started) {
      return;
    }
    await Future.wait(<Future<void>>[
      for (final ServiceViewCubit<T, G> gallery in loadedGalleries)
        _reloadGallery(gallery),
    ]);
  }

  Future<void> _reloadGallery(ServiceViewCubit<T, G> gallery) async {
    if (gallery.isClosed) {
      return;
    }
    if (gallery.state is ServiceViewInitialized<T, G>) {
      await gallery.refresh();
      return;
    }
    gallery.init(configInfo);
  }

  @override
  Future<void> close() async {
    final List<ServiceViewCubit<T, G>> galleries = loadedGalleries;
    _feedGalleries.clear();
    _single = null;
    _search = null;
    await Future.wait(<Future<void>>[
      for (final ServiceViewCubit<T, G> gallery in galleries) gallery.close(),
    ]);
    return super.close();
  }
}
