import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_skip_marker.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_subtitle.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/native_player/skip_markers.dart';

PlayableVideo playableVideoFromSources(List<AnimeVideoSource> sources) {
  final List<PlayableStream> streams = <PlayableStream>[];
  final List<PlayableSubtitle> subtitles = <PlayableSubtitle>[];
  final Set<String> subtitleUrls = <String>{};
  for (final AnimeVideoSource source in sources) {
    final String url = source.url.trim();
    if (url.isEmpty) {
      continue;
    }
    streams.add(_mapSource(source, url));
    for (final AnimeVideoSubtitle subtitle in source.subtitles) {
      final String subtitleUrl = subtitle.url.trim();
      if (subtitleUrl.isEmpty || !subtitleUrls.add(subtitleUrl)) {
        continue;
      }
      subtitles.add(_mapSubtitle(subtitle, subtitleUrl));
    }
  }
  return PlayableVideo(streams: streams, subtitles: subtitles);
}

PlayableVideo playableVideoFromDirectSource(String src) {
  return PlayableVideo(
    streams: <PlayableStream>[PlayableStream(url: src.trim())],
  );
}

PlayableStreamFormat parseStreamFormat(String? format) {
  switch (_normalizeFormat(format)) {
    case 'hls':
    case 'm3u8':
    case 'm3u':
    case 'application/x-mpegurl':
    case 'application/vnd.apple.mpegurl':
      return PlayableStreamFormat.hls;
    case 'dash':
    case 'mpd':
    case 'application/dash+xml':
      return PlayableStreamFormat.dash;
    case 'mp4':
    case 'm4v':
    case 'webm':
    case 'mkv':
    case 'progressive':
    case 'file':
    case 'video/mp4':
    case 'video/webm':
      return PlayableStreamFormat.mp4;
    default:
      return PlayableStreamFormat.auto;
  }
}

PlayableSubtitleFormat parseSubtitleFormat(String? format) {
  switch (_normalizeFormat(format)) {
    case 'vtt':
    case 'webvtt':
    case 'text/vtt':
      return PlayableSubtitleFormat.vtt;
    case 'srt':
    case 'subrip':
    case 'application/x-subrip':
      return PlayableSubtitleFormat.srt;
    default:
      return PlayableSubtitleFormat.auto;
  }
}

PlayableStream _mapSource(AnimeVideoSource source, String url) {
  return PlayableStream(
    url: url,
    quality: _blankToNull(source.quality),
    format: parseStreamFormat(source.format),
    headers: Map<String, String>.unmodifiable(source.headers),
    skipMarkers: playableSkipMarkersFrom(source.skip),
    audioLabel: _blankToNull(source.audioLabel),
    preferForDownload: source.preferForDownload,
  );
}

List<PlayableSkipMarker> playableSkipMarkersFrom(
  List<AnimeSkipMarker> markers,
) {
  final List<PlayableSkipMarker> mapped = <PlayableSkipMarker>[];
  for (final AnimeSkipMarker marker in markers) {
    final Duration? start = skipMarkerOffset(marker.start);
    final Duration? end = skipMarkerOffset(marker.end);
    if (start == null || end == null) {
      continue;
    }
    mapped.add(PlayableSkipMarker(
      type: _skipTypeOf(marker.type),
      start: start,
      end: end,
    ));
  }
  return normalizeSkipMarkers(mapped);
}

PlayableSkipType _skipTypeOf(AnimeSkipType type) {
  switch (type) {
    case AnimeSkipType.intro:
      return PlayableSkipType.intro;
    case AnimeSkipType.outro:
      return PlayableSkipType.outro;
    case AnimeSkipType.recap:
      return PlayableSkipType.recap;
  }
}

PlayableSubtitle _mapSubtitle(AnimeVideoSubtitle subtitle, String url) {
  return PlayableSubtitle(
    url: url,
    label: _blankToNull(subtitle.label),
    language: _blankToNull(subtitle.language),
    format: parseSubtitleFormat(subtitle.format),
    headers: Map<String, String>.unmodifiable(subtitle.headers),
  );
}

String _normalizeFormat(String? format) {
  final String normalized = (format ?? '').trim().toLowerCase();
  if (normalized.startsWith('.')) {
    return normalized.substring(1);
  }
  return normalized;
}

String? _blankToNull(String? value) {
  final String? trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
