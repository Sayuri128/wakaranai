import 'dart:convert';

import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';

const int kMediaSniffLength = 189;
const int _tsPacketLength = 188;
const int _tsSyncByte = 0x47;

enum SniffedMedia { video, webPage, hlsPlaylist, dashManifest, unknown }

const Set<String> _isoBoxTypes = <String>{
  'ftyp',
  'styp',
  'moov',
  'mdat',
  'free',
  'skip',
  'wide',
  'pdin',
  'moof',
  'sidx',
};

const List<int> _ebmlMagic = <int>[0x1a, 0x45, 0xdf, 0xa3];
const List<int> _flvMagic = <int>[0x46, 0x4c, 0x56];
const List<int> _mpegPsMagic = <int>[0x00, 0x00, 0x01, 0xba];

const Set<String> _webPageContentTypes = <String>{
  'text/html',
  'application/xhtml+xml',
};
const Set<String> _dashContentTypes = <String>{'application/dash+xml'};

SniffedMedia? sniffContentType(String? contentType) {
  if (contentType == null) {
    return null;
  }
  final String mimeType = contentType.split(';').first.trim().toLowerCase();
  if (_webPageContentTypes.contains(mimeType)) {
    return SniffedMedia.webPage;
  }
  if (_dashContentTypes.contains(mimeType)) {
    return SniffedMedia.dashManifest;
  }
  return null;
}

SniffedMedia sniffMediaHead(List<int> head) {
  if (_isVideoContainer(head)) {
    return SniffedMedia.video;
  }
  final String text = _leadingText(head);
  if (text.startsWith('#EXTM3U')) {
    return SniffedMedia.hlsPlaylist;
  }
  if (text.startsWith('<')) {
    if (text.contains('<MPD')) {
      return SniffedMedia.dashManifest;
    }
    return SniffedMedia.webPage;
  }
  return SniffedMedia.unknown;
}

UnsupportedEpisodeDownload nonVideoRejection(SniffedMedia kind, String url) {
  switch (kind) {
    case SniffedMedia.webPage:
      return UnsupportedEpisodeDownload(
        'Got a web page instead of a video from $url',
      );
    case SniffedMedia.dashManifest:
      return UnsupportedEpisodeDownload('DASH is not supported: $url');
    case SniffedMedia.hlsPlaylist:
      return UnsupportedEpisodeDownload(
        'Got an HLS playlist instead of a video file from $url',
      );
    case SniffedMedia.video:
    case SniffedMedia.unknown:
      return UnsupportedEpisodeDownload('Not a video file: $url');
  }
}

bool _isVideoContainer(List<int> head) {
  return _isIsoBmff(head) ||
      _startsWith(head, _ebmlMagic) ||
      _isMpegTs(head) ||
      _startsWith(head, _flvMagic) ||
      _startsWith(head, _mpegPsMagic);
}

bool _isIsoBmff(List<int> head) {
  if (head.length < 8) {
    return false;
  }
  final String boxType = String.fromCharCodes(head.sublist(4, 8));
  return _isoBoxTypes.contains(boxType);
}

bool _isMpegTs(List<int> head) {
  if (head.isEmpty || head[0] != _tsSyncByte) {
    return false;
  }
  if (head.length <= _tsPacketLength) {
    return true;
  }
  return head[_tsPacketLength] == _tsSyncByte;
}

bool _startsWith(List<int> head, List<int> magic) {
  if (head.length < magic.length) {
    return false;
  }
  for (int index = 0; index < magic.length; index++) {
    if (head[index] != magic[index]) {
      return false;
    }
  }
  return true;
}

String _leadingText(List<int> head) {
  String text = utf8.decode(head, allowMalformed: true);
  if (text.startsWith('﻿')) {
    text = text.substring(1);
  }
  return text.trimLeft();
}
