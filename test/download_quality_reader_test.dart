import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_quality_selection.dart';
import 'package:wakaranai/services/downloads/storage/download_quality_reader.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('fixedQualityPreferenceOf', () {
    test('defers to the player for the same-as-player option', () {
      expect(fixedQualityPreferenceOf(DownloadQuality.sameAsPlayer), isNull);
    });

    test('maps each fixed option to a stream and rendition label', () {
      expect(
        fixedQualityPreferenceOf(DownloadQuality.highest),
        const QualityPreference(streamLabel: 'Auto', renditionLabel: 'Auto'),
      );
      expect(
        fixedQualityPreferenceOf(DownloadQuality.p1080),
        const QualityPreference(streamLabel: '1080p', renditionLabel: '1080p'),
      );
      expect(
        fixedQualityPreferenceOf(DownloadQuality.p720),
        const QualityPreference(streamLabel: '720p', renditionLabel: '720p'),
      );
      expect(
        fixedQualityPreferenceOf(DownloadQuality.p480),
        const QualityPreference(streamLabel: '480p', renditionLabel: '480p'),
      );
    });

    test('maps fixed options to the hls height they ask for', () {
      expect(
        wantedHeightFor(fixedQualityPreferenceOf(DownloadQuality.highest)!),
        isNull,
      );
      expect(
        wantedHeightFor(fixedQualityPreferenceOf(DownloadQuality.p720)!),
        720,
      );
    });
  });

  group('downloadQualityPreferenceReader', () {
    const QualityPreference playerChoice =
        QualityPreference(streamLabel: 'Kodik', renditionLabel: '360p');

    test('uses the player quality when set to same as player', () async {
      int playerReads = 0;
      final QualityPreference result = await downloadQualityPreferenceReader(
        readDownloadQuality: () async => DownloadQuality.sameAsPlayer,
        readPlayerQuality: () async {
          playerReads++;
          return playerChoice;
        },
      )();

      expect(result, playerChoice);
      expect(playerReads, 1);
    });

    test('ignores the player quality when a fixed quality is chosen', () async {
      int playerReads = 0;
      final QualityPreference result = await downloadQualityPreferenceReader(
        readDownloadQuality: () async => DownloadQuality.p480,
        readPlayerQuality: () async {
          playerReads++;
          return playerChoice;
        },
      )();

      expect(result.renditionLabel, '480p');
      expect(playerReads, 0);
    });

    test('defaults to the player quality with nothing stored', () async {
      final PlayerPreferences player = PlayerPreferences();
      await player.setQualityPreference(playerChoice);

      final QualityPreference result =
          await defaultDownloadQualityPreferenceReader()();

      expect(result, playerChoice);
    });

    test('reads the stored download quality', () async {
      await DownloadStoragePreferences().setQuality(DownloadQuality.p1080);

      final QualityPreference result =
          await defaultDownloadQualityPreferenceReader()();

      expect(result.streamLabel, '1080p');
    });
  });

  group('preferredDownloadStreamIndex', () {
    const List<PlayableStream> streams = <PlayableStream>[
      PlayableStream(url: 'https://a/720.mp4', quality: '720p'),
      PlayableStream(url: 'https://a/1080.mp4', quality: 'FullHD 1080p'),
      PlayableStream(url: 'https://a/480.mp4', quality: '480p'),
    ];

    test('prefers an exact label match', () {
      expect(preferredDownloadStreamIndex(streams, '480p'), 2);
    });

    test('picks the tallest stream for the highest option', () {
      expect(preferredDownloadStreamIndex(streams, 'Auto'), 1);
    });

    test('picks the closest lower height for a missing tier', () {
      expect(preferredDownloadStreamIndex(streams, '1080p'), 1);
      expect(preferredDownloadStreamIndex(streams, '900p'), 0);
    });

    test('falls back to the lowest stream when every one is taller', () {
      expect(preferredDownloadStreamIndex(streams, '360p'), 2);
    });

    test('keeps the first stream for labels that are not quality tiers', () {
      expect(preferredDownloadStreamIndex(streams, 'Kodik'), 0);
      expect(preferredDownloadStreamIndex(streams, null), 0);
    });

    test('keeps the first stream when no stream has a height', () {
      const List<PlayableStream> unlabelled = <PlayableStream>[
        PlayableStream(url: 'https://a/a.mp4', quality: 'Main'),
        PlayableStream(url: 'https://a/b.mp4'),
      ];
      expect(preferredDownloadStreamIndex(unlabelled, 'Auto'), 0);
    });

    test('orders the download attempts from the preferred stream', () {
      expect(downloadableStreamOrder(streams, 'Auto'), <int>[1, 0, 2]);
    });
  });
}
