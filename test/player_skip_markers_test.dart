import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_skip_marker.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_mapper.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_track_selection.dart';
import 'package:wakaranai/ui/services/anime/native_player/skip_markers.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

const Duration _episodeLength = Duration(minutes: 24);

const PlayableSkipMarker _intro = PlayableSkipMarker(
  type: PlayableSkipType.intro,
  start: Duration(seconds: 0),
  end: Duration(seconds: 90),
);

const PlayableSkipMarker _recap = PlayableSkipMarker(
  type: PlayableSkipType.recap,
  start: Duration(seconds: 0),
  end: Duration(seconds: 30),
);

const PlayableSkipMarker _outro = PlayableSkipMarker(
  type: PlayableSkipType.outro,
  start: Duration(minutes: 22),
  end: Duration(minutes: 23, seconds: 30),
);

class _FakeEngine extends ValueNotifier<VideoPlayerValue>
    implements NativePlayerEngine {
  _FakeEngine(this.stream) : super(const VideoPlayerValue.uninitialized());

  final PlayableStream stream;
  final List<Duration> seeks = <Duration>[];

  @override
  Future<void> initialize() async {
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
    value = value.copyWith(position: position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> setClosedCaptionFile(ClosedCaptionFile? captionFile) async {}

  @override
  bool get supportsVideoTracks => false;

  @override
  Future<List<VideoTrack>> getVideoTracks() async => const <VideoTrack>[];

  @override
  Future<void> selectVideoTrack(VideoTrack? track) async {}

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget buildView() => const SizedBox.shrink();

  void playAt(Duration position) {
    value = value.copyWith(position: position, isPlaying: true);
  }
}

class _MemoryProgressStore implements EpisodeProgressStore {
  @override
  Future<EpisodeProgress?> start() async => null;

  @override
  Future<void> save(EpisodeProgress progress) async {}
}

class _NoSubtitles implements SubtitleLoader {
  @override
  Future<ClosedCaptionFile> load(PlayableSubtitle subtitle) {
    throw UnimplementedError();
  }
}

const AnimeVideo _episode = AnimeVideo(
  type: AnimeVideoType.IFRAME,
  uid: 'e1',
  src: 'https://player.test/e1',
  title: 'Episode 1',
  timestamp: null,
  data: <String, dynamic>{},
);

class _Player {
  _Player(this.video);

  final PlayableVideo video;
  final List<_FakeEngine> engines = <_FakeEngine>[];

  _FakeEngine get engine => engines.last;

  NativePlayerCubit build() {
    return NativePlayerCubit(
      video: video,
      playlist: EpisodePlaylist(
        groups: const <AnimeVideoGroup>[
          AnimeVideoGroup(title: 'Main', elements: <AnimeVideo>[_episode]),
        ],
        groupIndex: 0,
        current: _episode,
      ),
      engineFactory: (PlayableStream stream) {
        final _FakeEngine created = _FakeEngine(stream);
        engines.add(created);
        return created;
      },
      progressStoreFor: (AnimeVideo episode) => _MemoryProgressStore(),
      subtitleLoader: _NoSubtitles(),
      preferences: PlayerPreferences(),
      progressSaveInterval: const Duration(hours: 1),
      autoNextTick: const Duration(hours: 1),
    );
  }
}

PlayableVideo _markedVideo() {
  return const PlayableVideo(
    streams: <PlayableStream>[
      PlayableStream(
        url: 'https://cdn.test/1080.m3u8',
        quality: '1080p',
        skipMarkers: <PlayableSkipMarker>[_recap, _intro, _outro],
      ),
    ],
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

String _fallback(int index) => 'Source ${index + 1}';

void main() {
  group('skip marker windows', () {
    const List<PlayableSkipMarker> markers = <PlayableSkipMarker>[
      _recap,
      _intro,
      _outro,
    ];

    test('a marker is active from its start up to but not including its end',
        () {
      expect(activeSkipMarker(<PlayableSkipMarker>[_outro], _outro.start),
          _outro);
      expect(
        activeSkipMarker(
          <PlayableSkipMarker>[_outro],
          _outro.end - const Duration(milliseconds: 1),
        ),
        _outro,
      );
      expect(activeSkipMarker(<PlayableSkipMarker>[_outro], _outro.end),
          isNull);
      expect(
        activeSkipMarker(<PlayableSkipMarker>[_outro], const Duration(minutes: 5)),
        isNull,
      );
    });

    test('overlapping markers resolve to the one reaching furthest', () {
      expect(activeSkipMarker(markers, const Duration(seconds: 10)), _intro);
      expect(activeSkipMarker(markers, const Duration(seconds: 45)), _intro);
    });

    test('normalizing drops empty windows, clamps and sorts', () {
      final List<PlayableSkipMarker> normalized =
          normalizeSkipMarkers(<PlayableSkipMarker>[
        _outro,
        const PlayableSkipMarker(
          type: PlayableSkipType.recap,
          start: Duration(seconds: 50),
          end: Duration(seconds: 50),
        ),
        const PlayableSkipMarker(
          type: PlayableSkipType.intro,
          start: Duration(seconds: -5),
          end: Duration(seconds: 90),
        ),
        _intro,
      ]);

      expect(normalized, <PlayableSkipMarker>[_intro, _outro]);
    });

    test('source markers map from seconds and invalid ones are dropped', () {
      final List<PlayableSkipMarker> mapped =
          playableSkipMarkersFrom(const <AnimeSkipMarker>[
        AnimeSkipMarker(type: AnimeSkipType.outro, start: 1320, end: 1410),
        AnimeSkipMarker(type: AnimeSkipType.intro, start: 1.5, end: 89.25),
        AnimeSkipMarker(type: AnimeSkipType.recap, start: 30, end: 10),
      ]);

      expect(mapped, const <PlayableSkipMarker>[
        PlayableSkipMarker(
          type: PlayableSkipType.intro,
          start: Duration(milliseconds: 1500),
          end: Duration(milliseconds: 89250),
        ),
        PlayableSkipMarker(
          type: PlayableSkipType.outro,
          start: Duration(seconds: 1320),
          end: Duration(seconds: 1410),
        ),
      ]);
    });

    test('video sources carry markers, audio labels and download preference',
        () {
      final PlayableVideo video = playableVideoFromSources(
        const <AnimeVideoSource>[
          AnimeVideoSource(
            url: 'https://cdn.test/dub.m3u8',
            quality: '1080p',
            audioLabel: ' Studio Dub ',
            preferForDownload: true,
            skip: <AnimeSkipMarker>[
              AnimeSkipMarker(type: AnimeSkipType.intro, start: 0, end: 90),
            ],
          ),
          AnimeVideoSource(url: 'https://cdn.test/sub.m3u8', quality: '1080p'),
        ],
      );

      expect(video.streams.first.audioLabel, 'Studio Dub');
      expect(video.streams.first.preferForDownload, isTrue);
      expect(video.streams.first.skipMarkers, <PlayableSkipMarker>[_intro]);
      expect(video.streams.last.audioLabel, isNull);
      expect(video.streams.last.preferForDownload, isFalse);
      expect(video.streams.last.skipMarkers, isEmpty);
    });
  });

  group('auto-skip tracker', () {
    const List<PlayableSkipMarker> markers = <PlayableSkipMarker>[
      _recap,
      _intro,
      _outro,
    ];

    test('skips each intro and outro once per playback', () {
      final SkipMarkerTracker tracker = SkipMarkerTracker();

      expect(tracker.takeAutoSkip(markers, const Duration(seconds: 2)), _intro);
      expect(tracker.takeAutoSkip(markers, const Duration(seconds: 3)), isNull);
      expect(tracker.takeAutoSkip(markers, const Duration(minutes: 22)), _outro);
      expect(tracker.takeAutoSkip(markers, const Duration(minutes: 22)), isNull);

      tracker.reset();
      expect(tracker.takeAutoSkip(markers, const Duration(seconds: 2)), _intro);
    });

    test('never auto-skips a recap', () {
      final SkipMarkerTracker tracker = SkipMarkerTracker();

      expect(
        tracker.takeAutoSkip(
          <PlayableSkipMarker>[_recap],
          const Duration(seconds: 5),
        ),
        isNull,
      );
    });

    test('seeking back into a marker keeps it from auto-skipping', () {
      final SkipMarkerTracker tracker = SkipMarkerTracker();

      tracker.noteUserSeek(markers, const Duration(minutes: 22, seconds: 10));

      expect(tracker.takeAutoSkip(markers, const Duration(minutes: 22, seconds: 11)),
          isNull);
      expect(tracker.takeAutoSkip(markers, const Duration(seconds: 1)), _intro);
    });
  });

  group('source labels', () {
    test('append the audio label to the quality', () {
      expect(
        streamLabelsFor(
          const <PlayableStream>[
            PlayableStream(
              url: 'https://a/1',
              quality: '1080p',
              audioLabel: 'Studio Dub',
            ),
            PlayableStream(url: 'https://a/2', quality: '1080p', audioLabel: 'Sub'),
            PlayableStream(url: 'https://a/3', quality: '720p'),
            PlayableStream(url: 'https://a/4', audioLabel: 'Dub'),
            PlayableStream(url: 'https://a/5'),
          ],
          fallback: _fallback,
        ),
        <String>[
          '1080p · Studio Dub',
          '1080p · Sub',
          '720p',
          'Dub',
          'Source 5',
        ],
      );
    });

    test('number sources that would otherwise look the same', () {
      expect(
        streamLabelsFor(
          const <PlayableStream>[
            PlayableStream(url: 'https://a/1', quality: '1080p', audioLabel: 'Dub'),
            PlayableStream(url: 'https://a/2', quality: '1080p', audioLabel: 'Dub'),
            PlayableStream(url: 'https://a/3', quality: '720p'),
          ],
          fallback: _fallback,
        ),
        <String>['1080p · Dub (1)', '1080p · Dub (2)', '720p'],
      );
    });

    test('remembered quality prefers the remembered audio', () {
      const List<PlayableStream> streams = <PlayableStream>[
        PlayableStream(url: 'https://a/1', quality: '1080p', audioLabel: 'Sub'),
        PlayableStream(url: 'https://a/2', quality: '720p', audioLabel: 'Dub'),
        PlayableStream(url: 'https://a/3', quality: '1080p', audioLabel: 'Dub'),
      ];

      expect(preferredStreamIndex(streams, '1080p', preferredAudio: 'dub'), 2);
      expect(preferredStreamIndex(streams, '480p', preferredAudio: 'Dub'), 1);
      expect(preferredStreamIndex(streams, '720p', preferredAudio: 'Raw'), 1);
      expect(preferredStreamIndex(streams, '1080p'), 0);
      expect(preferredStreamIndex(streams, null), 0);
    });
  });

  group('player', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('skipping a marker seeks to its end', () async {
      final _Player player = _Player(_markedVideo());
      final NativePlayerCubit cubit = player.build();
      await cubit.init();

      expect(cubit.skipMarkers, <PlayableSkipMarker>[_recap, _intro, _outro]);
      await cubit.skipMarker(_intro);

      expect(player.engine.seeks.last, _intro.end);
      await cubit.close();
    });

    test('does not auto-skip when the setting is off', () async {
      final _Player player = _Player(_markedVideo());
      final NativePlayerCubit cubit = player.build();
      await cubit.init();

      player.engine.playAt(const Duration(seconds: 5));
      await _settle();

      expect(player.engine.seeks, isEmpty);
      expect(cubit.state.autoSkipCount, 0);
      await cubit.close();
    });

    test('auto-skips an intro once and not after seeking back into it',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.autoSkipMarkersKey: true,
      });
      final _Player player = _Player(_markedVideo());
      final NativePlayerCubit cubit = player.build();
      await cubit.init();

      player.engine.playAt(const Duration(seconds: 5));
      await _settle();

      expect(player.engine.seeks, <Duration>[_intro.end]);
      expect(cubit.state.autoSkipCount, 1);
      expect(cubit.state.lastAutoSkipType, PlayableSkipType.intro);

      await cubit.seekTo(const Duration(seconds: 40));
      player.engine.playAt(const Duration(seconds: 41));
      await _settle();

      expect(player.engine.seeks, <Duration>[
        _intro.end,
        const Duration(seconds: 40),
      ]);
      expect(cubit.state.autoSkipCount, 1);

      player.engine.playAt(const Duration(minutes: 22, seconds: 1));
      await _settle();

      expect(player.engine.seeks.last, _outro.end);
      expect(cubit.state.autoSkipCount, 2);
      expect(cubit.state.lastAutoSkipType, PlayableSkipType.outro);
      await cubit.close();
    });

    test('a user seek into an unskipped marker does not trigger auto-skip',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.autoSkipMarkersKey: true,
      });
      final _Player player = _Player(_markedVideo());
      final NativePlayerCubit cubit = player.build();
      await cubit.init();

      await cubit.seekTo(const Duration(minutes: 22, seconds: 30));
      player.engine.playAt(const Duration(minutes: 22, seconds: 31));
      await _settle();

      expect(player.engine.seeks, <Duration>[
        const Duration(minutes: 22, seconds: 30),
      ]);
      expect(cubit.state.autoSkipCount, 0);
      await cubit.close();
    });

    test('remembers the audio label of the picked source', () async {
      final _Player player = _Player(const PlayableVideo(
        streams: <PlayableStream>[
          PlayableStream(url: 'https://a/1', quality: '1080p', audioLabel: 'Sub'),
          PlayableStream(url: 'https://a/2', quality: '1080p', audioLabel: 'Dub'),
        ],
      ));
      final NativePlayerCubit cubit = player.build();
      await cubit.init();

      await cubit.selectQuality(1);
      final QualityPreference saved =
          await PlayerPreferences().getQualityPreference();

      expect(saved.streamLabel, '1080p');
      expect(saved.audioLabel, 'Dub');
      expect(saved.renditionLabel, kAutoQualityLabel);
      await cubit.close();

      final _Player next = _Player(const PlayableVideo(
        streams: <PlayableStream>[
          PlayableStream(url: 'https://b/1', quality: '1080p', audioLabel: 'Sub'),
          PlayableStream(url: 'https://b/2', quality: '1080p', audioLabel: 'Dub'),
        ],
      ));
      final NativePlayerCubit nextCubit = next.build();
      await nextCubit.init();

      expect(nextCubit.state.streamIndex, 1);
      await nextCubit.close();
    });
  });
}
