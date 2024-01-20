import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/main.dart';

part 'service_view_state.dart';

class ServiceViewCubit<T extends ApiClient, G extends GalleryView>
    extends Cubit<ServiceViewState<T, G>> {
  ServiceViewCubit(initialState) : super(initialState);

  void init(ConfigInfo configInfo) async {
    emit(ServiceViewLoading<T, G>(client: state.client));

    final List<G>? galleryViews = await _getGalleryViews(
        page: 1,
        query: null,
        filters: null,
        retry: () {
          init(configInfo);
        });
    final Map<String, Map<String, String>> imagesHeaders = {};
    for (final GalleryView galleryView in (galleryViews ?? [])) {
      imagesHeaders[galleryView.uid] = await state.client
          .getImageHeaders(uid: galleryView.uid, data: galleryView.data);
    }

    if (galleryViews != null) {
      emit(ServiceViewInitialized<T, G>(
          client: state.client,
          searchQuery: '',
          configInfo: configInfo,
          galleryViews: galleryViews,
          galleryViewImagesHeaders: imagesHeaders,
          currentPage: 1,
          selectedFilters: {},
          loading: false));
    }
  }

  Future<List<G>?> _getGalleryViews(
      {required int page,
      required String? query,
      required List<FilterData>? filters,
      required void Function() retry}) async {
    List<G>? galleryViews;

    final client = state.client;

    try {
      // TODO: avoid dynamic.
      // Will it be enough to add the getGallery method to the ApiClient interface??
      // What about the services that will be added over time? Will they all support gallery view?
      await (client as dynamic)
          .getGallery(page: page, query: query, filters: filters)
          .then((value) {
        galleryViews = value;
      });
    } catch (exception, stacktrace) {
      logger.e(exception);
      logger.e(stacktrace);
      emit(ServiceViewError<T, G>(
          message: exception.toString(), client: state.client, retry: retry));
    }

    return galleryViews;
  }

  Future<void> getGallery({String? query}) async {
    if (state is ServiceViewInitialized<T, G>) {
      final state = this.state as ServiceViewInitialized<T, G>;

      emit(state.copyWith(loading: true));

      List<G> galleryViews = [];
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
        emit(state.copyWith(loading: false));
        return;
      }

      galleryViews.addAll(newGalleryViews);

      emit((this.state as ServiceViewInitialized<T, G>).copyWith(
        galleryViews: galleryViews,
        currentPage: currentPage,
        loading: false,
      ));
    }
  }

  void search(String? query) async {
    final state = this.state as ServiceViewInitialized<T, G>;

    emit(ServiceViewLoading<T, G>(client: this.state.client));
    if (query == null || query.isEmpty) {
      emit(state.copyWith(searchQuery: ""));
      getGallery(query: "");
      return;
    }

    final List<G> galleryViews = [];
    final Map<String, String> galleryViewImagesHeaders = {};
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
    if (state is ServiceViewInitialized<T, G>) {
      final state = this.state as ServiceViewInitialized<T, G>;

      final newFilters = Map.of(state.selectedFilters);
      newFilters.remove(param);

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }

  void onFilterChanged(String param, FilterData data) {
    if (state is ServiceViewInitialized<T, G>) {
      final state = this.state as ServiceViewInitialized<T, G>;

      final newFilters = Map.of(state.selectedFilters);

      newFilters[param] = data;

      emit(state.copyWith(selectedFilters: newFilters));
    }
  }
}
