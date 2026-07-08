part of 'stats_cubit.dart';

@immutable
abstract class StatsState {
  const StatsState();
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsDisabled extends StatsState {}

class StatsError extends StatsState {}

class StatsLoaded extends StatsState {
  final ReadingStats stats;

  const StatsLoaded(this.stats);
}
