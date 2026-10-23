import 'package:equatable/equatable.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class PageTranslationSettings extends Equatable {
  const PageTranslationSettings({
    this.enabled = false,
    this.target = PageLanguage.english,
    this.wifiOnly = true,
    String? ocrEngine,
    String? translator,
  }) : ocrEngine = ocrEngine ?? '',
       translator = translator ?? '';

  final bool enabled;
  final PageLanguage target;
  final bool wifiOnly;
  final String ocrEngine;
  final String translator;

  String get ocrEngineId => PageTranslationEngines.ocrById(ocrEngine).id;

  String get translatorId =>
      PageTranslationEngines.translatorById(translator).id;

  static const int pipelineVersion = 8;

  String get engineKey => '$ocrEngineId+$translatorId@v$pipelineVersion';

  PageTranslationSettings copyWith({
    bool? enabled,
    PageLanguage? target,
    bool? wifiOnly,
    String? ocrEngine,
    String? translator,
  }) {
    return PageTranslationSettings(
      enabled: enabled ?? this.enabled,
      target: target ?? this.target,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      ocrEngine: ocrEngine ?? this.ocrEngine,
      translator: translator ?? this.translator,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    enabled,
    target.code,
    wifiOnly,
    ocrEngine,
    translator,
  ];
}
