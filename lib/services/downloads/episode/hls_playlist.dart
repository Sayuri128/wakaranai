import 'dart:convert';

import 'package:collection/collection.dart';

class HlsByteRange {
  const HlsByteRange({required this.offset, required this.length});

  final int offset;
  final int length;

  int get end => offset + length;

  String get rangeHeader => 'bytes=$offset-${end - 1}';

  @override
  bool operator ==(Object other) {
    return other is HlsByteRange &&
        other.offset == offset &&
        other.length == length;
  }

  @override
  int get hashCode => Object.hash(offset, length);
}

class HlsKey {
  const HlsKey({
    required this.method,
    this.uri,
    this.iv,
    this.keyFormat,
    this.keyFormatVersions,
  });

  final String method;
  final Uri? uri;
  final String? iv;
  final String? keyFormat;
  final String? keyFormatVersions;

  bool get isNone => method.toUpperCase() == 'NONE';

  bool get isAes128 => method.toUpperCase() == 'AES-128';

  bool get hasIdentityFormat {
    final String? format = keyFormat?.trim().toLowerCase();
    return format == null || format.isEmpty || format == 'identity';
  }

  @override
  bool operator ==(Object other) {
    return other is HlsKey &&
        other.method == method &&
        other.uri == uri &&
        other.iv == iv &&
        other.keyFormat == keyFormat &&
        other.keyFormatVersions == keyFormatVersions;
  }

  @override
  int get hashCode =>
      Object.hash(method, uri, iv, keyFormat, keyFormatVersions);
}

class HlsInitSection {
  const HlsInitSection({required this.uri, this.byteRange});

  final Uri uri;
  final HlsByteRange? byteRange;

  @override
  bool operator ==(Object other) {
    return other is HlsInitSection &&
        other.uri == uri &&
        other.byteRange == byteRange;
  }

  @override
  int get hashCode => Object.hash(uri, byteRange);
}

class HlsSegment {
  const HlsSegment({
    required this.uri,
    required this.duration,
    required this.sequenceNumber,
    this.title = '',
    this.byteRange,
    this.key,
    this.initSection,
    this.discontinuity = false,
  });

  final Uri uri;
  final double duration;
  final int sequenceNumber;
  final String title;
  final HlsByteRange? byteRange;
  final HlsKey? key;
  final HlsInitSection? initSection;
  final bool discontinuity;
}

class HlsVariant {
  const HlsVariant({
    required this.uri,
    this.bandwidth,
    this.averageBandwidth,
    this.width,
    this.height,
    this.codecs,
    this.frameRate,
    this.audioGroupId,
  });

  final Uri uri;
  final int? bandwidth;
  final int? averageBandwidth;
  final int? width;
  final int? height;
  final String? codecs;
  final String? frameRate;
  final String? audioGroupId;
}

class HlsAudioRendition {
  const HlsAudioRendition({
    required this.groupId,
    required this.name,
    this.uri,
    this.language,
    this.isDefault = false,
    this.autoSelect = false,
    this.channels,
  });

  final String groupId;
  final String name;
  final Uri? uri;
  final String? language;
  final bool isDefault;
  final bool autoSelect;
  final String? channels;
}

sealed class HlsPlaylist {
  const HlsPlaylist({required this.uri});

  final Uri uri;
}

class HlsMasterPlaylist extends HlsPlaylist {
  const HlsMasterPlaylist({
    required super.uri,
    required this.variants,
    this.audioRenditions = const <HlsAudioRendition>[],
    this.independentSegments = false,
  });

  final List<HlsVariant> variants;
  final List<HlsAudioRendition> audioRenditions;
  final bool independentSegments;

  List<HlsAudioRendition> audioGroup(String groupId) {
    return audioRenditions
        .where((HlsAudioRendition rendition) => rendition.groupId == groupId)
        .toList(growable: false);
  }
}

class HlsMediaPlaylist extends HlsPlaylist {
  const HlsMediaPlaylist({
    required super.uri,
    required this.segments,
    this.version,
    this.targetDuration,
    this.mediaSequence = 0,
    this.discontinuitySequence,
    this.independentSegments = false,
    this.hasEndList = false,
  });

