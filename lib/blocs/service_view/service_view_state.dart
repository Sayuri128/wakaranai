part of 'service_view_cubit.dart';

@immutable
abstract class ServiceViewState {
  final ApiClient client;

  const ServiceViewState({
    required this.client,
  });
}

class ServiceViewInitial extends ServiceViewState {
  const ServiceViewInitial({
    required ApiClient client,
  }) : super(client: client);
}

class ServiceViewLoading extends ServiceViewState {
  const ServiceViewLoading({
    required ApiClient client,
  }) : super(client: client);
}

class ServiceViewError extends ServiceViewState {
  final String message;
  final void Function() retry;

  const ServiceViewError(
      {required this.message, required ApiClient client, required this.retry})
      : super(client: client);
}

class ServiceViewInitialized extends ServiceViewState {
  final String searchQuery;
  final ConfigInfo configInfo;
  final List<GalleryView> galleryViews;
  final int currentPage;

  final Map<String, FilterData> selectedFilters;

  const ServiceViewInitialized(
      {required ApiClient client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.currentPage,
      required this.selectedFilters})
      : super(client: client);

  ServiceViewInitialized copyWith({
    String? searchQuery,
    ApiClient? client,
    ConfigInfo? configInfo,
    List<GalleryView>? galleryViews,
    int? currentPage,
    Map<String, FilterData>? selectedFilters,
  }) {
    return ServiceViewInitialized(
      searchQuery: searchQuery ?? this.searchQuery,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      galleryViews: galleryViews ?? this.galleryViews,
      currentPage: currentPage ?? this.currentPage,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }
}
