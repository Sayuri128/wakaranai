import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';

const List<PlayableStream> _dubAndSub = <PlayableStream>[
  PlayableStream(url: 'https://a.test/1', quality: ' 1080p ', audioLabel: 'Dub'),
  PlayableStream(url: 'https://a.test/2', quality: '720p', audioLabel: ' Sub '),
];

void main() {
  group('rememberedQualityPreference', () {
    test('remembers the chosen stream, audio and rendition labels', () {
      final QualityPreference remembered = rememberedQualityPreference(
        previous: const QualityPreference(),
        streams: _dubAndSub,
        streamIndex: 1,
        renditionLabel: '480p',
      );

      expect(
        remembered,
        const QualityPreference(
          streamLabel: '720p',
          renditionLabel: '480p',
          audioLabel: 'Sub',
        ),
      );
    });

    test('keeps the previous stream and audio for a single stream', () {
      final QualityPreference remembered = rememberedQualityPreference(
        previous: const QualityPreference(
          streamLabel: 'Main',
          renditionLabel: '1080p',
          audioLabel: 'Dub',
        ),
        streams: const <PlayableStream>[
          PlayableStream(url: 'https://a.test/1', quality: 'Other'),
        ],
        streamIndex: 0,
        renditionLabel: kAutoQualityLabel,
      );

      expect(
        remembered,
        const QualityPreference(
          streamLabel: 'Main',
          renditionLabel: kAutoQualityLabel,
          audioLabel: 'Dub',
        ),
      );
    });

    test('drops a legacy stream label it cannot replace', () {
      final QualityPreference remembered = rememberedQualityPreference(
        previous: const QualityPreference.legacy('1080p'),
        streams: const <PlayableStream>[
          PlayableStream(url: 'https://a.test/1'),
          PlayableStream(url: 'https://a.test/2', quality: '  '),
        ],
        streamIndex: 1,
        renditionLabel: kAutoQualityLabel,
      );

      expect(remembered.streamLabel, isNull);
      expect(remembered.audioLabel, isNull);
      expect(remembered.fromLegacyLabel, isFalse);
    });

    test('keeps the previous stream label when the stream has none', () {
      final QualityPreference remembered = rememberedQualityPreference(
        previous: const QualityPreference(streamLabel: 'Main'),
        streams: const <PlayableStream>[
          PlayableStream(url: 'https://a.test/1', audioLabel: 'Dub'),
          PlayableStream(url: 'https://a.test/2'),
        ],
        streamIndex: 0,
        renditionLabel: kAutoQualityLabel,
      );

      expect(remembered.streamLabel, 'Main');
      expect(remembered.audioLabel, 'Dub');
    });
  });
}
