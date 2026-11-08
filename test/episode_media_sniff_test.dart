import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/episode/episode_media_sniff.dart';

List<int> tsPackets(int count) {
  return <int>[
    for (int packet = 0; packet < count; packet++) ...<int>[
      0x47,
      ...List<int>.filled(187, packet),
    ],
  ];
}

void main() {
  test('recognises video containers by their first bytes', () {
    final Map<String, List<int>> containers = <String, List<int>>{
      'mp4': <int>[0, 0, 0, 0x18, ...ascii.encode('ftypisom'), 1, 2],
      'fragment': <int>[0, 0, 0, 0x18, ...ascii.encode('stypmsdh')],
      'moov first': <int>[0, 0, 0, 0x18, ...ascii.encode('moov')],
      'webm': <int>[0x1a, 0x45, 0xdf, 0xa3, 0x9f, 0x42],
      'ts': tsPackets(2),
      'flv': <int>[...ascii.encode('FLV'), 1, 5],
    };
    containers.forEach((String name, List<int> head) {
      expect(sniffMediaHead(head), SniffedMedia.video, reason: name);
    });
  });

  test('tells web pages, playlists and manifests apart', () {
    expect(
      sniffMediaHead(utf8.encode('﻿  <!DOCTYPE html><html>')),
      SniffedMedia.webPage,
    );
    expect(
      sniffMediaHead(utf8.encode('#EXTM3U\n#EXT-X-VERSION:3\n')),
      SniffedMedia.hlsPlaylist,
    );
    expect(
      sniffMediaHead(utf8.encode('<?xml version="1.0"?>\n<MPD type="x">')),
      SniffedMedia.dashManifest,
    );
    expect(
      sniffMediaHead(utf8.encode('{"error":"forbidden"}')),
      SniffedMedia.unknown,
    );
  });

  test('needs a second sync byte to call a long head transport stream', () {
    final List<int> head = tsPackets(2)..[188] = 0x00;

    expect(sniffMediaHead(head), SniffedMedia.unknown);
  });

  test('reads html and dash content types', () {
    expect(sniffContentType('text/html; charset=utf-8'), SniffedMedia.webPage);
    expect(sniffContentType('application/dash+xml'), SniffedMedia.dashManifest);
    expect(sniffContentType('video/mp4'), isNull);
    expect(sniffContentType(null), isNull);
  });
}
