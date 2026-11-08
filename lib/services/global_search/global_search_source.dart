import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';

class GlobalSearchSource {
  const GlobalSearchSource({required this.extension, this.configsService});

  final BaseExtension extension;
  final ConfigsService? configsService;

  ConfigInfo get config => extension.config;

  String get uid => config.uid;

  String get name => config.name.trim();

  bool get isLocal => LocalSources.isBuiltIn(uid);

  bool get isInstalled => extension is ExtensionDomain;

  bool get hasProtector => config.protectorConfig != null;

  @override
  bool operator ==(Object other) {
    return other is GlobalSearchSource && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'GlobalSearchSource($name, $uid)';
}
