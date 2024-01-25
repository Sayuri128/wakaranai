part of 'remote_configs_cubit.dart';

@immutable
abstract class RemoteConfigsState {}

class RemoteConfigsLoading extends RemoteConfigsState {}

class RemoteConfigsLoaded extends RemoteConfigsState {
  final List<RemoteConfig> mangaRemoteConfigs;
  final List<RemoteConfig> animeRemoteConfigs;

  RemoteConfigsLoaded(
      {required this.mangaRemoteConfigs, required this.animeRemoteConfigs});
}

class RemoteConfigsError extends RemoteConfigsState {
  final String message;

  RemoteConfigsError({
    required this.message,
  });
}
