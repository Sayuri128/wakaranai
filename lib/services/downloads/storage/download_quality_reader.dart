import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';

QualityPreference? fixedQualityPreferenceOf(DownloadQuality quality) {
  switch (quality) {
    case DownloadQuality.sameAsPlayer:
      return null;
    case DownloadQuality.highest:
      return _qualityAt(kAutoQualityLabel);
    case DownloadQuality.p1080:
      return _qualityAt('1080p');
    case DownloadQuality.p720:
      return _qualityAt('720p');
    case DownloadQuality.p480:
      return _qualityAt('480p');
  }
}

QualityPreference _qualityAt(String label) {
  return QualityPreference(streamLabel: label, renditionLabel: label);
}

QualityPreferenceReader downloadQualityPreferenceReader({
  required Future<DownloadQuality> Function() readDownloadQuality,
  required QualityPreferenceReader readPlayerQuality,
}) {
  return () async {
    final DownloadQuality quality = await readDownloadQuality();
    final QualityPreference? fixed = fixedQualityPreferenceOf(quality);
    if (fixed != null) {
      return fixed;
    }
    return readPlayerQuality();
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
