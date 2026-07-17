import 'package:wakaranai/data/domain/database/extension_source_type.dart';

class AddExtensionPageArguments {
  final String name;
  final String url;
  final String? ref;
  final ExtensionSourceType type;

  final bool update;

  const AddExtensionPageArguments({
    required this.name,
    required this.url,
    required this.type,
    this.ref,
    this.update = false,
  });
}
