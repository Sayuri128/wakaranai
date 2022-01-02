part of 'configs_cubit.dart';

@immutable
abstract class ConfigsState {}

class ConfigsLoading extends ConfigsState {}

class ConfigsLoaded extends ConfigsState {

  final List<ApiClient> mangaApiClients;

  ConfigsLoaded({
    required this.mangaApiClients,
  });
}
