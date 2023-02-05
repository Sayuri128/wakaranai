import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'manga_service_view_state.dart';

class MangaServiceViewCubit extends Cubit<MangaServiceViewState> {
  MangaServiceViewCubit(initialState) : super(initialState);

  void init() async {
    emit(MangaServiceViewLoading(client: state.client));

    final List<MangaGalleryView>? galleryViews = await _getGalleryViews(
        page: 1,
        query: null,
        filters: null,
        retry: () {
          init();
        });

    if (galleryViews != null) {
      emit(MangaServiceViewInitialized(
          client: state.client,
          searchQuery: '',
          configInfo: await state.client.getConfigInfo(),
          galleryViews: galleryViews,
          currentPage: 1,
          selectedFilters: {}));
    }
  }

  Future<List<MangaGalleryView>?> _getGalleryViews(
      {required int page,
      required String? query,
      required List<FilterData>? filters,
      required void Function() retry}) async {
    List<MangaGalleryView>? galleryViews;

    try {
      await state.client
          .getGallery(page: page, query: query, filters: filters)
          .then((value) {
        galleryViews = value;
      });
    } catch (exception) {
      emit(MangaServiceViewError(
          message: exception.toString(), client: state.client, retry: retry));
    }

    return galleryViews;
  }

  void getGallery({String? query}) async {
    if (state is MangaServiceViewInitialized) {
      final state = this.state as MangaServiceViewInitialized;
      List<MangaGalleryView> galleryViews = [];
      int currentPage = 0;

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
    final state = this.state as MangaServiceViewInitialized;

    emit(MangaServiceViewLoading(client: this.state.client));
    if (query == null || query.isEmpty) {
      emit(state.copyWith(searchQuery: ""));
      getGallery(query: "");
      return;
    }

    List<MangaGalleryView> galleryViews = [];
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
    if (state is MangaServiceViewInitialized) {
      final state = this.state as MangaServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);
      newFilters.remove(param);

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }

  void onFilterChanged(String param, FilterData data) {
    if (state is MangaServiceViewInitialized) {
      final state = this.state as MangaServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);

      newFilters[param] = data;

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }
}
