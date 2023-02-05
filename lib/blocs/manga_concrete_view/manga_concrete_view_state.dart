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

  const MangaConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required MangaApiClient apiClient})
      : super(apiClient: apiClient);
}
