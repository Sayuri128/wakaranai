import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/extension/base_extension.dart';
import 'package:wakaranai/data/models/remote_config/remote_category.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/utils/enum_converters.dart';

class ExtensionDomain extends BaseDomain<ExtensionTableCompanion>
    with BaseExtension {
  @override
  final RemoteCategory category;
  @override
  final ConfigInfo config;
  final String sourceCode;

  factory ExtensionDomain.fromDrift(ExtensionTableData data) {
    return ExtensionDomain(
      id: data.id,
      category: decodeEnum(RemoteCategory.values, data.type)!,
      config: ConfigInfo(
        name: data.name,
        language: data.language,
        logoUrl: data.logoUrl,
        nsfw: data.nsfw,
        uid: data.uid,
        version: data.version,
        type: remoteCategoryToConfigInfoType(
          decodeEnum(RemoteCategory.values, data.type)!,
        ),
        filters: [],
        searchAvailable: data.searchAvailable,
        protectorConfig: data.protectorConfig != null
            ? ProtectorConfig.fromJson(jsonDecode(data.protectorConfig!))
            : null,
      ),
      sourceCode: data.sourceCode,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  ExtensionTableCompanion toDrift({bool update = false, bool create = false}) {
    late DateTime? updatedAt;
    late DateTime createdAt;
    if (update) {
      updatedAt = DateTime.now();
      createdAt = this.createdAt;
    }
    if (create) {
      createdAt = DateTime.now();
      updatedAt = null;
    }

    return ExtensionTableCompanion(
      id: Value(id),
      uid: Value(config.uid),
      name: Value(config.name),
      type: Value(encodeEnum(config.type)),
      version: Value(config.version),
      logoUrl: Value(config.logoUrl),
      language: Value(config.language),
      nsfw: Value(config.nsfw),
      sourceCode: Value(sourceCode),
      searchAvailable: Value(config.searchAvailable),
      protectorConfig: Value(jsonEncode(config.protectorConfig)),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  const ExtensionDomain({
    required super.id,
    required this.category,
    required this.config,
    required this.sourceCode,
    required super.createdAt,
    super.updatedAt,
  });


}
