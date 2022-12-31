part of 'configs_sources_cubit.dart';

@immutable
abstract class ConfigsSourcesState {
  const ConfigsSourcesState();
}

class ConfigsSourcesInitial extends ConfigsSourcesState {}

class ConfigsSourcesLoading extends ConfigsSourcesState {}

class ConfigsSourcesInitialized extends ConfigsSourcesState {
  final List<ConfigsSourceItem> sources;

  const ConfigsSourcesInitialized({
    required this.sources,
  });
}
