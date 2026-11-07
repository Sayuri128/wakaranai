import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DownloadQuality { sameAsPlayer, highest, p1080, p720, p480 }

const DownloadQuality kDefaultDownloadQuality = DownloadQuality.sameAsPlayer;
const bool kDefaultDeleteEpisodesAfterWatching = false;

class DownloadStoragePreferences {
  static const String qualityKey = 'DOWNLOADS_QUALITY';
  static const String deleteAfterWatchingKey =
      'DOWNLOADS_DELETE_EPISODES_AFTER_WATCHING';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<DownloadQuality> getQuality() async {
    final SharedPreferences preferences = await _load();
    final String? stored = preferences.getString(qualityKey);
    return DownloadQuality.values.firstWhereOrNull(
          (DownloadQuality quality) => quality.name == stored,
        ) ??
        kDefaultDownloadQuality;
  }

  Future<void> setQuality(DownloadQuality quality) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(qualityKey, quality.name);
  }

  Future<bool> getDeleteAfterWatching() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(deleteAfterWatchingKey) ??
        kDefaultDeleteEpisodesAfterWatching;
  }

  Future<void> setDeleteAfterWatching(bool enabled) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(deleteAfterWatchingKey, enabled);
  }
}
