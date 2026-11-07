import 'dart:async';
import 'package:capyscript/api_clients/source_error.dart';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

const Duration _episodeLength = Duration(minutes: 24);

class _FakeEngine extends ValueNotifier<VideoPlayerValue>
    implements NativePlayerEngine {
  _FakeEngine(
    this.stream, {
    this.failOnInitialize = false,
    this.maxSupportedSpeed = 8.0,
    this.tracks = const <VideoTrack>[],
    this.supportsVideoTracks = true,
    this.initializeGate,
  }) : super(const VideoPlayerValue.uninitialized());

  final PlayableStream stream;
  final bool failOnInitialize;
  final Completer<void>? initializeGate;
  final double maxSupportedSpeed;
  final List<VideoTrack> tracks;
  final List<VideoTrack?> trackSelections = <VideoTrack?>[];
  int trackReads = 0;
  final List<Duration> seeks = <Duration>[];
  final List<double> speeds = <double>[];
  ClosedCaptionFile? captionFile;
  bool disposed = false;

  @override
  Future<void> initialize() async {
    final Completer<void>? gate = initializeGate;
    if (gate != null) {
      await gate.future;
    }
    if (failOnInitialize) {
      throw Exception('source unavailable');
    }
    value = value.copyWith(isInitialized: true, duration: _episodeLength);
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true, isCompleted: false);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seeks.add(position);
    value = value.copyWith(
      position: position,
      isCompleted: position == value.duration,
    );
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (speed > maxSupportedSpeed) {
      throw Exception('unsupported speed $speed');
    }
    speeds.add(speed);
    value = value.copyWith(playbackSpeed: speed);
  }

  @override
  Future<void> setClosedCaptionFile(ClosedCaptionFile? file) async {
    captionFile = file;
  }

  @override
  final bool supportsVideoTracks;

  @override
  Future<List<VideoTrack>> getVideoTracks() async {
    trackReads++;
    return tracks;
  }

  @override
  Future<void> selectVideoTrack(VideoTrack? track) async {
    trackSelections.add(track);
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

  void complete() {
    value = value.copyWith(
      isPlaying: false,
      position: _episodeLength,
      isCompleted: true,
    );
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

AnimeVideo _episode(String uid, String title) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/$uid',
    title: title,
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
  );
}

final List<AnimeVideoGroup> _groups = <AnimeVideoGroup>[
  AnimeVideoGroup(
    title: 'Dub A',
    elements: <AnimeVideo>[
      _episode('a1', 'Серія 1'),
      _episode('a2', 'Серія 2'),
      _episode('a3', 'Серія 3'),
    ],
  ),
  AnimeVideoGroup(
    title: 'Dub B',
    elements: <AnimeVideo>[
      _episode('b3', 'Серія 3'),
      _episode('b2', 'Серія 2'),
      _episode('b1', 'Серія 1'),
    ],
  ),
];

const PlayableVideo _firstVideo = PlayableVideo(
  streams: <PlayableStream>[
    PlayableStream(url: 'https://cdn.test/1080.m3u8', quality: '1080p'),
    PlayableStream(url: 'https://cdn.test/720.mp4', quality: '720p'),
  ],
  subtitles: <PlayableSubtitle>[
    PlayableSubtitle(url: 'https://cdn.test/en.vtt', language: 'en'),
  ],
);

PlayableVideo _videoFor(String uid) {
  return PlayableVideo(
    streams: <PlayableStream>[
      PlayableStream(url: 'https://cdn.test/$uid/1080.m3u8', quality: '1080p'),
      PlayableStream(url: 'https://cdn.test/$uid/720.mp4', quality: '720p'),
    ],
    subtitles: <PlayableSubtitle>[
      PlayableSubtitle(url: 'https://cdn.test/$uid/en.vtt', language: 'en'),
    ],
  );
}

VideoTrack _track(String id, int height, int bitrate) {
  return VideoTrack(
    id: id,
    isSelected: false,
    height: height,
    width: height * 16 ~/ 9,
    bitrate: bitrate,
  );
}

List<VideoTrack> _ladder(PlayableStream stream) {
  if (!stream.url.endsWith('.m3u8')) {
    return const <VideoTrack>[];
  }
  return <VideoTrack>[
    _track('0_0', 1080, 5000000),
    _track('0_1', 720, 2800000),
    _track('0_2', 480, 1200000),
  ];
}

PlayableVideo _singleHlsVideo(String uid) {
  return PlayableVideo(
    streams: <PlayableStream>[
      PlayableStream(url: 'https://cdn.test/$uid/master.m3u8'),
    ],
  );
}

