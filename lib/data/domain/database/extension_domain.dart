import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/utils/enum_converters.dart';

class ExtensionDomain extends BaseDomain<ExtensionTableCompanion>
    with BaseExtension {
  @override
  final ConfigInfo config;
  final String sourceCode;
  final String? revision;

  factory ExtensionDomain.fromDrift(ExtensionTableData data) {
    return ExtensionDomain(
      id: data.id,
      config: _storedConfig(data) ?? ConfigInfo(
        name: data.name,
        language: data.language,
        logoUrl: data.logoUrl,
        nsfw: data.nsfw,
        uid: data.uid,
        version: data.version,
        type: decodeEnum(ConfigInfoType.values, data.type)!,
        filters: [],
        searchAvailable: data.searchAvailable,
        protectorConfig: data.protectorConfig != null
            ? ProtectorConfig.fromJson(jsonDecode(data.protectorConfig!))
            : null,
      ),
      sourceCode: data.sourceCode,
      revision: data.revision,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static ConfigInfo? _storedConfig(ExtensionTableData data) {
    final String? json = data.configJson;
    if (json == null) return null;
    try {
      return ConfigInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  ExtensionTableCompanion toDrift({
    bool update = false,
    bool create = false,
  }) {
    late DateTime? updatedAt;
    late DateTime createdAt;
    late Value<int> id;
    if (update) {
      id = Value(this.id);
      updatedAt = DateTime.now();
      createdAt = this.createdAt;
    }
    if (create) {
      id = const Value.absent();
      createdAt = DateTime.now();
      updatedAt = null;
    }

    return ExtensionTableCompanion(
      id: id,
      uid: Value(config.uid),
      name: Value(config.name),
      type: Value(encodeEnum(config.type)),
      version: Value(config.version),
      logoUrl: Value(config.logoUrl),
      language: Value(config.language),
      nsfw: Value(config.nsfw),
      sourceCode: Value(sourceCode),
      searchAvailable: Value(config.searchAvailable),
      protectorConfig: Value(
        config.protectorConfig == null
            ? null
            : jsonEncode(config.protectorConfig),
      ),
      configJson: Value(jsonEncode(config.toJson())),
      revision: Value(revision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  ExtensionDomain({
    required super.id,
    required this.config,
    required this.sourceCode,
    required super.createdAt,
    this.revision,
    super.updatedAt,
  });

  ExtensionDomain copyWith({
    ConfigInfo? config,
    String? sourceCode,
    String? revision,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? id,
  }) {
    return ExtensionDomain(
      config: config ?? this.config,
      sourceCode: sourceCode ?? this.sourceCode,
      revision: revision ?? this.revision,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}
