import 'package:equatable/equatable.dart';

class GlossaryEntry extends Equatable {
  const GlossaryEntry({required this.source, required this.target});

  final String source;
  final String target;

  bool get isComplete => source.trim().isNotEmpty && target.trim().isNotEmpty;

  List<String> toJson() => <String>[source, target];

  static GlossaryEntry? fromJson(Object? json) {
    if (json is! List<dynamic> || json.length != 2) {
      return null;
    }
    final Object? source = json[0];
    final Object? target = json[1];
    if (source is! String || target is! String) {
      return null;
    }
    return GlossaryEntry(source: source, target: target);
  }

  @override
  List<Object?> get props => <Object?>[source, target];
}

List<GlossaryEntry> glossaryUsedIn(
  List<GlossaryEntry> glossary,
  List<String> texts,
) {
  final String page = texts.join('\n').toLowerCase();
  return <GlossaryEntry>[
    for (final GlossaryEntry entry in glossary)
      if (entry.isComplete && page.contains(entry.source.trim().toLowerCase()))
        entry,
  ];
}

String glossaryHint(List<GlossaryEntry> glossary) {
  return glossary
      .map((GlossaryEntry entry) => '${entry.source} = ${entry.target}')
      .join('; ');
}