PlayableVideo _codecStreamsVideo(String uid) {
  return PlayableVideo(
    streams: <PlayableStream>[
      PlayableStream(
        url: 'https://cdn.test/$uid/h265.m3u8',
        quality: 'Auto (H.265)',
      ),
      PlayableStream(
        url: 'https://cdn.test/$uid/h264.m3u8',
        quality: 'Auto (H.264)',
      ),
    ],
  );
}

class _Harness {
  _Harness({
    EpisodeProgress? initialProgress,
    this.failingInitializations = 0,
    this.hasNextEpisode = false,
    this.maxSupportedSpeed = 8.0,
    this.startUid = 'a1',
    this.webOnlyUids = const <String>{},
    this.tracksFor,
    this.videoFor,
    this.supportsVideoTracks = true,
    bool subtitleFails = false,
  })  : _initialProgress = initialProgress,
        subtitleLoader = _FakeSubtitleLoader(fail: subtitleFails);

  final EpisodeProgress? _initialProgress;
  final _FakeSubtitleLoader subtitleLoader;
  final List<_FakeEngine> engines = <_FakeEngine>[];
  final Map<String, _FakeProgressStore> stores = <String, _FakeProgressStore>{};
  final List<String> resolvedUids = <String>[];
  final Map<String, Completer<void>> resolveGates =
      <String, Completer<void>>{};
  final Map<String, Completer<void>> initializeGates =
      <String, Completer<void>>{};
  final bool hasNextEpisode;
  final double maxSupportedSpeed;
  final String startUid;
  final Set<String> webOnlyUids;
  final Map<String, Object> resolveFailures = <String, Object>{};
  final List<VideoTrack> Function(PlayableStream stream)? tracksFor;
  final PlayableVideo Function(String uid)? videoFor;
  final bool supportsVideoTracks;
  int failingInitializations;

  _FakeProgressStore get store => stores[startUid]!;

  NativePlayerCubit build() {
    final int groupIndex = startUid.startsWith('a') ? 0 : 1;
    final AnimeVideo start = _groups[groupIndex]
        .elements
        .firstWhere((AnimeVideo video) => video.uid == startUid);
    final PlayableVideo Function(String uid)? customVideo = videoFor;
    return NativePlayerCubit(
      video: customVideo == null ? _firstVideo : customVideo(startUid),
      playlist: EpisodePlaylist(
        groups: _groups,
        groupIndex: groupIndex,
        current: start,
      ),
      engineFactory: _createEngine,
      progressStoreFor: _storeFor,
      subtitleLoader: subtitleLoader,
      resolveEpisode: hasNextEpisode ? _resolve : null,
      preferences: PlayerPreferences(),
      progressSaveInterval: const Duration(hours: 1),
      autoNextTick: const Duration(hours: 1),
    );
  }

  EpisodeProgressStore _storeFor(AnimeVideo episode) {
    return stores.putIfAbsent(
      episode.uid,
      () => _FakeProgressStore(
        initial: episode.uid == startUid ? _initialProgress : null,
      ),
    );
  }

  Future<EpisodePlaybackPlan> _resolve(EpisodePlaylist target) async {
    final String uid = target.current.uid;
    resolvedUids.add(uid);
    final Completer<void>? gate = resolveGates[uid];
    if (gate != null) {
      await gate.future;
    }
    if (webOnlyUids.contains(uid)) {
      return const WebPlaybackPlan(WebPlaybackReason.failed);
    }
    final Object? failure = resolveFailures[uid];
    if (failure != null) {
      throw failure;
    }
    final PlayableVideo Function(String uid)? customVideo = videoFor;
    return NativePlaybackPlan(
      customVideo == null ? _videoFor(uid) : customVideo(uid),
    );
  }

  NativePlayerEngine _createEngine(PlayableStream stream) {
    final bool fail = failingInitializations > 0;
    if (fail) {
      failingInitializations--;
    }
    final _FakeEngine engine = _FakeEngine(
      stream,
      failOnInitialize: fail,
      maxSupportedSpeed: maxSupportedSpeed,
      tracks: tracksFor?.call(stream) ?? const <VideoTrack>[],
      supportsVideoTracks: supportsVideoTracks,
      initializeGate: initializeGates[stream.url],
    );
    engines.add(engine);
    return engine;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

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
      playlist: EpisodePlaylist.single(_episode('solo', 'Movie')),
      engineFactory: (PlayableStream stream) => _FakeEngine(stream),
      progressStoreFor: (AnimeVideo episode) => _FakeProgressStore(),
      subtitleLoader: _FakeSubtitleLoader(),
    );

    await cubit.init();

