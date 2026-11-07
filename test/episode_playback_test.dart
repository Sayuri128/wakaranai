import 'dart:async';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_subtitle.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/anime_episode_launcher.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_mapper.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

AnimeVideo _episode(
  String uid, {
  AnimeVideoType type = AnimeVideoType.IFRAME,
  String src = 'https://player.test/embed',
}) {
  return AnimeVideo(
    type: type,
    uid: uid,
    src: src,
    title: 'Episode $uid',
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
  );
}

class _FakeProvider implements VideoSourceProvider {
  _FakeProvider({
    this.supported = true,
    this.supportCheckFails = false,
    this.sources = const <AnimeVideoSource>[],
    this.failure,
    this.neverCompletes = false,
  });

  final bool supported;
  final bool supportCheckFails;
  final List<AnimeVideoSource> sources;
  final Object? failure;
  final bool neverCompletes;
  int fetchCount = 0;

  @override
  Future<bool> supportsVideoSources() async {
    if (supportCheckFails) {
      throw const FormatException('script syntax error');
    }
    return supported;
  }

  @override
  Future<List<AnimeVideoSource>> getVideoSources(AnimeVideo video) {
    fetchCount++;
    if (neverCompletes) {
      return Completer<List<AnimeVideoSource>>().future;
    }
    final Object? error = failure;
    if (error != null) {
      return Future<List<AnimeVideoSource>>.error(error);
    }
    return Future<List<AnimeVideoSource>>.value(sources);
  }
}

const List<AnimeVideoSource> _twoQualities = <AnimeVideoSource>[
  AnimeVideoSource(
    url: 'https://cdn.test/1080/master.m3u8',
    quality: '1080p',
    format: 'HLS',
    headers: <String, String>{'Referer': 'https://site.test/'},
    subtitles: <AnimeVideoSubtitle>[
      AnimeVideoSubtitle(url: 'https://cdn.test/en.vtt', language: 'en'),
      AnimeVideoSubtitle(
        url: 'https://cdn.test/ru',
        label: 'Русский',
        format: 'srt',
      ),
    ],
  ),
  AnimeVideoSource(
    url: 'https://cdn.test/720.mp4',
    quality: ' ',
    format: 'video/mp4',
    subtitles: <AnimeVideoSubtitle>[
      AnimeVideoSubtitle(url: 'https://cdn.test/en.vtt', language: 'en'),
    ],
  ),
  AnimeVideoSource(url: '   '),
];

Future<EpisodePlaybackPlan> _resolve(
  AnimeVideo episode,
  _FakeProvider provider, {
  VideoPlayerPreference preference = VideoPlayerPreference.auto,
  Duration timeout = kVideoSourcesTimeout,
}) {
  return resolveEpisodePlayback(
    episode: episode,
    provider: provider,
    preference: preference,
    timeout: timeout,
  );
}

