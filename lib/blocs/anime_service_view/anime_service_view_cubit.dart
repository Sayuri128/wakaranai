import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/logger.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';

part 'anime_service_view_state.dart';

class AnimeServiceViewCubit extends Cubit<AnimeServiceViewState> {
  AnimeServiceViewCubit(initialState) : super(initialState);

  void init(RemoteConfig remoteConfig) async {
    emit(AnimeServiceViewLoading(client: state.client));

    final List<AnimeGalleryView>? galleryViews = await _getGalleryViews(
        page: 1,
        query: null,
        filters: null,
        retry: () {
          init(remoteConfig);
        });

    if (galleryViews != null) {
      emit(AnimeServiceViewInitialized(
          client: state.client,
          searchQuery: '',
          configInfo: remoteConfig.config,
          galleryViews: galleryViews,
          currentPage: 1,
          selectedFilters: {}));
    }
  }

  Future<List<AnimeGalleryView>?> _getGalleryViews(
      {required int page,
        required String? query,
        required List<FilterData>? filters,
        required void Function() retry}) async {
    List<AnimeGalleryView>? galleryViews;

    try {
      await state.client
          .getGallery(page: page, query: query, filters: filters)
          .then((value) {
        galleryViews = value;
      });
    } catch (exception) {
      logger.e(exception);
      emit(AnimeServiceViewError(
          message: exception.toString(), client: state.client, retry: retry));
    }

    return galleryViews;
  }

  void getGallery({String? query}) async {
    if (state is AnimeServiceViewInitialized) {
      final state = this.state as AnimeServiceViewInitialized;
      List<AnimeGalleryView> galleryViews = [];
      int currentPage = 1;

      galleryViews = state.galleryViews;
      currentPage = state.currentPage;

      final newGalleryViews = await _getGalleryViews(
          page: currentPage += 1,
          filters: state.selectedFilters.values.toList(),
          query:
          query ?? (state.searchQuery.isEmpty ? null : state.searchQuery),
          retry: () {
            getGallery(query: query);
          });
      if (newGalleryViews == null) {
        return;
      }

      galleryViews.addAll(newGalleryViews);

      emit(
          state.copyWith(galleryViews: galleryViews, currentPage: currentPage));
    }
  }

  void search(String? query) async {
    final state = this.state as AnimeServiceViewInitialized;

    emit(AnimeServiceViewLoading(client: this.state.client));
    if (query == null || query.isEmpty) {
      emit(state.copyWith(searchQuery: ""));
      getGallery(query: "");
      return;
    }

    List<AnimeGalleryView> galleryViews = [];
    int currentPage = 0;

    final newGalleryViews = await _getGalleryViews(
        page: currentPage,
        query: query,
        filters: state.selectedFilters.values.toList(),
        retry: () {
          search(query);
        });

    if (newGalleryViews == null) {
      return;
    }

    galleryViews.addAll(newGalleryViews);

    emit(state.copyWith(
        galleryViews: galleryViews,
        currentPage: currentPage += 1,
        searchQuery: query));
  }

  void removeFilter(String param) {
    if (state is AnimeServiceViewInitialized) {
      final state = this.state as AnimeServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);
      newFilters.remove(param);

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }

  void onFilterChanged(String param, FilterData data) {
    if (state is AnimeServiceViewInitialized) {
      final state = this.state as AnimeServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);

      newFilters[param] = data;

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }
}
