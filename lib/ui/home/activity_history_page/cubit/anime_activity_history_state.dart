part of 'anime_activity_history_cubit.dart';

@immutable
sealed class AnimeActivityHistoryState {
  const AnimeActivityHistoryState();
}

final class AnimeActivityHistoryInitial extends AnimeActivityHistoryState {}

class AnimeActivityHistoryLoading extends AnimeActivityHistoryState {}

class AnimeActivityHistoryLoaded extends AnimeActivityHistoryState {
  final List<ActivityListItem<AnimeEpisodeActivityDomain>> animeActivities;

  const AnimeActivityHistoryLoaded({
    required this.animeActivities,
  });
}

class AnimeActivityHistoryError extends AnimeActivityHistoryState {
  final String message;

  const AnimeActivityHistoryError(this.message);
}
