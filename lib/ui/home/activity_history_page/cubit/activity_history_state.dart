part of 'activity_history_cubit.dart';

@immutable
abstract class ActivityHistoryState {
  const ActivityHistoryState();
}

final class ActivityHistoryInitial extends ActivityHistoryState {}

class ActivityHistoryLoading extends ActivityHistoryState {}

class ActivityHistoryLoaded extends ActivityHistoryState {
  final List<ActivityListItem> activities;

  const ActivityHistoryLoaded({
    required this.activities,
  });
}

class ActivityHistoryError extends ActivityHistoryState {
  final String message;

  const ActivityHistoryError(this.message);
}
