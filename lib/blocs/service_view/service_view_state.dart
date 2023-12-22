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
    required T client,
  }) : super(client: client);
}

class ServiceViewLoading<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  const ServiceViewLoading({
    required T client,
  }) : super(client: client);
}

class ServiceViewError<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  final String message;
  final void Function() retry;

  const ServiceViewError(
      {required this.message, required T client, required this.retry})
      : super(client: client);
}

class ServiceViewInitialized<T extends ApiClient, G extends GalleryView>
    extends ServiceViewState<T, G> {
  final String searchQuery;
  final ConfigInfo configInfo;
  final List<G> galleryViews;
  final int currentPage;
  final bool loading;

  final Map<String, FilterData> selectedFilters;

  const ServiceViewInitialized(
      {required T client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.currentPage,
      required this.selectedFilters,
      required this.loading})
      : super(client: client);

  ServiceViewInitialized<T, G> copyWith(
      {String? searchQuery,
      T? client,
      ConfigInfo? configInfo,
      List<G>? galleryViews,
      int? currentPage,
      Map<String, FilterData>? selectedFilters,
      bool? loading}) {
    return ServiceViewInitialized(
        searchQuery: searchQuery ?? this.searchQuery,
        client: client ?? this.client,
        configInfo: configInfo ?? this.configInfo,
        galleryViews: galleryViews ?? this.galleryViews,
        currentPage: currentPage ?? this.currentPage,
        selectedFilters: selectedFilters ?? this.selectedFilters,
        loading: loading ?? this.loading);
  }
}
