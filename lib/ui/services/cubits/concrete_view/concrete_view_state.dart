part of 'concrete_view_cubit.dart';

class ConcreteViewState<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> {
  final T apiClient;
  final ConfigInfo configInfo;

  const ConcreteViewState({
    required this.apiClient,
    required this.configInfo,
  });
}

class ConcreteViewInitialized<
    T extends ApiClient,
    C extends ConcreteView<dynamic>,
    G extends GalleryView> extends ConcreteViewState<T, C, G> {
  final C concreteView;
  final G galleryView;
  final ConcreteViewOrder order;
  final int groupIndex;
  final Map<String, ChapterActivityDomain> chapterActivities;
  final Map<String, String> imageHeaders;

  const ConcreteViewInitialized(
      {required this.concreteView,
      required this.galleryView,
      required this.order,
      required this.groupIndex,
      required super.apiClient,
      required super.configInfo,
      required this.chapterActivities,
      required this.imageHeaders});

  ConcreteViewInitialized<T, C, G> copyWith({
    C? concreteView,
    G? galleryView,
    int? groupIndex,
    ConcreteViewOrder? order,
    Map<String, String>? imageHeaders,
    T? apiClient,
    ConfigInfo? configInfo,
    Map<String, ChapterActivityDomain>? chapterActivities,
  }) {
    return ConcreteViewInitialized<T, C, G>(
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      order: order ?? this.order,
      groupIndex: groupIndex ?? this.groupIndex,
      imageHeaders: imageHeaders ?? this.imageHeaders,
      apiClient: apiClient ?? this.apiClient,
      configInfo: configInfo ?? this.configInfo,
      chapterActivities: chapterActivities ?? this.chapterActivities,
    );
  }
}

class ConcreteViewError<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> extends ConcreteViewState<T, C, G> {
  final String message;

  const ConcreteViewError({
    required this.message,
    required super.apiClient,
    required super.configInfo,
  });
}
