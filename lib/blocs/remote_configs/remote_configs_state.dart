part of 'remote_configs_cubit.dart';

@immutable
abstract class RemoteConfigsState {}

class RemoteConfigsLoading extends RemoteConfigsState {}

class RemoteConfigsLoaded extends RemoteConfigsState {

  final List<ApiClient> mangaApiClients;

  RemoteConfigsLoaded({
    required this.mangaApiClients,
  });
}
