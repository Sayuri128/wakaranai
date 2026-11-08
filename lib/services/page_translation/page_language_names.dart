import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

String pageLanguageName(PageLanguage language) {
  final S strings = S.current;
  switch (language.code) {
    case 'ja':
      return strings.page_language_japanese;
    case 'ko':
      return strings.page_language_korean;
    case 'zh':
      return strings.page_language_chinese;
    case 'en':
      return strings.page_language_english;
    case 'es':
      return strings.page_language_spanish;
    case 'fr':
      return strings.page_language_french;
    case 'de':
      return strings.page_language_german;
    case 'it':
      return strings.page_language_italian;
    case 'pt':
      return strings.page_language_portuguese;
    case 'id':
      return strings.page_language_indonesian;
    case 'vi':
      return strings.page_language_vietnamese;
    case 'ru':
      return strings.page_language_russian;
    case 'uk':
      return strings.page_language_ukrainian;
    case 'pl':
      return strings.page_language_polish;
    case 'tr':
      return strings.page_language_turkish;
    case 'th':
      return strings.page_language_thai;
    case 'ar':
      return strings.page_language_arabic;
    default:
      return language.name;
  }
}
