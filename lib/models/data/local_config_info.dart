import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LocalConfigInfo {
  final int? id;
  final String name;
  final String uid;
  final String logoUrl;
  final bool nsfw;
  final ConfigInfoType type;
  final String language;
  final int version;
  final LocalProtectorConfig? localProtectorConfig;
  final bool searchAvailable;

  LocalConfigInfo({
    this.id,
    required this.name,
    required this.uid,
    required this.logoUrl,
    required this.nsfw,
    required this.type,
    required this.language,
    required this.version,
    this.localProtectorConfig,
    required this.searchAvailable,
  });

  ConfigInfo asConfigInfo() => ConfigInfo(
      name: name,
      uid: uid,
      logoUrl: logoUrl,
      nsfw: nsfw,
      language: language,
      version: version,
      filters: [],
      searchAvailable: searchAvailable,
      protectorConfig: localProtectorConfig?.asProtectorConfig(),
      type: type);

  factory LocalConfigInfo.fromConfigInfo(ConfigInfo configInfo) =>
      LocalConfigInfo(
          name: configInfo.name,
          uid: configInfo.uid,
          logoUrl: configInfo.logoUrl,
          nsfw: configInfo.nsfw,
          type: configInfo.type,
          language: configInfo.language,
          version: configInfo.version,
          searchAvailable: configInfo.searchAvailable,
          localProtectorConfig: configInfo.protectorConfig != null
              ? LocalProtectorConfig.fromProtectorConfig(
                  configInfo.protectorConfig!)
              : null);
}
