import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/services/downloads/storage/local_playback_fallback.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';

const PlayableVideo _localVideo = PlayableVideo(
  streams: <PlayableStream>[
    PlayableStream(
      url: 'file:///downloads/e1/index.m3u8',
      format: PlayableStreamFormat.hls,
    ),
  ],
);

const PlayableVideo _remoteVideo = PlayableVideo(
  streams: <PlayableStream>[PlayableStream(url: 'https://cdn.test/e1.m3u8')],
);

DownloadDomain _download(
  String uid, {
  DownloadKind kind = DownloadKind.episode,
}) {
  return DownloadDomain(
    id: 1,
    uid: uid,
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Title',
    title: uid,
    status: DownloadStatus.done,
    downloadedPages: 0,
    totalPages: 0,
    dirPath: '/downloads/$uid',
    kind: kind,
    createdAt: DateTime(2026),
  );
}

class _LocalLookup implements DownloadedEpisodeLookup {
  final List<String> lookedUp = <String>[];

  @override
  Future<PlayableVideo?> playableFor(String episodeUid) async {
    lookedUp.add(episodeUid);
    return _localVideo;
  }

  @override
  Future<Set<String>> finishedEpisodeUidsOf(String concreteUid) async {
    return <String>{'e1'};
  }
}

AnimeVideo _directEpisode() {
  return AnimeVideo(
    type: AnimeVideoType.DIRECT,
    uid: 'e1',
    src: 'https://cdn.test/e1.mp4',
    title: 'Episode 1',
    timestamp: null,
    data: const <String, dynamic>{},
  );
}

AnimeVideo _iframeEpisode() {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: 'e1',
    src: 'https://player.test/e1',
    title: 'Episode 1',
    timestamp: null,
    data: const <String, dynamic>{},
  );
}

