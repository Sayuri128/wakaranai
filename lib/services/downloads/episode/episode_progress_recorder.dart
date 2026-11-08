import 'package:wakaranai/services/downloads/episode/episode_download_progress.dart';

class EpisodeProgressRecorder {
  EpisodeProgressRecorder({required this.interval, required this.publish});

  final Duration interval;
  final Future<void> Function(EpisodeDownloadProgress progress) publish;
  final Stopwatch _sinceLastPublish = Stopwatch();
  Future<void> _publishing = Future<void>.value();
  EpisodeDownloadProgress? _unpublished;

  void record(EpisodeDownloadProgress progress) {
    final bool due = !_sinceLastPublish.isRunning ||
        _sinceLastPublish.elapsed >= interval;
    if (!due) {
      _unpublished = progress;
      return;
    }
    _sinceLastPublish
      ..reset()
      ..start();
    _unpublished = null;
    _enqueue(progress);
  }

  Future<void> flush() {
    final EpisodeDownloadProgress? pending = _unpublished;
    _unpublished = null;
    if (pending != null) {
      _enqueue(pending);
    }
    return _publishing;
  }

  void _enqueue(EpisodeDownloadProgress progress) {
    _publishing = _publishing.then((_) => publish(progress));
  }
}

(int, int) episodeNotificationProgress(EpisodeDownloadProgress progress) {
  if (progress.totalSegments > 0) {
    return (progress.completedSegments, progress.totalSegments);
  }
  if (progress.totalBytes > 0) {
    final int percent =
        (progress.downloadedBytes * 100 ~/ progress.totalBytes).clamp(0, 100);
    return (percent, 100);
  }
  return (0, 0);
}
