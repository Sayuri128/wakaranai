import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakaranai/models/serializable_object.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LocalConfigInfo extends SqSerializableObject {
  int? id;
  final String name;
  final String logoUrl;
  final bool nsfw;
  final String language;
  final int version;
  final LocalProtectorConfig? localProtectorConfig;
  final bool searchAvailable;

  LocalConfigInfo({
    this.id,
    required this.name,
    required this.logoUrl,
    required this.nsfw,
    required this.language,
    required this.version,
    this.localProtectorConfig,
    required this.searchAvailable,
  });

  ConfigInfo asConfigInfo() => ConfigInfo(
      name: name,
      logoUrl: logoUrl,
      nsfw: nsfw,
      language: language,
      version: version,
      filters: [],
      searchAvailable: searchAvailable,
      protectorConfig: localProtectorConfig?.asProtectorConfig());

  factory LocalConfigInfo.fromConfigInfo(ConfigInfo configInfo) =>
      LocalConfigInfo(
          name: configInfo.name,
          logoUrl: configInfo.logoUrl,
          nsfw: configInfo.nsfw,
          language: configInfo.language,
          version: configInfo.version,
          searchAvailable: configInfo.searchAvailable,
          id: null,
          localProtectorConfig: configInfo.protectorConfig != null
              ? LocalProtectorConfig.fromProtectorConfig(
                  configInfo.protectorConfig!)
              : null);

  @override
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'nsfw': nsfw ? 1 : 0,
      'language': language,
      'version': version,
      if (lazy)
        'localProtectorConfigId': localProtectorConfig?.getId()
      else
        'localProtectorConfig': localProtectorConfig?.toMap(lazy: lazy),
      'searchAvailable': searchAvailable ? 1 : 0,
    };
  }

  factory LocalConfigInfo.fromMap(Map<String, dynamic> map) {
    return LocalConfigInfo(
      id: map['id'] as int,
      name: map['name'] as String,
      logoUrl: map['logoUrl'] as String,
      nsfw: (map['nsfw'] as int) == 1,
      language: map['language'] as String,
      version: map['version'] as int,
      localProtectorConfig: map['localProtectorConfig'] != null
          ? LocalProtectorConfig.fromMap(map['localProtectorConfig'])
          : null,
      searchAvailable: (map['searchAvailable'] as int) == 1,
    );
  }

  @override
  int? getId() => id;
}