void main() {
  group('LocalPlaybackFailures', () {
    test('a failure mark expires after its lifetime', () {
      DateTime now = DateTime(2026, 1, 1, 12);
      final LocalPlaybackFailures failures = LocalPlaybackFailures(
        lifetime: const Duration(minutes: 10),
        clock: () => now,
      )..markFailed('e1');

      now = now.add(const Duration(minutes: 9));
      expect(failures.hasFailed('e1'), isTrue);

      now = now.add(const Duration(minutes: 1));
      expect(failures.hasFailed('e1'), isFalse);
    });

    test('consuming a failure clears it', () {
      final LocalPlaybackFailures failures = LocalPlaybackFailures()
        ..markFailed('e1');

      expect(failures.consumeFailure('e1'), isTrue);
      expect(failures.consumeFailure('e1'), isFalse);
      expect(failures.hasFailed('e1'), isFalse);
    });
  });

  group('localPlaybackErrorAction', () {
    test('streams instead the first time a local file fails', () {
      expect(
        localPlaybackErrorAction(
          video: _localVideo,
          episodeUid: 'e1',
          failures: LocalPlaybackFailures(),
        ),
        LocalPlaybackErrorAction.streamInstead,
      );
    });

    test('shows the error for a stream that is not local', () {
      expect(
        localPlaybackErrorAction(
          video: _remoteVideo,
          episodeUid: 'e1',
          failures: LocalPlaybackFailures(),
        ),
        LocalPlaybackErrorAction.showError,
      );
      expect(
        localPlaybackErrorAction(
          video: const PlayableVideo(streams: <PlayableStream>[]),
          episodeUid: 'e1',
          failures: LocalPlaybackFailures(),
        ),
        LocalPlaybackErrorAction.showError,
      );
    });

    test('shows the error once the episode already fell back', () {
      final LocalPlaybackFailures failures = LocalPlaybackFailures()
        ..markFailed('e1');

      expect(
        localPlaybackErrorAction(
          video: _localVideo,
          episodeUid: 'e1',
          failures: failures,
        ),
        LocalPlaybackErrorAction.showError,
      );
    });
  });

  group('claimStreamingFallback', () {
    test('only claims the fallback once per episode', () {
      final LocalPlaybackFailures failures = LocalPlaybackFailures();

      expect(
        claimStreamingFallback(
          video: _localVideo,
          episodeUid: 'e1',
          failures: failures,
        ),
        isTrue,
      );
      expect(failures.hasFailed('e1'), isTrue);
      expect(
        claimStreamingFallback(
          video: _localVideo,
          episodeUid: 'e1',
          failures: failures,
        ),
        isFalse,
      );
    });

    test('never claims a stream that was not local', () {
      final LocalPlaybackFailures failures = LocalPlaybackFailures();

      expect(
        claimStreamingFallback(
          video: _remoteVideo,
          episodeUid: 'e1',
          failures: failures,
        ),
        isFalse,
      );
      expect(failures.hasFailed('e1'), isFalse);
    });
  });

  group('resolver after a failed download', () {
    test('skips the download and streams the episode', () async {
      final _LocalLookup lookup = _LocalLookup();
      final LocalPlaybackFailures failures = LocalPlaybackFailures()
        ..markFailed('e1');

      final EpisodePlaybackPlan plan = await resolveEpisodePlayback(
        episode: _directEpisode(),
        provider: null,
        preference: VideoPlayerPreference.auto,
        downloadedEpisodes: lookup,
        localPlaybackFailures: failures,
      );

      final PlayableVideo video = (plan as NativePlaybackPlan).video;
      expect(video.streams.single.url, 'https://cdn.test/e1.mp4');
      expect(lookup.lookedUp, isEmpty);
    });

    test('the fallback is used once and the next open tries the download',
        () async {
      final _LocalLookup lookup = _LocalLookup();
      final LocalPlaybackFailures failures = LocalPlaybackFailures()
        ..markFailed('e1');

      final EpisodePlaybackPlan fallback = await resolveEpisodePlayback(
        episode: _directEpisode(),
        provider: null,
        preference: VideoPlayerPreference.auto,
        downloadedEpisodes: lookup,
        localPlaybackFailures: failures,
      );
      final EpisodePlaybackPlan reopened = await resolveEpisodePlayback(
        episode: _directEpisode(),
        provider: null,
        preference: VideoPlayerPreference.auto,
        downloadedEpisodes: lookup,
        localPlaybackFailures: failures,
      );

      expect(
        (fallback as NativePlaybackPlan).video.streams.single.url,
        'https://cdn.test/e1.mp4',
      );
      expect((reopened as NativePlaybackPlan).video, same(_localVideo));
      expect(failures.hasFailed('e1'), isFalse);
    });

    test('without a way to stream the download is still played', () async {
      final _LocalLookup lookup = _LocalLookup();
      final LocalPlaybackFailures failures = LocalPlaybackFailures()
        ..markFailed('e1');

      final EpisodePlaybackPlan plan = await resolveEpisodePlayback(
        episode: _iframeEpisode(),
        provider: null,
        preference: VideoPlayerPreference.auto,
        downloadedEpisodes: lookup,
        localPlaybackFailures: failures,
      );

      expect((plan as NativePlaybackPlan).video, same(_localVideo));
      expect(
        failures.hasFailed('e1'),
        isTrue,
        reason: 'a second local failure must show the error, not loop',
      );
    });

    test('still prefers the download for other episodes', () async {
      final EpisodePlaybackPlan plan = await resolveEpisodePlayback(
        episode: _directEpisode(),
        provider: null,
        preference: VideoPlayerPreference.auto,
        downloadedEpisodes: _LocalLookup(),
        localPlaybackFailures: LocalPlaybackFailures()..markFailed('e2'),
      );

      expect((plan as NativePlaybackPlan).video, same(_localVideo));
    });
  });

  group('redownloadEpisode', () {
    test(
      'deletes the broken files, forgets the failure and queues again',
      () async {
        final LocalPlaybackFailures failures = LocalPlaybackFailures()
          ..markFailed('e1');
        final List<String> calls = <String>[];

        final bool started = await redownloadEpisode(
          episodeUid: 'e1',
          findDownload: (String uid) async => _download(uid),
          deleteDownload: (DownloadDomain download) async {
            calls.add('delete ${download.uid}');
          },
          downloadAgain: (DownloadDomain download) async {
            calls.add('download ${download.uid}');
          },
          failures: failures,
        );

        expect(started, isTrue);
        expect(calls, <String>['delete e1', 'download e1']);
        expect(failures.hasFailed('e1'), isFalse);
      },
    );

    test('does nothing when the download is gone', () async {
      final List<String> calls = <String>[];

      final bool started = await redownloadEpisode(
        episodeUid: 'e1',
        findDownload: (String uid) async => null,
        deleteDownload: (DownloadDomain download) async => calls.add('delete'),
        downloadAgain: (DownloadDomain download) async => calls.add('again'),
        failures: LocalPlaybackFailures(),
      );

      expect(started, isFalse);
      expect(calls, isEmpty);
    });
  });
}
