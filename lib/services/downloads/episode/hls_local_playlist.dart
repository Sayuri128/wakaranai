import 'dart:math';

import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';

const String kLocalIndexPlaylist = 'index.m3u8';
const String kLocalVideoPlaylist = 'video.m3u8';
const String kLocalAudioPlaylist = 'audio.m3u8';
const String kLocalVideoFolder = 'v';
const String kLocalAudioFolder = 'a';
const String kLocalKeysFolder = 'keys';
const String _localAudioGroupId = 'audio';

const Set<String> _mediaExtensions = <String>{
  'ts',
  'm4s',
  'mp4',
  'm4v',
  'm4a',
  'aac',
  'mp3',
  'ac3',
  'ec3',
  'cmfv',
  'cmfa',
  'webm',
};

enum HlsFileKind { segment, init, key }

class HlsFileTask {
  const HlsFileTask({
    required this.kind,
    required this.uri,
    required this.relativePath,
    this.byteRange,
  });

  final HlsFileKind kind;
  final Uri uri;
  final String relativePath;
  final HlsByteRange? byteRange;
}

class HlsKeyFiles {
  final Map<Uri, String> _paths = <Uri, String>{};

  String pathFor(Uri uri) {
    return _paths.putIfAbsent(
      uri,
      () => '$kLocalKeysFolder/${_paths.length}.key',
    );
  }
}

void ensureDownloadableKeys(HlsMediaPlaylist playlist) {
  for (final HlsKey key in playlist.keys) {
    if (key.isNone) {
      continue;
    }
    if (!key.isAes128) {
      throw UnsupportedEpisodeDownload(
        'Encryption method ${key.method} is not supported',
      );
    }
    if (!key.hasIdentityFormat) {
      throw UnsupportedEpisodeDownload(
        'Key format ${key.keyFormat} is not supported',
      );
    }
    if (key.uri == null) {
      throw const UnsupportedEpisodeDownload('AES-128 key without a URI');
    }
  }
}

class HlsLocalTrack {
  HlsLocalTrack._({
    required this.playlist,
    required this.folder,
    required this.segmentFiles,
    required this.initFiles,
    required this.keyFiles,
  });

  factory HlsLocalTrack.build(
    HlsMediaPlaylist playlist, {
    required String folder,
    required HlsKeyFiles keyFiles,
  }) {
    ensureDownloadableKeys(playlist);
    final bool fragmented = playlist.segments.any(
      (HlsSegment segment) => segment.initSection != null,
    );
    final Map<HlsInitSection, String> initFiles = <HlsInitSection, String>{};
    final Map<Uri, String> trackKeys = <Uri, String>{};
    final List<String> segmentFiles = <String>[];
    for (int index = 0; index < playlist.segments.length; index++) {
      final HlsSegment segment = playlist.segments[index];
      final HlsInitSection? init = segment.initSection;
      if (init != null) {
        initFiles.putIfAbsent(
          init,
          () =>
              '$folder/init${initFiles.length}.'
              '${_extensionOf(init.uri, fallback: 'mp4')}',
        );
      }
      final Uri? keyUri = _downloadableKeyUri(segment.key);
      if (keyUri != null) {
        trackKeys.putIfAbsent(keyUri, () => keyFiles.pathFor(keyUri));
      }
      final String fallback = fragmented ? 'm4s' : 'ts';
      segmentFiles.add(
        '$folder/${_segmentNumber(index)}.'
        '${_extensionOf(segment.uri, fallback: fallback)}',
      );
    }
    return HlsLocalTrack._(
      playlist: playlist,
      folder: folder,
      segmentFiles: segmentFiles,
      initFiles: initFiles,
      keyFiles: trackKeys,
    );
  }

  final HlsMediaPlaylist playlist;
  final String folder;
  final List<String> segmentFiles;
  final Map<HlsInitSection, String> initFiles;
  final Map<Uri, String> keyFiles;

  int get segmentCount => segmentFiles.length;

  List<HlsFileTask> get segmentTasks {
    return <HlsFileTask>[
      for (int index = 0; index < playlist.segments.length; index++)
        HlsFileTask(
          kind: HlsFileKind.segment,
          uri: playlist.segments[index].uri,
          byteRange: playlist.segments[index].byteRange,
          relativePath: segmentFiles[index],
        ),
    ];
  }

  List<HlsFileTask> get auxiliaryTasks {
    return <HlsFileTask>[
      for (final MapEntry<Uri, String> key in keyFiles.entries)
        HlsFileTask(
          kind: HlsFileKind.key,
          uri: key.key,
          relativePath: key.value,
        ),
      for (final MapEntry<HlsInitSection, String> init in initFiles.entries)
        HlsFileTask(
          kind: HlsFileKind.init,
          uri: init.key.uri,
          byteRange: init.key.byteRange,
          relativePath: init.value,
        ),
    ];
  }

  String render() {
    final StringBuffer buffer = StringBuffer()..writeln('#EXTM3U');
    final int? version = playlist.version;
    if (version != null) {
      buffer.writeln('#EXT-X-VERSION:$version');
    }
    buffer
      ..writeln('#EXT-X-TARGETDURATION:${_targetDuration()}')
      ..writeln('#EXT-X-MEDIA-SEQUENCE:${playlist.mediaSequence}');
    final int? discontinuitySequence = playlist.discontinuitySequence;
    if (discontinuitySequence != null) {
      buffer.writeln('#EXT-X-DISCONTINUITY-SEQUENCE:$discontinuitySequence');
    }
    buffer.writeln('#EXT-X-PLAYLIST-TYPE:VOD');
    if (playlist.independentSegments) {
      buffer.writeln('#EXT-X-INDEPENDENT-SEGMENTS');
    }
    _renderSegments(buffer);
    buffer.writeln('#EXT-X-ENDLIST');
    return buffer.toString();
  }

