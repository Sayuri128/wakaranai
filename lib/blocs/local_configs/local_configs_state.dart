part of 'local_configs_cubit.dart';

@immutable
abstract class LocalConfigsState {
  const LocalConfigsState();
}

class LocalConfigsInitial extends LocalConfigsState {}

class LocalConfigsInitialized extends LocalConfigsState {
  final List<LocalConfig> mangas;

  const LocalConfigsInitialized({
    required this.mangas,
  });

  LocalConfigsInitialized copyWith({
    List<LocalConfig>? mangas,
  }) {
    return LocalConfigsInitialized(
      mangas: mangas ?? this.mangas,
    );
  }
}
