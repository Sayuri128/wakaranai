import 'package:shared_preferences/shared_preferences.dart';

enum ReaderPageFit { screen, width, height }

enum ReaderBackground { black, grey, white, theme }

class ReaderPreferences {
  const ReaderPreferences({
    this.volumeKeys = false,
    this.invertVolumeKeys = false,
    this.pageFit = ReaderPageFit.screen,
    this.background = ReaderBackground.black,
    this.cropBorders = false,
    this.doublePageSpread = false,
    this.incognito = false,
  });

  final bool volumeKeys;
  final bool invertVolumeKeys;
  final ReaderPageFit pageFit;
  final ReaderBackground background;
  final bool cropBorders;
  final bool doublePageSpread;
  final bool incognito;

  ReaderPreferences copyWith({
    bool? volumeKeys,
    bool? invertVolumeKeys,
    ReaderPageFit? pageFit,
    ReaderBackground? background,
    bool? cropBorders,
    bool? doublePageSpread,
    bool? incognito,
  }) {
    return ReaderPreferences(
      volumeKeys: volumeKeys ?? this.volumeKeys,
      invertVolumeKeys: invertVolumeKeys ?? this.invertVolumeKeys,
      pageFit: pageFit ?? this.pageFit,
      background: background ?? this.background,
      cropBorders: cropBorders ?? this.cropBorders,
      doublePageSpread: doublePageSpread ?? this.doublePageSpread,
      incognito: incognito ?? this.incognito,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderPreferences &&
        other.volumeKeys == volumeKeys &&
        other.invertVolumeKeys == invertVolumeKeys &&
        other.pageFit == pageFit &&
        other.background == background &&
        other.cropBorders == cropBorders &&
        other.doublePageSpread == doublePageSpread &&
        other.incognito == incognito;
  }

  @override
  int get hashCode => Object.hash(
        volumeKeys,
        invertVolumeKeys,
        pageFit,
        background,
        cropBorders,
        doublePageSpread,
        incognito,
      );
}

class ReaderPreferencesStore {
  static const String volumeKeysKey = 'READER_VOLUME_KEYS';
  static const String invertVolumeKeysKey = 'READER_INVERT_VOLUME_KEYS';
  static const String pageFitKey = 'READER_PAGE_FIT';
  static const String backgroundKey = 'READER_BACKGROUND';
  static const String cropBordersKey = 'READER_CROP_BORDERS';
  static const String doublePageSpreadKey = 'READER_DOUBLE_PAGE_SPREAD';
  static const String incognitoKey = 'INCOGNITO_MODE';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<ReaderPreferences> read() async {
    final SharedPreferences preferences = await _load();
    return ReaderPreferences(
      volumeKeys: preferences.getBool(volumeKeysKey) ?? false,
      invertVolumeKeys: preferences.getBool(invertVolumeKeysKey) ?? false,
      pageFit: _byName(
        ReaderPageFit.values,
        preferences.getString(pageFitKey),
        ReaderPageFit.screen,
      ),
      background: _byName(
        ReaderBackground.values,
        preferences.getString(backgroundKey),
        ReaderBackground.black,
      ),
      cropBorders: preferences.getBool(cropBordersKey) ?? false,
      doublePageSpread: preferences.getBool(doublePageSpreadKey) ?? false,
      incognito: preferences.getBool(incognitoKey) ?? false,
    );
  }

  Future<void> write(ReaderPreferences value) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(volumeKeysKey, value.volumeKeys);
    await preferences.setBool(invertVolumeKeysKey, value.invertVolumeKeys);
    await preferences.setString(pageFitKey, value.pageFit.name);
    await preferences.setString(backgroundKey, value.background.name);
    await preferences.setBool(cropBordersKey, value.cropBorders);
    await preferences.setBool(doublePageSpreadKey, value.doublePageSpread);
    await preferences.setBool(incognitoKey, value.incognito);
  }

  T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
