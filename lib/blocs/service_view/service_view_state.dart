part of 'service_view_cubit.dart';

@immutable
abstract class ServiceViewState {}

class ServiceViewInitial extends ServiceViewState {
  final ApiClient client;

  ServiceViewInitial({
    required this.client,
  });
}

class ServiceViewInitialized extends ServiceViewState {
  final String searchQuery;
  final ApiClient client;
  final ConfigInfo configInfo;
  final List<GalleryView> galleryViews;
  final int currentPage;

  final Map<String, FilterData> selectedFilters;

  ServiceViewInitialized(
      {required this.client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.currentPage,
      required this.selectedFilters});

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
