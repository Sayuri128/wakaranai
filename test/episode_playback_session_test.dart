import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_session.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

AnimeVideo _video(String uid) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/$uid',
    title: 'Серія ${uid.substring(1)}',
    timestamp: null,
    data: const <String, dynamic>{},
  );
}

final List<AnimeVideoGroup> _groups = <AnimeVideoGroup>[
  AnimeVideoGroup(
    title: 'Dub A',
    elements: <AnimeVideo>[_video('a1'), _video('a2'), _video('a3')],
  ),
  AnimeVideoGroup(
    title: 'Dub B',
    elements: <AnimeVideo>[_video('b1'), _video('b2'), _video('b3')],
  ),
];

final EpisodePlaylist _start = EpisodePlaylist(
  groups: _groups,
  groupIndex: 0,
  current: _groups[0].elements[0],
);

const PlayableVideo _playable = PlayableVideo(
  streams: <PlayableStream>[PlayableStream(url: 'https://cdn.test/a.m3u8')],
);

EpisodePlaylist _at(int groupIndex, int episodeIndex) {
  return EpisodePlaylist(
    groups: _groups,
    groupIndex: groupIndex,
    current: _groups[groupIndex].elements[episodeIndex],
  );
}

class _Harness {
  final Map<String, EpisodePlaybackPlan?> plans =
      <String, EpisodePlaybackPlan?>{};
  final List<EpisodePlayerResult? Function(EpisodePlaylist position)>
      nativeResults =
      <EpisodePlayerResult? Function(EpisodePlaylist position)>[];
  final List<EpisodePlayerResult?> webResults = <EpisodePlayerResult?>[];
  final List<String> resolved = <String>[];
  final List<String> nativeOpened = <String>[];
  final List<String> webOpened = <String>[];
  final List<bool> webNotices = <bool>[];
  final List<SourceError?> webSourceErrors = <SourceError?>[];
  final List<String> episodesOpened = <String>[];
  final List<SourceErrorKind> reportedErrors = <SourceErrorKind>[];
  final List<bool> sourceErrorAnswers = <bool>[];
  void Function()? onSourceErrorReported;
  bool active = true;
  late final EpisodePlaybackSession session = EpisodePlaybackSession(
    isActive: () => active,
    onEpisodeOpened: (AnimeVideo episode) => episodesOpened.add(episode.uid),
    resolvePlan: _resolvePlan,
    openNativePlayer: _openNative,
    openWebPlayer: _openWeb,
    onSourceError: _onSourceError,
  );

  Future<bool> _onSourceError(
    EpisodePlaylist position,
    SourceError error,
  ) async {
    reportedErrors.add(error.kind);
    onSourceErrorReported?.call();
    if (sourceErrorAnswers.isEmpty) {
      return false;
    }
    return sourceErrorAnswers.removeAt(0);
  }

  Future<EpisodePlaybackPlan?> _resolvePlan(EpisodePlaylist position) async {
    final String uid = position.current.uid;
    resolved.add(uid);
    if (plans.containsKey(uid)) {
      return plans[uid];
    }
    return const NativePlaybackPlan(_playable);
  }

  Future<EpisodePlayerResult?> _openNative(
    EpisodePlaylist position,
    PlayableVideo video,
  ) async {
    nativeOpened.add(position.current.uid);
    if (nativeResults.isEmpty) {
      return null;
    }
    return nativeResults.removeAt(0)(position);
  }

  Future<EpisodePlayerResult?> _openWeb(
    EpisodePlaylist position, {
    required bool showFallbackNotice,
    SourceError? sourceError,
  }) async {
    webOpened.add(position.current.uid);
    webNotices.add(showFallbackNotice);
    webSourceErrors.add(sourceError);
    if (webResults.isEmpty) {
      return null;
    }
    return webResults.removeAt(0);
  }
}