  final List<HlsSegment> segments;
  final int? version;
  final int? targetDuration;
  final int mediaSequence;
  final int? discontinuitySequence;
  final bool independentSegments;
  final bool hasEndList;

  Iterable<HlsKey> get keys {
    return segments
        .map((HlsSegment segment) => segment.key)
        .whereType<HlsKey>()
        .toSet();
  }
}

class HlsParseException implements Exception {
  const HlsParseException(this.message);

  final String message;

  @override
  String toString() => 'HlsParseException: $message';
}

const String _streamInfTag = '#EXT-X-STREAM-INF:';
const String _mediaTag = '#EXT-X-MEDIA:';

bool looksLikeHlsPlaylist(String text) {
  return _stripLeadingNoise(text).startsWith('#EXTM3U');
}

bool isHlsMasterPlaylist(String text) {
  return text.contains(_streamInfTag);
}

HlsPlaylist parseHlsPlaylist(String text, Uri playlistUri) {
  if (!looksLikeHlsPlaylist(text)) {
    throw const HlsParseException('Missing #EXTM3U header');
  }
  if (isHlsMasterPlaylist(text)) {
    return parseHlsMasterPlaylist(text, playlistUri);
  }
  return parseHlsMediaPlaylist(text, playlistUri);
}

HlsMasterPlaylist parseHlsMasterPlaylist(String text, Uri playlistUri) {
  final List<HlsVariant> variants = <HlsVariant>[];
  final List<HlsAudioRendition> audioRenditions = <HlsAudioRendition>[];
  bool independentSegments = false;
  Map<String, String>? pendingStreamInf;

  for (final String line in _playlistLines(text)) {
    if (line.startsWith(_streamInfTag)) {
      pendingStreamInf = parseHlsAttributes(
        line.substring(_streamInfTag.length),
      );
      continue;
    }
    if (line.startsWith(_mediaTag)) {
      final HlsAudioRendition? rendition = _audioRenditionFrom(
        parseHlsAttributes(line.substring(_mediaTag.length)),
        playlistUri,
      );
      if (rendition != null) {
        audioRenditions.add(rendition);
      }
      continue;
    }
    if (line == '#EXT-X-INDEPENDENT-SEGMENTS') {
      independentSegments = true;
      continue;
    }
    if (line.startsWith('#')) {
      continue;
    }
    final Map<String, String>? streamInf = pendingStreamInf;
    if (streamInf == null) {
      continue;
    }
    variants.add(_variantFrom(streamInf, resolveHlsUri(playlistUri, line)));
    pendingStreamInf = null;
  }

  return HlsMasterPlaylist(
    uri: playlistUri,
    variants: variants,
    audioRenditions: audioRenditions,
    independentSegments: independentSegments,
  );
}

HlsMediaPlaylist parseHlsMediaPlaylist(String text, Uri playlistUri) {
  return _MediaPlaylistParser(playlistUri).parse(text);
}

class _MediaPlaylistParser {
  _MediaPlaylistParser(this.playlistUri);

  final Uri playlistUri;
  final List<HlsSegment> _segments = <HlsSegment>[];
  int? _version;
  int? _targetDuration;
  int _mediaSequence = 0;
  int? _discontinuitySequence;
  bool _independentSegments = false;
  bool _hasEndList = false;
  HlsKey? _currentKey;
  HlsInitSection? _currentInit;
  double? _pendingDuration;
  String _pendingTitle = '';
  _PendingByteRange? _pendingByteRange;
  bool _pendingDiscontinuity = false;
  Uri? _previousRangeUri;
  int _previousRangeEnd = 0;

  HlsMediaPlaylist parse(String text) {
    for (final String line in _playlistLines(text)) {
      if (line.startsWith('#')) {
        _handleTag(line);
      } else {
        _addSegment(line);
      }
    }
    return HlsMediaPlaylist(
      uri: playlistUri,
      segments: _segments,
      version: _version,
      targetDuration: _targetDuration,
      mediaSequence: _mediaSequence,
      discontinuitySequence: _discontinuitySequence,
      independentSegments: _independentSegments,
      hasEndList: _hasEndList,
    );
  }

