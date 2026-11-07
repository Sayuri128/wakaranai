import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/services/anime/native_player/local_media.dart';

enum LocalPlaybackErrorAction { streamInstead, showError }

class LocalPlaybackFailures {
  static final LocalPlaybackFailures shared = LocalPlaybackFailures();

  final Set<String> _failedEpisodeUids = <String>{};

  bool hasFailed(String episodeUid) => _failedEpisodeUids.contains(episodeUid);

  void markFailed(String episodeUid) {
    _failedEpisodeUids.add(episodeUid);
  }

  void forget(String episodeUid) {
    _failedEpisodeUids.remove(episodeUid);
  }
}

bool isLocalPlayback(PlayableVideo video) {
  return video.streams.isNotEmpty &&
      video.streams.every(
        (PlayableStream stream) => isLocalFileUrl(stream.url),
      );
}

LocalPlaybackErrorAction localPlaybackErrorAction({
  required PlayableVideo video,
  required String episodeUid,
  required LocalPlaybackFailures failures,
}) {
  if (!isLocalPlayback(video)) {
    return LocalPlaybackErrorAction.showError;
  }
  if (failures.hasFailed(episodeUid)) {
    return LocalPlaybackErrorAction.showError;
  }
  return LocalPlaybackErrorAction.streamInstead;
}

bool claimStreamingFallback({
  required PlayableVideo video,
  required String episodeUid,
  LocalPlaybackFailures? failures,
}) {
  final LocalPlaybackFailures registry =
      failures ?? LocalPlaybackFailures.shared;
  final LocalPlaybackErrorAction action = localPlaybackErrorAction(
    video: video,
    episodeUid: episodeUid,
    failures: registry,
  );
  if (action != LocalPlaybackErrorAction.streamInstead) {
    return false;
  }
  logger.w('Downloaded episode $episodeUid failed to play, streaming it');
  registry.markFailed(episodeUid);
  return true;
}

typedef EpisodeDownloadFinder = Future<DownloadDomain?> Function(String uid);
typedef EpisodeDownloadAction = Future<void> Function(DownloadDomain download);

Future<bool> redownloadEpisode({
  required String episodeUid,
  required EpisodeDownloadFinder findDownload,
  required EpisodeDownloadAction deleteDownload,
  required EpisodeDownloadAction downloadAgain,
  LocalPlaybackFailures? failures,
}) async {
  final DownloadDomain? download = await findDownload(episodeUid);
  if (download == null || !download.isEpisode) {
    return false;
  }
  await deleteDownload(download);
  (failures ?? LocalPlaybackFailures.shared).forget(episodeUid);
  await downloadAgain(download);
  return true;
}
