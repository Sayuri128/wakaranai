import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_track_selection.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PlayerPreferences', () {
    test('returns sensible defaults when nothing is stored', () async {
      final PlayerPreferences preferences = PlayerPreferences();

      expect(await preferences.getPlaybackSpeed(), 1.0);
      expect(await preferences.getHoldSpeed(), 2.0);
      expect(await preferences.getSubtitle(), isNull);
      expect(
        await preferences.getQualityPreference(),
        const QualityPreference(),
      );
      expect(await preferences.getSkipOpeningSeconds(), 85);
      expect(await preferences.getAutoPlayNext(), isTrue);
      expect(await preferences.getFitMode(), PlayerFitMode.fit);
    });

    test('round-trips every player setting', () async {
      final PlayerPreferences writer = PlayerPreferences();
      await writer.setPlaybackSpeed(2.5);
      await writer.setHoldSpeed(3.0);
      await writer.setSubtitle(const SubtitlePreference.language('en'));
      await writer.setQualityPreference(
        const QualityPreference(
          streamLabel: ' Auto (H.264) ',
          renditionLabel: ' 720p ',
        ),
      );
      await writer.setSkipOpeningSeconds(90);
      await writer.setAutoPlayNext(false);
      await writer.setFitMode(PlayerFitMode.stretch);

      final PlayerPreferences reader = PlayerPreferences();
      expect(await reader.getPlaybackSpeed(), 2.5);
      expect(await reader.getHoldSpeed(), 3.0);
      expect(
        await reader.getSubtitle(),
        const SubtitlePreference.language('en'),
      );
      expect(
        await reader.getQualityPreference(),
        const QualityPreference(
          streamLabel: 'Auto (H.264)',
          renditionLabel: '720p',
        ),
      );
      expect(await reader.getSkipOpeningSeconds(), 90);
      expect(await reader.getAutoPlayNext(), isFalse);
      expect(await reader.getFitMode(), PlayerFitMode.stretch);
    });

    test('stores keys with the PLAYER_ prefix', () async {
      final PlayerPreferences preferences = PlayerPreferences();
      await preferences.setPlaybackSpeed(1.5);
      await preferences.setSubtitle(const SubtitlePreference.off());
      await preferences.setFitMode(PlayerFitMode.fill);

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(
        raw.getKeys().every((String key) => key.startsWith('PLAYER_')),
        isTrue,
      );
      expect(raw.getString(PlayerPreferences.subtitleKey), 'off');
    });

    test('reads the legacy single quality key when nothing newer exists',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: ' 720p ',
      });

      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference.legacy('720p'),
      );
    });

    test('prefers the stream and rendition keys over the legacy key',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '1080p',
        PlayerPreferences.qualityRenditionKey: '480p',
      });

      expect(
        await PlayerPreferences().getQualityPreference(),
        const QualityPreference(renditionLabel: '480p'),
      );
    });

    test('saving a quality drops the legacy key and clears empty labels',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.legacyQualityKey: '1080p',
        PlayerPreferences.qualityStreamKey: 'Auto (H.265)',
      });
      final PlayerPreferences preferences = PlayerPreferences();

      await preferences.setQualityPreference(
        const QualityPreference(renditionLabel: 'Auto'),
      );

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.containsKey(PlayerPreferences.legacyQualityKey), isFalse);
      expect(raw.containsKey(PlayerPreferences.qualityStreamKey), isFalse);
      expect(raw.getString(PlayerPreferences.qualityRenditionKey), 'Auto');
    });

    test('clamps a stored out-of-range speed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.playbackSpeedKey: 9.0,
      });

      expect(await PlayerPreferences().getPlaybackSpeed(), 4.0);
    });

    test('ignores unknown hold speeds and skip amounts', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PlayerPreferences.holdSpeedKey: 7.0,
        PlayerPreferences.skipOpeningSecondsKey: 13,
      });
      final PlayerPreferences preferences = PlayerPreferences();

      expect(await preferences.getHoldSpeed(), 2.0);
      expect(await preferences.getSkipOpeningSeconds(), 85);
    });
  });

  group('normalizePlaybackSpeed', () {
    test('clamps to the supported range', () {
      expect(normalizePlaybackSpeed(0.1), 0.25);
      expect(normalizePlaybackSpeed(10), 4.0);
    });

    test('snaps to the slider step', () {
      expect(normalizePlaybackSpeed(1.33), 1.35);
      expect(normalizePlaybackSpeed(2.02), 2.0);
    });
  });

  group('holdPlaybackSpeed', () {
    test('uses the configured speed when it is faster', () {
      expect(
        holdPlaybackSpeed(currentSpeed: 1.0, configuredHoldSpeed: 2.0),
        2.0,
      );
      expect(
        holdPlaybackSpeed(currentSpeed: 0.5, configuredHoldSpeed: 1.5),
        1.5,
      );
    });

    test('steps above the current speed when it is not slower', () {
      expect(
        holdPlaybackSpeed(currentSpeed: 2.0, configuredHoldSpeed: 2.0),
        3.0,
      );
      expect(
        holdPlaybackSpeed(currentSpeed: 2.5, configuredHoldSpeed: 1.5),
        3.75,
      );
      expect(
        holdPlaybackSpeed(currentSpeed: 3.0, configuredHoldSpeed: 2.0),
        4.0,
      );
    });

    test('returns nothing when no faster speed exists', () {
      expect(
        holdPlaybackSpeed(currentSpeed: 4.0, configuredHoldSpeed: 4.0),
        isNull,
      );
    });
  });

  group('SubtitlePreference', () {
    test('encodes and decodes every kind', () {
      const List<SubtitlePreference> preferences = <SubtitlePreference>[
        SubtitlePreference.off(),
        SubtitlePreference.language('pt-BR'),
        SubtitlePreference.label('English: Full'),
      ];
      for (final SubtitlePreference preference in preferences) {
        expect(SubtitlePreference.decode(preference.encode()), preference);
      }
    });

    test('rejects malformed values', () {
      expect(SubtitlePreference.decode('language:'), isNull);
      expect(SubtitlePreference.decode('garbage'), isNull);
      expect(SubtitlePreference.decode(null), isNull);
    });
  });

  group('preferredStreamIndex', () {
    const List<PlayableStream> streams = <PlayableStream>[
      PlayableStream(url: 'https://cdn.test/1080.m3u8', quality: '1080p'),
      PlayableStream(url: 'https://cdn.test/720.m3u8', quality: '720p'),
      PlayableStream(url: 'https://cdn.test/raw.m3u8'),
    ];

    test('picks the stream whose quality matches', () {
      expect(preferredStreamIndex(streams, '720P'), 1);
    });

    test('falls back to the first stream', () {
      expect(preferredStreamIndex(streams, '480p'), 0);
      expect(preferredStreamIndex(streams, null), 0);
    });
  });

  group('preferredSubtitleIndex', () {
    const List<PlayableSubtitle> subtitles = <PlayableSubtitle>[
      PlayableSubtitle(url: 'https://cdn.test/ru.vtt', language: 'ru'),
      PlayableSubtitle(
        url: 'https://cdn.test/en.vtt',
        language: 'en-US',
        label: 'English',
      ),
      PlayableSubtitle(url: 'https://cdn.test/signs.vtt', label: 'Signs'),
    ];

    test('matches by language', () {
      expect(
        preferredSubtitleIndex(
          subtitles,
          const SubtitlePreference.language('en-us'),
        ),
        1,
      );
    });

    test('matches by primary language tag', () {
      expect(
        preferredSubtitleIndex(
          subtitles,
          const SubtitlePreference.language('en'),
        ),
        1,
      );
    });

    test('matches by label', () {
      expect(
        preferredSubtitleIndex(
          subtitles,
          const SubtitlePreference.label('signs'),
        ),
        2,
      );
    });

    test('returns nothing for off, unknown or missing preferences', () {
      expect(
        preferredSubtitleIndex(subtitles, const SubtitlePreference.off()),
        isNull,
      );
      expect(
        preferredSubtitleIndex(
          subtitles,
          const SubtitlePreference.language('de'),
        ),
        isNull,
      );
      expect(preferredSubtitleIndex(subtitles, null), isNull);
    });

    test('remembers language first and label as a fallback', () {
      expect(
        subtitlePreferenceFor(subtitles[1]),
        const SubtitlePreference.language('en-US'),
      );
      expect(
        subtitlePreferenceFor(subtitles[2]),
        const SubtitlePreference.label('Signs'),
      );
      expect(
        subtitlePreferenceFor(const PlayableSubtitle(url: 'https://x/y.vtt')),
        isNull,
      );
    });
  });
}
