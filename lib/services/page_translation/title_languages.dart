import 'package:equatable/equatable.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class TitleLanguages extends Equatable {
  const TitleLanguages({required this.source, required this.target});

  final PageLanguage source;
  final PageLanguage target;

  Set<PageLanguage> get packs => <PageLanguage>{source, target};

  String encode() => '${source.code}>${target.code}';

  static TitleLanguages? decode(String? value) {
    if (value == null) {
      return null;
    }
    final List<String> parts = value.split('>');
    if (parts.length != 2) {
      return null;
    }
    final PageLanguage? source = PageLanguage.sourceByCode(parts[0]);
    final PageLanguage? target = PageLanguage.targetByCode(parts[1]);
    if (source == null || target == null) {
      return null;
    }
    return TitleLanguages(source: source, target: target);
  }

  @override
  List<Object?> get props => <Object?>[source.code, target.code];
}
