import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/filter_data.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

part 'service_view_state.dart';

class ServiceViewCubit extends Cubit<ServiceViewState> {
  ServiceViewCubit(initialState) : super(initialState);

  void init() async {
    if (state is ServiceViewInitial) {
      final state = this.state as ServiceViewInitial;

      emit(ServiceViewLoading(client: state.client));

      final List<GalleryView>? galleryViews =
          await _getGalleryViews(page: 1, query: null, filters: null);

      if (galleryViews != null) {
        emit(ServiceViewInitialized(
            client: state.client,
            searchQuery: '',
            configInfo: await state.client.getConfigInfo(),
            galleryViews: galleryViews,
            currentPage: 1,
            selectedFilters: {}));
      }
    }
  }

  Future<List<GalleryView>?> _getGalleryViews(
      {required int page,
      required String? query,
      required List<FilterData>? filters}) async {
    List<GalleryView>? galleryViews;

    await state.client
        .getGallery(page: 1, query: query, filters: filters)
        .catchError((error) {
      emit(ServiceViewError(
          message: error?.toString() ?? '', client: state.client));
      return <GalleryView>[];
    }).then((value) {
      galleryViews = value;
    });

    return galleryViews;
  }

  void getGallery({String? query}) async {
    if (state is ServiceViewInitialized) {
      final state = this.state as ServiceViewInitialized;
      List<GalleryView> galleryViews = [];
      int currentPage = 0;

      galleryViews = state.galleryViews;
      currentPage = state.currentPage;

      final newGalleryViews = await _getGalleryViews(
          page: currentPage += 1,
          filters: state.selectedFilters.values.toList(),
          query:
              query ?? (state.searchQuery.isEmpty ? null : state.searchQuery));
      if (newGalleryViews == null) {
        return;
      }

      galleryViews.addAll(newGalleryViews);

      emit(
          state.copyWith(galleryViews: galleryViews, currentPage: currentPage));
    }
  }

  void search(String? query) async {
    final state = this.state as ServiceViewInitialized;

    emit(ServiceViewLoading(client: this.state.client));
    if (query == null || query.isEmpty) {
      emit(state.copyWith(searchQuery: ""));
      getGallery(query: "");
      return;
    }

    List<GalleryView> galleryViews = [];
    int currentPage = 0;

    final newGalleryViews = await _getGalleryViews(
        page: currentPage,
        query: query,
        filters: state.selectedFilters.values.toList());

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
    if (state is ServiceViewInitialized) {
      final state = this.state as ServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);
      newFilters.remove(param);

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }

  void onFilterChanged(String param, FilterData data) {
    if (state is ServiceViewInitialized) {
      final state = this.state as ServiceViewInitialized;

      final newFilters = Map.of(state.selectedFilters);

      newFilters[param] = data;

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }
}
