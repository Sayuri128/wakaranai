part of 'remote_configs_cubit.dart';

@immutable
abstract class RemoteConfigsState {}

class RemoteConfigsLoading extends RemoteConfigsState {}

class RemoteConfigsLoaded extends RemoteConfigsState {

  final List<MangaApiClient> mangaApiClients;
  final List<AnimeApiClient> animeApiClients;

  RemoteConfigsLoaded({
    required this.mangaApiClients,
    required this.animeApiClients
  });
}

class RemoteConfigsError extends RemoteConfigsState {
  final String message;

  RemoteConfigsError({
    required this.message,
  });
}
