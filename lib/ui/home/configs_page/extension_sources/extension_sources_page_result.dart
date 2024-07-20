import 'package:wakaranai/data/domain/database/extension/extension_source_type.dart';

class ExtensionSourcesPageResult {
  final int? id;
  final String url;
  final ExtensionSourceType type;
  final String name;

  const ExtensionSourcesPageResult({
    this.id,
    required this.url,
    required this.type,
    required this.name,
  });
}
