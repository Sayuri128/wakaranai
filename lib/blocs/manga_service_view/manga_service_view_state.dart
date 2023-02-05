part of 'manga_service_view_cubit.dart';

@immutable
abstract class MangaServiceViewState {
  final MangaApiClient client;

  const MangaServiceViewState({
    required this.client,
  });
}

class MangaServiceViewInitial extends MangaServiceViewState {
  const MangaServiceViewInitial({
    required MangaApiClient client,
  }) : super(client: client);
}

class MangaServiceViewLoading extends MangaServiceViewState {
  const MangaServiceViewLoading({
    required MangaApiClient client,
  }) : super(client: client);
}

class MangaServiceViewError extends MangaServiceViewState {
  final String message;
  final void Function() retry;

  const MangaServiceViewError(
      {required this.message, required MangaApiClient client, required this.retry})
      : super(client: client);
}

class MangaServiceViewInitialized extends MangaServiceViewState {
  final String searchQuery;
  final ConfigInfo configInfo;
  final List<MangaGalleryView> galleryViews;
  final int currentPage;

  final Map<String, FilterData> selectedFilters;

  const MangaServiceViewInitialized(
      {required MangaApiClient client,
      required this.searchQuery,
      required this.configInfo,
      required this.galleryViews,
      required this.currentPage,
      required this.selectedFilters})
      : super(client: client);

  MangaServiceViewInitialized copyWith({
    String? searchQuery,
    MangaApiClient? client,
    ConfigInfo? configInfo,
    List<MangaGalleryView>? galleryViews,
    int? currentPage,
    Map<String, FilterData>? selectedFilters,
  }) {
    return MangaServiceViewInitialized(
      searchQuery: searchQuery ?? this.searchQuery,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      galleryViews: galleryViews ?? this.galleryViews,
      currentPage: currentPage ?? this.currentPage,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }
}
