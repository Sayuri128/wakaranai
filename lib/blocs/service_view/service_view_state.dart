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

  ServiceViewInitialized(
      {required this.client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.currentPage});

  ServiceViewInitialized copyWith({
    String? searchQuery,
    ApiClient? client,
    ConfigInfo? configInfo,
    List<GalleryView>? galleryViews,
    int? currentPage,
  }) {
    return ServiceViewInitialized(
      searchQuery: searchQuery ?? this.searchQuery,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      galleryViews: galleryViews ?? this.galleryViews,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
