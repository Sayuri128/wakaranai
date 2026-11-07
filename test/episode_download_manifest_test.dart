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