  void _handleTag(String line) {
    final int colon = line.indexOf(':');
    final String name = colon < 0 ? line : line.substring(0, colon);
    final String value = colon < 0 ? '' : line.substring(colon + 1).trim();
    switch (name) {
      case '#EXTINF':
        _readExtInf(value);
      case '#EXT-X-BYTERANGE':
        _pendingByteRange = _PendingByteRange.parse(value);
      case '#EXT-X-KEY':
        _currentKey = _keyFrom(parseHlsAttributes(value), playlistUri);
      case '#EXT-X-MAP':
        _currentInit = _initSectionFrom(parseHlsAttributes(value));
      case '#EXT-X-MEDIA-SEQUENCE':
        _mediaSequence = int.tryParse(value) ?? 0;
      case '#EXT-X-DISCONTINUITY-SEQUENCE':
        _discontinuitySequence = int.tryParse(value);
      case '#EXT-X-DISCONTINUITY':
        _pendingDiscontinuity = true;
      case '#EXT-X-TARGETDURATION':
        _targetDuration = int.tryParse(value);
      case '#EXT-X-VERSION':
        _version = int.tryParse(value);
      case '#EXT-X-INDEPENDENT-SEGMENTS':
        _independentSegments = true;
      case '#EXT-X-ENDLIST':
        _hasEndList = true;
      case '#EXT-X-STREAM-INF':
        throw const HlsParseException('Expected a media playlist');
    }
  }

  void _readExtInf(String value) {
    final int comma = value.indexOf(',');
    final String durationText = comma < 0 ? value : value.substring(0, comma);
    _pendingDuration = double.tryParse(durationText.trim()) ?? 0;
    _pendingTitle = comma < 0 ? '' : value.substring(comma + 1).trim();
  }

  HlsInitSection? _initSectionFrom(Map<String, String> attributes) {
    final String? uri = attributes['URI'];
    if (uri == null || uri.isEmpty) {
      return null;
    }
    final String? range = attributes['BYTERANGE'];
    return HlsInitSection(
      uri: resolveHlsUri(playlistUri, uri),
      byteRange: range == null
          ? null
          : _PendingByteRange.parse(range).resolve(previousEnd: 0),
    );
  }

  void _addSegment(String line) {
    final Uri uri = resolveHlsUri(playlistUri, line);
    final HlsByteRange? byteRange = _resolvePendingByteRange(uri);
    _segments.add(
      HlsSegment(
        uri: uri,
        duration: _pendingDuration ?? 0,
        title: _pendingTitle,
        sequenceNumber: _mediaSequence + _segments.length,
        byteRange: byteRange,
        key: _currentKey,
        initSection: _currentInit,
        discontinuity: _pendingDiscontinuity,
      ),
    );
    _pendingDuration = null;
    _pendingTitle = '';
    _pendingByteRange = null;
    _pendingDiscontinuity = false;
  }

  HlsByteRange? _resolvePendingByteRange(Uri uri) {
    final _PendingByteRange? pending = _pendingByteRange;
    if (pending == null) {
      return null;
    }
    final int previousEnd = _previousRangeUri == uri ? _previousRangeEnd : 0;
    final HlsByteRange range = pending.resolve(previousEnd: previousEnd);
    _previousRangeUri = uri;
    _previousRangeEnd = range.end;
    return range;
  }
}

class _PendingByteRange {
  const _PendingByteRange({required this.length, this.offset});

  factory _PendingByteRange.parse(String value) {
    final List<String> parts = value.trim().split('@');
    final int? length = int.tryParse(parts.first.trim());
    if (length == null) {
      throw HlsParseException('Invalid byte range "$value"');
    }
    final int? offset = parts.length > 1 ? int.tryParse(parts[1].trim()) : null;
    return _PendingByteRange(length: length, offset: offset);
  }

  final int length;
  final int? offset;

  HlsByteRange resolve({required int previousEnd}) {
    return HlsByteRange(offset: offset ?? previousEnd, length: length);
  }
}

