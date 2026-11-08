import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';

void main() {
  test('manifest round-trips and maps to local file streams', () {
    const EpisodeDownloadManifest manifest = EpisodeDownloadManifest(
      format: EpisodeMediaFormat.hls,
      file: 'index.m3u8',
      quality: '720p',
      subtitles: <DownloadedSubtitle>[
        DownloadedSubtitle(
          file: 'subs/0.vtt',
          label: 'English',
          language: 'en',
          format: PlayableSubtitleFormat.vtt,
        ),
      ],
    );

    final EpisodeDownloadManifest? decoded =
        EpisodeDownloadManifest.decode(manifest.encode());
    expect(decoded, isNotNull);
    expect(decoded!.toJson(), manifest.toJson());

    final String dir = p.join(p.separator, 'data', 'ep');
    final PlayableVideo video = decoded.toPlayableVideo(dir);
    expect(video.streams.single.format, PlayableStreamFormat.hls);
    expect(Uri.parse(video.streams.single.url).scheme, 'file');
    expect(video.subtitles.single.language, 'en');
    expect(Uri.parse(video.subtitles.single.url).scheme, 'file');
  });

  test('skip markers and the audio label survive a round trip offline', () {
    const List<PlayableSkipMarker> markers = <PlayableSkipMarker>[
      PlayableSkipMarker(
        type: PlayableSkipType.intro,
        start: Duration(milliseconds: 1500),
        end: Duration(seconds: 90),
      ),
      PlayableSkipMarker(
        type: PlayableSkipType.outro,
        start: Duration(minutes: 22),
        end: Duration(minutes: 23),
      ),
    ];
    const EpisodeDownloadManifest manifest = EpisodeDownloadManifest(
      format: EpisodeMediaFormat.mp4,
      file: 'video.mp4',
      quality: '1080p',
      skipMarkers: markers,
      audioLabel: 'Studio Dub',
    );

    final EpisodeDownloadManifest decoded =
        EpisodeDownloadManifest.decode(manifest.encode())!;
    expect(decoded.toJson(), manifest.toJson());
    expect(decoded.skipMarkers, markers);
    expect(decoded.audioLabel, 'Studio Dub');

    final String dir = p.join(p.separator, 'data', 'ep');
    final PlayableStream stream = decoded.toPlayableVideo(dir).streams.single;
    expect(stream.skipMarkers, markers);
    expect(stream.audioLabel, 'Studio Dub');
  });

  test('manifests written before skip markers still decode', () {
    const String legacy =
        '{"format":"hls","file":"index.m3u8","quality":"720p","subtitles":[]}';

    final EpisodeDownloadManifest? decoded =
        EpisodeDownloadManifest.decode(legacy);

    expect(decoded, isNotNull);
    expect(decoded!.skipMarkers, isEmpty);
    expect(decoded.audioLabel, isNull);
    expect(decoded.toJson().containsKey('skip'), isFalse);
    final String dir = p.join(p.separator, 'data', 'ep');
    expect(decoded.toPlayableVideo(dir).streams.single.skipMarkers, isEmpty);
  });

  test('malformed skip entries are dropped without losing the manifest', () {
    const String raw = '{"format":"mp4","file":"video.mp4","skip":['
        '{"type":"intro","startMs":0,"endMs":90000},'
        '{"type":"credits","startMs":0,"endMs":1000},'
        '{"type":"outro","startMs":"x","endMs":1000},'
        '{"type":"recap","startMs":5000,"endMs":1000},'
        '"oops"]}';

    final EpisodeDownloadManifest? decoded = EpisodeDownloadManifest.decode(raw);

    expect(decoded!.skipMarkers, const <PlayableSkipMarker>[
      PlayableSkipMarker(
        type: PlayableSkipType.intro,
        start: Duration.zero,
        end: Duration(seconds: 90),
      ),
    ]);
  });

  test('broken manifest json decodes to null', () {
    expect(EpisodeDownloadManifest.decode('{oops'), isNull);
    expect(EpisodeDownloadManifest.decode(null), isNull);
  });

  test('episode payload round-trips through the download row', () {
    const AnimeVideo episode = AnimeVideo(
      type: AnimeVideoType.IFRAME,
      uid: 'https://embed/1',
      src: 'https://embed/1',
      title: 'Episode 1',
      timestamp: null,
      data: <String, dynamic>{'k': 'v'},
      number: 1,
    );
    final DownloadDomain download = DownloadDomain(
      id: 1,
      uid: episode.uid,
      extensionUid: 'ext',
      concreteUid: 'anime',
      concreteId: 1,
      concreteTitle: 'Anime',
      title: episode.title,
      status: DownloadStatus.done,
      downloadedPages: 0,
      totalPages: 0,
      dirPath: '/tmp',
      data: encodeDownloadedEpisode(episode),
      kind: DownloadKind.episode,
      createdAt: DateTime(2026),
    );

    final AnimeVideo? restored = downloadedEpisodeOf(download);
    expect(restored?.uid, episode.uid);
    expect(restored?.number, 1);
    expect(restored?.data, <String, dynamic>{'k': 'v'});
  });
}
