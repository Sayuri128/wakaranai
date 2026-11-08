import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/app_language_preferences.dart';
import 'package:wakaranai/services/app_language/app_language.dart';

Future<S> loadBackgroundStrings({
  List<Locale>? systemLocales,
  String? fallbackLocaleName,
}) async {
  final AppLanguage language = await _savedLanguage();
  final List<Locale> candidates = <Locale>[
    ...systemLocales ?? PlatformDispatcher.instance.locales,
    if (fallbackLocaleName != null) _localeFromName(fallbackLocaleName),
  ];
  return S.load(resolveAppLocale(language, candidates));
}

Future<AppLanguage> _savedLanguage() async {
  try {
    await (await SharedPreferences.getInstance()).reload();
    return await AppLanguagePreferences().read();
  } catch (_) {
    return AppLanguage.system;
  }
}

Locale _localeFromName(String localeName) {
  final List<String> parts = localeName.split(RegExp('[_-]'));
  return Locale(parts.first);
}
