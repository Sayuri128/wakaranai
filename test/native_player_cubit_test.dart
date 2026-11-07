import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

const Duration _episodeLength = Duration(minutes: 24);

class _FakeEngine extends ValueNotifier<VideoPlayerValue>
    implements NativePlayerEngine {
  _FakeEngine(this.stream, {this.failOnInitialize = false})
      : super(const VideoPlayerValue.uninitialized());

  final PlayableStream stream;
  final bool failOnInitialize;
  final List<Duration> seeks = <Duration>[];
  ClosedCaptionFile? captionFile;
  bool disposed = false;

  @override
  Future<void> initialize() async {
    if (failOnInitialize) {
      throw Exception('source unavailable');
    }
    value = value.copyWith(isInitialized: true, duration: _episodeLength);
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seeks.add(position);
    value = value.copyWith(position: position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
  }

  @override
  Future<void> setClosedCaptionFile(ClosedCaptionFile? file) async {
    captionFile = file;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    super.dispose();
  }

  @override
  Widget buildView() {
    return const SizedBox.shrink();
  }

  void failPlayback(String description) {
    value = value.copyWith(errorDescription: description, isPlaying: false);
  }
}

class _FakeProgressStore implements EpisodeProgressStore {
  _FakeProgressStore({this.initial});

  final EpisodeProgress? initial;
  final List<EpisodeProgress> saved = <EpisodeProgress>[];

  @override
  Future<EpisodeProgress?> start() async {
    return initial;
  }

  @override
  Future<void> save(EpisodeProgress progress) async {
    saved.add(progress);
  }
}

class _FakeSubtitleLoader implements SubtitleLoader {
  _FakeSubtitleLoader({this.fail = false});

  final bool fail;

  @override
  Future<ClosedCaptionFile> load(PlayableSubtitle subtitle) async {
    if (fail) {
      throw Exception('404');
    }
    return WebVTTCaptionFile(
      'WEBVTT\n\n00:00:01.000 --> 00:00:02.000\nHello\n',
    );
  }
}

class _Harness {
  _Harness({
    EpisodeProgress? initialProgress,
    this.failingInitializations = 0,
    bool subtitleFails = false,
  })  : store = _FakeProgressStore(initial: initialProgress),
        subtitleLoader = _FakeSubtitleLoader(fail: subtitleFails);

  final _FakeProgressStore store;
  final _FakeSubtitleLoader subtitleLoader;
  final List<_FakeEngine> engines = <_FakeEngine>[];
  int failingInitializations;

  NativePlayerCubit build() {
    return NativePlayerCubit(
      video: const PlayableVideo(
        streams: <PlayableStream>[
          PlayableStream(url: 'https://cdn.test/1080.m3u8', quality: '1080p'),
          PlayableStream(url: 'https://cdn.test/720.mp4', quality: '720p'),
        ],
        subtitles: <PlayableSubtitle>[
          PlayableSubtitle(url: 'https://cdn.test/en.vtt', language: 'en'),
        ],
      ),
      engineFactory: _createEngine,
      progressStore: store,
      subtitleLoader: subtitleLoader,
      progressSaveInterval: const Duration(hours: 1),
    );
  }

  NativePlayerEngine _createEngine(PlayableStream stream) {
    final bool fail = failingInitializations > 0;
    if (fail) {
      failingInitializations--;
    }
    final _FakeEngine engine = _FakeEngine(stream, failOnInitialize: fail);
    engines.add(engine);
    return engine;
  }
}

void main() {
  test('opens the first stream and starts playing', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();

    await cubit.init();

    expect(cubit.state.status, NativePlayerStatus.ready);
    expect(cubit.state.streamIndex, 0);
    expect(cubit.state.isPlaying, isTrue);
    expect(harness.engines.single.stream.quality, '1080p');
    expect(harness.engines.single.seeks, isEmpty);
    await cubit.close();
  });

  test('switching quality keeps the position and play state', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(minutes: 5));

    await cubit.selectQuality(1);

    expect(harness.engines, hasLength(2));
    expect(harness.engines.first.disposed, isTrue);
    final _FakeEngine current = harness.engines.last;
    expect(current.stream.quality, '720p');
    expect(current.value.position, const Duration(minutes: 5));
    expect(current.value.isPlaying, isTrue);
    expect(cubit.state.streamIndex, 1);
    expect(cubit.state.status, NativePlayerStatus.ready);
    await cubit.close();
  });

  test('switching quality while paused stays paused', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(minutes: 3));
    await cubit.togglePlayPause();

    await cubit.selectQuality(1);

    expect(harness.engines.last.value.position, const Duration(minutes: 3));
    expect(harness.engines.last.value.isPlaying, isFalse);
    expect(cubit.state.isPlaying, isFalse);
    await cubit.close();
  });

  test('switching quality carries the playback speed over', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.setPlaybackSpeed(1.5);

    await cubit.selectQuality(1);

    expect(harness.engines.last.value.playbackSpeed, 1.5);
    expect(cubit.state.playbackSpeed, 1.5);
    await cubit.close();
  });

  test('resumes from the saved position on open', () async {
    final _Harness harness = _Harness(
      initialProgress: const EpisodeProgress(
        watchedSeconds: 300,
        totalSeconds: 1440,
      ),
    );
    final NativePlayerCubit cubit = harness.build();

    await cubit.init();

    expect(harness.engines.single.seeks, <Duration>[
      const Duration(seconds: 300),
    ]);
    await cubit.close();
  });

  test('starts over when the saved position is near the end', () async {
    final _Harness harness = _Harness(
      initialProgress: const EpisodeProgress(
        watchedSeconds: 1420,
        totalSeconds: 1440,
      ),
    );
    final NativePlayerCubit cubit = harness.build();

    await cubit.init();

    expect(harness.engines.single.seeks, isEmpty);
    await cubit.close();
  });

  test('saves progress on pause and on close', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(minutes: 2));

    await cubit.togglePlayPause();
    await cubit.saveProgress();

    expect(
      harness.store.saved.last,
      const EpisodeProgress(watchedSeconds: 120, totalSeconds: 1440),
    );

    await cubit.togglePlayPause();
    await cubit.seekTo(const Duration(minutes: 7));
    await cubit.close();

    expect(
      harness.store.saved.last,
      const EpisodeProgress(watchedSeconds: 420, totalSeconds: 1440),
    );
    expect(harness.engines.single.disposed, isTrue);
  });

  test('does not write identical progress twice', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(minutes: 2));

    await cubit.saveProgress();
    await cubit.saveProgress();

    expect(harness.store.saved, hasLength(1));
    await cubit.close();
  });

  test('double tap seeking is clamped to the video bounds', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();

    await cubit.seekBy(-kNativePlayerSeekStep);
    expect(harness.engines.single.value.position, Duration.zero);

    await cubit.seekTo(_episodeLength - const Duration(seconds: 4));
    await cubit.seekBy(kNativePlayerSeekStep);
    expect(harness.engines.single.value.position, _episodeLength);
    await cubit.close();
  });

  test('a failed open shows an error and retry recovers', () async {
    final _Harness harness = _Harness(failingInitializations: 1);
    final NativePlayerCubit cubit = harness.build();

    await cubit.init();

    expect(cubit.state.status, NativePlayerStatus.error);
    expect(cubit.state.errorMessage, contains('source unavailable'));
    expect(harness.engines.single.disposed, isTrue);

    await cubit.retry();

    expect(cubit.state.status, NativePlayerStatus.ready);
    expect(harness.engines, hasLength(2));
    await cubit.close();
  });

  test('a playback error keeps the position for retry', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(minutes: 9));

    harness.engines.single.failPlayback('decoder crashed');

    expect(cubit.state.status, NativePlayerStatus.error);
    expect(cubit.state.errorMessage, 'decoder crashed');

    await cubit.retry();

    expect(cubit.state.status, NativePlayerStatus.ready);
    expect(harness.engines.last.value.position, const Duration(minutes: 9));
    await cubit.close();
  });

  test('selecting a subtitle attaches the caption file', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();

    await cubit.selectSubtitle(0);

    expect(cubit.state.subtitleIndex, 0);
    expect(cubit.state.subtitleLoading, isFalse);
    expect(harness.engines.single.captionFile, isNotNull);

    await cubit.selectQuality(1);
    expect(harness.engines.last.captionFile, isNotNull);

    await cubit.selectSubtitle(null);
    expect(cubit.state.subtitleIndex, isNull);
    expect(harness.engines.last.captionFile, isNull);
    await cubit.close();
  });

  test('a failed subtitle download is reported and turned off', () async {
    final _Harness harness = _Harness(subtitleFails: true);
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();

    await cubit.selectSubtitle(0);

    expect(cubit.state.subtitleFailed, isTrue);
    expect(cubit.state.subtitleIndex, isNull);
    expect(harness.engines.single.captionFile, isNull);
    await cubit.close();
  });

  test('a video without streams goes straight to the error state', () async {
    final NativePlayerCubit cubit = NativePlayerCubit(
      video: const PlayableVideo(streams: <PlayableStream>[]),
      engineFactory: (PlayableStream stream) => _FakeEngine(stream),
      progressStore: _FakeProgressStore(),
      subtitleLoader: _FakeSubtitleLoader(),
    );

    await cubit.init();

    expect(cubit.state.status, NativePlayerStatus.error);
    await cubit.close();
  });
}