HlsVariant _variantFrom(Map<String, String> attributes, Uri uri) {
  final _Resolution? resolution = _Resolution.parse(attributes['RESOLUTION']);
  return HlsVariant(
    uri: uri,
    bandwidth: int.tryParse(attributes['BANDWIDTH'] ?? ''),
    averageBandwidth: int.tryParse(attributes['AVERAGE-BANDWIDTH'] ?? ''),
    width: resolution?.width,
    height: resolution?.height,
    codecs: attributes['CODECS'],
    frameRate: attributes['FRAME-RATE'],
    audioGroupId: attributes['AUDIO'],
  );
}

HlsAudioRendition? _audioRenditionFrom(
  Map<String, String> attributes,
  Uri playlistUri,
) {
  if (attributes['TYPE']?.toUpperCase() != 'AUDIO') {
    return null;
  }
  final String? groupId = attributes['GROUP-ID'];
  if (groupId == null) {
    return null;
  }
  final String? uri = attributes['URI'];
  return HlsAudioRendition(
    groupId: groupId,
    name: attributes['NAME'] ?? groupId,
    uri: uri == null || uri.isEmpty ? null : resolveHlsUri(playlistUri, uri),
    language: attributes['LANGUAGE'],
    isDefault: attributes['DEFAULT']?.toUpperCase() == 'YES',
    autoSelect: attributes['AUTOSELECT']?.toUpperCase() == 'YES',
    channels: attributes['CHANNELS'],
  );
}

HlsKey _keyFrom(Map<String, String> attributes, Uri playlistUri) {
  final String? uri = attributes['URI'];
  return HlsKey(
    method: attributes['METHOD'] ?? 'NONE',
    uri: uri == null || uri.isEmpty ? null : resolveHlsUri(playlistUri, uri),
    iv: attributes['IV'],
    keyFormat: attributes['KEYFORMAT'],
    keyFormatVersions: attributes['KEYFORMATVERSIONS'],
  );
}

class _Resolution {
  const _Resolution(this.width, this.height);

  static _Resolution? parse(String? value) {
    if (value == null) {
      return null;
    }
    final List<String> parts = value.toLowerCase().split('x');
    if (parts.length != 2) {
      return null;
    }
    final int? width = int.tryParse(parts[0].trim());
    final int? height = int.tryParse(parts[1].trim());
    if (width == null || height == null) {
      return null;
    }
    return _Resolution(width, height);
  }

  final int width;
  final int height;
}

Map<String, String> parseHlsAttributes(String input) {
  final Map<String, String> attributes = <String, String>{};
  int position = 0;
  while (position < input.length) {
    final int equals = input.indexOf('=', position);
    if (equals < 0) {
      break;
    }
    final String name = input.substring(position, equals).trim().toUpperCase();
    final _AttributeValue value = _readAttributeValue(input, equals + 1);
    if (name.isNotEmpty) {
      attributes[name] = value.text;
    }
    position = value.nextPosition;
  }
  return attributes;
}

class _AttributeValue {
  const _AttributeValue(this.text, this.nextPosition);

  final String text;
  final int nextPosition;
}

_AttributeValue _readAttributeValue(String input, int start) {
  if (start < input.length && input[start] == '"') {
    final int closing = input.indexOf('"', start + 1);
    final int end = closing < 0 ? input.length : closing;
    final int comma = input.indexOf(',', end);
    return _AttributeValue(
      input.substring(start + 1, end),
      comma < 0 ? input.length : comma + 1,
    );
  }
  final int comma = input.indexOf(',', start);
  final int end = comma < 0 ? input.length : comma;
  return _AttributeValue(
    input.substring(start, end).trim(),
    comma < 0 ? input.length : comma + 1,
  );
}

Uri resolveHlsUri(Uri base, String reference) {
  final String trimmed = reference.trim();
  try {
    return base.resolveUri(Uri.parse(trimmed));
  } on FormatException {
    return base.resolveUri(Uri.parse(Uri.encodeFull(trimmed)));
  }
}

Iterable<String> _playlistLines(String text) {
  return const LineSplitter()
      .convert(_stripLeadingNoise(text))
      .map((String line) => line.trim())
      .whereNot((String line) => line.isEmpty);
}

String _stripLeadingNoise(String text) {
  String result = text;
  if (result.startsWith('﻿')) {
    result = result.substring(1);
  }
  return result.trimLeft();
}
