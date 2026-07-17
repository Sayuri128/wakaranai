import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/database/extension_source_type.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/utils/enum_converters.dart';

class ExtensionSourceDomain extends BaseDomain<ExtensionSourceTableCompanion> {
  final String name;
  final String url;
  final String? ref;
  final ExtensionSourceType type;

  ExtensionSourceDomain({
    required super.id,
    required this.name,
    required this.url,
    required this.type,
    this.ref,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExtensionSourceDomain.fromDrift(ExtensionSourceTableData data) =>
      ExtensionSourceDomain(
        id: data.id,
        name: data.name,
        url: data.url,
        ref: data.ref,
        type: decodeEnum(ExtensionSourceType.values, data.type)!,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  ExtensionSourceTableCompanion toDrift({
    bool update = false,
    bool create = false,
  }) {
    if (create) {
      return ExtensionSourceTableCompanion(
        name: Value(name),
        url: Value(url),
        ref: Value(ref),
        type: Value(type.toString()),
        createdAt: Value(createdAt),
      );
    }

    return ExtensionSourceTableCompanion(
      id: Value(id),
      name: Value(name),
      url: Value(url),
      ref: Value(ref),
      type: Value(encodeEnum(type)),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  ExtensionSourceDomain copyWith({
    String? name,
    String? url,
    String? ref,
    ExtensionSourceType? type,
  }) {
    return ExtensionSourceDomain(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      ref: ref ?? this.ref,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
