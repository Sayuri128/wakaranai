part of 'manga_concrete_view_cubit.dart';

class MangaConcreteViewState {
  final MangaApiClient apiClient;

  const MangaConcreteViewState({
    required this.apiClient,
  });
}

class MangaConcreteViewInitialized extends MangaConcreteViewState {
  final MangaConcreteView concreteView;
  final MangaGalleryView galleryView;
  final int currentGroupIndex;

  const MangaConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required this.currentGroupIndex,
      required MangaApiClient apiClient})
      : super(apiClient: apiClient);

  MangaConcreteViewInitialized copyWith({
    MangaConcreteView? concreteView,
    MangaGalleryView? galleryView,
    int? currentGroupIndex,
    MangaApiClient? mangaApiClient
  }) {
    return MangaConcreteViewInitialized(
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      currentGroupIndex: currentGroupIndex ?? this.currentGroupIndex,
      apiClient: mangaApiClient ?? this.apiClient
    );
  }
}
