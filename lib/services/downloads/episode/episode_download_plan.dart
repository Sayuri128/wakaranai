import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/hls_local_playlist.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';

const String kPlanFileName = '.plan.json';
const String kMp4SourceFileName = '.mp4-source.json';
const String kLocalMp4File = 'video.mp4';
const String kSubtitlesFolder = 'subs';
const int _planVersion = 1;

const Set<String> _engineOwnedEntries = <String>{
  kLocalVideoFolder,
  kLocalAudioFolder,
  kLocalKeysFolder,
  kSubtitlesFolder,
  kLocalIndexPlaylist,
  kLocalVideoPlaylist,
  kLocalAudioPlaylist,
  kLocalMp4File,
  kMp4SourceFileName,
};

class EpisodeDownloadPlan {
  const EpisodeDownloadPlan(this.signature);

  factory EpisodeDownloadPlan.mp4({
    required int streamIndex,
    required String? streamQuality,
  }) {
    return EpisodeDownloadPlan(<String, Object?>{
      'version': _planVersion,
      'format': 'mp4',
      'stream': streamIndex,
      'quality': streamQuality,
    });
  }

  factory EpisodeDownloadPlan.hls({
    required int streamIndex,
    required String? streamQuality,
    required HlsVariant? variant,
    required HlsAudioRendition? audio,
    required List<HlsMediaPlaylist> tracks,
  }) {
    return EpisodeDownloadPlan(<String, Object?>{
      'version': _planVersion,
      'format': 'hls',
      'stream': streamIndex,
      'quality': streamQuality,
      'variantHeight': variant?.height,
      'variantBandwidth': variant?.bandwidth ?? variant?.averageBandwidth,
      'audio': audio == null ? null : '${audio.groupId}/${audio.name}',
      'tracks': <Object?>[
        for (final HlsMediaPlaylist track in tracks) _trackSignature(track),
      ],
    });
  }

  final Map<String, Object?> signature;

  String encode() => jsonEncode(signature);

  static Map<String, Object?> _trackSignature(HlsMediaPlaylist playlist) {
    return <String, Object?>{
      'segments': playlist.segments.length,
      'mediaSequence': playlist.mediaSequence,
      'durations': <int>[
        for (final HlsSegment segment in playlist.segments)
          (segment.duration * 1000).round(),
      ],
      'ranges': playlist.segments.any(
        (HlsSegment segment) => segment.byteRange != null,
      ),
    };
  }
}

class Mp4SourceFingerprint {
  const Mp4SourceFingerprint({this.totalBytes, this.etag, this.lastModified});

  factory Mp4SourceFingerprint.fromJson(Map<String, Object?> json) {
    return Mp4SourceFingerprint(
      totalBytes: json['total'] is int ? json['total'] as int : null,
      etag: json['etag'] is String ? json['etag'] as String : null,
      lastModified: json['lastModified'] is String
          ? json['lastModified'] as String
          : null,
    );
  }

  final int? totalBytes;
  final String? etag;
  final String? lastModified;

  String? get ifRangeValidator {
    final String? strongEtag = etag;
    if (strongEtag != null &&
        strongEtag.isNotEmpty &&
        !strongEtag.startsWith('W/')) {
      return strongEtag;
    }
    final String? modified = lastModified;
    if (modified == null || modified.isEmpty) {
      return null;
    }
    return modified;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'total': totalBytes,
      'etag': etag,
      'lastModified': lastModified,
    };
  }
}

Future<Mp4SourceFingerprint?> readMp4SourceFingerprint(Directory dir) async {
  final String? text = await _readTextFile(
    File(p.join(dir.path, kMp4SourceFileName)),
  );
  if (text == null) {
    return null;
  }
  try {
    final Object? decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return Mp4SourceFingerprint.fromJson(decoded);
  } on FormatException {
    return null;
  }
}

Future<void> writeMp4SourceFingerprint(
  Directory dir,
  Mp4SourceFingerprint fingerprint,
) {
  return writeTextAtomically(
    File(p.join(dir.path, kMp4SourceFileName)),
    jsonEncode(fingerprint.toJson()),
  );
}

Future<void> clearMp4SourceFingerprint(Directory dir) {
  return deleteIfExists(File(p.join(dir.path, kMp4SourceFileName)));
}

Future<bool> applyDownloadPlan(Directory dir, EpisodeDownloadPlan plan) async {
  await dir.create(recursive: true);
  final File planFile = File(p.join(dir.path, kPlanFileName));
  final String encoded = plan.encode();
  final String? existing = await _readTextFile(planFile);
  if (existing == encoded) {
    return true;
  }
  if (existing != null) {
    logger.i('Episode download plan changed in ${dir.path}, starting over');
  }
  await wipeEpisodeMedia(dir);
  await writeTextAtomically(planFile, encoded);
  return false;
}

Future<String?> _readTextFile(File file) async {
  try {
    if (!await file.exists()) {
      return null;
    }
    return await file.readAsString();
  } on FileSystemException {
    return null;
  }
}

Future<void> wipeEpisodeMedia(Directory dir) async {
  if (!await dir.exists()) {
    return;
  }
  await for (final FileSystemEntity entity in dir.list(followLinks: false)) {
    final String name = p.basename(entity.path);
    final bool owned =
        _engineOwnedEntries.contains(name) ||
        name.endsWith(kPartSuffix) ||
        name.endsWith('.tmp');
    if (owned) {
      await deleteIfExists(entity);
    }
  }
}
