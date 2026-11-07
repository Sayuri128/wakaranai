import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_cleanup.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

typedef EpisodeActivitiesReader =
    Future<List<AnimeEpisodeActivityDomain>?> Function(String concreteUid);

bool isEpisodeWatchedForCleanup(AnimeEpisodeActivityDomain activity) {
  if (activity.markedWatched) {
    return true;
  }
  final int? watchedSeconds = activity.watchedTime;
  if (watchedSeconds == null) {
    return false;
  }
  return isWatchedToTheEnd(
    EpisodeProgress(
      watchedSeconds: watchedSeconds,
      totalSeconds: activity.totalTime,
    ),
  );
}

Set<String> watchedEpisodeUidsForCleanup(
  Iterable<AnimeEpisodeActivityDomain> activities,
) {
  return <String>{
    for (final AnimeEpisodeActivityDomain activity in activities)
      if (isEpisodeWatchedForCleanup(activity)) activity.uid,
  };
}

List<DownloadDomain> watchedEpisodeDownloads(
  Iterable<DownloadDomain> downloads,
  Set<String> finishedEpisodeUids,
) {
  return downloads
      .where(
        (DownloadDomain download) =>
            download.isEpisode &&
            download.status == DownloadStatus.done &&
            finishedEpisodeUids.contains(download.uid),
      )
      .toList(growable: false);
}

class WatchedEpisodeFinder {
  WatchedEpisodeFinder({required EpisodeActivitiesReader readActivities})
    : _readActivities = readActivities;

  factory WatchedEpisodeFinder.fromRepository(
    AnimeEpisodeActivityRepository repository,
  ) {
    return WatchedEpisodeFinder(
      readActivities: repository.getAllActivitiesByConcreteId,
    );
  }

  final EpisodeActivitiesReader _readActivities;

  Future<List<DownloadDomain>> watchedDownloadsOf(
    List<DownloadDomain> titleDownloads,
  ) async {
    final bool hasEpisodes = titleDownloads.any(
      (DownloadDomain download) => download.isEpisode,
    );
    if (!hasEpisodes) {
      return const <DownloadDomain>[];
    }
    final String concreteUid = titleDownloads.first.concreteUid;
    final List<AnimeEpisodeActivityDomain>? activities = await _readActivities(
      concreteUid,
    );
    if (activities == null || activities.isEmpty) {
      return const <DownloadDomain>[];
    }
    return watchedEpisodeDownloads(
      titleDownloads,
      watchedEpisodeUidsForCleanup(activities),
    );
  }
}
