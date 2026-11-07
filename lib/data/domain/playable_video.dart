enum PlayableStreamFormat { hls, mp4, dash, auto }

enum PlayableSubtitleFormat { vtt, srt, auto }

class PlayableVideo {
  const PlayableVideo({
    required this.streams,
    this.subtitles = const <PlayableSubtitle>[],
  });

  final List<PlayableStream> streams;
  final List<PlayableSubtitle> subtitles;
}

enum PlayableSkipType { intro, outro, recap }

class PlayableSkipMarker {
  const PlayableSkipMarker({
    required this.type,
    required this.start,
    required this.end,
  });

  final PlayableSkipType type;
  final Duration start;
  final Duration end;

  bool contains(Duration position) {
    return position >= start && position < end;
  }

  @override
  bool operator ==(Object other) {
    return other is PlayableSkipMarker &&
        other.type == type &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(type, start, end);

  @override
  String toString() {
    return 'PlayableSkipMarker(${type.name}, $start, $end)';
  }
}

class PlayableStream {
  const PlayableStream({
    required this.url,
    this.quality,
    this.format = PlayableStreamFormat.auto,
    this.headers = const <String, String>{},
    this.skipMarkers = const <PlayableSkipMarker>[],
    this.audioLabel,
    this.preferForDownload = false,
  });

  final String url;
  final String? quality;
  final PlayableStreamFormat format;
  final Map<String, String> headers;
  final List<PlayableSkipMarker> skipMarkers;
  final String? audioLabel;
  final bool preferForDownload;
}

class PlayableSubtitle {
  const PlayableSubtitle({
    required this.url,
    this.label,
    this.language,
    this.format = PlayableSubtitleFormat.auto,
    this.headers = const <String, String>{},
  });

  final String url;
  final String? label;
  final String? language;
  final PlayableSubtitleFormat format;
  final Map<String, String> headers;
}

final RegExp _subRipTimingLine = RegExp(
  r'\d{1,2}:\d{2}:\d{2},\d{3}\s*-->\s*\d{1,2}:\d{2}:\d{2},\d{3}',
);

PlayableStreamFormat resolveStreamFormat(PlayableStream stream) {
  if (stream.format != PlayableStreamFormat.auto) {
    return stream.format;
  }
  final String path = _lowercasePath(stream.url);
  if (path.endsWith('.m3u8')) {
    return PlayableStreamFormat.hls;
  }
  if (path.endsWith('.mpd')) {
    return PlayableStreamFormat.dash;
  }
  if (path.endsWith('.mp4') ||
      path.endsWith('.m4v') ||
      path.endsWith('.webm') ||
      path.endsWith('.mkv')) {
    return PlayableStreamFormat.mp4;
  }
  return PlayableStreamFormat.auto;
}

PlayableSubtitleFormat resolveSubtitleFormat(
  PlayableSubtitle subtitle, {
  String? content,
}) {
  if (subtitle.format != PlayableSubtitleFormat.auto) {
    return subtitle.format;
  }
  final String path = _lowercasePath(subtitle.url);
  if (path.endsWith('.vtt')) {
    return PlayableSubtitleFormat.vtt;
  }
  if (path.endsWith('.srt')) {
    return PlayableSubtitleFormat.srt;
  }
  if (content == null) {
    return PlayableSubtitleFormat.auto;
  }
  return detectSubtitleFormatFromContent(content);
}

PlayableSubtitleFormat detectSubtitleFormatFromContent(String content) {
  final String body = stripByteOrderMark(content).trimLeft();
  if (body.startsWith('WEBVTT')) {
    return PlayableSubtitleFormat.vtt;
  }
  if (_subRipTimingLine.hasMatch(body)) {
    return PlayableSubtitleFormat.srt;
  }
  if (body.contains('-->')) {
    return PlayableSubtitleFormat.vtt;
  }
  return PlayableSubtitleFormat.auto;
}

String stripByteOrderMark(String content) {
  if (content.startsWith('﻿')) {
    return content.substring(1);
  }
  return content;
}

String _lowercasePath(String url) {
  final Uri? uri = Uri.tryParse(url.trim());
  if (uri == null) {
    return url.trim().toLowerCase();
  }
  return uri.path.toLowerCase();
}
