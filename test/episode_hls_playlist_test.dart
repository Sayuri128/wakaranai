import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/episode_quality_selection.dart';
import 'package:wakaranai/services/downloads/episode/hls_local_playlist.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';

const String masterText = '''
#EXTM3U
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aud",NAME="Japanese, Stereo",LANGUAGE="ja",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="2",URI="audio/ja.m3u8?sig=abc"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aud",NAME="English",LANGUAGE="en",DEFAULT=NO,URI="audio/en.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",URI="subs/en.m3u8"
#EXT-X-STREAM-INF:BANDWIDTH=800000,AVERAGE-BANDWIDTH=700000,RESOLUTION=640x360,CODECS="avc1.4d401e,mp4a.40.2",AUDIO="aud"
360/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2500000,RESOLUTION=1280x720,FRAME-RATE=23.976,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="aud"
https://cdn.example.com/720/index.m3u8?token=x
''';

const String encryptedMediaText = '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXT-X-MEDIA-SEQUENCE:5
#EXT-X-KEY:METHOD=AES-128,URI="/keys/k1?t=1",IV=0x000102030405060708090a0b0c0d0e0f
#EXTINF:5.005,
seg5.ts?t=1
#EXT-X-DISCONTINUITY
#EXT-X-KEY:METHOD=NONE
#EXTINF:4.5,title
../other/seg6.ts
#EXT-X-ENDLIST
''';

const String byteRangeMediaText = '''
#EXTM3U
#EXT-X-VERSION:7
#EXT-X-TARGETDURATION:4
#EXT-X-MAP:URI="main.mp4",BYTERANGE="720@0"
#EXTINF:4,
#EXT-X-BYTERANGE:1000@720
main.mp4
#EXTINF:3.5,
#EXT-X-BYTERANGE:1200
main.mp4
''';

final Uri masterUri = Uri.parse(
  'https://host.example.com/hls/master.m3u8?exp=1&sig=zz',
);
final Uri mediaUri = Uri.parse(
  'https://media.example.com/a/b/index.m3u8?token=abc',
);

HlsVariant variant({int? height, int? bandwidth}) {
  return HlsVariant(
    uri: Uri.parse('https://cdn/${height ?? 'x'}/${bandwidth ?? 0}.m3u8'),
    height: height,
    width: height == null ? null : height * 16 ~/ 9,
    bandwidth: bandwidth,
  );
}

void main() {
  group('master playlist parsing', () {
    test('reads variants and audio renditions with quoted commas', () {
      final HlsMasterPlaylist master =
          parseHlsPlaylist(masterText, masterUri) as HlsMasterPlaylist;

      expect(master.independentSegments, isTrue);
      expect(master.variants, hasLength(2));
      final HlsVariant low = master.variants.first;
      expect(low.uri.toString(), 'https://host.example.com/hls/360/index.m3u8');
      expect(low.bandwidth, 800000);
      expect(low.averageBandwidth, 700000);
      expect(low.width, 640);
      expect(low.height, 360);
      expect(low.codecs, 'avc1.4d401e,mp4a.40.2');
      expect(low.audioGroupId, 'aud');
      final HlsVariant high = master.variants.last;
      expect(
        high.uri.toString(),
        'https://cdn.example.com/720/index.m3u8?token=x',
      );
      expect(high.frameRate, '23.976');

      expect(master.audioRenditions, hasLength(2));
      final HlsAudioRendition japanese = master.audioRenditions.first;
      expect(japanese.name, 'Japanese, Stereo');
      expect(japanese.language, 'ja');
      expect(japanese.isDefault, isTrue);
      expect(japanese.autoSelect, isTrue);
      expect(japanese.channels, '2');
      expect(
        japanese.uri.toString(),
        'https://host.example.com/hls/audio/ja.m3u8?sig=abc',
      );
      expect(master.audioRenditions.last.isDefault, isFalse);
    });

    test('picks the default audio rendition with a uri', () {
      final HlsMasterPlaylist master =
          parseHlsPlaylist(masterText, masterUri) as HlsMasterPlaylist;

      final HlsAudioRendition? audio = pickAudioRendition(
        master,
        master.variants.first,
      );

      expect(audio?.name, 'Japanese, Stereo');
    });

    test('parses attribute lists with quoted commas and bare values', () {
      expect(
        parseHlsAttributes('A=1,B="x,y",c=NO,D="",E=0x0F'),
        <String, String>{'A': '1', 'B': 'x,y', 'C': 'NO', 'D': '', 'E': '0x0F'},
      );
    });
  });

  group('media playlist parsing', () {
    test('reads keys, ivs, sequence numbers and discontinuities', () {
      final HlsMediaPlaylist media =
          parseHlsPlaylist(encryptedMediaText, mediaUri) as HlsMediaPlaylist;

      expect(media.version, 3);
      expect(media.targetDuration, 6);
      expect(media.mediaSequence, 5);
      expect(media.hasEndList, isTrue);
      expect(media.segments, hasLength(2));

      final HlsSegment first = media.segments.first;
      expect(first.uri.toString(), 'https://media.example.com/a/b/seg5.ts?t=1');
      expect(first.duration, 5.005);
      expect(first.sequenceNumber, 5);
      expect(first.key?.isAes128, isTrue);
      expect(
        first.key?.uri.toString(),
        'https://media.example.com/keys/k1?t=1',
      );
      expect(first.key?.iv, '0x000102030405060708090a0b0c0d0e0f');

      final HlsSegment second = media.segments.last;
      expect(
        second.uri.toString(),
        'https://media.example.com/a/other/seg6.ts',
      );
      expect(second.title, 'title');
      expect(second.sequenceNumber, 6);
      expect(second.discontinuity, isTrue);
      expect(second.key?.isNone, isTrue);
    });

    test('continues implicit byte ranges and reads the init map', () {
      final HlsMediaPlaylist media =
          parseHlsPlaylist(byteRangeMediaText, mediaUri) as HlsMediaPlaylist;

      final HlsInitSection? init = media.segments.first.initSection;
      expect(init?.uri.toString(), 'https://media.example.com/a/b/main.mp4');
      expect(init?.byteRange, const HlsByteRange(offset: 0, length: 720));
      expect(
        media.segments.first.byteRange,
        const HlsByteRange(offset: 720, length: 1000),
      );
      expect(
        media.segments.last.byteRange,
        const HlsByteRange(offset: 1720, length: 1200),
      );
      expect(media.segments.last.byteRange?.rangeHeader, 'bytes=1720-2919');
      expect(media.hasEndList, isFalse);
    });

    test('rejects text without an EXTM3U header', () {
      expect(
        () => parseHlsPlaylist('<html></html>', mediaUri),
        throwsA(isA<HlsParseException>()),
      );
    });
  });

  group('variant choice', () {
    final List<HlsVariant> variants = <HlsVariant>[
      variant(height: 480, bandwidth: 1000),
      variant(height: 1080, bandwidth: 5000),
      variant(height: 720, bandwidth: 2500),
      variant(height: 720, bandwidth: 3000),
    ];

    test('picks the closest height at or below the wanted one', () {
      expect(pickHlsVariant(variants, 900).height, 720);
      expect(pickHlsVariant(variants, 900).bandwidth, 3000);
      expect(pickHlsVariant(variants, 480).height, 480);
    });

    test('falls back to the lowest when everything is taller', () {
      expect(pickHlsVariant(variants, 360).height, 480);
    });

    test('picks the highest when no height is wanted', () {
      expect(pickHlsVariant(variants, null).height, 1080);
    });

    test('picks the highest bandwidth without height info', () {
      final List<HlsVariant> unknown = <HlsVariant>[
        variant(bandwidth: 100),
        variant(bandwidth: 900),
        variant(bandwidth: 500),
      ];
      expect(pickHlsVariant(unknown, 720).bandwidth, 900);
    });

    test('derives the wanted height from the remembered quality', () {
      expect(
        wantedHeightFor(
          const QualityPreference(streamLabel: 'FHD', renditionLabel: '720p'),
        ),
        720,
      );
      expect(
        wantedHeightFor(const QualityPreference(streamLabel: '1080p')),
        1080,
      );
      expect(
        wantedHeightFor(
          const QualityPreference(streamLabel: '480p', renditionLabel: 'Auto'),
        ),
        isNull,
      );
      expect(wantedHeightFor(const QualityPreference()), isNull);
    });

    test('orders streams by preference and skips dash', () {
      const List<PlayableStream> streams = <PlayableStream>[
        PlayableStream(url: 'https://a/manifest.mpd', quality: 'DASH'),
        PlayableStream(url: 'https://a/low.mp4', quality: '480p'),
        PlayableStream(url: 'https://a/hi.m3u8', quality: '1080p'),
      ];
      expect(downloadableStreamOrder(streams, 'DASH'), <int>[1, 2]);
      expect(downloadableStreamOrder(streams, '1080p'), <int>[2, 1]);
      expect(downloadableStreamOrder(streams, null), <int>[1, 2]);
    });
  });

  group('local playlist', () {
    test('rewrites keys and segments to relative local files', () {
      final HlsMediaPlaylist media = parseHlsMediaPlaylist(
        encryptedMediaText,
        mediaUri,
      );
      final HlsLocalTrack track = HlsLocalTrack.build(
        media,
        folder: kLocalVideoFolder,
        keyFiles: HlsKeyFiles(),
      );

      final String rendered = track.render();

      expect(rendered.split('\n'), <String>[
        '#EXTM3U',
        '#EXT-X-VERSION:3',
        '#EXT-X-TARGETDURATION:6',
        '#EXT-X-MEDIA-SEQUENCE:5',
        '#EXT-X-PLAYLIST-TYPE:VOD',
        '#EXT-X-KEY:METHOD=AES-128,URI="keys/0.key",'
            'IV=0x000102030405060708090a0b0c0d0e0f',
        '#EXTINF:5.005,',
        'v/000001.ts',
        '#EXT-X-DISCONTINUITY',
        '#EXT-X-KEY:METHOD=NONE',
        '#EXTINF:4.5,title',
        'v/000002.ts',
        '#EXT-X-ENDLIST',
        '',
      ]);
      expect(track.auxiliaryTasks.single.kind, HlsFileKind.key);
      expect(
        track.auxiliaryTasks.single.uri.toString(),
        'https://media.example.com/keys/k1?t=1',
      );
    });

    test('splits byte ranges into files and points the map locally', () {
      final HlsMediaPlaylist media = parseHlsMediaPlaylist(
        byteRangeMediaText,
        mediaUri,
      );
      final HlsLocalTrack track = HlsLocalTrack.build(
        media,
        folder: kLocalVideoFolder,
        keyFiles: HlsKeyFiles(),
      );

      final String rendered = track.render();

      expect(rendered, contains('#EXT-X-MAP:URI="v/init0.mp4"\n'));
      expect(rendered, isNot(contains('BYTERANGE')));
      expect(rendered, contains('v/000001.mp4\n'));
      expect(rendered, contains('v/000002.mp4\n'));
      expect(rendered, contains('#EXT-X-PLAYLIST-TYPE:VOD'));
      expect(rendered, endsWith('#EXT-X-ENDLIST\n'));
      expect(
        track.segmentTasks.map((HlsFileTask task) => task.byteRange),
        <HlsByteRange>[
          const HlsByteRange(offset: 720, length: 1000),
          const HlsByteRange(offset: 1720, length: 1200),
        ],
      );
      expect(
        track.auxiliaryTasks.single.byteRange,
        const HlsByteRange(offset: 0, length: 720),
      );
    });

    test('keeps segment extensions that make sense and falls back to ts', () {
      const String text = '#EXTM3U\n#EXTINF:2,\na.jpg?x=1\n#EXTINF:2,\nb.aac\n';
      final HlsLocalTrack track = HlsLocalTrack.build(
        parseHlsMediaPlaylist(text, mediaUri),
        folder: kLocalAudioFolder,
        keyFiles: HlsKeyFiles(),
      );

      expect(track.segmentFiles, <String>['a/000001.ts', 'a/000002.aac']);
    });

    test('rejects sample-aes and non identity key formats', () {
      const String sampleAes =
          '#EXTM3U\n'
          '#EXT-X-KEY:METHOD=SAMPLE-AES,URI="skd://key"\n'
          '#EXTINF:2,\na.ts\n';
      const String fairPlay =
          '#EXTM3U\n'
          '#EXT-X-KEY:METHOD=AES-128,URI="k",KEYFORMAT="com.apple.streamingkeydelivery"\n'
          '#EXTINF:2,\na.ts\n';
      for (final String text in <String>[sampleAes, fairPlay]) {
        expect(
          () => HlsLocalTrack.build(
            parseHlsMediaPlaylist(text, mediaUri),
            folder: kLocalVideoFolder,
            keyFiles: HlsKeyFiles(),
          ),
          throwsA(isA<UnsupportedEpisodeDownload>()),
        );
      }
    });

    test('writes a local master for a separate audio rendition', () {
      final HlsMasterPlaylist master =
          parseHlsPlaylist(masterText, masterUri) as HlsMasterPlaylist;

      final String rendered = renderLocalMasterPlaylist(
        variant: master.variants.last,
        audio: master.audioRenditions.first,
      );

      expect(rendered.split('\n'), <String>[
        '#EXTM3U',
        '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Japanese, Stereo",'
            'LANGUAGE="ja",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="2",'
            'URI="audio.m3u8"',
        '#EXT-X-STREAM-INF:BANDWIDTH=2500000,RESOLUTION=1280x720,'
            'CODECS="avc1.4d401f,mp4a.40.2",FRAME-RATE=23.976,AUDIO="audio"',
        'video.m3u8',
        '',
      ]);
    });
  });
}
