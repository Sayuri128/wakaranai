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

      emit(ServiceViewInitialized(
          client: state.client,
          searchQuery: '',
          configInfo: await state.client.getConfigInfo(),
          galleryViews: await state.client.getGallery(page: 1),
          currentPage: 1,
          selectedFilters: {}));
    }
  }

  void getGallery() async {
    if (state is ServiceViewInitialized) {
      final state = this.state as ServiceViewInitialized;
      List<GalleryView> galleryViews = [];
      int currentPage = 0;

      galleryViews = state.galleryViews;
      currentPage = state.currentPage;

      if (state.searchQuery.isEmpty) {
        galleryViews.addAll(await state.client.getGallery(
            page: currentPage += 1,
            filters: state.selectedFilters.values.toList()));
      } else {
        galleryViews.addAll(await state.client.getGallery(
            page: currentPage += 1,
            query: state.searchQuery,
            filters: state.selectedFilters.values.toList()));
      }

      emit(
          state.copyWith(galleryViews: galleryViews, currentPage: currentPage));
    }
  }

  void search(String? query) async {
    if (state is ServiceViewInitialized) {
      final state = this.state as ServiceViewInitialized;

      if (query != null && query.isEmpty) {
        emit(state.copyWith(searchQuery: ""));
        getGallery();
        return;
      }

      List<GalleryView> galleryViews = [];
      int currentPage = 0;

      galleryViews.addAll(await state.client.getGallery(
          page: currentPage,
          query: query == null ? state.searchQuery : null,
          filters: state.selectedFilters.values.toList()));

      emit(state.copyWith(
          galleryViews: galleryViews,
          currentPage: currentPage += 1,
          searchQuery: query));
    }
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
