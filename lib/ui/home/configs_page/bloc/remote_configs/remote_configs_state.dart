part of 'remote_configs_cubit.dart';

@immutable
abstract class RemoteConfigsState {}

class RemoteConfigsLoading extends RemoteConfigsState {}

class RemoteConfigsLoaded extends RemoteConfigsState {
  final String sourceName;
  final List<BaseExtension> mangaRemoteConfigs;
  final List<BaseExtension> animeRemoteConfigs;
  final Map<String, ExtensionListingStatus> listingStatuses;

  RemoteConfigsLoaded({
    required this.mangaRemoteConfigs,
    required this.animeRemoteConfigs,
    required this.sourceName,
    this.listingStatuses = const <String, ExtensionListingStatus>{},
  });

  ExtensionListingStatus listingStatusOf(BaseExtension extension) {
    return listingStatuses[extension.config.uid] ??
        ExtensionListingStatus.available;
  }
}

class RemoteConfigsError extends RemoteConfigsState {
  final String message;

  RemoteConfigsError({
    required this.message,
  });
}
