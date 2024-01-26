import 'package:wakaranai/data/domain/extension/extension_source_type.dart';

class AddExtensionPageArguments {
  final String name;
  final String url;
  final ExtensionSourceType type;

  final bool update;

  const AddExtensionPageArguments({
    required this.name,
    required this.url,
    required this.type,
    this.update = false,
  });
}
