import 'dart:io';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:collection/collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/home/downloads_page/downloaded_episode_launcher.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/anime_episode_launcher.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

class _FakeDownloadRepository extends DownloadRepository {
  _FakeDownloadRepository(this.rows, WakaranaiDatabase database)
      : super(database: database);

  final List<DownloadDomain> rows;

  @override
  Future<DownloadDomain?> getByUid(String uid) async {
    return rows.firstWhereOrNull((DownloadDomain row) => row.uid == uid);
  }

  @override
  Future<List<DownloadDomain>> getByConcreteUid(String concreteUid) async {
    return rows
        .where((DownloadDomain row) => row.concreteUid == concreteUid)
        .toList();
  }
}

class _FakeDownloadedEpisodes implements DownloadedEpisodeLookup {
  _FakeDownloadedEpisodes(this.videos);

  final Map<String, PlayableVideo> videos;

  @override
  Future<PlayableVideo?> playableFor(String episodeUid) async {
    return videos[episodeUid];
  }

  @override
  Future<Set<String>> finishedEpisodeUidsOf(String concreteUid) async {
    return videos.keys.toSet();
  }
}

const EpisodeDownloadManifest _hlsManifest = EpisodeDownloadManifest(
  format: EpisodeMediaFormat.hls,
  file: 'index.m3u8',
  quality: '720p',
  subtitles: <DownloadedSubtitle>[
    DownloadedSubtitle(
      file: 'en.vtt',
      language: 'en',
      format: PlayableSubtitleFormat.vtt,
    ),
  ],
);

AnimeVideo _video(String uid, {double? number}) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/$uid',
    title: 'Episode $uid',
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
    number: number,
  );
}

AnimeConcreteView _anime(List<AnimeVideoGroup> groups) {
  return AnimeConcreteView(
    uid: 'anime',
    cover: 'https://cdn.test/cover.jpg',
    title: 'Cached anime',
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    groups: groups,
    status: AnimeStatus.ONGOING,
  );
}

DownloadDomain _download(
  String uid, {
  required String dirPath,
  DownloadStatus status = DownloadStatus.done,
  DownloadKind kind = DownloadKind.episode,
  String? playback,
  String? data,
  String concreteUid = 'anime',
}) {
  return DownloadDomain(
    id: 0,
    uid: uid,
    extensionUid: 'extension',
    concreteUid: concreteUid,
    concreteId: 1,
    concreteTitle: 'Downloaded anime',
    concreteCover: 'https://cdn.test/downloaded.jpg',
    title: 'Episode $uid',
    status: status,
    downloadedPages: 0,
    totalPages: 0,
    dirPath: dirPath,
    data: data,
    kind: kind,
    playback: playback ?? _hlsManifest.encode(),
    createdAt: DateTime(2026),
  );
}

List<String> _uids(AnimeVideoGroup group) {
  return group.elements.map((AnimeVideo video) => video.uid).toList();
}

