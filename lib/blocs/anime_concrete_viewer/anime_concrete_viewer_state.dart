part of 'anime_concrete_viewer_cubit.dart';

class AnimeConcreteViewState {
  final AnimeApiClient apiClient;

  const AnimeConcreteViewState({
    required this.apiClient,
  });
}

class AnimeConcreteViewInitialized extends AnimeConcreteViewState {
  final AnimeConcreteView concreteView;
  final AnimeGalleryView galleryView;
  final AnimeConcreteViewOrder order;
  final int videoGroupIndex;

  const AnimeConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required this.order,
      required this.videoGroupIndex,
      required AnimeApiClient apiClient})
      : super(apiClient: apiClient);

  AnimeConcreteViewInitialized copyWith(
      {AnimeConcreteView? concreteView,
      AnimeGalleryView? galleryView,
      int? videoGroupIndex,
      AnimeConcreteViewOrder? order,
      AnimeApiClient? animeApiClient}) {
    return AnimeConcreteViewInitialized(
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      order: order ?? this.order,
      videoGroupIndex: videoGroupIndex ?? this.videoGroupIndex,
      apiClient: animeApiClient ?? this.apiClient,
    );
  }
}
