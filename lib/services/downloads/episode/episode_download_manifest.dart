import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';

enum EpisodeMediaFormat { hls, mp4 }

class DownloadedSubtitle {
  const DownloadedSubtitle({
    required this.file,
    this.label,
    this.language,
    this.format = PlayableSubtitleFormat.auto,
  });

  factory DownloadedSubtitle.fromJson(Map<String, dynamic> json) {
    return DownloadedSubtitle(
      file: json['file'] as String,
      label: json['label'] as String?,
      language: json['language'] as String?,
      format: PlayableSubtitleFormat.values.firstWhereOrNull(
            (PlayableSubtitleFormat format) => format.name == json['format'],
          ) ??
          PlayableSubtitleFormat.auto,
    );
  }

  final String file;
  final String? label;
  final String? language;
  final PlayableSubtitleFormat format;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'file': file,
      if (label != null) 'label': label,
      if (language != null) 'language': language,
      'format': format.name,
    };
  }
}

class EpisodeDownloadManifest {
  const EpisodeDownloadManifest({
    required this.format,
    required this.file,
    this.quality,
    this.subtitles = const <DownloadedSubtitle>[],
  });

  factory EpisodeDownloadManifest.fromJson(Map<String, dynamic> json) {
    final List<dynamic> subtitles =
        json['subtitles'] as List<dynamic>? ?? const <dynamic>[];
    return EpisodeDownloadManifest(
      format: EpisodeMediaFormat.values.byName(json['format'] as String),
      file: json['file'] as String,
      quality: json['quality'] as String?,
      subtitles: subtitles
          .map((dynamic item) =>
              DownloadedSubtitle.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static EpisodeDownloadManifest? decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return EpisodeDownloadManifest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  final EpisodeMediaFormat format;
  final String file;
  final String? quality;
  final List<DownloadedSubtitle> subtitles;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'format': format.name,
      'file': file,
      if (quality != null) 'quality': quality,
      'subtitles': subtitles
          .map((DownloadedSubtitle subtitle) => subtitle.toJson())
          .toList(growable: false),
    };
  }

  String encode() => jsonEncode(toJson());

  String mediaPathIn(String dirPath) => p.join(dirPath, file);

  PlayableVideo toPlayableVideo(String dirPath) {
    return PlayableVideo(
      streams: <PlayableStream>[
        PlayableStream(
          url: Uri.file(mediaPathIn(dirPath)).toString(),
          quality: quality,
          format: format == EpisodeMediaFormat.hls
              ? PlayableStreamFormat.hls
              : PlayableStreamFormat.mp4,
        ),
      ],
      subtitles: subtitles
          .map(
            (DownloadedSubtitle subtitle) => PlayableSubtitle(
              url: Uri.file(p.join(dirPath, subtitle.file)).toString(),
              label: subtitle.label,
              language: subtitle.language,
              format: subtitle.format,
            ),
          )
          .toList(growable: false),
    );
  }
}

AnimeVideo? downloadedEpisodeOf(DownloadDomain download) {
  final String? raw = download.data;
  if (!download.isEpisode || raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return AnimeVideo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

String encodeDownloadedEpisode(AnimeVideo episode) {
  return jsonEncode(episode.toJson());
}
