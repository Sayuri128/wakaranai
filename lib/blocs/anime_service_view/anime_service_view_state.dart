part of 'anime_service_view_cubit.dart';

@immutable
abstract class AnimeServiceViewState {
  final AnimeApiClient client;

  const AnimeServiceViewState({
    required this.client,
  });
}

class AnimeServiceViewInitial extends AnimeServiceViewState {
  const AnimeServiceViewInitial({
    required AnimeApiClient client,
  }) : super(client: client);
}

class AnimeServiceViewLoading extends AnimeServiceViewState {
  const AnimeServiceViewLoading({
    required AnimeApiClient client,
  }) : super(client: client);
}

class AnimeServiceViewError extends AnimeServiceViewState {
  final String message;
  final void Function() retry;

  const AnimeServiceViewError(
      {required this.message, required AnimeApiClient client, required this.retry})
      : super(client: client);
}

class AnimeServiceViewInitialized extends AnimeServiceViewState {
  final String searchQuery;
  final ConfigInfo configInfo;
  final List<AnimeGalleryView> galleryViews;
  final int currentPage;

  final Map<String, FilterData> selectedFilters;

  const AnimeServiceViewInitialized(
      {required AnimeApiClient client,
        required this.searchQuery,
        required this.configInfo,
        required this.galleryViews,
        required this.currentPage,
        required this.selectedFilters})
      : super(client: client);

  AnimeServiceViewInitialized copyWith({
    String? searchQuery,
    AnimeApiClient? client,
    ConfigInfo? configInfo,
    List<AnimeGalleryView>? galleryViews,
    int? currentPage,
    Map<String, FilterData>? selectedFilters,
  }) {
    return AnimeServiceViewInitialized(
      searchQuery: searchQuery ?? this.searchQuery,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      galleryViews: galleryViews ?? this.galleryViews,
      currentPage: currentPage ?? this.currentPage,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }
}
