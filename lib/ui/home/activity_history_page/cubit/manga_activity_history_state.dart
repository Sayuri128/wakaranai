part of 'manga_activity_history_cubit.dart';

@immutable
abstract class ActivityHistoryState {
  const ActivityHistoryState();
}

final class ActivityHistoryInitial extends ActivityHistoryState {}

class ActivityHistoryLoading extends ActivityHistoryState {}

class ActivityHistoryLoaded extends ActivityHistoryState {
  final List<ActivityListItem<ChapterActivityDomain>> mangaActivities;

  const ActivityHistoryLoaded({
    required this.mangaActivities,
  });

}

class ActivityHistoryError extends ActivityHistoryState {
  final String message;

  const ActivityHistoryError(this.message);
}
