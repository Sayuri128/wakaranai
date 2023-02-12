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
  final MangaConcreteViewOrder order;
  final int currentGroupIndex;

  const MangaConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required this.currentGroupIndex,
      required this.order,
      required MangaApiClient apiClient})
      : super(apiClient: apiClient);

  MangaConcreteViewInitialized copyWith(
      {MangaConcreteView? concreteView,
      MangaGalleryView? galleryView,
      MangaConcreteViewOrder? order,
      int? currentGroupIndex,
      MangaApiClient? mangaApiClient}) {
    return MangaConcreteViewInitialized(
        concreteView: concreteView ?? this.concreteView,
        galleryView: galleryView ?? this.galleryView,
        order: order ?? this.order,
        currentGroupIndex: currentGroupIndex ?? this.currentGroupIndex,
        apiClient: mangaApiClient ?? this.apiClient);
  }
}