  void _renderSegments(StringBuffer buffer) {
    HlsKey? previousKey;
    HlsInitSection? previousInit;
    for (int index = 0; index < playlist.segments.length; index++) {
      final HlsSegment segment = playlist.segments[index];
      if (segment.discontinuity) {
        buffer.writeln('#EXT-X-DISCONTINUITY');
      }
      if (segment.key != previousKey) {
        buffer.writeln(_keyLine(segment.key));
        previousKey = segment.key;
      }
      final HlsInitSection? init = segment.initSection;
      final bool initChanged = init != previousInit || segment.discontinuity;
      if (init != null && initChanged) {
        buffer.writeln('#EXT-X-MAP:URI="${initFiles[init]}"');
      }
      previousInit = init;
      buffer
        ..writeln(
          '#EXTINF:${_formatDuration(segment.duration)},'
          '${_sanitizeTitle(segment.title)}',
        )
        ..writeln(segmentFiles[index]);
    }
  }

  String _keyLine(HlsKey? key) {
    if (key == null || key.isNone) {
      return '#EXT-X-KEY:METHOD=NONE';
    }
    final StringBuffer line = StringBuffer(
      '#EXT-X-KEY:METHOD=AES-128,URI="${keyFiles[key.uri]}"',
    );
    final String? iv = key.iv;
    if (iv != null && iv.isNotEmpty) {
      line.write(',IV=$iv');
    }
    return line.toString();
  }

  int _targetDuration() {
    final double longest = playlist.segments.fold<double>(
      0,
      (double current, HlsSegment segment) => max(current, segment.duration),
    );
    return max(playlist.targetDuration ?? 0, longest.ceil());
  }
}

Uri? _downloadableKeyUri(HlsKey? key) {
  if (key == null || !key.isAes128) {
    return null;
  }
  return key.uri;
}

String _segmentNumber(int index) {
  return (index + 1).toString().padLeft(6, '0');
}

String _extensionOf(Uri uri, {required String fallback}) {
  final String lastSegment = uri.pathSegments.isEmpty
      ? ''
      : uri.pathSegments.last;
  final int dot = lastSegment.lastIndexOf('.');
  if (dot < 0) {
    return fallback;
  }
  final String extension = lastSegment.substring(dot + 1).toLowerCase();
  if (_mediaExtensions.contains(extension)) {
    return extension;
  }
  return fallback;
}

String _formatDuration(double seconds) {
  String text = seconds.toStringAsFixed(6);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  if (text.endsWith('.')) {
    text = '${text}0';
  }
  return text;
}

String _sanitizeTitle(String title) {
  return title.replaceAll(RegExp(r'[\r\n]'), ' ');
}

String _quoted(String value) {
  return '"${value.replaceAll(RegExp(r'["\r\n]'), '')}"';
}

String renderLocalMasterPlaylist({
  required HlsVariant variant,
  required HlsAudioRendition audio,
  String videoPlaylist = kLocalVideoPlaylist,
  String audioPlaylist = kLocalAudioPlaylist,
}) {
  final StringBuffer buffer = StringBuffer()..writeln('#EXTM3U');
  buffer.writeln(_audioMediaLine(audio, audioPlaylist));
  buffer
    ..writeln(_streamInfLine(variant))
    ..writeln(videoPlaylist);
  return buffer.toString();
}

String _audioMediaLine(HlsAudioRendition audio, String audioPlaylist) {
  final List<String> attributes = <String>[
    'TYPE=AUDIO',
    'GROUP-ID=${_quoted(_localAudioGroupId)}',
    'NAME=${_quoted(audio.name)}',
  ];
  final String? language = audio.language;
  if (language != null && language.isNotEmpty) {
    attributes.add('LANGUAGE=${_quoted(language)}');
  }
  attributes.addAll(<String>['DEFAULT=YES', 'AUTOSELECT=YES']);
  final String? channels = audio.channels;
  if (channels != null && channels.isNotEmpty) {
    attributes.add('CHANNELS=${_quoted(channels)}');
  }
  attributes.add('URI=${_quoted(audioPlaylist)}');
  return '#EXT-X-MEDIA:${attributes.join(',')}';
}

String _streamInfLine(HlsVariant variant) {
  final List<String> attributes = <String>[
    'BANDWIDTH=${variant.bandwidth ?? variant.averageBandwidth ?? 1}',
  ];
  final int? averageBandwidth = variant.averageBandwidth;
  if (averageBandwidth != null) {
    attributes.add('AVERAGE-BANDWIDTH=$averageBandwidth');
  }
  final int? width = variant.width;
  final int? height = variant.height;
  if (width != null && height != null) {
    attributes.add('RESOLUTION=${width}x$height');
  }
  final String? codecs = variant.codecs;
  if (codecs != null && codecs.isNotEmpty) {
    attributes.add('CODECS=${_quoted(codecs)}');
  }
  final String? frameRate = variant.frameRate;
  if (frameRate != null && frameRate.isNotEmpty) {
    attributes.add('FRAME-RATE=$frameRate');
  }
  attributes.add('AUDIO=${_quoted(_localAudioGroupId)}');
  return '#EXT-X-STREAM-INF:${attributes.join(',')}';
}
