import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/services/device/external_player.dart';

void main() {
  test('picks the highest labelled quality for an external player', () {
    final PlayableStream? stream = pickExternalStream(const <PlayableStream>[
      PlayableStream(url: 'https://cdn/480.m3u8', quality: '480p'),
      PlayableStream(url: 'https://cdn/1080.m3u8', quality: '1080p'),
      PlayableStream(url: 'https://cdn/720.m3u8', quality: '720p'),
    ]);
    expect(stream?.url, 'https://cdn/1080.m3u8');
  });

  test('returns nothing without streams', () {
    expect(pickExternalStream(const <PlayableStream>[]), isNull);
  });

  test('derives the mime type from the format or the url', () {
    expect(
      externalMimeType(const PlayableStream(
        url: 'https://cdn/a',
        format: PlayableStreamFormat.hls,
      )),
      'application/x-mpegURL',
    );
    expect(
      externalMimeType(const PlayableStream(url: 'https://cdn/video.mp4?t=1')),
      'video/mp4',
    );
    expect(
      externalMimeType(const PlayableStream(url: 'https://cdn/stream')),
      'video/*',
    );
  });
}
