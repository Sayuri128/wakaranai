import 'package:equatable/equatable.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';

class PageTranslationSettings extends Equatable {
  const PageTranslationSettings({
    this.enabled = false,
    this.target = PageLanguage.english,
    this.wifiOnly = true,
    String? ocrEngine,
    String? translator,
    this.overlay = const TranslationOverlayStyle(),
  }) : ocrEngine = ocrEngine ?? '',
       translator = translator ?? '';

  final bool enabled;
  final PageLanguage target;
  final bool wifiOnly;
  final String ocrEngine;
  final String translator;
  final TranslationOverlayStyle overlay;

  String get ocrEngineId => PageTranslationEngines.ocrById(ocrEngine).id;

  String get translatorId =>
      PageTranslationEngines.translatorById(translator).id;

  static const int pipelineVersion = 8;

  static const String versionMarker = '@v';

  static String get currentVersionSuffix => '$versionMarker$pipelineVersion';

  String get engineFamily => '$ocrEngineId+$translatorId';

  String get engineKey => '$engineFamily$currentVersionSuffix';

  PageTranslationSettings copyWith({
    bool? enabled,
    PageLanguage? target,
    bool? wifiOnly,
    String? ocrEngine,
    String? translator,
    TranslationOverlayStyle? overlay,
  }) {
    return PageTranslationSettings(
      enabled: enabled ?? this.enabled,
      target: target ?? this.target,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      ocrEngine: ocrEngine ?? this.ocrEngine,
      translator: translator ?? this.translator,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    enabled,
    target.code,
    wifiOnly,
    ocrEngine,
    translator,
    overlay,
  ];
}