void main() {
  group('source mapping', () {
    test('maps every source to a stream and skips blank urls', () {
      final PlayableVideo video = playableVideoFromSources(_twoQualities);

      expect(video.streams, hasLength(2));
      final PlayableStream best = video.streams.first;
      expect(best.url, 'https://cdn.test/1080/master.m3u8');
      expect(best.quality, '1080p');
      expect(best.format, PlayableStreamFormat.hls);
      expect(best.headers, <String, String>{'Referer': 'https://site.test/'});
      final PlayableStream fallback = video.streams.last;
      expect(fallback.quality, isNull);
      expect(fallback.format, PlayableStreamFormat.mp4);
    });

    test('collects subtitles from all sources without duplicates', () {
      final PlayableVideo video = playableVideoFromSources(_twoQualities);

      expect(
        video.subtitles.map((PlayableSubtitle s) => s.url),
        <String>['https://cdn.test/en.vtt', 'https://cdn.test/ru'],
      );
      expect(video.subtitles.first.language, 'en');
      expect(video.subtitles.first.format, PlayableSubtitleFormat.auto);
      expect(video.subtitles.last.label, 'Русский');
      expect(video.subtitles.last.format, PlayableSubtitleFormat.srt);
    });

    test('parses format strings', () {
      expect(parseStreamFormat('m3u8'), PlayableStreamFormat.hls);
      expect(
        parseStreamFormat('application/vnd.apple.mpegurl'),
        PlayableStreamFormat.hls,
      );
      expect(parseStreamFormat('.mpd'), PlayableStreamFormat.dash);
      expect(parseStreamFormat('DASH'), PlayableStreamFormat.dash);
      expect(parseStreamFormat('mp4'), PlayableStreamFormat.mp4);
      expect(parseStreamFormat(null), PlayableStreamFormat.auto);
      expect(parseStreamFormat('flv'), PlayableStreamFormat.auto);
      expect(parseSubtitleFormat('WebVTT'), PlayableSubtitleFormat.vtt);
      expect(parseSubtitleFormat('SubRip'), PlayableSubtitleFormat.srt);
      expect(parseSubtitleFormat('ass'), PlayableSubtitleFormat.auto);
    });

    test('a direct source becomes a single auto stream without headers', () {
      final PlayableVideo video =
          playableVideoFromDirectSource(' https://cdn.test/ep.m3u8 ');

      expect(video.streams.single.url, 'https://cdn.test/ep.m3u8');
      expect(video.streams.single.format, PlayableStreamFormat.auto);
      expect(video.streams.single.headers, isEmpty);
      expect(video.subtitles, isEmpty);
    });
  });

  group('playback decision', () {
    test('web-only preference never asks the script', () async {
      final _FakeProvider provider = _FakeProvider(sources: _twoQualities);

      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1', type: AnimeVideoType.DIRECT),
        provider,
        preference: VideoPlayerPreference.webOnly,
      );

      expect(plan, isA<WebPlaybackPlan>());
      expect(
        (plan as WebPlaybackPlan).reason,
        WebPlaybackReason.webOnlyPreference,
      );
      expect(provider.fetchCount, 0);
    });

    test('a direct episode without script support plays its src', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1', type: AnimeVideoType.DIRECT, src: 'https://cdn.test/a.mp4'),
        _FakeProvider(supported: false),
      );

      expect(plan, isA<NativePlaybackPlan>());
      expect(
        (plan as NativePlaybackPlan).video.streams.single.url,
        'https://cdn.test/a.mp4',
      );
    });

    test('a direct episode prefers the script sources', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1', type: AnimeVideoType.DIRECT),
        _FakeProvider(sources: _twoQualities),
      );

      expect((plan as NativePlaybackPlan).video.streams, hasLength(2));
    });

    test('a direct episode falls back to its src when the script fails',
        () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1', type: AnimeVideoType.DIRECT, src: 'https://cdn.test/a.mp4'),
        _FakeProvider(failure: Exception('boom')),
      );

      expect(
        (plan as NativePlaybackPlan).video.streams.single.url,
        'https://cdn.test/a.mp4',
      );
    });

    test('script sources open the native player', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1'),
        _FakeProvider(sources: _twoQualities),
      );

      expect(plan, isA<NativePlaybackPlan>());
    });

    test('no sources falls back quietly to the web player', () async {
      final EpisodePlaybackPlan plan =
          await _resolve(_episode('1'), _FakeProvider());

      final WebPlaybackPlan web = plan as WebPlaybackPlan;
      expect(web.reason, WebPlaybackReason.noSources);
      expect(web.shouldNotifyUser, isFalse);
    });

    test('only blank sources count as no sources', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1'),
        _FakeProvider(sources: const <AnimeVideoSource>[
          AnimeVideoSource(url: ''),
        ]),
      );

      expect((plan as WebPlaybackPlan).reason, WebPlaybackReason.noSources);
    });

    test('a throwing script falls back with a notice', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1'),
        _FakeProvider(failure: Exception('boom')),
      );

      final WebPlaybackPlan web = plan as WebPlaybackPlan;
      expect(web.reason, WebPlaybackReason.failed);
      expect(web.shouldNotifyUser, isTrue);
    });

    test('a slow script times out and falls back with a notice', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1'),
        _FakeProvider(neverCompletes: true),
        timeout: const Duration(milliseconds: 20),
      );

      final WebPlaybackPlan web = plan as WebPlaybackPlan;
      expect(web.reason, WebPlaybackReason.timedOut);
      expect(web.shouldNotifyUser, isTrue);
    });

    test('no script support uses the web player as before', () async {
      final _FakeProvider provider = _FakeProvider(supported: false);

      final EpisodePlaybackPlan plan = await _resolve(_episode('1'), provider);

      final WebPlaybackPlan web = plan as WebPlaybackPlan;
      expect(web.reason, WebPlaybackReason.unsupported);
      expect(web.shouldNotifyUser, isFalse);
      expect(provider.fetchCount, 0);
    });

    test('a broken support check counts as unsupported', () async {
      final EpisodePlaybackPlan plan = await _resolve(
        _episode('1'),
        _FakeProvider(supportCheckFails: true),
      );

      expect((plan as WebPlaybackPlan).reason, WebPlaybackReason.unsupported);
    });

    test('the loading callback only fires when sources are fetched',
        () async {
      int fetchingCalls = 0;
      await resolveEpisodePlayback(
        episode: _episode('1'),
        provider: _FakeProvider(supported: false),
        preference: VideoPlayerPreference.auto,
        onFetchingSources: () => fetchingCalls++,
      );
      expect(fetchingCalls, 0);

      await resolveEpisodePlayback(
        episode: _episode('1'),
        provider: _FakeProvider(sources: _twoQualities),
        preference: VideoPlayerPreference.auto,
        onFetchingSources: () => fetchingCalls++,
      );
      expect(fetchingCalls, 1);
    });
  });

  group('next episode', () {
    final List<AnimeVideo> episodes = <AnimeVideo>[
      _episode('a'),
      _episode('b'),
      _episode('c'),
    ];

    test('follows the order shown in the list', () {
      expect(nextEpisodeAfter(episodes, 'a')?.uid, 'b');
      expect(nextEpisodeAfter(episodes, 'b')?.uid, 'c');
    });

    test('the last episode has no next one', () {
      expect(nextEpisodeAfter(episodes, 'c'), isNull);
    });

    test('an unknown episode has no next one', () {
      expect(nextEpisodeAfter(episodes, 'zzz'), isNull);
    });
  });

  test('calls on the same owner run one at a time', () async {
    final Object client = Object();
    final List<String> events = <String>[];
    final Completer<void> firstGate = Completer<void>();

    final Future<void> first = runSerializedOn(client, () async {
      events.add('first start');
      await firstGate.future;
      events.add('first end');
    });
    final Future<void> second = runSerializedOn(client, () async {
      events.add('second start');
    });
    await Future<void>.delayed(Duration.zero);
    expect(events, <String>['first start']);

    firstGate.complete();
    await Future.wait(<Future<void>>[first, second]);
    expect(events, <String>['first start', 'first end', 'second start']);
  });

  test('a failed call does not block the next one', () async {
    final Object client = Object();
    final Future<void> failing = runSerializedOn<void>(
      client,
      () async => throw StateError('broken'),
    );
    await expectLater(failing, throwsStateError);

    expect(await runSerializedOn(client, () async => 42), 42);
  });
}