    expect(cubit.state.status, NativePlayerStatus.error);
    await cubit.close();
  });

  group('playback speed', () {
    test('accepts speeds above 2x and remembers them for the next episode',
        () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.setPlaybackSpeed(3.5);

      expect(harness.engines.single.value.playbackSpeed, 3.5);
      expect(cubit.state.playbackSpeed, 3.5);
      await cubit.close();

      final _Harness nextEpisode = _Harness();
      final NativePlayerCubit nextCubit = nextEpisode.build();
      await nextCubit.init();

      expect(nextCubit.state.playbackSpeed, 3.5);
      expect(nextEpisode.engines.single.value.playbackSpeed, 3.5);
      await nextCubit.close();
    });

    test('clamps and snaps requested speeds', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.setPlaybackSpeed(6);
      expect(cubit.state.playbackSpeed, 4.0);

      await cubit.setPlaybackSpeed(0.1);
      expect(cubit.state.playbackSpeed, 0.25);

      await cubit.setPlaybackSpeed(1.33);
      expect(cubit.state.playbackSpeed, 1.35);
      expect(harness.engines.single.value.playbackSpeed, 1.35);
      await cubit.close();
    });

    test('keeps a fast speed across quality switches and retries', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(3.0);

      await cubit.selectQuality(1);
      expect(harness.engines.last.value.playbackSpeed, 3.0);

      harness.engines.last.failPlayback('decoder crashed');
      await cubit.retry();
      expect(harness.engines.last.value.playbackSpeed, 3.0);
      expect(cubit.state.playbackSpeed, 3.0);
      await cubit.close();
    });

    test('a rejected speed falls back and is not remembered', () async {
      final _Harness harness = _Harness(maxSupportedSpeed: 2.0);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(1.5);

      await cubit.setPlaybackSpeed(3.0);

      expect(cubit.state.playbackSpeed, 1.5);
      expect(cubit.state.speedRejections, 1);
      expect(harness.engines.single.value.playbackSpeed, 1.5);
      expect(await PlayerPreferences().getPlaybackSpeed(), 1.5);
      await cubit.close();
    });

    test('a remembered speed the engine rejects resets to normal', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.playbackSpeedKey: 3.0,
      });
      final _Harness harness = _Harness(maxSupportedSpeed: 2.0);
      final NativePlayerCubit cubit = harness.build();

      await cubit.init();

      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(cubit.state.playbackSpeed, 1.0);
      expect(cubit.state.speedRejections, 1);
      await cubit.close();
    });
  });

  group('hold to speed up', () {
    test('plays at the hold speed and restores the previous speed', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(1.25);

      await cubit.startHoldSpeed();

      expect(cubit.state.holdActive, isTrue);
      expect(harness.engines.single.value.playbackSpeed, 2.0);

      await cubit.endHoldSpeed();

      expect(cubit.state.holdActive, isFalse);
      expect(harness.engines.single.value.playbackSpeed, 1.25);
      expect(await PlayerPreferences().getPlaybackSpeed(), 1.25);
      await cubit.close();
    });

    test('uses the configured hold speed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.holdSpeedKey: 4.0,
      });
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.startHoldSpeed();

      expect(harness.engines.single.value.playbackSpeed, 4.0);
      await cubit.close();
    });

    test('a speed picked while holding applies on release', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.startHoldSpeed();

      await cubit.setPlaybackSpeed(1.5);
      expect(harness.engines.single.value.playbackSpeed, 2.0);

      await cubit.endHoldSpeed();
      expect(harness.engines.single.value.playbackSpeed, 1.5);
      await cubit.close();
    });

    test('never slows down when already faster than the hold speed',
        () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(2.5);

      await cubit.startHoldSpeed();

      expect(cubit.state.holdActive, isTrue);
      expect(cubit.state.activeHoldSpeed, 3.75);
      expect(cubit.state.displayedHoldSpeed, 3.75);
      expect(harness.engines.single.value.playbackSpeed, 3.75);

      await cubit.endHoldSpeed();

      expect(cubit.state.activeHoldSpeed, isNull);
      expect(harness.engines.single.value.playbackSpeed, 2.5);
      await cubit.close();
    });

    test('does nothing at the maximum speed', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(4.0);
      final int speedChanges = harness.engines.single.speeds.length;

      await cubit.startHoldSpeed();

      expect(cubit.state.holdActive, isFalse);
      expect(harness.engines.single.speeds, hasLength(speedChanges));
      await cubit.close();
    });

    test('a faster speed picked while holding raises the hold speed',
        () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.startHoldSpeed();
      expect(harness.engines.single.value.playbackSpeed, 2.0);

      await cubit.setPlaybackSpeed(3.0);

      expect(cubit.state.activeHoldSpeed, 4.0);
      expect(harness.engines.single.value.playbackSpeed, 4.0);

      await cubit.endHoldSpeed();

      expect(harness.engines.single.value.playbackSpeed, 3.0);
      await cubit.close();
    });

    test('does nothing while paused', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.togglePlayPause();

      await cubit.startHoldSpeed();

      expect(cubit.state.holdActive, isFalse);
      expect(harness.engines.single.speeds, isEmpty);
      await cubit.close();
    });
  });

  group('remembered tracks', () {
    test('opens the remembered quality first', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectQuality(1);
      await cubit.close();

      final _Harness nextEpisode = _Harness();
      final NativePlayerCubit nextCubit = nextEpisode.build();
      await nextCubit.init();

      expect(nextCubit.state.streamIndex, 1);
      expect(nextEpisode.engines.single.stream.quality, '720p');
      await nextCubit.close();
    });

    test('auto-selects the remembered subtitle language', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectSubtitle(0);
      await cubit.close();

      expect(
        await PlayerPreferences().getSubtitle(),
        const SubtitlePreference.language('en'),
      );

      final _Harness nextEpisode = _Harness();
      final NativePlayerCubit nextCubit = nextEpisode.build();
      await nextCubit.init();

      expect(nextCubit.state.subtitleIndex, 0);
      expect(nextEpisode.engines.single.captionFile, isNotNull);
      await nextCubit.close();
    });

    test('remembers turning subtitles off', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.subtitleKey: 'language:en',
      });
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      expect(cubit.state.subtitleIndex, 0);

      await cubit.selectSubtitle(null);
      await cubit.close();

      final _Harness nextEpisode = _Harness();
      final NativePlayerCubit nextCubit = nextEpisode.build();
      await nextCubit.init();

      expect(nextCubit.state.subtitleIndex, isNull);
      expect(nextEpisode.engines.single.captionFile, isNull);
      await nextCubit.close();
    });
  });

  group('auto-play next episode', () {
    test('counts down after the episode ends and then switches in place',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      harness.engines.single.complete();

      expect(cubit.state.autoNextSecondsLeft, kAutoNextCountdownSeconds);
      for (int tick = 1; tick < kAutoNextCountdownSeconds; tick++) {
        await cubit.tickAutoNext();
        expect(
          cubit.state.autoNextSecondsLeft,
          kAutoNextCountdownSeconds - tick,
        );
      }
      expect(harness.resolvedUids, isEmpty);

      await cubit.tickAutoNext();

      expect(cubit.state.autoNextSecondsLeft, isNull);
      expect(harness.resolvedUids, <String>['a2']);
      expect(cubit.state.playlist.current.uid, 'a2');
      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(harness.engines.last.stream.url, 'https://cdn.test/a2/1080.m3u8');
      await cubit.close();
    });

    test('play now skips the rest of the countdown', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      harness.engines.single.complete();

      await cubit.playNextNow();

      expect(cubit.state.autoNextSecondsLeft, isNull);
      expect(cubit.state.playlist.current.uid, 'a2');
      await cubit.close();
    });

    test('cancel stops the countdown', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      harness.engines.single.complete();

      cubit.cancelAutoNext();
      await cubit.tickAutoNext();

      expect(cubit.state.autoNextSecondsLeft, isNull);
      expect(harness.resolvedUids, isEmpty);
      expect(cubit.state.playlist.current.uid, 'a1');
      await cubit.close();
    });

    test('seeking back after the end clears the countdown', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      harness.engines.single.complete();

      await cubit.seekTo(const Duration(minutes: 20));

      expect(cubit.state.autoNextSecondsLeft, isNull);

      harness.engines.single.complete();
      expect(cubit.state.autoNextSecondsLeft, kAutoNextCountdownSeconds);
      await cubit.close();
    });

    test('stays put when disabled, on the last episode or without a playlist',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.autoPlayNextKey: false,
      });
      final _Harness disabled = _Harness(hasNextEpisode: true);
      final NativePlayerCubit disabledCubit = disabled.build();
      await disabledCubit.init();
      disabled.engines.single.complete();
      expect(disabledCubit.state.autoNextSecondsLeft, isNull);
      await disabledCubit.close();

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final _Harness lastEpisode =
          _Harness(hasNextEpisode: true, startUid: 'a3');
      final NativePlayerCubit lastCubit = lastEpisode.build();
      await lastCubit.init();
      lastEpisode.engines.single.complete();
      expect(lastCubit.state.autoNextSecondsLeft, isNull);
      await lastCubit.close();

      final _Harness noPlaylist = _Harness();
      final NativePlayerCubit noPlaylistCubit = noPlaylist.build();
      await noPlaylistCubit.init();
      noPlaylist.engines.single.complete();
      expect(noPlaylistCubit.state.autoNextSecondsLeft, isNull);
      expect(noPlaylistCubit.hasNextEpisode, isFalse);
      await noPlaylistCubit.close();
    });
  });

  group('switching episodes in place', () {
    test('saves progress for the old episode before loading the new one',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      final _FakeEngine firstEngine = harness.engines.single;
      await cubit.seekTo(const Duration(minutes: 7));

      await cubit.playNext();

      expect(
        harness.stores['a1']!.saved.last,
        const EpisodeProgress(watchedSeconds: 420, totalSeconds: 1440),
      );
      expect(firstEngine.disposed, isTrue);
      expect(harness.stores['a2']!.saved, isEmpty);
      expect(cubit.state.playlist.current.uid, 'a2');
      expect(
        cubit.state.watchedEpisodeUids,
        containsAll(<String>['a1', 'a2']),
      );
      await cubit.close();
    });

    test('shows the loading state while the next episode resolves', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      final List<NativePlayerState> states = <NativePlayerState>[];
      final StreamSubscription<NativePlayerState> subscription =
          cubit.stream.listen(states.add);

      await cubit.playNext();
      await subscription.cancel();

      final NativePlayerState loading = states.firstWhere(
        (NativePlayerState state) =>
            state.status == NativePlayerStatus.loading,
      );
      expect(loading.playlist.current.uid, 'a2');
      expect(loading.engine, isNull);
      await cubit.close();
    });

    test('reapplies the remembered speed, quality, subtitle and fit', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(1.5);
      await cubit.selectQuality(1);
      await cubit.selectSubtitle(0);
      await cubit.setFitMode(PlayerFitMode.fill);

      await cubit.playNext();

      final _FakeEngine engine = harness.engines.last;
      expect(engine.stream.url, 'https://cdn.test/a2/720.mp4');
      expect(engine.value.playbackSpeed, 1.5);
      expect(engine.captionFile, isNotNull);
      expect(cubit.state.streamIndex, 1);
      expect(cubit.state.subtitleIndex, 0);
      expect(cubit.state.fitMode, PlayerFitMode.fill);
      expect(cubit.video.streams.first.url, 'https://cdn.test/a2/1080.m3u8');
      await cubit.close();
    });

    test('resumes the new episode from its own saved progress', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      harness.stores['a2'] = _FakeProgressStore(
        initial: const EpisodeProgress(watchedSeconds: 300, totalSeconds: 1440),
      );

      await cubit.playNext();

      expect(harness.engines.last.seeks, <Duration>[
        const Duration(minutes: 5),
      ]);
      await cubit.close();
    });

    test('previous follows the episode numbers and stops at the first',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true, startUid: 'a2');
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.hasPreviousEpisode, isTrue);
      await cubit.playPrevious();
      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.hasPreviousEpisode, isFalse);
      await cubit.close();
    });

    test('changing the dub keeps the episode number', () async {
      final _Harness harness = _Harness(hasNextEpisode: true, startUid: 'a2');
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.selectGroup(1);

      expect(cubit.state.playlist.groupIndex, 1);
      expect(cubit.state.playlist.current.uid, 'b2');
      expect(harness.resolvedUids, <String>['b2']);
      await cubit.close();
    });

    test('an episode the native player cannot play asks for the web player',
        () async {
      final _Harness harness = _Harness(
        hasNextEpisode: true,
        webOnlyUids: <String>{'a2'},
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.seekTo(const Duration(minutes: 3));

      await cubit.playNext();

      final OpenInWebPlayer? request = cubit.state.webPlayerRequest;
      expect(request, isNotNull);
      expect(request!.position.current.uid, 'a2');
      expect(request.showFallbackNotice, isTrue);
      expect(harness.stores['a1']!.saved.last.watchedSeconds, 180);
      expect(harness.engines, hasLength(1));
      await cubit.close();
    });

    test('a typed source error stops on the episode and retries it',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      harness.resolveFailures['a2'] =
          const SourceError(SourceErrorKind.loginRequired, 'session expired');
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.playNext();

      expect(cubit.state.status, NativePlayerStatus.error);
      expect(cubit.state.sourceError?.kind, SourceErrorKind.loginRequired);
      expect(cubit.state.webPlayerRequest, isNull);
      expect(cubit.state.switchingEpisode, isFalse);
      expect(cubit.state.playlist.current.uid, 'a2');

      harness.resolveFailures.remove('a2');
      await cubit.retry();

      expect(harness.resolvedUids, <String>['a2', 'a2']);
      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(cubit.state.sourceError, isNull);
      expect(harness.engines.last.stream.url, contains('/a2/'));
      await cubit.close();
    });

    test('an unsupported source error hands the episode to the web player',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      harness.resolveFailures['a2'] =
          const SourceError(SourceErrorKind.unsupported);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.playNext();

      final OpenInWebPlayer? request = cubit.state.webPlayerRequest;
      expect(request?.sourceError?.kind, SourceErrorKind.unsupported);
      expect(request?.showFallbackNotice, isTrue);
      await cubit.close();
    });

    test('a newer switch wins over a slower one', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      final Future<void> first = cubit.playNext();
      final Future<void> second = cubit.selectEpisode(_groups[0].elements[2]);
      await Future.wait(<Future<void>>[first, second]);

      expect(cubit.state.playlist.current.uid, 'a3');
      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(harness.engines.last.stream.url, contains('/a3/'));
      await cubit.close();
    });

    test('does nothing without a resolver', () async {
      final _Harness harness = _Harness();
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.playNext();

      expect(cubit.state.playlist.current.uid, 'a1');
      expect(harness.engines, hasLength(1));
      await cubit.close();
    });
  });

  group('cancelling an episode switch', () {
    test('back while the next episode resolves resumes the previous one',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      final _FakeEngine firstEngine = harness.engines.single;
      await cubit.seekTo(const Duration(minutes: 7));
      final Completer<void> resolving = Completer<void>();
      harness.resolveGates['a2'] = resolving;

      final Future<void> switching = cubit.playNext();
      await pumpEventQueue();

      expect(cubit.state.switchingEpisode, isTrue);
      expect(cubit.state.status, NativePlayerStatus.loading);
      expect(cubit.state.playlist.current.uid, 'a2');
      expect(firstEngine.value.isPlaying, isFalse);
      expect(firstEngine.disposed, isFalse);

      expect(await cubit.cancelSwitch(), isTrue);

      expect(cubit.state.switchingEpisode, isFalse);
      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.state.engine, same(firstEngine));
      expect(firstEngine.value.position, const Duration(minutes: 7));
      expect(firstEngine.value.isPlaying, isTrue);
      expect(cubit.state.isPlaying, isTrue);
      expect(cubit.state.watchedEpisodeUids, isNot(contains('a2')));

      resolving.complete();
      await switching;
      await pumpEventQueue();

      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.state.engine, same(firstEngine));
      expect(harness.engines, hasLength(1));
      expect(harness.stores['a2'], isNull);
      expect(firstEngine.disposed, isFalse);

      await cubit.seekTo(const Duration(minutes: 9));
      await cubit.close();
      expect(
        harness.stores['a1']!.saved.last,
        const EpisodeProgress(watchedSeconds: 540, totalSeconds: 1440),
      );
      expect(firstEngine.disposed, isTrue);
    });

    test('the previous episode keeps its stream, rendition, speed and subtitle',
        () async {
      final _Harness harness = _Harness(
        hasNextEpisode: true,
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.setPlaybackSpeed(1.5);
      await cubit.selectQuality(1);
      await cubit.selectRendition(cubit.state.renditions[1]);
      final _FakeEngine previousEngine = harness.engines.last;
      final Completer<void> resolving = Completer<void>();
      harness.resolveGates['a2'] = resolving;

      final Future<void> switching = cubit.playNext();
      await pumpEventQueue();
      await cubit.cancelSwitch();
      resolving.complete();
      await switching;

      expect(cubit.state.engine, same(previousEngine));
      expect(cubit.state.streamIndex, 1);
      expect(cubit.state.renditions, hasLength(3));
      expect(cubit.state.selectedRenditionId, '0_1');
      expect(cubit.state.playbackSpeed, 1.5);
      expect(previousEngine.value.playbackSpeed, 1.5);
      expect(cubit.video.streams.first.url, 'https://cdn.test/a1/h265.m3u8');
      await cubit.close();
    });

    test('the previous episode keeps its subtitle', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectSubtitle(0);
      final Completer<void> resolving = Completer<void>();
      harness.resolveGates['a2'] = resolving;

      final Future<void> switching = cubit.playNext();
      await pumpEventQueue();
      await cubit.cancelSwitch();
      resolving.complete();
      await switching;

      expect(cubit.state.subtitleIndex, 0);
      expect(harness.engines.single.captionFile, isNotNull);
      await cubit.close();
    });

    test('cancelling while the new engine opens disposes it', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      final _FakeEngine firstEngine = harness.engines.single;
      final Completer<void> opening = Completer<void>();
      harness.initializeGates['https://cdn.test/a2/1080.m3u8'] = opening;

      final Future<void> switching = cubit.playNext();
      await pumpEventQueue();
      expect(harness.engines, hasLength(2));
      final _FakeEngine abandonedEngine = harness.engines.last;

      await cubit.cancelSwitch();
      opening.complete();
      await switching;
      await pumpEventQueue();

      expect(abandonedEngine.disposed, isTrue);
      expect(firstEngine.disposed, isFalse);
      expect(cubit.state.engine, same(firstEngine));
      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.state.status, NativePlayerStatus.ready);
      await cubit.close();
    });

    test('the auto-next countdown switch can be cancelled', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      final _FakeEngine firstEngine = harness.engines.single;
      final Completer<void> resolving = Completer<void>();
      harness.resolveGates['a2'] = resolving;
      firstEngine.complete();

      final Future<void> switching = cubit.playNextNow();
      await pumpEventQueue();
      expect(cubit.state.switchingEpisode, isTrue);

      await cubit.cancelSwitch();
      resolving.complete();
      await switching;

      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.state.engine, same(firstEngine));
      expect(cubit.state.autoNextSecondsLeft, isNull);
      await cubit.tickAutoNext();
      expect(cubit.state.playlist.current.uid, 'a1');
      expect(harness.resolvedUids, <String>['a2']);
      await cubit.close();
    });

    test('back is not intercepted when no switch is running', () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(await cubit.cancelSwitch(), isFalse);
      expect(cubit.state.switchingEpisode, isFalse);

      await cubit.playNext();

      expect(cubit.state.switchingEpisode, isFalse);
      expect(await cubit.cancelSwitch(), isFalse);
      expect(cubit.state.playlist.current.uid, 'a2');
      await cubit.close();
    });

    test('a switch from a failed episode reopens it from its position',
        () async {
      final _Harness harness = _Harness(hasNextEpisode: true);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.seekTo(const Duration(minutes: 4));
      harness.engines.single.failPlayback('decoder crashed');
      expect(cubit.state.status, NativePlayerStatus.error);
      final Completer<void> resolving = Completer<void>();
      harness.resolveGates['a2'] = resolving;

      final Future<void> switching = cubit.playNext();
      await pumpEventQueue();
      await cubit.cancelSwitch();
      resolving.complete();
      await switching;

      expect(cubit.state.playlist.current.uid, 'a1');
      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(harness.engines, hasLength(2));
      expect(harness.engines.last.stream.url, 'https://cdn.test/1080.m3u8');
      expect(harness.engines.last.value.position, const Duration(minutes: 4));
      await cubit.close();
    });
  });

  test('skip opening jumps by the configured amount', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PlayerPreferences.skipOpeningSecondsKey: 90,
    });
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();
    await cubit.seekTo(const Duration(seconds: 30));

    await cubit.skipOpening();

    expect(
      harness.engines.single.value.position,
      const Duration(seconds: 120),
    );
    await cubit.close();
  });

  group('video renditions', () {
    test('lists the renditions of the current stream after opening', () async {
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(
        cubit.state.renditions.map((PlayerRendition rendition) => rendition.height),
        <int>[1080, 720, 480],
      );
      expect(cubit.state.selectedRenditionId, isNull);
      expect(harness.engines.single.trackSelections, isEmpty);
      await cubit.close();
    });

    test('selecting a rendition switches in place and keeps playback',
        () async {
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.seekTo(const Duration(minutes: 3));

      await cubit.selectRendition(cubit.state.renditions[1]);

      final _FakeEngine engine = harness.engines.single;
      expect(engine.trackSelections.single?.id, '0_1');
      expect(engine.value.position, const Duration(minutes: 3));
      expect(engine.value.isPlaying, isTrue);
      expect(cubit.state.selectedRenditionId, '0_1');
      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(renditionLabel: '720p'),
      );
      await cubit.close();
    });

    test('auto clears the manual rendition', () async {
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectRendition(cubit.state.renditions.first);

      await cubit.selectQualityOption(
        const QualityOption.auto(streamIndex: 0, label: 'Auto'),
      );

      expect(harness.engines.single.trackSelections.last, isNull);
      expect(cubit.state.selectedRenditionId, isNull);
      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(renditionLabel: kAutoQualityLabel),
      );
      await cubit.close();
    });

    test('remembers the stream together with the rendition picked inside it',
        () async {
      final _Harness harness = _Harness(
        hasNextEpisode: true,
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectQuality(1);
      await cubit.selectRendition(cubit.state.renditions[1]);

      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(
          streamLabel: 'Auto (H.264)',
          renditionLabel: '720p',
        ),
      );

      await cubit.playNext();

      final _FakeEngine engine = harness.engines.last;
      expect(engine.stream.url, 'https://cdn.test/a2/h264.m3u8');
      expect(cubit.state.streamIndex, 1);
      expect(engine.trackSelections.single?.id, '0_1');
      expect(cubit.state.selectedRenditionId, '0_1');
      await cubit.close();
    });

    test('a new player opens the remembered stream and rendition', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.qualityStreamKey: 'Auto (H.264)',
        PlayerPreferences.qualityRenditionKey: '900p',
        PlayerPreferences.legacyQualityKey: '1080p',
      });
      final _Harness harness = _Harness(
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.streamIndex, 1);
      expect(cubit.state.selectedRenditionId, '0_1');
      await cubit.close();
    });

    test('a remembered Auto rendition keeps the remembered stream adaptive',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.qualityStreamKey: 'Auto (H.264)',
        PlayerPreferences.qualityRenditionKey: kAutoQualityLabel,
      });
      final _Harness harness = _Harness(
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.streamIndex, 1);
      expect(harness.engines.single.trackSelections, isEmpty);
      expect(cubit.state.selectedRenditionId, isNull);
      await cubit.close();
    });

    test('picking a stream resets the remembered rendition to Auto', () async {
      final _Harness harness = _Harness(
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectRendition(cubit.state.renditions.last);

      await cubit.selectQuality(1);

      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(
          streamLabel: 'Auto (H.264)',
          renditionLabel: kAutoQualityLabel,
        ),
      );
      await cubit.close();
    });

    test('a legacy stream label opens that stream adaptively', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: 'Auto (H.264)',
      });
      final _Harness harness = _Harness(
        videoFor: _codecStreamsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.streamIndex, 1);
      expect(harness.engines.single.trackSelections, isEmpty);
      await cubit.close();
    });

    test('a single-stream source keeps the remembered stream label', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.qualityStreamKey: 'Auto (H.264)',
        PlayerPreferences.qualityRenditionKey: kAutoQualityLabel,
      });
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      await cubit.selectRendition(cubit.state.renditions.last);

      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(
          streamLabel: 'Auto (H.264)',
          renditionLabel: '480p',
        ),
      );
      await cubit.close();
    });

    test('opens the remembered rendition', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '720p',
      });
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(harness.engines.single.trackSelections.single?.id, '0_1');
      expect(cubit.state.selectedRenditionId, '0_1');
      await cubit.close();
    });

    test('falls back to the closest lower rendition', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '900p',
      });
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.selectedRenditionId, '0_1');
      await cubit.close();
    });

    test('a remembered Auto stays adaptive', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: 'Auto',
      });
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(harness.engines.single.trackSelections, isEmpty);
      expect(cubit.state.selectedRenditionId, isNull);
      await cubit.close();
    });

    test('a remembered stream label keeps that stream adaptive', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '1080p',
      });
      final _Harness harness = _Harness(tracksFor: _ladder);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.streamIndex, 0);
      expect(cubit.state.renditions, hasLength(3));
      expect(harness.engines.single.trackSelections, isEmpty);
      await cubit.close();
    });

    test('switching stream re-reads the tracks of the new stream', () async {
      final _Harness harness = _Harness(tracksFor: _ladder);
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      expect(cubit.state.renditions, hasLength(3));

      await cubit.selectQualityOption(
        const QualityOption.stream(streamIndex: 1, label: '720p'),
      );

      expect(harness.engines, hasLength(2));
      expect(harness.engines.last.trackReads, 1);
      expect(cubit.state.streamIndex, 1);
      expect(cubit.state.renditions, isEmpty);
      await cubit.close();
    });

    test('re-applies the rendition after an in-place episode switch',
        () async {
      final _Harness harness = _Harness(
        hasNextEpisode: true,
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectRendition(cubit.state.renditions.last);

      await cubit.playNext();

      final _FakeEngine engine = harness.engines.last;
      expect(engine.stream.url, 'https://cdn.test/a2/master.m3u8');
      expect(engine.trackSelections.single?.id, '0_2');
      expect(cubit.state.selectedRenditionId, '0_2');
      await cubit.close();
    });

    test('re-applies the rendition after a retry', () async {
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();
      await cubit.selectRendition(cubit.state.renditions.first);

      await cubit.retry();

      expect(harness.engines, hasLength(2));
      expect(harness.engines.last.trackSelections.single?.id, '0_0');
      expect(cubit.state.selectedRenditionId, '0_0');
      await cubit.close();
    });

    test('without track support nothing is read or selected', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '720p',
      });
      final _Harness harness = _Harness(
        videoFor: _singleHlsVideo,
        tracksFor: _ladder,
        supportsVideoTracks: false,
      );
      final NativePlayerCubit cubit = harness.build();
      await cubit.init();

      expect(cubit.state.status, NativePlayerStatus.ready);
      expect(cubit.state.renditions, isEmpty);
      expect(harness.engines.single.trackReads, 0);
      expect(harness.engines.single.trackSelections, isEmpty);
      await cubit.close();
    });
  });

  test('fit mode cycles and is remembered', () async {
    final _Harness harness = _Harness();
    final NativePlayerCubit cubit = harness.build();
    await cubit.init();

    await cubit.cycleFitMode();
    expect(cubit.state.fitMode, PlayerFitMode.fill);
    await cubit.cycleFitMode();
    expect(cubit.state.fitMode, PlayerFitMode.stretch);
    await cubit.close();

    final NativePlayerCubit nextCubit = _Harness().build();
    await nextCubit.init();
    expect(nextCubit.state.fitMode, PlayerFitMode.stretch);
    await nextCubit.close();
  });
}