void main() {
  late Directory root;
  late WakaranaiDatabase database;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wakaranai_episode_test');
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  Future<String> episodeDir(String uid, {bool withMedia = true}) async {
    final Directory dir = await Directory(p.join(root.path, uid)).create();
    if (withMedia) {
      await File(p.join(dir.path, 'index.m3u8')).writeAsString('#EXTM3U\n');
    }
    return dir.path;
  }

  RepositoryDownloadedEpisodeLookup lookupOf(List<DownloadDomain> rows) {
    return RepositoryDownloadedEpisodeLookup(
      _FakeDownloadRepository(rows, database),
    );
  }

  group('downloaded episode lookup', () {
    test('a finished episode plays from its local files', () async {
      final String dir = await episodeDir('1');

      final PlayableVideo? video =
          await lookupOf(<DownloadDomain>[_download('1', dirPath: dir)])
              .playableFor('1');

      final PlayableStream stream = video!.streams.single;
      expect(stream.url, Uri.file(p.join(dir, 'index.m3u8')).toString());
      expect(stream.url, startsWith('file://'));
      expect(stream.format, PlayableStreamFormat.hls);
      expect(stream.headers, isEmpty);
      expect(
        video.subtitles.single.url,
        Uri.file(p.join(dir, 'en.vtt')).toString(),
      );
    });

    test('only finished episode downloads with media count', () async {
      final String present = await episodeDir('present');
      final String missing = await episodeDir('missing', withMedia: false);
      final RepositoryDownloadedEpisodeLookup lookup =
          lookupOf(<DownloadDomain>[
        _download('present', dirPath: present),
        _download('missing', dirPath: missing),
        _download(
          'running',
          dirPath: present,
          status: DownloadStatus.downloading,
        ),
        _download('chapter', dirPath: present, kind: DownloadKind.chapter),
        _download('broken', dirPath: present, playback: '{not json'),
        _download('elsewhere', dirPath: present, concreteUid: 'other'),
      ]);

      expect(await lookup.playableFor('present'), isNotNull);
      expect(await lookup.playableFor('missing'), isNull);
      expect(await lookup.playableFor('running'), isNull);
      expect(await lookup.playableFor('chapter'), isNull);
      expect(await lookup.playableFor('broken'), isNull);
      expect(await lookup.playableFor('unknown'), isNull);
      expect(await lookup.finishedEpisodeUidsOf('anime'), <String>{'present'});
    });
  });

  test('local subtitles are read from disk, tolerating bad bytes', () async {
    final File file = File(p.join(root.path, 'en.srt'));
    await file.writeAsBytes(<int>[
      0xEF, 0xBB, 0xBF,
      ...'1\r\n00:00:01,000 --> 00:00:02,000\r\nFirst '.codeUnits,
      0xFF,
      ...'\r\n\r\n2\r\n00:00:03,000 --> 00:00:04,000\r\nSecond\r\n'.codeUnits,
    ]);

    final ClosedCaptionFile captions = await DioSubtitleLoader().load(
      PlayableSubtitle(url: Uri.file(file.path).toString()),
    );

    expect(captions.captions, hasLength(2));
    expect(captions.captions.last.text, 'Second');
  });

  group('offline playlist', () {
    final AnimeConcreteView cached = _anime(<AnimeVideoGroup>[
      AnimeVideoGroup(title: 'Raw', elements: <AnimeVideo>[_video('c1')]),
      AnimeVideoGroup(
        title: 'Dub',
        elements: <AnimeVideo>[
          _video('a1', number: 1),
          _video('a2', number: 2),
          _video('a3', number: 3),
        ],
      ),
      AnimeVideoGroup(
        title: 'Sub',
        elements: <AnimeVideo>[_video('b1', number: 1), _video('b2', number: 2)],
      ),
    ]);

    test('keeps only downloaded episodes of the cached groups', () {
      final OfflineEpisodePlayback playback = buildOfflineEpisodePlayback(
        download: _download('b2', dirPath: root.path),
        cachedAnime: cached,
        finishedEpisodeUids: <String>{'a1', 'a3'},
      );

      expect(playback.anime, same(cached));
      expect(playback.groups.map((AnimeVideoGroup g) => g.title),
          <String>['Dub', 'Sub']);
      expect(_uids(playback.groups[0]), <String>['a1', 'a3']);
      expect(_uids(playback.groups[1]), <String>['b2']);
      expect(playback.groupIndex, 1);
      expect(playback.episode.uid, 'b2');
    });

    test('an episode missing from the cache plays on its own', () {
      final AnimeVideo stored = _video('x9', number: 9);

      final OfflineEpisodePlayback playback = buildOfflineEpisodePlayback(
        download: _download(
          'x9',
          dirPath: root.path,
          data: encodeDownloadedEpisode(stored),
        ),
        cachedAnime: cached,
        finishedEpisodeUids: <String>{'a1', 'x9'},
      );

      expect(playback.groups, hasLength(1));
      expect(_uids(playback.groups.single), <String>['x9']);
      expect(playback.groupIndex, 0);
      expect(playback.episode.uid, 'x9');
      expect(playback.episode.number, 9);
    });

    test('without a cached concrete a stub is built from the download', () {
      final OfflineEpisodePlayback playback = buildOfflineEpisodePlayback(
        download: _download('x1', dirPath: root.path),
        cachedAnime: null,
        finishedEpisodeUids: <String>{'x1'},
      );

      expect(playback.anime.uid, 'anime');
      expect(playback.anime.title, 'Downloaded anime');
      expect(playback.anime.cover, 'https://cdn.test/downloaded.jpg');
      expect(playback.episode.uid, 'x1');
      expect(playback.episode.title, 'Episode x1');
    });
  });

  group('launcher without an extension client', () {
    const PlayableVideo local = PlayableVideo(
      streams: <PlayableStream>[
        PlayableStream(url: 'file:///downloads/a1/video.mp4'),
      ],
    );

    AnimeEpisodeLauncher launcher() {
      final AnimeVideoGroup group = AnimeVideoGroup(
        title: '',
        elements: <AnimeVideo>[_video('a1'), _video('a2')],
      );
      return AnimeEpisodeLauncher(
        client: null,
        anime: _anime(<AnimeVideoGroup>[group]),
        groups: <AnimeVideoGroup>[group],
        groupIndex: 0,
        downloadedEpisodes:
            _FakeDownloadedEpisodes(<String, PlayableVideo>{'a1': local}),
      );
    }

    test('plays a downloaded episode natively', () async {
      final EpisodePlaybackPlan plan =
          await launcher().resolve(_video('a1'), VideoPlayerPreference.auto);

      expect((plan as NativePlaybackPlan).video, same(local));
    });

    test('falls back like a failed script for other episodes', () async {
      final EpisodePlaybackPlan plan =
          await launcher().resolve(_video('a2'), VideoPlayerPreference.auto);

      expect((plan as WebPlaybackPlan).reason, WebPlaybackReason.failed);
    });
  });
}
