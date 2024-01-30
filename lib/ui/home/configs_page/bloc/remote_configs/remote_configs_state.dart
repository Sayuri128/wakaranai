part of 'remote_configs_cubit.dart';

@immutable
abstract class RemoteConfigsState {}

class RemoteConfigsLoading extends RemoteConfigsState {}

class RemoteConfigsLoaded extends RemoteConfigsState {
  final String sourceName;
  final List<BaseExtension> mangaRemoteConfigs;
  final List<BaseExtension> animeRemoteConfigs;

  RemoteConfigsLoaded({
    required this.mangaRemoteConfigs,
    required this.animeRemoteConfigs,
    required this.sourceName,
  });
}

class RemoteConfigsError extends RemoteConfigsState {
  final String message;

  RemoteConfigsError({
    required this.message,
  });
}
