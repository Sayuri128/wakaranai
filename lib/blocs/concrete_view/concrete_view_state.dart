part of 'concrete_view_cubit.dart';

class ConcreteViewState {
  final ApiClient apiClient;

  const ConcreteViewState({
    required this.apiClient,
  });
}

class ConcreteViewInitialized extends ConcreteViewState {
  final ConcreteView concreteView;
  final GalleryView galleryView;

  const ConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required ApiClient apiClient})
      : super(apiClient: apiClient);
}
