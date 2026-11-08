import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

typedef DownloadFinder = Future<DownloadDomain?> Function(String uid);
typedef DownloadDeleter = Future<void> Function(DownloadDomain download);

bool isWatchedToTheEnd(EpisodeProgress progress) {
  final int? totalSeconds = progress.totalSeconds;
  if (totalSeconds == null || totalSeconds <= 0) {
    return false;
  }
  return progress.watchedSeconds / totalSeconds >= kResumeFinishedFraction;
}

class WatchedEpisodeCleanup {
  WatchedEpisodeCleanup({
    required Future<bool> Function() isEnabled,
    required DownloadFinder findDownload,
    required DownloadDeleter deleteDownload,
  })  : _isEnabled = isEnabled,
        _findDownload = findDownload,
        _deleteDownload = deleteDownload;

  factory WatchedEpisodeCleanup.of(BuildContext context) {
    final DownloadRepository repository = context.read<DownloadRepository>();
    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    final DownloadStoragePreferences preferences =
        DownloadStoragePreferences();
    return WatchedEpisodeCleanup(
      isEnabled: preferences.getDeleteAfterWatching,
      findDownload: repository.getByUid,
      deleteDownload: manager.deleteDownload,
    );
  }

  final Future<bool> Function() _isEnabled;
  final DownloadFinder _findDownload;
  final DownloadDeleter _deleteDownload;
  final Set<String> _finishedEpisodeUids = <String>{};

  Set<String> get finishedEpisodeUids =>
      Set<String>.unmodifiable(_finishedEpisodeUids);

  EpisodeProgressStore track(EpisodeProgressStore store, AnimeVideo episode) {
    return _TrackingProgressStore(
      inner: store,
      episodeUid: episode.uid,
      cleanup: this,
    );
  }

  void record(String episodeUid, EpisodeProgress progress) {
    if (isWatchedToTheEnd(progress)) {
      _finishedEpisodeUids.add(episodeUid);
      return;
    }
    _finishedEpisodeUids.remove(episodeUid);
  }

  Future<int> deleteFinishedAfter(Future<void> playbackClosed) async {
    await playbackClosed;
    return deleteFinished();
  }

  Future<int> deleteFinished() async {
    if (_finishedEpisodeUids.isEmpty) {
      return 0;
    }
    final List<String> episodeUids = _finishedEpisodeUids.toList();
    _finishedEpisodeUids.clear();
    if (!await _isEnabled()) {
      return 0;
    }
    int deleted = 0;
    for (final String episodeUid in episodeUids) {
      if (await _deleteIfDownloaded(episodeUid)) {
        deleted++;
      }
    }
    return deleted;
  }

  Future<bool> _deleteIfDownloaded(String episodeUid) async {
    try {
      final DownloadDomain? download = await _findDownload(episodeUid);
      if (download == null ||
          !download.isEpisode ||
          download.status != DownloadStatus.done) {
        return false;
      }
      await _deleteDownload(download);
      logger.i('Deleted watched episode download $episodeUid');
      return true;
    } catch (error, stackTrace) {
      logger.w('Failed to delete watched episode $episodeUid: $error');
      logger.w(stackTrace);
      return false;
    }
  }
}

class _TrackingProgressStore implements EpisodeProgressStore {
  _TrackingProgressStore({
    required this.inner,
    required this.episodeUid,
    required this.cleanup,
  });

  final EpisodeProgressStore inner;
  final String episodeUid;
  final WatchedEpisodeCleanup cleanup;

  @override
  Future<EpisodeProgress?> start() {
    return inner.start();
  }

  @override
  Future<void> save(EpisodeProgress progress) async {
    await inner.save(progress);
    cleanup.record(episodeUid, progress);
  }
}
