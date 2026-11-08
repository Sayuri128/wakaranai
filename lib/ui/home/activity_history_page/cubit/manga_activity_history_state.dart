part of 'manga_activity_history_cubit.dart';

@immutable
abstract class ActivityHistoryState {
  const ActivityHistoryState();
}

final class ActivityHistoryInitial extends ActivityHistoryState {}

class ActivityHistoryLoading extends ActivityHistoryState {}

class ActivityHistoryLoaded extends ActivityHistoryState {
  final List<ActivityListItem<ChapterActivityDomain>> mangaActivities;
  final Set<String> novelExtensionUids;
  final Set<String> audioExtensionUids;

  const ActivityHistoryLoaded({
    required this.mangaActivities,
    this.novelExtensionUids = const <String>{},
    this.audioExtensionUids = const <String>{},
  });

  bool isNovel(ConcreteDataDomain concrete) {
    return novelExtensionUids.contains(concrete.extensionUid);
  }

  bool isAudio(ConcreteDataDomain concrete) {
    return audioExtensionUids.contains(concrete.extensionUid);
  }

}

class ActivityHistoryError extends ActivityHistoryState {
  final String message;

  const ActivityHistoryError(this.message);
}
