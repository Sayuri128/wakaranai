import 'package:wakaranai/data/domain/database/extension_source_type.dart';

class AddExtensionPageResult {
  final String name;
  final String url;
  final ExtensionSourceType type;

  const AddExtensionPageResult({
    required this.name,
    required this.url,
    required this.type,
  });
}
