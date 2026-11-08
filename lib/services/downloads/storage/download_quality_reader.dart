import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';

typedef QualityPreferenceReader = Future<QualityPreference> Function();

QualityPreference? fixedQualityPreferenceOf(
  DownloadQuality quality, {
  String? audioLabel,
}) {
  switch (quality) {
    case DownloadQuality.sameAsPlayer:
      return null;
    case DownloadQuality.highest:
      return _qualityAt(kAutoQualityLabel, audioLabel);
    case DownloadQuality.p1080:
      return _qualityAt('1080p', audioLabel);
    case DownloadQuality.p720:
      return _qualityAt('720p', audioLabel);
    case DownloadQuality.p480:
      return _qualityAt('480p', audioLabel);
  }
}

QualityPreference _qualityAt(String label, String? audioLabel) {
  return QualityPreference(
    streamLabel: label,
    renditionLabel: label,
    audioLabel: audioLabel,
  );
}

QualityPreferenceReader downloadQualityPreferenceReader({
  required Future<DownloadQuality> Function() readDownloadQuality,
  required QualityPreferenceReader readPlayerQuality,
}) {
  return () async {
    final DownloadQuality quality = await readDownloadQuality();
    final QualityPreference playerQuality = await readPlayerQuality();
    final QualityPreference? fixed = fixedQualityPreferenceOf(
      quality,
      audioLabel: playerQuality.audioLabel,
    );
    if (fixed != null) {
      return fixed;
    }
    return playerQuality;
  };
}

QualityPreferenceReader defaultDownloadQualityPreferenceReader() {
  final DownloadStoragePreferences storagePreferences =
      DownloadStoragePreferences();
  final PlayerPreferences playerPreferences = PlayerPreferences();
  return downloadQualityPreferenceReader(
    readDownloadQuality: storagePreferences.getQuality,
    readPlayerQuality: playerPreferences.getQualityPreference,
  );
}
