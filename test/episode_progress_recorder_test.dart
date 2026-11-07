import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_progress.dart';
import 'package:wakaranai/services/downloads/episode/episode_progress_recorder.dart';

EpisodeDownloadProgress _progress({
  int completedSegments = 0,
  int totalSegments = 0,
  int downloadedBytes = 0,
  int totalBytes = 0,
}) {
  return EpisodeDownloadProgress(
    completedSegments: completedSegments,
    totalSegments: totalSegments,
    downloadedBytes: downloadedBytes,
    totalBytes: totalBytes,
  );
}

void main() {
  group('EpisodeProgressRecorder', () {
    test('publishes the first progress right away', () async {
      final List<EpisodeDownloadProgress> published =
          <EpisodeDownloadProgress>[];
      final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
        interval: const Duration(hours: 1),
        publish: (EpisodeDownloadProgress progress) async {
          published.add(progress);
        },
      );

      final EpisodeDownloadProgress first = _progress(completedSegments: 1);
      recorder.record(first);
      await recorder.flush();

      expect(published, <EpisodeDownloadProgress>[first]);
    });

    test('holds progress inside the interval and flushes only the latest',
        () async {
      final List<EpisodeDownloadProgress> published =
          <EpisodeDownloadProgress>[];
      final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
        interval: const Duration(hours: 1),
        publish: (EpisodeDownloadProgress progress) async {
          published.add(progress);
        },
      );

      final EpisodeDownloadProgress first = _progress(completedSegments: 1);
      final EpisodeDownloadProgress second = _progress(completedSegments: 2);
      final EpisodeDownloadProgress third = _progress(completedSegments: 3);
      recorder.record(first);
      recorder.record(second);
      recorder.record(third);
      await recorder.flush();

      expect(published, <EpisodeDownloadProgress>[first, third]);
    });

    test('publishes every progress once the interval has elapsed', () async {
      final List<EpisodeDownloadProgress> published =
          <EpisodeDownloadProgress>[];
      final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
        interval: Duration.zero,
        publish: (EpisodeDownloadProgress progress) async {
          published.add(progress);
        },
      );

      final EpisodeDownloadProgress first = _progress(completedSegments: 1);
      final EpisodeDownloadProgress second = _progress(completedSegments: 2);
      recorder.record(first);
      recorder.record(second);
      await recorder.flush();

      expect(published, <EpisodeDownloadProgress>[first, second]);
    });

    test('publishes in order even when a publish is slow', () async {
      final List<int> published = <int>[];
      final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
        interval: Duration.zero,
        publish: (EpisodeDownloadProgress progress) async {
          if (progress.completedSegments == 1) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
          published.add(progress.completedSegments);
        },
      );

      recorder.record(_progress(completedSegments: 1));
      recorder.record(_progress(completedSegments: 2));
      await recorder.flush();

      expect(published, <int>[1, 2]);
    });

    test('flush without pending progress publishes nothing new', () async {
      int publishes = 0;
      final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
        interval: const Duration(hours: 1),
        publish: (EpisodeDownloadProgress progress) async {
          publishes++;
        },
      );

      await recorder.flush();
      recorder.record(_progress(completedSegments: 1));
      await recorder.flush();
      await recorder.flush();

      expect(publishes, 1);
    });
  });

  group('episodeNotificationProgress', () {
    test('uses segments when the total is known', () {
      expect(
        episodeNotificationProgress(_progress(
          completedSegments: 3,
          totalSegments: 10,
          downloadedBytes: 50,
          totalBytes: 100,
        )),
        (3, 10),
      );
    });

    test('falls back to a byte percentage', () {
      expect(
        episodeNotificationProgress(
            _progress(downloadedBytes: 250, totalBytes: 1000)),
        (25, 100),
      );
    });

    test('clamps the byte percentage to 100', () {
      expect(
        episodeNotificationProgress(
            _progress(downloadedBytes: 1500, totalBytes: 1000)),
        (100, 100),
      );
    });

    test('is indeterminate without totals', () {
      expect(episodeNotificationProgress(_progress()), (0, 0));
    });
  });
}
