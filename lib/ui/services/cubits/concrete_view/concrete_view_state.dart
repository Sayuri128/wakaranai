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
  final ConcreteDataDomain? domain;
  final ConcreteViewOrder order;
  final int groupIndex;
  final Map<String, ChapterActivityDomain> chapterActivities;
  final Map<String, AnimeEpisodeActivityDomain> animeEpisodeActivities;
  final Map<String, String> imageHeaders;
  final List<String> selection;

  const ConcreteViewInitialized({
    required this.concreteView,
    required this.domain,
    required this.order,
    required this.groupIndex,
    required super.apiClient,
    required super.configInfo,
    required this.chapterActivities,
    required this.animeEpisodeActivities,
    required this.imageHeaders,
    required this.selection,
  });

  ConcreteViewInitialized<T, C, G> copyWith({
    C? concreteView,
    ConcreteDataDomain? domain,
    int? groupIndex,
    ConcreteViewOrder? order,
    Map<String, String>? imageHeaders,
    T? apiClient,
    ConfigInfo? configInfo,
    Map<String, ChapterActivityDomain>? chapterActivities,
    Map<String, AnimeEpisodeActivityDomain>? animeEpisodeActivities,
    List<String>? selection,
  }) {
    return ConcreteViewInitialized<T, C, G>(
      concreteView: concreteView ?? this.concreteView,
      domain: domain ?? this.domain,
      order: order ?? this.order,
      groupIndex: groupIndex ?? this.groupIndex,
      imageHeaders: imageHeaders ?? this.imageHeaders,
      apiClient: apiClient ?? this.apiClient,
      configInfo: configInfo ?? this.configInfo,
      chapterActivities: chapterActivities ?? this.chapterActivities,
      animeEpisodeActivities:
          animeEpisodeActivities ?? this.animeEpisodeActivities,
      selection: selection ?? this.selection,
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
