part of 'concrete_view_cubit.dart';

class ConcreteViewState<
    T extends ApiClient,
    C extends ConcreteView<GroupOfConcrete<dynamic>>,
    G extends GalleryView> {
  final T apiClient;

  const ConcreteViewState({
    required this.apiClient,
  });
}

class ConcreteViewInitialized<
    T extends ApiClient,
    C extends ConcreteView<GroupOfConcrete<dynamic>>,
    G extends GalleryView> extends ConcreteViewState<T, C, G> {
  final C concreteView;
  final G galleryView;
  final ConcreteViewOrder order;
  final int groupIndex;

  const ConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required this.order,
      required this.groupIndex,
      required T apiClient})
      : super(apiClient: apiClient);

  ConcreteViewInitialized<T, C, G> copyWith(
      {C? concreteView,
      G? galleryView,
      int? groupIndex,
      ConcreteViewOrder? order,
      T? apiClient}) {
    return ConcreteViewInitialized<T, C, G>(
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      order: order ?? this.order,
      groupIndex: groupIndex ?? this.groupIndex,
      apiClient: apiClient ?? this.apiClient,
    );
  }
}
