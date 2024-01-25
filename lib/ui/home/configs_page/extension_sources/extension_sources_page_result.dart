import 'package:wakaranai/data/domain/extension/extension_source_domain.dart';
import 'package:wakaranai/data/domain/extension/extension_source_type.dart';

class ExtensionSourcesPageResult {
  final String url;
  final ExtensionSourceType type;
  final String name;

  const ExtensionSourcesPageResult({
    required this.url,
    required this.type,
    required this.name,
  });
}
