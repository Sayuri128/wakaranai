part of 'local_configs_cubit.dart';

@immutable
abstract class LocalConfigsState {
  const LocalConfigsState();
}

class LocalConfigsInitial extends LocalConfigsState {}

class LocalConfigsLoading extends LocalConfigsState {}

class LocalConfigsLoaded extends LocalConfigsState {
  final List<LocalConfigInfo> localConfigsInfo;

  const LocalConfigsLoaded({
    required this.localConfigsInfo,
  });

  LocalConfigsLoaded copyWith({
    List<LocalConfigInfo>? localConfigsInfo,
  }) {
    return LocalConfigsLoaded(
      localConfigsInfo: localConfigsInfo ?? this.localConfigsInfo,
    );
  }
}
