part of 'service_view_cubit.dart';

@immutable
abstract class ServiceViewState<T extends ApiClient, G extends GalleryView> {
  final T client;

  const ServiceViewState({
    required this.client,
  });
}

class ServiceViewInitial<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  const ServiceViewInitial({
    required super.client,
  });
}

class ServiceViewLoading<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  const ServiceViewLoading({
    required super.client,
  });
}

class ServiceViewError<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  final String message;
  final void Function() retry;

  const ServiceViewError(
      {required this.message, required super.client, required this.retry});
}

class ServiceViewInitialized<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  final String searchQuery;
  final ConfigInfo configInfo;
  final List<G> galleryViews;
  final Map<String, Map<String, String>> galleryViewImagesHeaders;
  final int currentPage;
  final bool loading;

  final Map<String, FilterData> selectedFilters;

  const ServiceViewInitialized(
      {required super.client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.galleryViewImagesHeaders,
      required this.currentPage,
      required this.selectedFilters,
      required this.loading});

  ServiceViewInitialized<T, G> copyWith(
      {String? searchQuery,
      T? client,
      ConfigInfo? configInfo,
      List<G>? galleryViews,
      Map<String, Map<String, String>>? galleryViewImagesHeaders,
      int? currentPage,
      Map<String, FilterData>? selectedFilters,
      bool? loading}) {
    return ServiceViewInitialized(
        searchQuery: searchQuery ?? this.searchQuery,
        client: client ?? this.client,
        configInfo: configInfo ?? this.configInfo,
        galleryViews: galleryViews ?? this.galleryViews,
        galleryViewImagesHeaders:
            galleryViewImagesHeaders ?? this.galleryViewImagesHeaders,
        currentPage: currentPage ?? this.currentPage,
        selectedFilters: selectedFilters ?? this.selectedFilters,
        loading: loading ?? this.loading);
  }
}
