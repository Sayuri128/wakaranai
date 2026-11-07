import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_plan.dart';
import 'package:wakaranai/services/downloads/episode/episode_fetcher.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/episode_http.dart';

Future<List<DownloadedSubtitle>> downloadEpisodeSubtitles({
  required List<PlayableSubtitle> subtitles,
  required Directory dir,
  required EpisodeFetcher fetcher,
}) async {
  final List<DownloadedSubtitle> downloaded = <DownloadedSubtitle>[];
  for (int index = 0; index < subtitles.length; index++) {
    final PlayableSubtitle subtitle = subtitles[index];
    try {
      downloaded.add(
        await _downloadSubtitle(index, subtitle, dir: dir, fetcher: fetcher),
      );
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) {
        rethrow;
      }
      logger.w('Skipping subtitle ${subtitle.url}: $error');
    }
  }
  return downloaded;
}

Future<DownloadedSubtitle> _downloadSubtitle(
  int index,
  PlayableSubtitle subtitle, {
  required Directory dir,
  required EpisodeFetcher fetcher,
}) async {
  final DownloadedSubtitle? existing = await _existingSubtitle(
    index,
    subtitle,
    dir,
  );
  if (existing != null) {
    return existing;
  }
  final Uint8List bytes = await _subtitleBytes(subtitle, fetcher);
  if (bytes.isEmpty) {
    throw const FormatException('Empty subtitle');
  }
  final PlayableSubtitleFormat format = _formatOf(subtitle, bytes);
  final String relativePath = _subtitlePath(index, format);
  final File target = File(p.join(dir.path, relativePath));
  final File part = partFileOf(target);
  await part.parent.create(recursive: true);
  await part.writeAsBytes(bytes, flush: true);
  await part.rename(target.path);
  return _describe(subtitle, relativePath, format);
}

Future<Uint8List> _subtitleBytes(
  PlayableSubtitle subtitle,
  EpisodeFetcher fetcher,
) async {
  final String url = subtitle.url.trim();
  if (url.startsWith('data:')) {
    return UriData.parse(url).contentAsBytes();
  }
  return fetcher.fetchBytes(url, mergeEpisodeHeaders(subtitle.headers));
}

PlayableSubtitleFormat _formatOf(PlayableSubtitle subtitle, Uint8List bytes) {
  final PlayableSubtitleFormat format = resolveSubtitleFormat(
    subtitle,
    content: decodeText(bytes),
  );
  if (format == PlayableSubtitleFormat.auto) {
    return PlayableSubtitleFormat.vtt;
  }
  return format;
}

Future<DownloadedSubtitle?> _existingSubtitle(
  int index,
  PlayableSubtitle subtitle,
  Directory dir,
) async {
  for (final PlayableSubtitleFormat format in <PlayableSubtitleFormat>[
    PlayableSubtitleFormat.vtt,
    PlayableSubtitleFormat.srt,
  ]) {
    final String relativePath = _subtitlePath(index, format);
    if (await File(p.join(dir.path, relativePath)).exists()) {
      return _describe(subtitle, relativePath, format);
    }
  }
  return null;
}

String _subtitlePath(int index, PlayableSubtitleFormat format) {
  return '$kSubtitlesFolder/$index.${format.name}';
}

DownloadedSubtitle _describe(
  PlayableSubtitle subtitle,
  String relativePath,
  PlayableSubtitleFormat format,
) {
  return DownloadedSubtitle(
    file: relativePath,
    label: subtitle.label,
    language: subtitle.language,
    format: format,
  );
}