void main() {
  test('a typed source error is reported and ends the session', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const SourceErrorPlaybackPlan(
      SourceError(SourceErrorKind.notFound),
    );

    await harness.session.run(_start);

    expect(harness.reportedErrors, <SourceErrorKind>[SourceErrorKind.notFound]);
    expect(harness.nativeOpened, isEmpty);
    expect(harness.webOpened, isEmpty);
  });

  test('a source error the user retries resolves the episode again',
      () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const SourceErrorPlaybackPlan(
      SourceError(SourceErrorKind.loginRequired),
    );
    harness.sourceErrorAnswers.add(true);
    harness.onSourceErrorReported = () => harness.plans.remove('a1');

    await harness.session.run(_start);

    expect(harness.resolved, <String>['a1', 'a1']);
    expect(harness.nativeOpened, <String>['a1']);
  });

  test('an unsupported source hands its error to the web player', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const WebPlaybackPlan(
      WebPlaybackReason.failed,
      sourceError: SourceError(SourceErrorKind.unsupported),
    );

    await harness.session.run(_start);

    expect(harness.webOpened, <String>['a1']);
    expect(harness.webNotices, <bool>[true]);
    expect(
      harness.webSourceErrors.single?.kind,
      SourceErrorKind.unsupported,
    );
  });

  test('a native episode that is closed ends the session', () async {
    final _Harness harness = _Harness();

    final EpisodePlaylist last = await harness.session.run(_start);

    expect(harness.resolved, <String>['a1']);
    expect(harness.nativeOpened, <String>['a1']);
    expect(harness.webOpened, isEmpty);
    expect(harness.episodesOpened, <String>['a1']);
    expect(last.current.uid, 'a1');
  });

  test('switches made inside the native player are remembered', () async {
    final _Harness harness = _Harness();
    harness.nativeResults.add((EpisodePlaylist position) {
      harness.session.enterEpisode(_at(1, 1));
      return null;
    });

    final EpisodePlaylist last = await harness.session.run(_start);

    expect(last.groupIndex, 1);
    expect(last.current.uid, 'b2');
    expect(harness.episodesOpened, <String>['a1', 'b2']);
  });

  test('the native player can hand an episode to the web player', () async {
    final _Harness harness = _Harness();
    harness.nativeResults.add(
      (EpisodePlaylist position) =>
          OpenInWebPlayer(_at(0, 1), showFallbackNotice: true),
    );

    final EpisodePlaylist last = await harness.session.run(_start);

    expect(harness.webOpened, <String>['a2']);
    expect(harness.webNotices, <bool>[true]);
    expect(harness.resolved, <String>['a1']);
    expect(last.current.uid, 'a2');
  });

  test('an episode picked in the web player goes through the decision again',
      () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const WebPlaybackPlan(WebPlaybackReason.unsupported);
    harness.webResults.add(PlayEpisodeRequested(_at(0, 2)));

    final EpisodePlaylist last = await harness.session.run(_start);

    expect(harness.resolved, <String>['a1', 'a3']);
    expect(harness.webOpened, <String>['a1']);
    expect(harness.webNotices, <bool>[false]);
    expect(harness.nativeOpened, <String>['a3']);
    expect(last.current.uid, 'a3');
  });

  test('a failed lookup opens the web player with a notice', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const WebPlaybackPlan(WebPlaybackReason.timedOut);

    await harness.session.run(_start);

    expect(harness.webNotices, <bool>[true]);
  });

  test('web to web keeps looping until the player is closed', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const WebPlaybackPlan(WebPlaybackReason.noSources);
    harness.plans['a2'] = const WebPlaybackPlan(WebPlaybackReason.noSources);
    harness.webResults
      ..add(PlayEpisodeRequested(_at(0, 1)))
      ..add(null);

    await harness.session.run(_start);

    expect(harness.webOpened, <String>['a1', 'a2']);
    expect(harness.episodesOpened, <String>['a1', 'a2']);
  });

  test('a cancelled lookup opens nothing', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = null;

    await harness.session.run(_start);

    expect(harness.nativeOpened, isEmpty);
    expect(harness.webOpened, isEmpty);
  });

  test('stops once the caller is gone', () async {
    final _Harness harness = _Harness();
    harness.plans['a1'] = const WebPlaybackPlan(WebPlaybackReason.noSources);

    final Future<EpisodePlaylist> running = harness.session.run(_start);
    harness.active = false;
    await running;

    expect(harness.resolved, <String>['a1']);
    expect(harness.webOpened, isEmpty);
    expect(harness.nativeOpened, isEmpty);
  });
}
