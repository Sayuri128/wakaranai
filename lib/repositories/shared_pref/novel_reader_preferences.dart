import 'package:shared_preferences/shared_preferences.dart';

enum NovelReaderFont { ubuntu, serif }

enum NovelReaderBackground { theme, black, sepia, white }

class NovelReaderPreferences {
  static const double minFontSize = 12;
  static const double maxFontSize = 32;
  static const double fontSizeStep = 1;
  static const double defaultFontSize = 18;

  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.4;
  static const double lineHeightStep = 0.1;
  static const double defaultLineHeight = 1.6;

  static const double minMargin = 0;
  static const double maxMargin = 48;
  static const double marginStep = 4;
  static const double defaultMargin = 20;

  const NovelReaderPreferences({
    this.fontSize = defaultFontSize,
    this.lineHeight = defaultLineHeight,
    this.horizontalMargin = defaultMargin,
    this.font = NovelReaderFont.ubuntu,
    this.background = NovelReaderBackground.theme,
    this.justify = false,
    this.keepScreenOn = true,
  });

  final double fontSize;
  final double lineHeight;
  final double horizontalMargin;
  final NovelReaderFont font;
  final NovelReaderBackground background;
  final bool justify;
  final bool keepScreenOn;

  NovelReaderPreferences copyWith({
    double? fontSize,
    double? lineHeight,
    double? horizontalMargin,
    NovelReaderFont? font,
    NovelReaderBackground? background,
    bool? justify,
    bool? keepScreenOn,
  }) {
    return NovelReaderPreferences(
      fontSize: clampFontSize(fontSize ?? this.fontSize),
      lineHeight: clampLineHeight(lineHeight ?? this.lineHeight),
      horizontalMargin: clampMargin(horizontalMargin ?? this.horizontalMargin),
      font: font ?? this.font,
      background: background ?? this.background,
      justify: justify ?? this.justify,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }

  static double clampFontSize(double value) {
    return _clamp(value, minFontSize, maxFontSize, defaultFontSize);
  }

  static double clampLineHeight(double value) {
    final double clamped =
        _clamp(value, minLineHeight, maxLineHeight, defaultLineHeight);
    return (clamped * 10).round() / 10;
  }

  static double clampMargin(double value) {
    return _clamp(value, minMargin, maxMargin, defaultMargin);
  }

  static double _clamp(double value, double min, double max, double fallback) {
    if (value.isNaN || value.isInfinite) {
      return fallback;
    }
    return value.clamp(min, max).toDouble();
  }

  @override
  bool operator ==(Object other) {
    return other is NovelReaderPreferences &&
        other.fontSize == fontSize &&
        other.lineHeight == lineHeight &&
        other.horizontalMargin == horizontalMargin &&
        other.font == font &&
        other.background == background &&
        other.justify == justify &&
        other.keepScreenOn == keepScreenOn;
  }

  @override
  int get hashCode => Object.hash(
        fontSize,
        lineHeight,
        horizontalMargin,
        font,
        background,
        justify,
        keepScreenOn,
      );
}

class NovelReaderPreferencesStore {
  static const String keyPrefix = 'NOVEL_READER_';
  static const String fontSizeKey = '${keyPrefix}FONT_SIZE';
  static const String lineHeightKey = '${keyPrefix}LINE_HEIGHT';
  static const String marginKey = '${keyPrefix}HORIZONTAL_MARGIN';
  static const String fontKey = '${keyPrefix}FONT';
  static const String backgroundKey = '${keyPrefix}BACKGROUND';
  static const String justifyKey = '${keyPrefix}JUSTIFY';
  static const String keepScreenOnKey = '${keyPrefix}KEEP_SCREEN_ON';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<NovelReaderPreferences> read() async {
    final SharedPreferences preferences = await _load();
    return NovelReaderPreferences(
      fontSize: NovelReaderPreferences.clampFontSize(
        preferences.getDouble(fontSizeKey) ??
            NovelReaderPreferences.defaultFontSize,
      ),
      lineHeight: NovelReaderPreferences.clampLineHeight(
        preferences.getDouble(lineHeightKey) ??
            NovelReaderPreferences.defaultLineHeight,
      ),
      horizontalMargin: NovelReaderPreferences.clampMargin(
        preferences.getDouble(marginKey) ??
            NovelReaderPreferences.defaultMargin,
      ),
      font: _byName(
        NovelReaderFont.values,
        preferences.getString(fontKey),
        NovelReaderFont.ubuntu,
      ),
      background: _byName(
        NovelReaderBackground.values,
        preferences.getString(backgroundKey),
        NovelReaderBackground.theme,
      ),
      justify: preferences.getBool(justifyKey) ?? false,
      keepScreenOn: preferences.getBool(keepScreenOnKey) ?? true,
    );
  }

  Future<void> write(NovelReaderPreferences value) async {
    final SharedPreferences preferences = await _load();
    await preferences.setDouble(fontSizeKey, value.fontSize);
    await preferences.setDouble(lineHeightKey, value.lineHeight);
    await preferences.setDouble(marginKey, value.horizontalMargin);
    await preferences.setString(fontKey, value.font.name);
    await preferences.setString(backgroundKey, value.background.name);
    await preferences.setBool(justifyKey, value.justify);
    await preferences.setBool(keepScreenOnKey, value.keepScreenOn);
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
