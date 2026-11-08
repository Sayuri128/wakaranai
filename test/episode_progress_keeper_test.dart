import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/episode_progress_keeper.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

class _RecordingStore implements EpisodeProgressStore {
  _RecordingStore({this.initial, this.failStart = false});

  final EpisodeProgress? initial;
  final bool failStart;
  final List<EpisodeProgress> saved = <EpisodeProgress>[];

  @override
  Future<EpisodeProgress?> start() async {
    if (failStart) {
      throw StateError('unavailable');
    }
    return initial;
  }

  @override
  Future<void> save(EpisodeProgress progress) async {
    saved.add(progress);
  }
}

VideoPlayerValue _value({
  Duration position = Duration.zero,
  Duration duration = const Duration(minutes: 24),
  bool isInitialized = true,
  bool isCompleted = false,
}) {
  return VideoPlayerValue(
    duration: duration,
    position: position,
    isInitialized: isInitialized,
    isCompleted: isCompleted,
  );
}

void main() {
  group('episodeProgressOf', () {
    test('reports the watched position against the duration', () {
      expect(
        episodeProgressOf(_value(position: const Duration(seconds: 90))),
        const EpisodeProgress(watchedSeconds: 90, totalSeconds: 1440),
      );
    });

    test('counts a completed episode as fully watched', () {
      expect(
        episodeProgressOf(_value(
          position: const Duration(seconds: 10),
          isCompleted: true,
        )),
        const EpisodeProgress(watchedSeconds: 1440, totalSeconds: 1440),
      );
    });

    test('has nothing to report before playback starts', () {
      expect(episodeProgressOf(_value()), isNull);
      expect(
        episodeProgressOf(_value(
          position: const Duration(seconds: 5),
          isInitialized: false,
        )),
        isNull,
      );
      expect(
        episodeProgressOf(_value(
          position: const Duration(seconds: 5),
          duration: Duration.zero,
        )),
        isNull,
      );
    });
  });

  group('EpisodeProgressKeeper', () {
    test('loads the saved progress and forgets it on a failed load', () async {
      final EpisodeProgressKeeper keeper = EpisodeProgressKeeper(
        _RecordingStore(initial: const EpisodeProgress(watchedSeconds: 30)),
      );

      await keeper.loadSaved();
      expect(keeper.saved, const EpisodeProgress(watchedSeconds: 30));

      keeper.startEpisode(_RecordingStore(failStart: true));
      await keeper.loadSaved();
      expect(keeper.saved, isNull);
    });

    test('skips saving unchanged or missing progress', () async {
      final _RecordingStore store = _RecordingStore();
      final EpisodeProgressKeeper keeper = EpisodeProgressKeeper(store);
      const EpisodeProgress progress = EpisodeProgress(watchedSeconds: 60);

      await keeper.save(() => null);
      await keeper.save(() => progress);
      await keeper.save(() => progress);

      expect(store.saved, <EpisodeProgress>[progress]);
      expect(keeper.lastPersisted, progress);
    });

    test('reads the progress when the save runs, not when it is queued',
        () async {
      final _RecordingStore store = _RecordingStore();
      final EpisodeProgressKeeper keeper = EpisodeProgressKeeper(store);
      EpisodeProgress current = const EpisodeProgress(watchedSeconds: 1);

      final Future<void> first = keeper.save(() => current);
      final Future<void> second = keeper.save(() => current);
      current = const EpisodeProgress(watchedSeconds: 2);
      await first;
      await second;

      expect(store.saved, const <EpisodeProgress>[
        EpisodeProgress(watchedSeconds: 2),
      ]);
    });

    test('starting another episode resets what was saved', () async {
      final EpisodeProgressKeeper keeper = EpisodeProgressKeeper(
        _RecordingStore(initial: const EpisodeProgress(watchedSeconds: 30)),
      );
      await keeper.loadSaved();
      await keeper.save(() => const EpisodeProgress(watchedSeconds: 40));

      final _RecordingStore next = _RecordingStore();
      keeper.startEpisode(next);

      expect(keeper.store, same(next));
      expect(keeper.saved, isNull);
      expect(keeper.lastPersisted, isNull);
    });
  });
}
