import 'package:collection/collection.dart';

enum OcrScript { latin, japanese, korean, chinese }

class PageLanguage {
  const PageLanguage(this.code, this.name, {this.script = OcrScript.latin});

  final String code;
  final String name;
  final OcrScript script;

  bool get usesSpaces =>
      script != OcrScript.japanese && script != OcrScript.chinese;

  static const PageLanguage japanese = PageLanguage(
    'ja',
    'Japanese',
    script: OcrScript.japanese,
  );
  static const PageLanguage korean = PageLanguage(
    'ko',
    'Korean',
    script: OcrScript.korean,
  );
  static const PageLanguage chinese = PageLanguage(
    'zh',
    'Chinese',
    script: OcrScript.chinese,
  );
  static const PageLanguage english = PageLanguage('en', 'English');

  static const List<PageLanguage> sources = <PageLanguage>[
    japanese,
    korean,
    chinese,
    english,
    PageLanguage('es', 'Spanish'),
    PageLanguage('fr', 'French'),
    PageLanguage('de', 'German'),
    PageLanguage('it', 'Italian'),
    PageLanguage('pt', 'Portuguese'),
    PageLanguage('id', 'Indonesian'),
    PageLanguage('vi', 'Vietnamese'),
  ];

  static const List<PageLanguage> targets = <PageLanguage>[
    english,
    PageLanguage('ru', 'Russian'),
    PageLanguage('uk', 'Ukrainian'),
    PageLanguage('es', 'Spanish'),
    PageLanguage('pt', 'Portuguese'),
    PageLanguage('fr', 'French'),
    PageLanguage('de', 'German'),
    PageLanguage('it', 'Italian'),
    PageLanguage('pl', 'Polish'),
    PageLanguage('tr', 'Turkish'),
    PageLanguage('id', 'Indonesian'),
    PageLanguage('vi', 'Vietnamese'),
    PageLanguage('th', 'Thai'),
    PageLanguage('ar', 'Arabic'),
    japanese,
    korean,
    chinese,
  ];

  static List<PageLanguage> get all {
    final Map<String, PageLanguage> unique = <String, PageLanguage>{
      for (final PageLanguage language in <PageLanguage>[
        ...sources,
        ...targets,
      ])
        language.code: language,
    };
    return unique.values.toList()
      ..sort((PageLanguage a, PageLanguage b) => a.name.compareTo(b.name));
  }

  static const Map<String, String> _extensionLanguages = <String, String>{
    'english': 'en',
    'en': 'en',
    '日本語': 'ja',
    'japanese': 'ja',
    'ja': 'ja',
    '한국어': 'ko',
    'korean': 'ko',
    'ko': 'ko',
    '中文': 'zh',
    'chinese': 'zh',
    'zh': 'zh',
    'español': 'es',
    'spanish': 'es',
    'français': 'fr',
    'french': 'fr',
    'deutsch': 'de',
    'german': 'de',
    'italiano': 'it',
    'italian': 'it',
    'português': 'pt',
    'portuguese': 'pt',
    'bahasa indonesia': 'id',
    'indonesian': 'id',
    'tiếng việt': 'vi',
    'vietnamese': 'vi',
  };

  static PageLanguage? sourceForExtension(String? language) {
    final String? normalized = language?.trim().toLowerCase();
    return sourceByCode(_extensionLanguages[normalized]);
  }

  static PageLanguage? sourceByCode(String? code) {
    return sources.firstWhereOrNull(
      (PageLanguage language) => language.code == code,
    );
  }

  static PageLanguage? targetByCode(String? code) {
    return targets.firstWhereOrNull(
      (PageLanguage language) => language.code == code,
    );
  }

  @override
  bool operator ==(Object other) => other is PageLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
