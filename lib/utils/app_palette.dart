import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/text_styles.dart';

enum AppThemeId {
  midnight,
  amoled,
  light,
  ocean,
  dracula,
  ember,
  sky,
  sakura,
  sepia,
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.id,
    required this.brightness,
    required this.background,
    required this.onBackground,
    required this.secondaryText,
    required this.onPrimary,
    required this.primary,
    required this.secondary,
    required this.mediumLight,
    required this.mediumLight2,
    required this.mediumDark,
    required this.mediumDark2,
    required this.red,
    required this.shadow,
    required this.overlayBase,
    required this.dialogSurface,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.onMedia,
  });

  final AppThemeId id;
  final Brightness brightness;

  final Color background;
  final Color onBackground;
  final Color secondaryText;
  final Color onPrimary;

  final Color primary;
  final Color secondary;
  final Color mediumLight;
  final Color mediumLight2;
  final Color mediumDark;
  final Color mediumDark2;
  final Color red;

  final Color shadow;
  final Color overlayBase;
  final Color dialogSurface;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color onMedia;

  static const AppPalette midnight = AppPalette(
    id: AppThemeId.midnight,
    brightness: Brightness.dark,
    background: Color(0xFF303030),
    onBackground: Colors.white,
    secondaryText: Colors.grey,
    onPrimary: Color(0x9B000000),
    primary: Color(0xFF00E676),
    secondary: Color(0xFF00D3AC),
    mediumLight: Color(0xFF00BADA),
    mediumLight2: Color(0xFF009EF1),
    mediumDark: Color(0xFF007CE9),
    mediumDark2: Color(0xFF3F54C2),
    red: Colors.redAccent,
    shadow: Color(0x33000000),
    overlayBase: Colors.white,
    dialogSurface: Color(0xFF3A3A3A),
    shimmerBase: Color(0xFF3A3A3A),
    shimmerHighlight: Color(0xFF4C4C4C),
    onMedia: Colors.white,
  );

  static const AppPalette amoled = AppPalette(
    id: AppThemeId.amoled,
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    onBackground: Colors.white,
    secondaryText: Colors.grey,
    onPrimary: Color(0x9B000000),
    primary: Color(0xFF00E676),
    secondary: Color(0xFF00D3AC),
    mediumLight: Color(0xFF00BADA),
    mediumLight2: Color(0xFF009EF1),
    mediumDark: Color(0xFF007CE9),
    mediumDark2: Color(0xFF3F54C2),
    red: Colors.redAccent,
    shadow: Color(0x33000000),
    overlayBase: Colors.white,
    dialogSurface: Color(0xFF161616),
    shimmerBase: Color(0xFF161616),
    shimmerHighlight: Color(0xFF2A2A2A),
    onMedia: Colors.white,
  );

  static const AppPalette light = AppPalette(
    id: AppThemeId.light,
    brightness: Brightness.light,
    background: Color(0xFFF3F4F6),
    onBackground: Color(0xFF1A1C1E),
    secondaryText: Color(0xFF6B7075),
    onPrimary: Color(0xB2000000),
    primary: Color(0xFF00A152),
    secondary: Color(0xFF009E86),
    mediumLight: Color(0xFF0093AE),
    mediumLight2: Color(0xFF007FC4),
    mediumDark: Color(0xFF0063C0),
    mediumDark2: Color(0xFF3140A0),
    red: Color(0xFFD32F2F),
    shadow: Color(0x1F000000),
    overlayBase: Color(0xFF12161B),
    dialogSurface: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE2E4E7),
    shimmerHighlight: Color(0xFFF1F2F4),
    onMedia: Colors.white,
  );

  static const AppPalette ocean = AppPalette(
    id: AppThemeId.ocean,
    brightness: Brightness.dark,
    background: Color(0xFF16232E),
    onBackground: Color(0xFFEAF2F8),
    secondaryText: Color(0xFF8A9BA8),
    onPrimary: Color(0x9B000000),
    primary: Color(0xFF22D3EE),
    secondary: Color(0xFF2DD4BF),
    mediumLight: Color(0xFF38BDF8),
    mediumLight2: Color(0xFF0EA5E9),
    mediumDark: Color(0xFF0284C7),
    mediumDark2: Color(0xFF0369A1),
    red: Colors.redAccent,
    shadow: Color(0x33000000),
    overlayBase: Colors.white,
    dialogSurface: Color(0xFF1E2E3C),
    shimmerBase: Color(0xFF1E2E3C),
    shimmerHighlight: Color(0xFF2C4055),
    onMedia: Colors.white,
  );

  static const AppPalette dracula = AppPalette(
    id: AppThemeId.dracula,
    brightness: Brightness.dark,
    background: Color(0xFF282A36),
    onBackground: Color(0xFFF8F8F2),
    secondaryText: Color(0xFF9AA0B5),
    onPrimary: Color(0x9B000000),
    primary: Color(0xFFBD93F9),
    secondary: Color(0xFFFF79C6),
    mediumLight: Color(0xFFFF79C6),
    mediumLight2: Color(0xFFBD93F9),
    mediumDark: Color(0xFF9D7CD8),
    mediumDark2: Color(0xFF6272A4),
    red: Color(0xFFFF5555),
    shadow: Color(0x33000000),
    overlayBase: Colors.white,
    dialogSurface: Color(0xFF343746),
    shimmerBase: Color(0xFF343746),
    shimmerHighlight: Color(0xFF44475A),
    onMedia: Colors.white,
  );

  static const AppPalette ember = AppPalette(
    id: AppThemeId.ember,
    brightness: Brightness.dark,
    background: Color(0xFF211A17),
    onBackground: Color(0xFFF5EDE8),
    secondaryText: Color(0xFFA89B92),
    onPrimary: Color(0x9B000000),
    primary: Color(0xFFFF9E45),
    secondary: Color(0xFFFFB74D),
    mediumLight: Color(0xFFFFCA28),
    mediumLight2: Color(0xFFFFA000),
    mediumDark: Color(0xFFFB8C00),
    mediumDark2: Color(0xFFF57C00),
    red: Colors.redAccent,
    shadow: Color(0x33000000),
    overlayBase: Colors.white,
    dialogSurface: Color(0xFF2C2320),
    shimmerBase: Color(0xFF2C2320),
    shimmerHighlight: Color(0xFF3D302B),
    onMedia: Colors.white,
  );

  static const AppPalette sky = AppPalette(
    id: AppThemeId.sky,
    brightness: Brightness.light,
    background: Color(0xFFF2F5FA),
    onBackground: Color(0xFF17202E),
    secondaryText: Color(0xFF5C6675),
    onPrimary: Colors.white,
    primary: Color(0xFF1E6FE0),
    secondary: Color(0xFF0EA5E9),
    mediumLight: Color(0xFF38BDF8),
    mediumLight2: Color(0xFF0EA5E9),
    mediumDark: Color(0xFF1565C0),
    mediumDark2: Color(0xFF0D47A1),
    red: Color(0xFFD32F2F),
    shadow: Color(0x1F000000),
    overlayBase: Color(0xFF0E1726),
    dialogSurface: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE1E6EE),
    shimmerHighlight: Color(0xFFF0F3F8),
    onMedia: Colors.white,
  );

  static const AppPalette sakura = AppPalette(
    id: AppThemeId.sakura,
    brightness: Brightness.light,
    background: Color(0xFFFDF3F5),
    onBackground: Color(0xFF2A1D22),
    secondaryText: Color(0xFF7A6870),
    onPrimary: Colors.white,
    primary: Color(0xFFE23E75),
    secondary: Color(0xFFF06292),
    mediumLight: Color(0xFFF48FB1),
    mediumLight2: Color(0xFFEC407A),
    mediumDark: Color(0xFFD81B60),
    mediumDark2: Color(0xFFAD1457),
    red: Color(0xFFD32F2F),
    shadow: Color(0x1F000000),
    overlayBase: Color(0xFF2A141B),
    dialogSurface: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFF0DCE2),
    shimmerHighlight: Color(0xFFF8EBEF),
    onMedia: Colors.white,
  );

  static const AppPalette sepia = AppPalette(
    id: AppThemeId.sepia,
    brightness: Brightness.light,
    background: Color(0xFFF3E9D2),
    onBackground: Color(0xFF3A2F1E),
    secondaryText: Color(0xFF7A6A50),
    onPrimary: Colors.white,
    primary: Color(0xFFA9601E),
    secondary: Color(0xFFC68B4B),
    mediumLight: Color(0xFFD8A15A),
    mediumLight2: Color(0xFFC0803A),
    mediumDark: Color(0xFF9C5A1E),
    mediumDark2: Color(0xFF7E4A18),
    red: Color(0xFFC0392B),
    shadow: Color(0x1F000000),
    overlayBase: Color(0xFF2E2416),
    dialogSurface: Color(0xFFFBF3E2),
    shimmerBase: Color(0xFFE6D8BC),
    shimmerHighlight: Color(0xFFF1E7CF),
    onMedia: Colors.white,
  );

  static const List<AppPalette> all = <AppPalette>[
    midnight,
    amoled,
    ocean,
    dracula,
    ember,
    light,
    sky,
    sakura,
    sepia,
  ];

  static AppPalette fromId(AppThemeId id) {
    return all.firstWhere((AppPalette p) => p.id == id, orElse: () => midnight);
  }

  ThemeData toThemeData() {
    final ThemeData base =
        brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: background,
      extensions: <ThemeExtension<dynamic>>[this],
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: background,
        error: red,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(4.0)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          medium(size: 16, color: onBackground),
        ),
        indicatorColor: primary.withValues(alpha: 0.9),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(color: onBackground),
        ),
      ),
      dialogTheme: DialogThemeData(surfaceTintColor: background),
      cardTheme: CardThemeData(surfaceTintColor: background),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  AppPalette copyWith({Brightness? brightness}) => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}
