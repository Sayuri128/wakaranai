part of 'local_configs_cubit.dart';

@immutable
abstract class LocalConfigsState {
  const LocalConfigsState();
}

class LocalConfigsInitial extends LocalConfigsState {}

class LocalConfigsLoading extends LocalConfigsState {}

class LocalConfigsLoaded extends LocalConfigsState {
  final List<LocalApiClient> localApiClients;

  const LocalConfigsLoaded({
    required this.localApiClients,
  });

  LocalConfigsLoaded copyWith({
    List<LocalApiClient>? localApiClients,
  }) {
    return LocalConfigsLoaded(
      localApiClients: localApiClients ?? this.localApiClients,
    );
  }
}
