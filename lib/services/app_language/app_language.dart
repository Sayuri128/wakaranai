import 'dart:ui';

import 'package:wakaranai/generated/l10n.dart';

enum AppLanguage {
  system(storageValue: 'system', languageCode: null),
  english(storageValue: 'en', languageCode: 'en'),
  ukrainian(storageValue: 'uk', languageCode: 'uk');

  const AppLanguage({required this.storageValue, required this.languageCode});

  final String storageValue;
  final String? languageCode;

  Locale? get locale {
    final String? code = languageCode;
    if (code == null) {
      return null;
    }
    return Locale(code);
  }

  static AppLanguage fromStorage(String? value) {
    for (final AppLanguage language in values) {
      if (language.storageValue == value) {
        return language;
      }
    }
    return AppLanguage.system;
  }
}

Locale resolveAppLocale(AppLanguage language, List<Locale> systemLocales) {
  final Locale? chosen = language.locale;
  if (chosen != null) {
    return chosen;
  }
  final List<Locale> supported = S.delegate.supportedLocales;
  for (final Locale systemLocale in systemLocales) {
    for (final Locale candidate in supported) {
      if (candidate.languageCode == systemLocale.languageCode) {
        return candidate;
      }
    }
  }
  return supported.first;
}
