// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wakaranai_database.dart';

// ignore_for_file: type=lint
class $ExtensionSourceTableTable extends ExtensionSourceTable
    with TableInfo<$ExtensionSourceTableTable, ExtensionSourceTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtensionSourceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    type,
    name,
    url,
    ref,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extension_source_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtensionSourceTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtensionSourceTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtensionSourceTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
    );
  }

  @override
  $ExtensionSourceTableTable createAlias(String alias) {
    return $ExtensionSourceTableTable(attachedDatabase, alias);
  }
}

class ExtensionSourceTableData extends DataClass
    implements Insertable<ExtensionSourceTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String type;
  final String name;
  final String url;
  final String? ref;
  const ExtensionSourceTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.name,
    required this.url,
    this.ref,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    return map;
  }

  ExtensionSourceTableCompanion toCompanion(bool nullToAbsent) {
    return ExtensionSourceTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      type: Value(type),
      name: Value(name),
      url: Value(url),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
    );
  }

  factory ExtensionSourceTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtensionSourceTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      ref: serializer.fromJson<String?>(json['ref']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'ref': serializer.toJson<String?>(ref),
    };
  }

  ExtensionSourceTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? type,
    String? name,
    String? url,
    Value<String?> ref = const Value.absent(),
  }) => ExtensionSourceTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    type: type ?? this.type,
    name: name ?? this.name,
    url: url ?? this.url,
    ref: ref.present ? ref.value : this.ref,
  );
  ExtensionSourceTableData copyWithCompanion(
    ExtensionSourceTableCompanion data,
  ) {
    return ExtensionSourceTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      ref: data.ref.present ? data.ref.value : this.ref,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionSourceTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('ref: $ref')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, type, name, url, ref);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtensionSourceTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type &&
          other.name == this.name &&
          other.url == this.url &&
          other.ref == this.ref);
}

class ExtensionSourceTableCompanion
    extends UpdateCompanion<ExtensionSourceTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> type;
  final Value<String> name;
  final Value<String> url;
  final Value<String?> ref;
  const ExtensionSourceTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.ref = const Value.absent(),
  });
  ExtensionSourceTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String type,
    required String name,
    required String url,
    this.ref = const Value.absent(),
  }) : type = Value(type),
       name = Value(name),
       url = Value(url);
  static Insertable<ExtensionSourceTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? ref,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (ref != null) 'ref': ref,
    });
  }

  ExtensionSourceTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? type,
    Value<String>? name,
    Value<String>? url,
    Value<String?>? ref,
  }) {
    return ExtensionSourceTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
      ref: ref ?? this.ref,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionSourceTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('ref: $ref')
          ..write(')'))
        .toString();
  }
}

class $ExtensionTableTable extends ExtensionTable
    with TableInfo<$ExtensionTableTable, ExtensionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtensionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nsfwMeta = const VerificationMeta('nsfw');
  @override
  late final GeneratedColumn<bool> nsfw = GeneratedColumn<bool>(
    'nsfw',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nsfw" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sourceCodeMeta = const VerificationMeta(
    'sourceCode',
  );
  @override
  late final GeneratedColumn<String> sourceCode = GeneratedColumn<String>(
    'source_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchAvailableMeta = const VerificationMeta(
    'searchAvailable',
  );
  @override
  late final GeneratedColumn<bool> searchAvailable = GeneratedColumn<bool>(
    'search_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("search_available" IN (0, 1))',
    ),
  );
  static const VerificationMeta _protectorConfigMeta = const VerificationMeta(
    'protectorConfig',
  );
  @override
  late final GeneratedColumn<String> protectorConfig = GeneratedColumn<String>(
    'protector_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<String> revision = GeneratedColumn<String>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    name,
    type,
    version,
    logoUrl,
    language,
    nsfw,
    sourceCode,
    searchAvailable,
    protectorConfig,
    configJson,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extension_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtensionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_logoUrlMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('nsfw')) {
      context.handle(
        _nsfwMeta,
        nsfw.isAcceptableOrUnknown(data['nsfw']!, _nsfwMeta),
      );
    } else if (isInserting) {
      context.missing(_nsfwMeta);
    }
    if (data.containsKey('source_code')) {
      context.handle(
        _sourceCodeMeta,
        sourceCode.isAcceptableOrUnknown(data['source_code']!, _sourceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceCodeMeta);
    }
    if (data.containsKey('search_available')) {
      context.handle(
        _searchAvailableMeta,
        searchAvailable.isAcceptableOrUnknown(
          data['search_available']!,
          _searchAvailableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_searchAvailableMeta);
    }
    if (data.containsKey('protector_config')) {
      context.handle(
        _protectorConfigMeta,
        protectorConfig.isAcceptableOrUnknown(
          data['protector_config']!,
          _protectorConfigMeta,
        ),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtensionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtensionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      nsfw: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nsfw'],
      )!,
      sourceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_code'],
      )!,
      searchAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}search_available'],
      )!,
      protectorConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protector_config'],
      ),
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision'],
      ),
    );
  }

  @override
  $ExtensionTableTable createAlias(String alias) {
    return $ExtensionTableTable(attachedDatabase, alias);
  }
}

class ExtensionTableData extends DataClass
    implements Insertable<ExtensionTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String name;
  final String type;
  final int version;
  final String logoUrl;
  final String language;
  final bool nsfw;
  final String sourceCode;
  final bool searchAvailable;
  final String? protectorConfig;
  final String? configJson;
  final String? revision;
  const ExtensionTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.name,
    required this.type,
    required this.version,
    required this.logoUrl,
    required this.language,
    required this.nsfw,
    required this.sourceCode,
    required this.searchAvailable,
    this.protectorConfig,
    this.configJson,
    this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['version'] = Variable<int>(version);
    map['logo_url'] = Variable<String>(logoUrl);
    map['language'] = Variable<String>(language);
    map['nsfw'] = Variable<bool>(nsfw);
    map['source_code'] = Variable<String>(sourceCode);
    map['search_available'] = Variable<bool>(searchAvailable);
    if (!nullToAbsent || protectorConfig != null) {
      map['protector_config'] = Variable<String>(protectorConfig);
    }
    if (!nullToAbsent || configJson != null) {
      map['config_json'] = Variable<String>(configJson);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<String>(revision);
    }
    return map;
  }

  ExtensionTableCompanion toCompanion(bool nullToAbsent) {
    return ExtensionTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      name: Value(name),
      type: Value(type),
      version: Value(version),
      logoUrl: Value(logoUrl),
      language: Value(language),
      nsfw: Value(nsfw),
      sourceCode: Value(sourceCode),
      searchAvailable: Value(searchAvailable),
      protectorConfig: protectorConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(protectorConfig),
      configJson: configJson == null && nullToAbsent
          ? const Value.absent()
          : Value(configJson),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
    );
  }

  factory ExtensionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtensionTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      version: serializer.fromJson<int>(json['version']),
      logoUrl: serializer.fromJson<String>(json['logoUrl']),
      language: serializer.fromJson<String>(json['language']),
      nsfw: serializer.fromJson<bool>(json['nsfw']),
      sourceCode: serializer.fromJson<String>(json['sourceCode']),
      searchAvailable: serializer.fromJson<bool>(json['searchAvailable']),
      protectorConfig: serializer.fromJson<String?>(json['protectorConfig']),
      configJson: serializer.fromJson<String?>(json['configJson']),
      revision: serializer.fromJson<String?>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'version': serializer.toJson<int>(version),
      'logoUrl': serializer.toJson<String>(logoUrl),
      'language': serializer.toJson<String>(language),
      'nsfw': serializer.toJson<bool>(nsfw),
      'sourceCode': serializer.toJson<String>(sourceCode),
      'searchAvailable': serializer.toJson<bool>(searchAvailable),
      'protectorConfig': serializer.toJson<String?>(protectorConfig),
      'configJson': serializer.toJson<String?>(configJson),
      'revision': serializer.toJson<String?>(revision),
    };
  }

  ExtensionTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? name,
    String? type,
    int? version,
    String? logoUrl,
    String? language,
    bool? nsfw,
    String? sourceCode,
    bool? searchAvailable,
    Value<String?> protectorConfig = const Value.absent(),
    Value<String?> configJson = const Value.absent(),
    Value<String?> revision = const Value.absent(),
  }) => ExtensionTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    name: name ?? this.name,
    type: type ?? this.type,
    version: version ?? this.version,
    logoUrl: logoUrl ?? this.logoUrl,
    language: language ?? this.language,
    nsfw: nsfw ?? this.nsfw,
    sourceCode: sourceCode ?? this.sourceCode,
    searchAvailable: searchAvailable ?? this.searchAvailable,
    protectorConfig: protectorConfig.present
        ? protectorConfig.value
        : this.protectorConfig,
    configJson: configJson.present ? configJson.value : this.configJson,
    revision: revision.present ? revision.value : this.revision,
  );
  ExtensionTableData copyWithCompanion(ExtensionTableCompanion data) {
    return ExtensionTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      version: data.version.present ? data.version.value : this.version,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      language: data.language.present ? data.language.value : this.language,
      nsfw: data.nsfw.present ? data.nsfw.value : this.nsfw,
      sourceCode: data.sourceCode.present
          ? data.sourceCode.value
          : this.sourceCode,
      searchAvailable: data.searchAvailable.present
          ? data.searchAvailable.value
          : this.searchAvailable,
      protectorConfig: data.protectorConfig.present
          ? data.protectorConfig.value
          : this.protectorConfig,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('searchAvailable: $searchAvailable, ')
          ..write('protectorConfig: $protectorConfig, ')
          ..write('configJson: $configJson, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    name,
    type,
    version,
    logoUrl,
    language,
    nsfw,
    sourceCode,
    searchAvailable,
    protectorConfig,
    configJson,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtensionTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.type == this.type &&
          other.version == this.version &&
          other.logoUrl == this.logoUrl &&
          other.language == this.language &&
          other.nsfw == this.nsfw &&
          other.sourceCode == this.sourceCode &&
          other.searchAvailable == this.searchAvailable &&
          other.protectorConfig == this.protectorConfig &&
          other.configJson == this.configJson &&
          other.revision == this.revision);
}

class ExtensionTableCompanion extends UpdateCompanion<ExtensionTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> name;
  final Value<String> type;
  final Value<int> version;
  final Value<String> logoUrl;
  final Value<String> language;
  final Value<bool> nsfw;
  final Value<String> sourceCode;
  final Value<bool> searchAvailable;
  final Value<String?> protectorConfig;
  final Value<String?> configJson;
  final Value<String?> revision;
  const ExtensionTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.language = const Value.absent(),
    this.nsfw = const Value.absent(),
    this.sourceCode = const Value.absent(),
    this.searchAvailable = const Value.absent(),
    this.protectorConfig = const Value.absent(),
    this.configJson = const Value.absent(),
    this.revision = const Value.absent(),
  });
  ExtensionTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String name,
    required String type,
    required int version,
    required String logoUrl,
    required String language,
    required bool nsfw,
    required String sourceCode,
    required bool searchAvailable,
    this.protectorConfig = const Value.absent(),
    this.configJson = const Value.absent(),
    this.revision = const Value.absent(),
  }) : uid = Value(uid),
       name = Value(name),
       type = Value(type),
       version = Value(version),
       logoUrl = Value(logoUrl),
       language = Value(language),
       nsfw = Value(nsfw),
       sourceCode = Value(sourceCode),
       searchAvailable = Value(searchAvailable);
  static Insertable<ExtensionTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? version,
    Expression<String>? logoUrl,
    Expression<String>? language,
    Expression<bool>? nsfw,
    Expression<String>? sourceCode,
    Expression<bool>? searchAvailable,
    Expression<String>? protectorConfig,
    Expression<String>? configJson,
    Expression<String>? revision,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (language != null) 'language': language,
      if (nsfw != null) 'nsfw': nsfw,
      if (sourceCode != null) 'source_code': sourceCode,
      if (searchAvailable != null) 'search_available': searchAvailable,
      if (protectorConfig != null) 'protector_config': protectorConfig,
      if (configJson != null) 'config_json': configJson,
      if (revision != null) 'revision': revision,
    });
  }

  ExtensionTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? name,
    Value<String>? type,
    Value<int>? version,
    Value<String>? logoUrl,
    Value<String>? language,
    Value<bool>? nsfw,
    Value<String>? sourceCode,
    Value<bool>? searchAvailable,
    Value<String?>? protectorConfig,
    Value<String?>? configJson,
    Value<String?>? revision,
  }) {
    return ExtensionTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      type: type ?? this.type,
      version: version ?? this.version,
      logoUrl: logoUrl ?? this.logoUrl,
      language: language ?? this.language,
      nsfw: nsfw ?? this.nsfw,
      sourceCode: sourceCode ?? this.sourceCode,
      searchAvailable: searchAvailable ?? this.searchAvailable,
      protectorConfig: protectorConfig ?? this.protectorConfig,
      configJson: configJson ?? this.configJson,
      revision: revision ?? this.revision,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (nsfw.present) {
      map['nsfw'] = Variable<bool>(nsfw.value);
    }
    if (sourceCode.present) {
      map['source_code'] = Variable<String>(sourceCode.value);
    }
    if (searchAvailable.present) {
      map['search_available'] = Variable<bool>(searchAvailable.value);
    }
    if (protectorConfig.present) {
      map['protector_config'] = Variable<String>(protectorConfig.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (revision.present) {
      map['revision'] = Variable<String>(revision.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('searchAvailable: $searchAvailable, ')
          ..write('protectorConfig: $protectorConfig, ')
          ..write('configJson: $configJson, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }
}

class $ConcreteDataTableTable extends ConcreteDataTable
    with TableInfo<$ConcreteDataTableTable, ConcreteDataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConcreteDataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionUidMeta = const VerificationMeta(
    'extensionUid',
  );
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
    'extension_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concreteJsonMeta = const VerificationMeta(
    'concreteJson',
  );
  @override
  late final GeneratedColumn<String> concreteJson = GeneratedColumn<String>(
    'concrete_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    title,
    cover,
    data,
    concreteJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concrete_data_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConcreteDataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('extension_uid')) {
      context.handle(
        _extensionUidMeta,
        extensionUid.isAcceptableOrUnknown(
          data['extension_uid']!,
          _extensionUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('concrete_json')) {
      context.handle(
        _concreteJsonMeta,
        concreteJson.isAcceptableOrUnknown(
          data['concrete_json']!,
          _concreteJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConcreteDataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcreteDataTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      extensionUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension_uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      concreteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_json'],
      ),
    );
  }

  @override
  $ConcreteDataTableTable createAlias(String alias) {
    return $ConcreteDataTableTable(attachedDatabase, alias);
  }
}

class ConcreteDataTableData extends DataClass
    implements Insertable<ConcreteDataTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final String? concreteJson;
  const ConcreteDataTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.concreteJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['extension_uid'] = Variable<String>(extensionUid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    if (!nullToAbsent || concreteJson != null) {
      map['concrete_json'] = Variable<String>(concreteJson);
    }
    return map;
  }

  ConcreteDataTableCompanion toCompanion(bool nullToAbsent) {
    return ConcreteDataTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      extensionUid: Value(extensionUid),
      title: Value(title),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      concreteJson: concreteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(concreteJson),
    );
  }

  factory ConcreteDataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConcreteDataTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      extensionUid: serializer.fromJson<String>(json['extensionUid']),
      title: serializer.fromJson<String>(json['title']),
      cover: serializer.fromJson<String?>(json['cover']),
      data: serializer.fromJson<String?>(json['data']),
      concreteJson: serializer.fromJson<String?>(json['concreteJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'extensionUid': serializer.toJson<String>(extensionUid),
      'title': serializer.toJson<String>(title),
      'cover': serializer.toJson<String?>(cover),
      'data': serializer.toJson<String?>(data),
      'concreteJson': serializer.toJson<String?>(concreteJson),
    };
  }

  ConcreteDataTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? extensionUid,
    String? title,
    Value<String?> cover = const Value.absent(),
    Value<String?> data = const Value.absent(),
    Value<String?> concreteJson = const Value.absent(),
  }) => ConcreteDataTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    extensionUid: extensionUid ?? this.extensionUid,
    title: title ?? this.title,
    cover: cover.present ? cover.value : this.cover,
    data: data.present ? data.value : this.data,
    concreteJson: concreteJson.present ? concreteJson.value : this.concreteJson,
  );
  ConcreteDataTableData copyWithCompanion(ConcreteDataTableCompanion data) {
    return ConcreteDataTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      extensionUid: data.extensionUid.present
          ? data.extensionUid.value
          : this.extensionUid,
      title: data.title.present ? data.title.value : this.title,
      cover: data.cover.present ? data.cover.value : this.cover,
      data: data.data.present ? data.data.value : this.data,
      concreteJson: data.concreteJson.present
          ? data.concreteJson.value
          : this.concreteJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConcreteDataTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('data: $data, ')
          ..write('concreteJson: $concreteJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    title,
    cover,
    data,
    concreteJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConcreteDataTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.extensionUid == this.extensionUid &&
          other.title == this.title &&
          other.cover == this.cover &&
          other.data == this.data &&
          other.concreteJson == this.concreteJson);
}

class ConcreteDataTableCompanion
    extends UpdateCompanion<ConcreteDataTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> extensionUid;
  final Value<String> title;
  final Value<String?> cover;
  final Value<String?> data;
  final Value<String?> concreteJson;
  const ConcreteDataTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.title = const Value.absent(),
    this.cover = const Value.absent(),
    this.data = const Value.absent(),
    this.concreteJson = const Value.absent(),
  });
  ConcreteDataTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String extensionUid,
    required String title,
    this.cover = const Value.absent(),
    this.data = const Value.absent(),
    this.concreteJson = const Value.absent(),
  }) : uid = Value(uid),
       extensionUid = Value(extensionUid),
       title = Value(title);
  static Insertable<ConcreteDataTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? extensionUid,
    Expression<String>? title,
    Expression<String>? cover,
    Expression<String>? data,
    Expression<String>? concreteJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (extensionUid != null) 'extension_uid': extensionUid,
      if (title != null) 'title': title,
      if (cover != null) 'cover': cover,
      if (data != null) 'data': data,
      if (concreteJson != null) 'concrete_json': concreteJson,
    });
  }

  ConcreteDataTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? extensionUid,
    Value<String>? title,
    Value<String?>? cover,
    Value<String?>? data,
    Value<String?>? concreteJson,
  }) {
    return ConcreteDataTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      extensionUid: extensionUid ?? this.extensionUid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      data: data ?? this.data,
      concreteJson: concreteJson ?? this.concreteJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (extensionUid.present) {
      map['extension_uid'] = Variable<String>(extensionUid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (concreteJson.present) {
      map['concrete_json'] = Variable<String>(concreteJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConcreteDataTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('data: $data, ')
          ..write('concreteJson: $concreteJson')
          ..write(')'))
        .toString();
  }
}

class $ChapterActivityTableTable extends ChapterActivityTable
    with TableInfo<$ChapterActivityTableTable, ChapterActivityTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterActivityTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concreteIdMeta = const VerificationMeta(
    'concreteId',
  );
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
    'concrete_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readPagesMeta = const VerificationMeta(
    'readPages',
  );
  @override
  late final GeneratedColumn<int> readPages = GeneratedColumn<int>(
    'read_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    title,
    timestamp,
    data,
    concreteId,
    readPages,
    totalPages,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_activity_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterActivityTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
        _concreteIdMeta,
        concreteId.isAcceptableOrUnknown(data['concrete_id']!, _concreteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('read_pages')) {
      context.handle(
        _readPagesMeta,
        readPages.isAcceptableOrUnknown(data['read_pages']!, _readPagesMeta),
      );
    } else if (isInserting) {
      context.missing(_readPagesMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPagesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterActivityTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterActivityTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      concreteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}concrete_id'],
      )!,
      readPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_pages'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
    );
  }

  @override
  $ChapterActivityTableTable createAlias(String alias) {
    return $ChapterActivityTableTable(attachedDatabase, alias);
  }
}

class ChapterActivityTableData extends DataClass
    implements Insertable<ChapterActivityTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String title;
  final String? timestamp;
  final String? data;
  final int concreteId;
  final int readPages;
  final int totalPages;
  const ChapterActivityTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.title,
    this.timestamp,
    this.data,
    required this.concreteId,
    required this.readPages,
    required this.totalPages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<String>(timestamp);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['concrete_id'] = Variable<int>(concreteId);
    map['read_pages'] = Variable<int>(readPages);
    map['total_pages'] = Variable<int>(totalPages);
    return map;
  }

  ChapterActivityTableCompanion toCompanion(bool nullToAbsent) {
    return ChapterActivityTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      title: Value(title),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      concreteId: Value(concreteId),
      readPages: Value(readPages),
      totalPages: Value(totalPages),
    );
  }

  factory ChapterActivityTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterActivityTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      timestamp: serializer.fromJson<String?>(json['timestamp']),
      data: serializer.fromJson<String?>(json['data']),
      concreteId: serializer.fromJson<int>(json['concreteId']),
      readPages: serializer.fromJson<int>(json['readPages']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'title': serializer.toJson<String>(title),
      'timestamp': serializer.toJson<String?>(timestamp),
      'data': serializer.toJson<String?>(data),
      'concreteId': serializer.toJson<int>(concreteId),
      'readPages': serializer.toJson<int>(readPages),
      'totalPages': serializer.toJson<int>(totalPages),
    };
  }

  ChapterActivityTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? title,
    Value<String?> timestamp = const Value.absent(),
    Value<String?> data = const Value.absent(),
    int? concreteId,
    int? readPages,
    int? totalPages,
  }) => ChapterActivityTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    title: title ?? this.title,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    data: data.present ? data.value : this.data,
    concreteId: concreteId ?? this.concreteId,
    readPages: readPages ?? this.readPages,
    totalPages: totalPages ?? this.totalPages,
  );
  ChapterActivityTableData copyWithCompanion(
    ChapterActivityTableCompanion data,
  ) {
    return ChapterActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
      concreteId: data.concreteId.present
          ? data.concreteId.value
          : this.concreteId,
      readPages: data.readPages.present ? data.readPages.value : this.readPages,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterActivityTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('concreteId: $concreteId, ')
          ..write('readPages: $readPages, ')
          ..write('totalPages: $totalPages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    title,
    timestamp,
    data,
    concreteId,
    readPages,
    totalPages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterActivityTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.timestamp == this.timestamp &&
          other.data == this.data &&
          other.concreteId == this.concreteId &&
          other.readPages == this.readPages &&
          other.totalPages == this.totalPages);
}

class ChapterActivityTableCompanion
    extends UpdateCompanion<ChapterActivityTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> title;
  final Value<String?> timestamp;
  final Value<String?> data;
  final Value<int> concreteId;
  final Value<int> readPages;
  final Value<int> totalPages;
  const ChapterActivityTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    this.concreteId = const Value.absent(),
    this.readPages = const Value.absent(),
    this.totalPages = const Value.absent(),
  });
  ChapterActivityTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String title,
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    required int concreteId,
    required int readPages,
    required int totalPages,
  }) : uid = Value(uid),
       title = Value(title),
       concreteId = Value(concreteId),
       readPages = Value(readPages),
       totalPages = Value(totalPages);
  static Insertable<ChapterActivityTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? title,
    Expression<String>? timestamp,
    Expression<String>? data,
    Expression<int>? concreteId,
    Expression<int>? readPages,
    Expression<int>? totalPages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (timestamp != null) 'timestamp': timestamp,
      if (data != null) 'data': data,
      if (concreteId != null) 'concrete_id': concreteId,
      if (readPages != null) 'read_pages': readPages,
      if (totalPages != null) 'total_pages': totalPages,
    });
  }

  ChapterActivityTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? title,
    Value<String?>? timestamp,
    Value<String?>? data,
    Value<int>? concreteId,
    Value<int>? readPages,
    Value<int>? totalPages,
  }) {
    return ChapterActivityTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      concreteId: concreteId ?? this.concreteId,
      readPages: readPages ?? this.readPages,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (concreteId.present) {
      map['concrete_id'] = Variable<int>(concreteId.value);
    }
    if (readPages.present) {
      map['read_pages'] = Variable<int>(readPages.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterActivityTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('concreteId: $concreteId, ')
          ..write('readPages: $readPages, ')
          ..write('totalPages: $totalPages')
          ..write(')'))
        .toString();
  }
}

class $AnimeEpisodeActivityTableTable extends AnimeEpisodeActivityTable
    with
        TableInfo<
          $AnimeEpisodeActivityTableTable,
          AnimeEpisodeActivityTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeEpisodeActivityTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concreteIdMeta = const VerificationMeta(
    'concreteId',
  );
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
    'concrete_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchedTimeMeta = const VerificationMeta(
    'watchedTime',
  );
  @override
  late final GeneratedColumn<int> watchedTime = GeneratedColumn<int>(
    'watched_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTimeMeta = const VerificationMeta(
    'totalTime',
  );
  @override
  late final GeneratedColumn<int> totalTime = GeneratedColumn<int>(
    'total_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedWatchedMeta = const VerificationMeta(
    'markedWatched',
  );
  @override
  late final GeneratedColumn<bool> markedWatched = GeneratedColumn<bool>(
    'marked_watched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("marked_watched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    title,
    timestamp,
    data,
    concreteId,
    watchedTime,
    totalTime,
    markedWatched,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_episode_activity_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimeEpisodeActivityTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
        _concreteIdMeta,
        concreteId.isAcceptableOrUnknown(data['concrete_id']!, _concreteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('watched_time')) {
      context.handle(
        _watchedTimeMeta,
        watchedTime.isAcceptableOrUnknown(
          data['watched_time']!,
          _watchedTimeMeta,
        ),
      );
    }
    if (data.containsKey('total_time')) {
      context.handle(
        _totalTimeMeta,
        totalTime.isAcceptableOrUnknown(data['total_time']!, _totalTimeMeta),
      );
    }
    if (data.containsKey('marked_watched')) {
      context.handle(
        _markedWatchedMeta,
        markedWatched.isAcceptableOrUnknown(
          data['marked_watched']!,
          _markedWatchedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimeEpisodeActivityTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeEpisodeActivityTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      concreteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}concrete_id'],
      )!,
      watchedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watched_time'],
      ),
      totalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_time'],
      ),
      markedWatched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}marked_watched'],
      )!,
    );
  }

  @override
  $AnimeEpisodeActivityTableTable createAlias(String alias) {
    return $AnimeEpisodeActivityTableTable(attachedDatabase, alias);
  }
}

class AnimeEpisodeActivityTableData extends DataClass
    implements Insertable<AnimeEpisodeActivityTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String title;
  final String? timestamp;
  final String? data;
  final int concreteId;
  final int? watchedTime;
  final int? totalTime;
  final bool markedWatched;
  const AnimeEpisodeActivityTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.title,
    this.timestamp,
    this.data,
    required this.concreteId,
    this.watchedTime,
    this.totalTime,
    required this.markedWatched,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<String>(timestamp);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['concrete_id'] = Variable<int>(concreteId);
    if (!nullToAbsent || watchedTime != null) {
      map['watched_time'] = Variable<int>(watchedTime);
    }
    if (!nullToAbsent || totalTime != null) {
      map['total_time'] = Variable<int>(totalTime);
    }
    map['marked_watched'] = Variable<bool>(markedWatched);
    return map;
  }

  AnimeEpisodeActivityTableCompanion toCompanion(bool nullToAbsent) {
    return AnimeEpisodeActivityTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      title: Value(title),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      concreteId: Value(concreteId),
      watchedTime: watchedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedTime),
      totalTime: totalTime == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTime),
      markedWatched: Value(markedWatched),
    );
  }

  factory AnimeEpisodeActivityTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimeEpisodeActivityTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      timestamp: serializer.fromJson<String?>(json['timestamp']),
      data: serializer.fromJson<String?>(json['data']),
      concreteId: serializer.fromJson<int>(json['concreteId']),
      watchedTime: serializer.fromJson<int?>(json['watchedTime']),
      totalTime: serializer.fromJson<int?>(json['totalTime']),
      markedWatched: serializer.fromJson<bool>(json['markedWatched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'title': serializer.toJson<String>(title),
      'timestamp': serializer.toJson<String?>(timestamp),
      'data': serializer.toJson<String?>(data),
      'concreteId': serializer.toJson<int>(concreteId),
      'watchedTime': serializer.toJson<int?>(watchedTime),
      'totalTime': serializer.toJson<int?>(totalTime),
      'markedWatched': serializer.toJson<bool>(markedWatched),
    };
  }

  AnimeEpisodeActivityTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? title,
    Value<String?> timestamp = const Value.absent(),
    Value<String?> data = const Value.absent(),
    int? concreteId,
    Value<int?> watchedTime = const Value.absent(),
    Value<int?> totalTime = const Value.absent(),
    bool? markedWatched,
  }) => AnimeEpisodeActivityTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    title: title ?? this.title,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    data: data.present ? data.value : this.data,
    concreteId: concreteId ?? this.concreteId,
    watchedTime: watchedTime.present ? watchedTime.value : this.watchedTime,
    totalTime: totalTime.present ? totalTime.value : this.totalTime,
    markedWatched: markedWatched ?? this.markedWatched,
  );
  AnimeEpisodeActivityTableData copyWithCompanion(
    AnimeEpisodeActivityTableCompanion data,
  ) {
    return AnimeEpisodeActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
      concreteId: data.concreteId.present
          ? data.concreteId.value
          : this.concreteId,
      watchedTime: data.watchedTime.present
          ? data.watchedTime.value
          : this.watchedTime,
      totalTime: data.totalTime.present ? data.totalTime.value : this.totalTime,
      markedWatched: data.markedWatched.present
          ? data.markedWatched.value
          : this.markedWatched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimeEpisodeActivityTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('concreteId: $concreteId, ')
          ..write('watchedTime: $watchedTime, ')
          ..write('totalTime: $totalTime, ')
          ..write('markedWatched: $markedWatched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    title,
    timestamp,
    data,
    concreteId,
    watchedTime,
    totalTime,
    markedWatched,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimeEpisodeActivityTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.timestamp == this.timestamp &&
          other.data == this.data &&
          other.concreteId == this.concreteId &&
          other.watchedTime == this.watchedTime &&
          other.totalTime == this.totalTime &&
          other.markedWatched == this.markedWatched);
}

class AnimeEpisodeActivityTableCompanion
    extends UpdateCompanion<AnimeEpisodeActivityTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> title;
  final Value<String?> timestamp;
  final Value<String?> data;
  final Value<int> concreteId;
  final Value<int?> watchedTime;
  final Value<int?> totalTime;
  final Value<bool> markedWatched;
  const AnimeEpisodeActivityTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    this.concreteId = const Value.absent(),
    this.watchedTime = const Value.absent(),
    this.totalTime = const Value.absent(),
    this.markedWatched = const Value.absent(),
  });
  AnimeEpisodeActivityTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String title,
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    required int concreteId,
    this.watchedTime = const Value.absent(),
    this.totalTime = const Value.absent(),
    this.markedWatched = const Value.absent(),
  }) : uid = Value(uid),
       title = Value(title),
       concreteId = Value(concreteId);
  static Insertable<AnimeEpisodeActivityTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? title,
    Expression<String>? timestamp,
    Expression<String>? data,
    Expression<int>? concreteId,
    Expression<int>? watchedTime,
    Expression<int>? totalTime,
    Expression<bool>? markedWatched,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (timestamp != null) 'timestamp': timestamp,
      if (data != null) 'data': data,
      if (concreteId != null) 'concrete_id': concreteId,
      if (watchedTime != null) 'watched_time': watchedTime,
      if (totalTime != null) 'total_time': totalTime,
      if (markedWatched != null) 'marked_watched': markedWatched,
    });
  }

  AnimeEpisodeActivityTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? title,
    Value<String?>? timestamp,
    Value<String?>? data,
    Value<int>? concreteId,
    Value<int?>? watchedTime,
    Value<int?>? totalTime,
    Value<bool>? markedWatched,
  }) {
    return AnimeEpisodeActivityTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      concreteId: concreteId ?? this.concreteId,
      watchedTime: watchedTime ?? this.watchedTime,
      totalTime: totalTime ?? this.totalTime,
      markedWatched: markedWatched ?? this.markedWatched,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (concreteId.present) {
      map['concrete_id'] = Variable<int>(concreteId.value);
    }
    if (watchedTime.present) {
      map['watched_time'] = Variable<int>(watchedTime.value);
    }
    if (totalTime.present) {
      map['total_time'] = Variable<int>(totalTime.value);
    }
    if (markedWatched.present) {
      map['marked_watched'] = Variable<bool>(markedWatched.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimeEpisodeActivityTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('concreteId: $concreteId, ')
          ..write('watchedTime: $watchedTime, ')
          ..write('totalTime: $totalTime, ')
          ..write('markedWatched: $markedWatched')
          ..write(')'))
        .toString();
  }
}

class $CategoryTableTable extends CategoryTable
    with TableInfo<$CategoryTableTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoryTableTable createAlias(String alias) {
    return $CategoryTableTable(attachedDatabase, alias);
  }
}

class CategoryTableData extends DataClass
    implements Insertable<CategoryTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String name;
  final int sortOrder;
  const CategoryTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoryTableCompanion toCompanion(bool nullToAbsent) {
    return CategoryTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? name,
    int? sortOrder,
  }) => CategoryTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryTableData copyWithCompanion(CategoryTableCompanion data) {
    return CategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CategoryTableCompanion extends UpdateCompanion<CategoryTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> name;
  final Value<int> sortOrder;
  const CategoryTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoryTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CategoryTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoryTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return CategoryTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntryTableTable extends LibraryEntryTable
    with TableInfo<$LibraryEntryTableTable, LibraryEntryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionUidMeta = const VerificationMeta(
    'extensionUid',
  );
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
    'extension_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackUpdatesMeta = const VerificationMeta(
    'trackUpdates',
  );
  @override
  late final GeneratedColumn<bool> trackUpdates = GeneratedColumn<bool>(
    'track_updates',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_updates" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyUpdatesMeta = const VerificationMeta(
    'notifyUpdates',
  );
  @override
  late final GeneratedColumn<bool> notifyUpdates = GeneratedColumn<bool>(
    'notify_updates',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_updates" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    title,
    cover,
    data,
    categoryId,
    lastReadAt,
    trackUpdates,
    notifyUpdates,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('extension_uid')) {
      context.handle(
        _extensionUidMeta,
        extensionUid.isAcceptableOrUnknown(
          data['extension_uid']!,
          _extensionUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    }
    if (data.containsKey('track_updates')) {
      context.handle(
        _trackUpdatesMeta,
        trackUpdates.isAcceptableOrUnknown(
          data['track_updates']!,
          _trackUpdatesMeta,
        ),
      );
    }
    if (data.containsKey('notify_updates')) {
      context.handle(
        _notifyUpdatesMeta,
        notifyUpdates.isAcceptableOrUnknown(
          data['notify_updates']!,
          _notifyUpdatesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      extensionUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension_uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      ),
      trackUpdates: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_updates'],
      )!,
      notifyUpdates: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_updates'],
      )!,
    );
  }

  @override
  $LibraryEntryTableTable createAlias(String alias) {
    return $LibraryEntryTableTable(attachedDatabase, alias);
  }
}

class LibraryEntryTableData extends DataClass
    implements Insertable<LibraryEntryTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final int? categoryId;
  final DateTime? lastReadAt;
  final bool trackUpdates;
  final bool notifyUpdates;
  const LibraryEntryTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.categoryId,
    this.lastReadAt,
    required this.trackUpdates,
    required this.notifyUpdates,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['extension_uid'] = Variable<String>(extensionUid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    map['track_updates'] = Variable<bool>(trackUpdates);
    map['notify_updates'] = Variable<bool>(notifyUpdates);
    return map;
  }

  LibraryEntryTableCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntryTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      extensionUid: Value(extensionUid),
      title: Value(title),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      trackUpdates: Value(trackUpdates),
      notifyUpdates: Value(notifyUpdates),
    );
  }

  factory LibraryEntryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      extensionUid: serializer.fromJson<String>(json['extensionUid']),
      title: serializer.fromJson<String>(json['title']),
      cover: serializer.fromJson<String?>(json['cover']),
      data: serializer.fromJson<String?>(json['data']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
      trackUpdates: serializer.fromJson<bool>(json['trackUpdates']),
      notifyUpdates: serializer.fromJson<bool>(json['notifyUpdates']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'extensionUid': serializer.toJson<String>(extensionUid),
      'title': serializer.toJson<String>(title),
      'cover': serializer.toJson<String?>(cover),
      'data': serializer.toJson<String?>(data),
      'categoryId': serializer.toJson<int?>(categoryId),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
      'trackUpdates': serializer.toJson<bool>(trackUpdates),
      'notifyUpdates': serializer.toJson<bool>(notifyUpdates),
    };
  }

  LibraryEntryTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? extensionUid,
    String? title,
    Value<String?> cover = const Value.absent(),
    Value<String?> data = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<DateTime?> lastReadAt = const Value.absent(),
    bool? trackUpdates,
    bool? notifyUpdates,
  }) => LibraryEntryTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    extensionUid: extensionUid ?? this.extensionUid,
    title: title ?? this.title,
    cover: cover.present ? cover.value : this.cover,
    data: data.present ? data.value : this.data,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
    trackUpdates: trackUpdates ?? this.trackUpdates,
    notifyUpdates: notifyUpdates ?? this.notifyUpdates,
  );
  LibraryEntryTableData copyWithCompanion(LibraryEntryTableCompanion data) {
    return LibraryEntryTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      extensionUid: data.extensionUid.present
          ? data.extensionUid.value
          : this.extensionUid,
      title: data.title.present ? data.title.value : this.title,
      cover: data.cover.present ? data.cover.value : this.cover,
      data: data.data.present ? data.data.value : this.data,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
      trackUpdates: data.trackUpdates.present
          ? data.trackUpdates.value
          : this.trackUpdates,
      notifyUpdates: data.notifyUpdates.present
          ? data.notifyUpdates.value
          : this.notifyUpdates,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('data: $data, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('trackUpdates: $trackUpdates, ')
          ..write('notifyUpdates: $notifyUpdates')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    title,
    cover,
    data,
    categoryId,
    lastReadAt,
    trackUpdates,
    notifyUpdates,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.extensionUid == this.extensionUid &&
          other.title == this.title &&
          other.cover == this.cover &&
          other.data == this.data &&
          other.categoryId == this.categoryId &&
          other.lastReadAt == this.lastReadAt &&
          other.trackUpdates == this.trackUpdates &&
          other.notifyUpdates == this.notifyUpdates);
}

class LibraryEntryTableCompanion
    extends UpdateCompanion<LibraryEntryTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> extensionUid;
  final Value<String> title;
  final Value<String?> cover;
  final Value<String?> data;
  final Value<int?> categoryId;
  final Value<DateTime?> lastReadAt;
  final Value<bool> trackUpdates;
  final Value<bool> notifyUpdates;
  const LibraryEntryTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.title = const Value.absent(),
    this.cover = const Value.absent(),
    this.data = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.trackUpdates = const Value.absent(),
    this.notifyUpdates = const Value.absent(),
  });
  LibraryEntryTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String extensionUid,
    required String title,
    this.cover = const Value.absent(),
    this.data = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.trackUpdates = const Value.absent(),
    this.notifyUpdates = const Value.absent(),
  }) : uid = Value(uid),
       extensionUid = Value(extensionUid),
       title = Value(title);
  static Insertable<LibraryEntryTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? extensionUid,
    Expression<String>? title,
    Expression<String>? cover,
    Expression<String>? data,
    Expression<int>? categoryId,
    Expression<DateTime>? lastReadAt,
    Expression<bool>? trackUpdates,
    Expression<bool>? notifyUpdates,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (extensionUid != null) 'extension_uid': extensionUid,
      if (title != null) 'title': title,
      if (cover != null) 'cover': cover,
      if (data != null) 'data': data,
      if (categoryId != null) 'category_id': categoryId,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (trackUpdates != null) 'track_updates': trackUpdates,
      if (notifyUpdates != null) 'notify_updates': notifyUpdates,
    });
  }

  LibraryEntryTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? extensionUid,
    Value<String>? title,
    Value<String?>? cover,
    Value<String?>? data,
    Value<int?>? categoryId,
    Value<DateTime?>? lastReadAt,
    Value<bool>? trackUpdates,
    Value<bool>? notifyUpdates,
  }) {
    return LibraryEntryTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      extensionUid: extensionUid ?? this.extensionUid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      data: data ?? this.data,
      categoryId: categoryId ?? this.categoryId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      trackUpdates: trackUpdates ?? this.trackUpdates,
      notifyUpdates: notifyUpdates ?? this.notifyUpdates,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (extensionUid.present) {
      map['extension_uid'] = Variable<String>(extensionUid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (trackUpdates.present) {
      map['track_updates'] = Variable<bool>(trackUpdates.value);
    }
    if (notifyUpdates.present) {
      map['notify_updates'] = Variable<bool>(notifyUpdates.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('data: $data, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('trackUpdates: $trackUpdates, ')
          ..write('notifyUpdates: $notifyUpdates')
          ..write(')'))
        .toString();
  }
}

class $DownloadTableTable extends DownloadTable
    with TableInfo<$DownloadTableTable, DownloadTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionUidMeta = const VerificationMeta(
    'extensionUid',
  );
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
    'extension_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteUidMeta = const VerificationMeta(
    'concreteUid',
  );
  @override
  late final GeneratedColumn<String> concreteUid = GeneratedColumn<String>(
    'concrete_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteIdMeta = const VerificationMeta(
    'concreteId',
  );
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
    'concrete_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteTitleMeta = const VerificationMeta(
    'concreteTitle',
  );
  @override
  late final GeneratedColumn<String> concreteTitle = GeneratedColumn<String>(
    'concrete_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteCoverMeta = const VerificationMeta(
    'concreteCover',
  );
  @override
  late final GeneratedColumn<String> concreteCover = GeneratedColumn<String>(
    'concrete_cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DownloadStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DownloadStatus>($DownloadTableTable.$converterstatus);
  static const VerificationMeta _downloadedPagesMeta = const VerificationMeta(
    'downloadedPages',
  );
  @override
  late final GeneratedColumn<int> downloadedPages = GeneratedColumn<int>(
    'downloaded_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirPathMeta = const VerificationMeta(
    'dirPath',
  );
  @override
  late final GeneratedColumn<String> dirPath = GeneratedColumn<String>(
    'dir_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headersMeta = const VerificationMeta(
    'headers',
  );
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
    'headers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DownloadKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<DownloadKind>($DownloadTableTable.$converterkind);
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playbackMeta = const VerificationMeta(
    'playback',
  );
  @override
  late final GeneratedColumn<String> playback = GeneratedColumn<String>(
    'playback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    concreteUid,
    concreteId,
    concreteTitle,
    concreteCover,
    title,
    status,
    downloadedPages,
    totalPages,
    dirPath,
    headers,
    data,
    kind,
    downloadedBytes,
    totalBytes,
    playback,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('extension_uid')) {
      context.handle(
        _extensionUidMeta,
        extensionUid.isAcceptableOrUnknown(
          data['extension_uid']!,
          _extensionUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('concrete_uid')) {
      context.handle(
        _concreteUidMeta,
        concreteUid.isAcceptableOrUnknown(
          data['concrete_uid']!,
          _concreteUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concreteUidMeta);
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
        _concreteIdMeta,
        concreteId.isAcceptableOrUnknown(data['concrete_id']!, _concreteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('concrete_title')) {
      context.handle(
        _concreteTitleMeta,
        concreteTitle.isAcceptableOrUnknown(
          data['concrete_title']!,
          _concreteTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concreteTitleMeta);
    }
    if (data.containsKey('concrete_cover')) {
      context.handle(
        _concreteCoverMeta,
        concreteCover.isAcceptableOrUnknown(
          data['concrete_cover']!,
          _concreteCoverMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('downloaded_pages')) {
      context.handle(
        _downloadedPagesMeta,
        downloadedPages.isAcceptableOrUnknown(
          data['downloaded_pages']!,
          _downloadedPagesMeta,
        ),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('dir_path')) {
      context.handle(
        _dirPathMeta,
        dirPath.isAcceptableOrUnknown(data['dir_path']!, _dirPathMeta),
      );
    } else if (isInserting) {
      context.missing(_dirPathMeta);
    }
    if (data.containsKey('headers')) {
      context.handle(
        _headersMeta,
        headers.isAcceptableOrUnknown(data['headers']!, _headersMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('playback')) {
      context.handle(
        _playbackMeta,
        playback.isAcceptableOrUnknown(data['playback']!, _playbackMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      extensionUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension_uid'],
      )!,
      concreteUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_uid'],
      )!,
      concreteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}concrete_id'],
      )!,
      concreteTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_title'],
      )!,
      concreteCover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_cover'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: $DownloadTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      downloadedPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_pages'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
      dirPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dir_path'],
      )!,
      headers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      kind: $DownloadTableTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      playback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback'],
      ),
    );
  }

  @override
  $DownloadTableTable createAlias(String alias) {
    return $DownloadTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadStatus, int, int> $converterstatus =
      const EnumIndexConverter<DownloadStatus>(DownloadStatus.values);
  static JsonTypeConverter2<DownloadKind, int, int> $converterkind =
      const EnumIndexConverter<DownloadKind>(DownloadKind.values);
}

class DownloadTableData extends DataClass
    implements Insertable<DownloadTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String extensionUid;
  final String concreteUid;
  final int concreteId;
  final String concreteTitle;
  final String? concreteCover;
  final String title;
  final DownloadStatus status;
  final int downloadedPages;
  final int totalPages;
  final String dirPath;
  final String? headers;
  final String? data;
  final DownloadKind kind;
  final int downloadedBytes;
  final int totalBytes;
  final String? playback;
  const DownloadTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.extensionUid,
    required this.concreteUid,
    required this.concreteId,
    required this.concreteTitle,
    this.concreteCover,
    required this.title,
    required this.status,
    required this.downloadedPages,
    required this.totalPages,
    required this.dirPath,
    this.headers,
    this.data,
    required this.kind,
    required this.downloadedBytes,
    required this.totalBytes,
    this.playback,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['extension_uid'] = Variable<String>(extensionUid);
    map['concrete_uid'] = Variable<String>(concreteUid);
    map['concrete_id'] = Variable<int>(concreteId);
    map['concrete_title'] = Variable<String>(concreteTitle);
    if (!nullToAbsent || concreteCover != null) {
      map['concrete_cover'] = Variable<String>(concreteCover);
    }
    map['title'] = Variable<String>(title);
    {
      map['status'] = Variable<int>(
        $DownloadTableTable.$converterstatus.toSql(status),
      );
    }
    map['downloaded_pages'] = Variable<int>(downloadedPages);
    map['total_pages'] = Variable<int>(totalPages);
    map['dir_path'] = Variable<String>(dirPath);
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<String>(headers);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    {
      map['kind'] = Variable<int>(
        $DownloadTableTable.$converterkind.toSql(kind),
      );
    }
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['total_bytes'] = Variable<int>(totalBytes);
    if (!nullToAbsent || playback != null) {
      map['playback'] = Variable<String>(playback);
    }
    return map;
  }

  DownloadTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      extensionUid: Value(extensionUid),
      concreteUid: Value(concreteUid),
      concreteId: Value(concreteId),
      concreteTitle: Value(concreteTitle),
      concreteCover: concreteCover == null && nullToAbsent
          ? const Value.absent()
          : Value(concreteCover),
      title: Value(title),
      status: Value(status),
      downloadedPages: Value(downloadedPages),
      totalPages: Value(totalPages),
      dirPath: Value(dirPath),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      kind: Value(kind),
      downloadedBytes: Value(downloadedBytes),
      totalBytes: Value(totalBytes),
      playback: playback == null && nullToAbsent
          ? const Value.absent()
          : Value(playback),
    );
  }

  factory DownloadTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      extensionUid: serializer.fromJson<String>(json['extensionUid']),
      concreteUid: serializer.fromJson<String>(json['concreteUid']),
      concreteId: serializer.fromJson<int>(json['concreteId']),
      concreteTitle: serializer.fromJson<String>(json['concreteTitle']),
      concreteCover: serializer.fromJson<String?>(json['concreteCover']),
      title: serializer.fromJson<String>(json['title']),
      status: $DownloadTableTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      downloadedPages: serializer.fromJson<int>(json['downloadedPages']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      dirPath: serializer.fromJson<String>(json['dirPath']),
      headers: serializer.fromJson<String?>(json['headers']),
      data: serializer.fromJson<String?>(json['data']),
      kind: $DownloadTableTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      playback: serializer.fromJson<String?>(json['playback']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'extensionUid': serializer.toJson<String>(extensionUid),
      'concreteUid': serializer.toJson<String>(concreteUid),
      'concreteId': serializer.toJson<int>(concreteId),
      'concreteTitle': serializer.toJson<String>(concreteTitle),
      'concreteCover': serializer.toJson<String?>(concreteCover),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<int>(
        $DownloadTableTable.$converterstatus.toJson(status),
      ),
      'downloadedPages': serializer.toJson<int>(downloadedPages),
      'totalPages': serializer.toJson<int>(totalPages),
      'dirPath': serializer.toJson<String>(dirPath),
      'headers': serializer.toJson<String?>(headers),
      'data': serializer.toJson<String?>(data),
      'kind': serializer.toJson<int>(
        $DownloadTableTable.$converterkind.toJson(kind),
      ),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'playback': serializer.toJson<String?>(playback),
    };
  }

  DownloadTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? extensionUid,
    String? concreteUid,
    int? concreteId,
    String? concreteTitle,
    Value<String?> concreteCover = const Value.absent(),
    String? title,
    DownloadStatus? status,
    int? downloadedPages,
    int? totalPages,
    String? dirPath,
    Value<String?> headers = const Value.absent(),
    Value<String?> data = const Value.absent(),
    DownloadKind? kind,
    int? downloadedBytes,
    int? totalBytes,
    Value<String?> playback = const Value.absent(),
  }) => DownloadTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    extensionUid: extensionUid ?? this.extensionUid,
    concreteUid: concreteUid ?? this.concreteUid,
    concreteId: concreteId ?? this.concreteId,
    concreteTitle: concreteTitle ?? this.concreteTitle,
    concreteCover: concreteCover.present
        ? concreteCover.value
        : this.concreteCover,
    title: title ?? this.title,
    status: status ?? this.status,
    downloadedPages: downloadedPages ?? this.downloadedPages,
    totalPages: totalPages ?? this.totalPages,
    dirPath: dirPath ?? this.dirPath,
    headers: headers.present ? headers.value : this.headers,
    data: data.present ? data.value : this.data,
    kind: kind ?? this.kind,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    totalBytes: totalBytes ?? this.totalBytes,
    playback: playback.present ? playback.value : this.playback,
  );
  DownloadTableData copyWithCompanion(DownloadTableCompanion data) {
    return DownloadTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      extensionUid: data.extensionUid.present
          ? data.extensionUid.value
          : this.extensionUid,
      concreteUid: data.concreteUid.present
          ? data.concreteUid.value
          : this.concreteUid,
      concreteId: data.concreteId.present
          ? data.concreteId.value
          : this.concreteId,
      concreteTitle: data.concreteTitle.present
          ? data.concreteTitle.value
          : this.concreteTitle,
      concreteCover: data.concreteCover.present
          ? data.concreteCover.value
          : this.concreteCover,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      downloadedPages: data.downloadedPages.present
          ? data.downloadedPages.value
          : this.downloadedPages,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      dirPath: data.dirPath.present ? data.dirPath.value : this.dirPath,
      headers: data.headers.present ? data.headers.value : this.headers,
      data: data.data.present ? data.data.value : this.data,
      kind: data.kind.present ? data.kind.value : this.kind,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      playback: data.playback.present ? data.playback.value : this.playback,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('concreteUid: $concreteUid, ')
          ..write('concreteId: $concreteId, ')
          ..write('concreteTitle: $concreteTitle, ')
          ..write('concreteCover: $concreteCover, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('dirPath: $dirPath, ')
          ..write('headers: $headers, ')
          ..write('data: $data, ')
          ..write('kind: $kind, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('playback: $playback')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    extensionUid,
    concreteUid,
    concreteId,
    concreteTitle,
    concreteCover,
    title,
    status,
    downloadedPages,
    totalPages,
    dirPath,
    headers,
    data,
    kind,
    downloadedBytes,
    totalBytes,
    playback,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.extensionUid == this.extensionUid &&
          other.concreteUid == this.concreteUid &&
          other.concreteId == this.concreteId &&
          other.concreteTitle == this.concreteTitle &&
          other.concreteCover == this.concreteCover &&
          other.title == this.title &&
          other.status == this.status &&
          other.downloadedPages == this.downloadedPages &&
          other.totalPages == this.totalPages &&
          other.dirPath == this.dirPath &&
          other.headers == this.headers &&
          other.data == this.data &&
          other.kind == this.kind &&
          other.downloadedBytes == this.downloadedBytes &&
          other.totalBytes == this.totalBytes &&
          other.playback == this.playback);
}

class DownloadTableCompanion extends UpdateCompanion<DownloadTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> extensionUid;
  final Value<String> concreteUid;
  final Value<int> concreteId;
  final Value<String> concreteTitle;
  final Value<String?> concreteCover;
  final Value<String> title;
  final Value<DownloadStatus> status;
  final Value<int> downloadedPages;
  final Value<int> totalPages;
  final Value<String> dirPath;
  final Value<String?> headers;
  final Value<String?> data;
  final Value<DownloadKind> kind;
  final Value<int> downloadedBytes;
  final Value<int> totalBytes;
  final Value<String?> playback;
  const DownloadTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.concreteUid = const Value.absent(),
    this.concreteId = const Value.absent(),
    this.concreteTitle = const Value.absent(),
    this.concreteCover = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedPages = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.dirPath = const Value.absent(),
    this.headers = const Value.absent(),
    this.data = const Value.absent(),
    this.kind = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.playback = const Value.absent(),
  });
  DownloadTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    this.concreteCover = const Value.absent(),
    required String title,
    required DownloadStatus status,
    this.downloadedPages = const Value.absent(),
    this.totalPages = const Value.absent(),
    required String dirPath,
    this.headers = const Value.absent(),
    this.data = const Value.absent(),
    this.kind = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.playback = const Value.absent(),
  }) : uid = Value(uid),
       extensionUid = Value(extensionUid),
       concreteUid = Value(concreteUid),
       concreteId = Value(concreteId),
       concreteTitle = Value(concreteTitle),
       title = Value(title),
       status = Value(status),
       dirPath = Value(dirPath);
  static Insertable<DownloadTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? extensionUid,
    Expression<String>? concreteUid,
    Expression<int>? concreteId,
    Expression<String>? concreteTitle,
    Expression<String>? concreteCover,
    Expression<String>? title,
    Expression<int>? status,
    Expression<int>? downloadedPages,
    Expression<int>? totalPages,
    Expression<String>? dirPath,
    Expression<String>? headers,
    Expression<String>? data,
    Expression<int>? kind,
    Expression<int>? downloadedBytes,
    Expression<int>? totalBytes,
    Expression<String>? playback,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (extensionUid != null) 'extension_uid': extensionUid,
      if (concreteUid != null) 'concrete_uid': concreteUid,
      if (concreteId != null) 'concrete_id': concreteId,
      if (concreteTitle != null) 'concrete_title': concreteTitle,
      if (concreteCover != null) 'concrete_cover': concreteCover,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (downloadedPages != null) 'downloaded_pages': downloadedPages,
      if (totalPages != null) 'total_pages': totalPages,
      if (dirPath != null) 'dir_path': dirPath,
      if (headers != null) 'headers': headers,
      if (data != null) 'data': data,
      if (kind != null) 'kind': kind,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (playback != null) 'playback': playback,
    });
  }

  DownloadTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? extensionUid,
    Value<String>? concreteUid,
    Value<int>? concreteId,
    Value<String>? concreteTitle,
    Value<String?>? concreteCover,
    Value<String>? title,
    Value<DownloadStatus>? status,
    Value<int>? downloadedPages,
    Value<int>? totalPages,
    Value<String>? dirPath,
    Value<String?>? headers,
    Value<String?>? data,
    Value<DownloadKind>? kind,
    Value<int>? downloadedBytes,
    Value<int>? totalBytes,
    Value<String?>? playback,
  }) {
    return DownloadTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      extensionUid: extensionUid ?? this.extensionUid,
      concreteUid: concreteUid ?? this.concreteUid,
      concreteId: concreteId ?? this.concreteId,
      concreteTitle: concreteTitle ?? this.concreteTitle,
      concreteCover: concreteCover ?? this.concreteCover,
      title: title ?? this.title,
      status: status ?? this.status,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      totalPages: totalPages ?? this.totalPages,
      dirPath: dirPath ?? this.dirPath,
      headers: headers ?? this.headers,
      data: data ?? this.data,
      kind: kind ?? this.kind,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      playback: playback ?? this.playback,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (extensionUid.present) {
      map['extension_uid'] = Variable<String>(extensionUid.value);
    }
    if (concreteUid.present) {
      map['concrete_uid'] = Variable<String>(concreteUid.value);
    }
    if (concreteId.present) {
      map['concrete_id'] = Variable<int>(concreteId.value);
    }
    if (concreteTitle.present) {
      map['concrete_title'] = Variable<String>(concreteTitle.value);
    }
    if (concreteCover.present) {
      map['concrete_cover'] = Variable<String>(concreteCover.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $DownloadTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (downloadedPages.present) {
      map['downloaded_pages'] = Variable<int>(downloadedPages.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (dirPath.present) {
      map['dir_path'] = Variable<String>(dirPath.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $DownloadTableTable.$converterkind.toSql(kind.value),
      );
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (playback.present) {
      map['playback'] = Variable<String>(playback.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('concreteUid: $concreteUid, ')
          ..write('concreteId: $concreteId, ')
          ..write('concreteTitle: $concreteTitle, ')
          ..write('concreteCover: $concreteCover, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('dirPath: $dirPath, ')
          ..write('headers: $headers, ')
          ..write('data: $data, ')
          ..write('kind: $kind, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('playback: $playback')
          ..write(')'))
        .toString();
  }
}

class $LibraryUpdateTableTable extends LibraryUpdateTable
    with TableInfo<$LibraryUpdateTableTable, LibraryUpdateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryUpdateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryEntryUidMeta = const VerificationMeta(
    'libraryEntryUid',
  );
  @override
  late final GeneratedColumn<String> libraryEntryUid = GeneratedColumn<String>(
    'library_entry_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionUidMeta = const VerificationMeta(
    'extensionUid',
  );
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
    'extension_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteTitleMeta = const VerificationMeta(
    'concreteTitle',
  );
  @override
  late final GeneratedColumn<String> concreteTitle = GeneratedColumn<String>(
    'concrete_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concreteCoverMeta = const VerificationMeta(
    'concreteCover',
  );
  @override
  late final GeneratedColumn<String> concreteCover = GeneratedColumn<String>(
    'concrete_cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UpdateMediaType, int> mediaType =
      GeneratedColumn<int>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<UpdateMediaType>(
        $LibraryUpdateTableTable.$convertermediaType,
      );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    libraryEntryUid,
    extensionUid,
    title,
    concreteTitle,
    concreteCover,
    mediaType,
    data,
    seen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_update_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryUpdateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('library_entry_uid')) {
      context.handle(
        _libraryEntryUidMeta,
        libraryEntryUid.isAcceptableOrUnknown(
          data['library_entry_uid']!,
          _libraryEntryUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_libraryEntryUidMeta);
    }
    if (data.containsKey('extension_uid')) {
      context.handle(
        _extensionUidMeta,
        extensionUid.isAcceptableOrUnknown(
          data['extension_uid']!,
          _extensionUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('concrete_title')) {
      context.handle(
        _concreteTitleMeta,
        concreteTitle.isAcceptableOrUnknown(
          data['concrete_title']!,
          _concreteTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concreteTitleMeta);
    }
    if (data.containsKey('concrete_cover')) {
      context.handle(
        _concreteCoverMeta,
        concreteCover.isAcceptableOrUnknown(
          data['concrete_cover']!,
          _concreteCoverMeta,
        ),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryUpdateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryUpdateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      libraryEntryUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_entry_uid'],
      )!,
      extensionUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension_uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      concreteTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_title'],
      )!,
      concreteCover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concrete_cover'],
      ),
      mediaType: $LibraryUpdateTableTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $LibraryUpdateTableTable createAlias(String alias) {
    return $LibraryUpdateTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UpdateMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<UpdateMediaType>(UpdateMediaType.values);
}

class LibraryUpdateTableData extends DataClass
    implements Insertable<LibraryUpdateTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String libraryEntryUid;
  final String extensionUid;
  final String title;
  final String concreteTitle;
  final String? concreteCover;
  final UpdateMediaType mediaType;
  final String? data;
  final bool seen;
  const LibraryUpdateTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.libraryEntryUid,
    required this.extensionUid,
    required this.title,
    required this.concreteTitle,
    this.concreteCover,
    required this.mediaType,
    this.data,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['library_entry_uid'] = Variable<String>(libraryEntryUid);
    map['extension_uid'] = Variable<String>(extensionUid);
    map['title'] = Variable<String>(title);
    map['concrete_title'] = Variable<String>(concreteTitle);
    if (!nullToAbsent || concreteCover != null) {
      map['concrete_cover'] = Variable<String>(concreteCover);
    }
    {
      map['media_type'] = Variable<int>(
        $LibraryUpdateTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  LibraryUpdateTableCompanion toCompanion(bool nullToAbsent) {
    return LibraryUpdateTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      libraryEntryUid: Value(libraryEntryUid),
      extensionUid: Value(extensionUid),
      title: Value(title),
      concreteTitle: Value(concreteTitle),
      concreteCover: concreteCover == null && nullToAbsent
          ? const Value.absent()
          : Value(concreteCover),
      mediaType: Value(mediaType),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      seen: Value(seen),
    );
  }

  factory LibraryUpdateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryUpdateTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      libraryEntryUid: serializer.fromJson<String>(json['libraryEntryUid']),
      extensionUid: serializer.fromJson<String>(json['extensionUid']),
      title: serializer.fromJson<String>(json['title']),
      concreteTitle: serializer.fromJson<String>(json['concreteTitle']),
      concreteCover: serializer.fromJson<String?>(json['concreteCover']),
      mediaType: $LibraryUpdateTableTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      data: serializer.fromJson<String?>(json['data']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'libraryEntryUid': serializer.toJson<String>(libraryEntryUid),
      'extensionUid': serializer.toJson<String>(extensionUid),
      'title': serializer.toJson<String>(title),
      'concreteTitle': serializer.toJson<String>(concreteTitle),
      'concreteCover': serializer.toJson<String?>(concreteCover),
      'mediaType': serializer.toJson<int>(
        $LibraryUpdateTableTable.$convertermediaType.toJson(mediaType),
      ),
      'data': serializer.toJson<String?>(data),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  LibraryUpdateTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? libraryEntryUid,
    String? extensionUid,
    String? title,
    String? concreteTitle,
    Value<String?> concreteCover = const Value.absent(),
    UpdateMediaType? mediaType,
    Value<String?> data = const Value.absent(),
    bool? seen,
  }) => LibraryUpdateTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    libraryEntryUid: libraryEntryUid ?? this.libraryEntryUid,
    extensionUid: extensionUid ?? this.extensionUid,
    title: title ?? this.title,
    concreteTitle: concreteTitle ?? this.concreteTitle,
    concreteCover: concreteCover.present
        ? concreteCover.value
        : this.concreteCover,
    mediaType: mediaType ?? this.mediaType,
    data: data.present ? data.value : this.data,
    seen: seen ?? this.seen,
  );
  LibraryUpdateTableData copyWithCompanion(LibraryUpdateTableCompanion data) {
    return LibraryUpdateTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      libraryEntryUid: data.libraryEntryUid.present
          ? data.libraryEntryUid.value
          : this.libraryEntryUid,
      extensionUid: data.extensionUid.present
          ? data.extensionUid.value
          : this.extensionUid,
      title: data.title.present ? data.title.value : this.title,
      concreteTitle: data.concreteTitle.present
          ? data.concreteTitle.value
          : this.concreteTitle,
      concreteCover: data.concreteCover.present
          ? data.concreteCover.value
          : this.concreteCover,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      data: data.data.present ? data.data.value : this.data,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryUpdateTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('libraryEntryUid: $libraryEntryUid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('concreteTitle: $concreteTitle, ')
          ..write('concreteCover: $concreteCover, ')
          ..write('mediaType: $mediaType, ')
          ..write('data: $data, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    libraryEntryUid,
    extensionUid,
    title,
    concreteTitle,
    concreteCover,
    mediaType,
    data,
    seen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryUpdateTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.libraryEntryUid == this.libraryEntryUid &&
          other.extensionUid == this.extensionUid &&
          other.title == this.title &&
          other.concreteTitle == this.concreteTitle &&
          other.concreteCover == this.concreteCover &&
          other.mediaType == this.mediaType &&
          other.data == this.data &&
          other.seen == this.seen);
}

class LibraryUpdateTableCompanion
    extends UpdateCompanion<LibraryUpdateTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> libraryEntryUid;
  final Value<String> extensionUid;
  final Value<String> title;
  final Value<String> concreteTitle;
  final Value<String?> concreteCover;
  final Value<UpdateMediaType> mediaType;
  final Value<String?> data;
  final Value<bool> seen;
  const LibraryUpdateTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.libraryEntryUid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.title = const Value.absent(),
    this.concreteTitle = const Value.absent(),
    this.concreteCover = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.data = const Value.absent(),
    this.seen = const Value.absent(),
  });
  LibraryUpdateTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String libraryEntryUid,
    required String extensionUid,
    required String title,
    required String concreteTitle,
    this.concreteCover = const Value.absent(),
    required UpdateMediaType mediaType,
    this.data = const Value.absent(),
    this.seen = const Value.absent(),
  }) : uid = Value(uid),
       libraryEntryUid = Value(libraryEntryUid),
       extensionUid = Value(extensionUid),
       title = Value(title),
       concreteTitle = Value(concreteTitle),
       mediaType = Value(mediaType);
  static Insertable<LibraryUpdateTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? libraryEntryUid,
    Expression<String>? extensionUid,
    Expression<String>? title,
    Expression<String>? concreteTitle,
    Expression<String>? concreteCover,
    Expression<int>? mediaType,
    Expression<String>? data,
    Expression<bool>? seen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (libraryEntryUid != null) 'library_entry_uid': libraryEntryUid,
      if (extensionUid != null) 'extension_uid': extensionUid,
      if (title != null) 'title': title,
      if (concreteTitle != null) 'concrete_title': concreteTitle,
      if (concreteCover != null) 'concrete_cover': concreteCover,
      if (mediaType != null) 'media_type': mediaType,
      if (data != null) 'data': data,
      if (seen != null) 'seen': seen,
    });
  }

  LibraryUpdateTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? libraryEntryUid,
    Value<String>? extensionUid,
    Value<String>? title,
    Value<String>? concreteTitle,
    Value<String?>? concreteCover,
    Value<UpdateMediaType>? mediaType,
    Value<String?>? data,
    Value<bool>? seen,
  }) {
    return LibraryUpdateTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      libraryEntryUid: libraryEntryUid ?? this.libraryEntryUid,
      extensionUid: extensionUid ?? this.extensionUid,
      title: title ?? this.title,
      concreteTitle: concreteTitle ?? this.concreteTitle,
      concreteCover: concreteCover ?? this.concreteCover,
      mediaType: mediaType ?? this.mediaType,
      data: data ?? this.data,
      seen: seen ?? this.seen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (libraryEntryUid.present) {
      map['library_entry_uid'] = Variable<String>(libraryEntryUid.value);
    }
    if (extensionUid.present) {
      map['extension_uid'] = Variable<String>(extensionUid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (concreteTitle.present) {
      map['concrete_title'] = Variable<String>(concreteTitle.value);
    }
    if (concreteCover.present) {
      map['concrete_cover'] = Variable<String>(concreteCover.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
        $LibraryUpdateTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryUpdateTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('libraryEntryUid: $libraryEntryUid, ')
          ..write('extensionUid: $extensionUid, ')
          ..write('title: $title, ')
          ..write('concreteTitle: $concreteTitle, ')
          ..write('concreteCover: $concreteCover, ')
          ..write('mediaType: $mediaType, ')
          ..write('data: $data, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }
}

class $PageTranslationTableTable extends PageTranslationTable
    with TableInfo<$PageTranslationTableTable, PageTranslationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageTranslationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagePathMeta = const VerificationMeta(
    'pagePath',
  );
  @override
  late final GeneratedColumn<String> pagePath = GeneratedColumn<String>(
    'page_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLanguageMeta = const VerificationMeta(
    'sourceLanguage',
  );
  @override
  late final GeneratedColumn<String> sourceLanguage = GeneratedColumn<String>(
    'source_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLanguageMeta = const VerificationMeta(
    'targetLanguage',
  );
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
    'target_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    uid,
    pagePath,
    engine,
    sourceLanguage,
    targetLanguage,
    resultJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page_translation_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageTranslationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('page_path')) {
      context.handle(
        _pagePathMeta,
        pagePath.isAcceptableOrUnknown(data['page_path']!, _pagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_pagePathMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    } else if (isInserting) {
      context.missing(_engineMeta);
    }
    if (data.containsKey('source_language')) {
      context.handle(
        _sourceLanguageMeta,
        sourceLanguage.isAcceptableOrUnknown(
          data['source_language']!,
          _sourceLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLanguageMeta);
    }
    if (data.containsKey('target_language')) {
      context.handle(
        _targetLanguageMeta,
        targetLanguage.isAcceptableOrUnknown(
          data['target_language']!,
          _targetLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLanguageMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PageTranslationTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageTranslationTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      pagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_path'],
      )!,
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      )!,
      sourceLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_language'],
      )!,
      targetLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_language'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
    );
  }

  @override
  $PageTranslationTableTable createAlias(String alias) {
    return $PageTranslationTableTable(attachedDatabase, alias);
  }
}

class PageTranslationTableData extends DataClass
    implements Insertable<PageTranslationTableData> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uid;
  final String pagePath;
  final String engine;
  final String sourceLanguage;
  final String targetLanguage;
  final String resultJson;
  const PageTranslationTableData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.pagePath,
    required this.engine,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.resultJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['uid'] = Variable<String>(uid);
    map['page_path'] = Variable<String>(pagePath);
    map['engine'] = Variable<String>(engine);
    map['source_language'] = Variable<String>(sourceLanguage);
    map['target_language'] = Variable<String>(targetLanguage);
    map['result_json'] = Variable<String>(resultJson);
    return map;
  }

  PageTranslationTableCompanion toCompanion(bool nullToAbsent) {
    return PageTranslationTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      uid: Value(uid),
      pagePath: Value(pagePath),
      engine: Value(engine),
      sourceLanguage: Value(sourceLanguage),
      targetLanguage: Value(targetLanguage),
      resultJson: Value(resultJson),
    );
  }

  factory PageTranslationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageTranslationTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      uid: serializer.fromJson<String>(json['uid']),
      pagePath: serializer.fromJson<String>(json['pagePath']),
      engine: serializer.fromJson<String>(json['engine']),
      sourceLanguage: serializer.fromJson<String>(json['sourceLanguage']),
      targetLanguage: serializer.fromJson<String>(json['targetLanguage']),
      resultJson: serializer.fromJson<String>(json['resultJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'uid': serializer.toJson<String>(uid),
      'pagePath': serializer.toJson<String>(pagePath),
      'engine': serializer.toJson<String>(engine),
      'sourceLanguage': serializer.toJson<String>(sourceLanguage),
      'targetLanguage': serializer.toJson<String>(targetLanguage),
      'resultJson': serializer.toJson<String>(resultJson),
    };
  }

  PageTranslationTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? uid,
    String? pagePath,
    String? engine,
    String? sourceLanguage,
    String? targetLanguage,
    String? resultJson,
  }) => PageTranslationTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    uid: uid ?? this.uid,
    pagePath: pagePath ?? this.pagePath,
    engine: engine ?? this.engine,
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    resultJson: resultJson ?? this.resultJson,
  );
  PageTranslationTableData copyWithCompanion(
    PageTranslationTableCompanion data,
  ) {
    return PageTranslationTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      pagePath: data.pagePath.present ? data.pagePath.value : this.pagePath,
      engine: data.engine.present ? data.engine.value : this.engine,
      sourceLanguage: data.sourceLanguage.present
          ? data.sourceLanguage.value
          : this.sourceLanguage,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageTranslationTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('pagePath: $pagePath, ')
          ..write('engine: $engine, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('resultJson: $resultJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    uid,
    pagePath,
    engine,
    sourceLanguage,
    targetLanguage,
    resultJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageTranslationTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uid == this.uid &&
          other.pagePath == this.pagePath &&
          other.engine == this.engine &&
          other.sourceLanguage == this.sourceLanguage &&
          other.targetLanguage == this.targetLanguage &&
          other.resultJson == this.resultJson);
}

class PageTranslationTableCompanion
    extends UpdateCompanion<PageTranslationTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> uid;
  final Value<String> pagePath;
  final Value<String> engine;
  final Value<String> sourceLanguage;
  final Value<String> targetLanguage;
  final Value<String> resultJson;
  const PageTranslationTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.pagePath = const Value.absent(),
    this.engine = const Value.absent(),
    this.sourceLanguage = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.resultJson = const Value.absent(),
  });
  PageTranslationTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String uid,
    required String pagePath,
    required String engine,
    required String sourceLanguage,
    required String targetLanguage,
    required String resultJson,
  }) : uid = Value(uid),
       pagePath = Value(pagePath),
       engine = Value(engine),
       sourceLanguage = Value(sourceLanguage),
       targetLanguage = Value(targetLanguage),
       resultJson = Value(resultJson);
  static Insertable<PageTranslationTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uid,
    Expression<String>? pagePath,
    Expression<String>? engine,
    Expression<String>? sourceLanguage,
    Expression<String>? targetLanguage,
    Expression<String>? resultJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uid != null) 'uid': uid,
      if (pagePath != null) 'page_path': pagePath,
      if (engine != null) 'engine': engine,
      if (sourceLanguage != null) 'source_language': sourceLanguage,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (resultJson != null) 'result_json': resultJson,
    });
  }

  PageTranslationTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? uid,
    Value<String>? pagePath,
    Value<String>? engine,
    Value<String>? sourceLanguage,
    Value<String>? targetLanguage,
    Value<String>? resultJson,
  }) {
    return PageTranslationTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      pagePath: pagePath ?? this.pagePath,
      engine: engine ?? this.engine,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      resultJson: resultJson ?? this.resultJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (pagePath.present) {
      map['page_path'] = Variable<String>(pagePath.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (sourceLanguage.present) {
      map['source_language'] = Variable<String>(sourceLanguage.value);
    }
    if (targetLanguage.present) {
      map['target_language'] = Variable<String>(targetLanguage.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageTranslationTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uid: $uid, ')
          ..write('pagePath: $pagePath, ')
          ..write('engine: $engine, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('resultJson: $resultJson')
          ..write(')'))
        .toString();
  }
}

class $ExtensionStorageTableTable extends ExtensionStorageTable
    with TableInfo<$ExtensionStorageTableTable, ExtensionStorageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtensionStorageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _extensionUidMeta = const VerificationMeta(
    'extensionUid',
  );
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
    'extension_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    extensionUid,
    entryKey,
    value,
    expiresAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extension_storage_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtensionStorageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('extension_uid')) {
      context.handle(
        _extensionUidMeta,
        extensionUid.isAcceptableOrUnknown(
          data['extension_uid']!,
          _extensionUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {extensionUid, entryKey};
  @override
  ExtensionStorageTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtensionStorageTableData(
      extensionUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension_uid'],
      )!,
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExtensionStorageTableTable createAlias(String alias) {
    return $ExtensionStorageTableTable(attachedDatabase, alias);
  }
}

class ExtensionStorageTableData extends DataClass
    implements Insertable<ExtensionStorageTableData> {
  final String extensionUid;
  final String entryKey;
  final String value;
  final int? expiresAt;
  final int updatedAt;
  const ExtensionStorageTableData({
    required this.extensionUid,
    required this.entryKey,
    required this.value,
    this.expiresAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['extension_uid'] = Variable<String>(extensionUid);
    map['entry_key'] = Variable<String>(entryKey);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ExtensionStorageTableCompanion toCompanion(bool nullToAbsent) {
    return ExtensionStorageTableCompanion(
      extensionUid: Value(extensionUid),
      entryKey: Value(entryKey),
      value: Value(value),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExtensionStorageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtensionStorageTableData(
      extensionUid: serializer.fromJson<String>(json['extensionUid']),
      entryKey: serializer.fromJson<String>(json['entryKey']),
      value: serializer.fromJson<String>(json['value']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'extensionUid': serializer.toJson<String>(extensionUid),
      'entryKey': serializer.toJson<String>(entryKey),
      'value': serializer.toJson<String>(value),
      'expiresAt': serializer.toJson<int?>(expiresAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ExtensionStorageTableData copyWith({
    String? extensionUid,
    String? entryKey,
    String? value,
    Value<int?> expiresAt = const Value.absent(),
    int? updatedAt,
  }) => ExtensionStorageTableData(
    extensionUid: extensionUid ?? this.extensionUid,
    entryKey: entryKey ?? this.entryKey,
    value: value ?? this.value,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExtensionStorageTableData copyWithCompanion(
    ExtensionStorageTableCompanion data,
  ) {
    return ExtensionStorageTableData(
      extensionUid: data.extensionUid.present
          ? data.extensionUid.value
          : this.extensionUid,
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      value: data.value.present ? data.value.value : this.value,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionStorageTableData(')
          ..write('extensionUid: $extensionUid, ')
          ..write('entryKey: $entryKey, ')
          ..write('value: $value, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(extensionUid, entryKey, value, expiresAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtensionStorageTableData &&
          other.extensionUid == this.extensionUid &&
          other.entryKey == this.entryKey &&
          other.value == this.value &&
          other.expiresAt == this.expiresAt &&
          other.updatedAt == this.updatedAt);
}

class ExtensionStorageTableCompanion
    extends UpdateCompanion<ExtensionStorageTableData> {
  final Value<String> extensionUid;
  final Value<String> entryKey;
  final Value<String> value;
  final Value<int?> expiresAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ExtensionStorageTableCompanion({
    this.extensionUid = const Value.absent(),
    this.entryKey = const Value.absent(),
    this.value = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExtensionStorageTableCompanion.insert({
    required String extensionUid,
    required String entryKey,
    required String value,
    this.expiresAt = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : extensionUid = Value(extensionUid),
       entryKey = Value(entryKey),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<ExtensionStorageTableData> custom({
    Expression<String>? extensionUid,
    Expression<String>? entryKey,
    Expression<String>? value,
    Expression<int>? expiresAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (extensionUid != null) 'extension_uid': extensionUid,
      if (entryKey != null) 'entry_key': entryKey,
      if (value != null) 'value': value,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExtensionStorageTableCompanion copyWith({
    Value<String>? extensionUid,
    Value<String>? entryKey,
    Value<String>? value,
    Value<int?>? expiresAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExtensionStorageTableCompanion(
      extensionUid: extensionUid ?? this.extensionUid,
      entryKey: entryKey ?? this.entryKey,
      value: value ?? this.value,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (extensionUid.present) {
      map['extension_uid'] = Variable<String>(extensionUid.value);
    }
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtensionStorageTableCompanion(')
          ..write('extensionUid: $extensionUid, ')
          ..write('entryKey: $entryKey, ')
          ..write('value: $value, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$WakaranaiDatabase extends GeneratedDatabase {
  _$WakaranaiDatabase(QueryExecutor e) : super(e);
  $WakaranaiDatabaseManager get managers => $WakaranaiDatabaseManager(this);
  late final $ExtensionSourceTableTable extensionSourceTable =
      $ExtensionSourceTableTable(this);
  late final $ExtensionTableTable extensionTable = $ExtensionTableTable(this);
  late final $ConcreteDataTableTable concreteDataTable =
      $ConcreteDataTableTable(this);
  late final $ChapterActivityTableTable chapterActivityTable =
      $ChapterActivityTableTable(this);
  late final $AnimeEpisodeActivityTableTable animeEpisodeActivityTable =
      $AnimeEpisodeActivityTableTable(this);
  late final $CategoryTableTable categoryTable = $CategoryTableTable(this);
  late final $LibraryEntryTableTable libraryEntryTable =
      $LibraryEntryTableTable(this);
  late final $DownloadTableTable downloadTable = $DownloadTableTable(this);
  late final $LibraryUpdateTableTable libraryUpdateTable =
      $LibraryUpdateTableTable(this);
  late final $PageTranslationTableTable pageTranslationTable =
      $PageTranslationTableTable(this);
  late final $ExtensionStorageTableTable extensionStorageTable =
      $ExtensionStorageTableTable(this);
  late final Index concreteDataUid = Index(
    'concrete_data_uid',
    'CREATE UNIQUE INDEX concrete_data_uid ON concrete_data_table (uid)',
  );
  late final Index chapterActivityUid = Index(
    'chapter_activity_uid',
    'CREATE UNIQUE INDEX chapter_activity_uid ON chapter_activity_table (uid)',
  );
  late final Index animeEpisodeActivityUid = Index(
    'anime_episode_activity_uid',
    'CREATE UNIQUE INDEX anime_episode_activity_uid ON anime_episode_activity_table (uid)',
  );
  late final Index libraryEntryUid = Index(
    'library_entry_uid',
    'CREATE UNIQUE INDEX library_entry_uid ON library_entry_table (uid)',
  );
  late final Index downloadUid = Index(
    'download_uid',
    'CREATE UNIQUE INDEX download_uid ON download_table (uid)',
  );
  late final Index libraryUpdateUid = Index(
    'library_update_uid',
    'CREATE UNIQUE INDEX library_update_uid ON library_update_table (uid)',
  );
  late final Index pageTranslationUid = Index(
    'page_translation_uid',
    'CREATE UNIQUE INDEX page_translation_uid ON page_translation_table (uid)',
  );
  late final Index extensionStorageExpiresAt = Index(
    'extension_storage_expires_at',
    'CREATE INDEX extension_storage_expires_at ON extension_storage_table (expires_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    extensionSourceTable,
    extensionTable,
    concreteDataTable,
    chapterActivityTable,
    animeEpisodeActivityTable,
    categoryTable,
    libraryEntryTable,
    downloadTable,
    libraryUpdateTable,
    pageTranslationTable,
    extensionStorageTable,
    concreteDataUid,
    chapterActivityUid,
    animeEpisodeActivityUid,
    libraryEntryUid,
    downloadUid,
    libraryUpdateUid,
    pageTranslationUid,
    extensionStorageExpiresAt,
  ];
}

typedef $$ExtensionSourceTableTableCreateCompanionBuilder =
    ExtensionSourceTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String type,
      required String name,
      required String url,
      Value<String?> ref,
    });
typedef $$ExtensionSourceTableTableUpdateCompanionBuilder =
    ExtensionSourceTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> type,
      Value<String> name,
      Value<String> url,
      Value<String?> ref,
    });

class $$ExtensionSourceTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionSourceTableTable> {
  $$ExtensionSourceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtensionSourceTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionSourceTableTable> {
  $$ExtensionSourceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtensionSourceTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionSourceTableTable> {
  $$ExtensionSourceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);
}

class $$ExtensionSourceTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $ExtensionSourceTableTable,
          ExtensionSourceTableData,
          $$ExtensionSourceTableTableFilterComposer,
          $$ExtensionSourceTableTableOrderingComposer,
          $$ExtensionSourceTableTableAnnotationComposer,
          $$ExtensionSourceTableTableCreateCompanionBuilder,
          $$ExtensionSourceTableTableUpdateCompanionBuilder,
          (
            ExtensionSourceTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $ExtensionSourceTableTable,
              ExtensionSourceTableData
            >,
          ),
          ExtensionSourceTableData,
          PrefetchHooks Function()
        > {
  $$ExtensionSourceTableTableTableManager(
    _$WakaranaiDatabase db,
    $ExtensionSourceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtensionSourceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtensionSourceTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExtensionSourceTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> ref = const Value.absent(),
              }) => ExtensionSourceTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                type: type,
                name: name,
                url: url,
                ref: ref,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String type,
                required String name,
                required String url,
                Value<String?> ref = const Value.absent(),
              }) => ExtensionSourceTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                type: type,
                name: name,
                url: url,
                ref: ref,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtensionSourceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $ExtensionSourceTableTable,
      ExtensionSourceTableData,
      $$ExtensionSourceTableTableFilterComposer,
      $$ExtensionSourceTableTableOrderingComposer,
      $$ExtensionSourceTableTableAnnotationComposer,
      $$ExtensionSourceTableTableCreateCompanionBuilder,
      $$ExtensionSourceTableTableUpdateCompanionBuilder,
      (
        ExtensionSourceTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $ExtensionSourceTableTable,
          ExtensionSourceTableData
        >,
      ),
      ExtensionSourceTableData,
      PrefetchHooks Function()
    >;
typedef $$ExtensionTableTableCreateCompanionBuilder =
    ExtensionTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String name,
      required String type,
      required int version,
      required String logoUrl,
      required String language,
      required bool nsfw,
      required String sourceCode,
      required bool searchAvailable,
      Value<String?> protectorConfig,
      Value<String?> configJson,
      Value<String?> revision,
    });
typedef $$ExtensionTableTableUpdateCompanionBuilder =
    ExtensionTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> name,
      Value<String> type,
      Value<int> version,
      Value<String> logoUrl,
      Value<String> language,
      Value<bool> nsfw,
      Value<String> sourceCode,
      Value<bool> searchAvailable,
      Value<String?> protectorConfig,
      Value<String?> configJson,
      Value<String?> revision,
    });

class $$ExtensionTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionTableTable> {
  $$ExtensionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nsfw => $composableBuilder(
    column: $table.nsfw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get searchAvailable => $composableBuilder(
    column: $table.searchAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protectorConfig => $composableBuilder(
    column: $table.protectorConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtensionTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionTableTable> {
  $$ExtensionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nsfw => $composableBuilder(
    column: $table.nsfw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get searchAvailable => $composableBuilder(
    column: $table.searchAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protectorConfig => $composableBuilder(
    column: $table.protectorConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtensionTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionTableTable> {
  $$ExtensionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get nsfw =>
      $composableBuilder(column: $table.nsfw, builder: (column) => column);

  GeneratedColumn<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get searchAvailable => $composableBuilder(
    column: $table.searchAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protectorConfig => $composableBuilder(
    column: $table.protectorConfig,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ExtensionTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $ExtensionTableTable,
          ExtensionTableData,
          $$ExtensionTableTableFilterComposer,
          $$ExtensionTableTableOrderingComposer,
          $$ExtensionTableTableAnnotationComposer,
          $$ExtensionTableTableCreateCompanionBuilder,
          $$ExtensionTableTableUpdateCompanionBuilder,
          (
            ExtensionTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $ExtensionTableTable,
              ExtensionTableData
            >,
          ),
          ExtensionTableData,
          PrefetchHooks Function()
        > {
  $$ExtensionTableTableTableManager(
    _$WakaranaiDatabase db,
    $ExtensionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtensionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtensionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtensionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> logoUrl = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> nsfw = const Value.absent(),
                Value<String> sourceCode = const Value.absent(),
                Value<bool> searchAvailable = const Value.absent(),
                Value<String?> protectorConfig = const Value.absent(),
                Value<String?> configJson = const Value.absent(),
                Value<String?> revision = const Value.absent(),
              }) => ExtensionTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                name: name,
                type: type,
                version: version,
                logoUrl: logoUrl,
                language: language,
                nsfw: nsfw,
                sourceCode: sourceCode,
                searchAvailable: searchAvailable,
                protectorConfig: protectorConfig,
                configJson: configJson,
                revision: revision,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String name,
                required String type,
                required int version,
                required String logoUrl,
                required String language,
                required bool nsfw,
                required String sourceCode,
                required bool searchAvailable,
                Value<String?> protectorConfig = const Value.absent(),
                Value<String?> configJson = const Value.absent(),
                Value<String?> revision = const Value.absent(),
              }) => ExtensionTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                name: name,
                type: type,
                version: version,
                logoUrl: logoUrl,
                language: language,
                nsfw: nsfw,
                sourceCode: sourceCode,
                searchAvailable: searchAvailable,
                protectorConfig: protectorConfig,
                configJson: configJson,
                revision: revision,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtensionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $ExtensionTableTable,
      ExtensionTableData,
      $$ExtensionTableTableFilterComposer,
      $$ExtensionTableTableOrderingComposer,
      $$ExtensionTableTableAnnotationComposer,
      $$ExtensionTableTableCreateCompanionBuilder,
      $$ExtensionTableTableUpdateCompanionBuilder,
      (
        ExtensionTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $ExtensionTableTable,
          ExtensionTableData
        >,
      ),
      ExtensionTableData,
      PrefetchHooks Function()
    >;
typedef $$ConcreteDataTableTableCreateCompanionBuilder =
    ConcreteDataTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String extensionUid,
      required String title,
      Value<String?> cover,
      Value<String?> data,
      Value<String?> concreteJson,
    });
typedef $$ConcreteDataTableTableUpdateCompanionBuilder =
    ConcreteDataTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> extensionUid,
      Value<String> title,
      Value<String?> cover,
      Value<String?> data,
      Value<String?> concreteJson,
    });

class $$ConcreteDataTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $ConcreteDataTableTable> {
  $$ConcreteDataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteJson => $composableBuilder(
    column: $table.concreteJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConcreteDataTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $ConcreteDataTableTable> {
  $$ConcreteDataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteJson => $composableBuilder(
    column: $table.concreteJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConcreteDataTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $ConcreteDataTableTable> {
  $$ConcreteDataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get concreteJson => $composableBuilder(
    column: $table.concreteJson,
    builder: (column) => column,
  );
}

class $$ConcreteDataTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $ConcreteDataTableTable,
          ConcreteDataTableData,
          $$ConcreteDataTableTableFilterComposer,
          $$ConcreteDataTableTableOrderingComposer,
          $$ConcreteDataTableTableAnnotationComposer,
          $$ConcreteDataTableTableCreateCompanionBuilder,
          $$ConcreteDataTableTableUpdateCompanionBuilder,
          (
            ConcreteDataTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $ConcreteDataTableTable,
              ConcreteDataTableData
            >,
          ),
          ConcreteDataTableData,
          PrefetchHooks Function()
        > {
  $$ConcreteDataTableTableTableManager(
    _$WakaranaiDatabase db,
    $ConcreteDataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConcreteDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConcreteDataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConcreteDataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> extensionUid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<String?> concreteJson = const Value.absent(),
              }) => ConcreteDataTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                title: title,
                cover: cover,
                data: data,
                concreteJson: concreteJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String extensionUid,
                required String title,
                Value<String?> cover = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<String?> concreteJson = const Value.absent(),
              }) => ConcreteDataTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                title: title,
                cover: cover,
                data: data,
                concreteJson: concreteJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConcreteDataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $ConcreteDataTableTable,
      ConcreteDataTableData,
      $$ConcreteDataTableTableFilterComposer,
      $$ConcreteDataTableTableOrderingComposer,
      $$ConcreteDataTableTableAnnotationComposer,
      $$ConcreteDataTableTableCreateCompanionBuilder,
      $$ConcreteDataTableTableUpdateCompanionBuilder,
      (
        ConcreteDataTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $ConcreteDataTableTable,
          ConcreteDataTableData
        >,
      ),
      ConcreteDataTableData,
      PrefetchHooks Function()
    >;
typedef $$ChapterActivityTableTableCreateCompanionBuilder =
    ChapterActivityTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String title,
      Value<String?> timestamp,
      Value<String?> data,
      required int concreteId,
      required int readPages,
      required int totalPages,
    });
typedef $$ChapterActivityTableTableUpdateCompanionBuilder =
    ChapterActivityTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> title,
      Value<String?> timestamp,
      Value<String?> data,
      Value<int> concreteId,
      Value<int> readPages,
      Value<int> totalPages,
    });

class $$ChapterActivityTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $ChapterActivityTableTable> {
  $$ChapterActivityTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readPages => $composableBuilder(
    column: $table.readPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterActivityTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $ChapterActivityTableTable> {
  $$ChapterActivityTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readPages => $composableBuilder(
    column: $table.readPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterActivityTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $ChapterActivityTableTable> {
  $$ChapterActivityTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readPages =>
      $composableBuilder(column: $table.readPages, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );
}

class $$ChapterActivityTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $ChapterActivityTableTable,
          ChapterActivityTableData,
          $$ChapterActivityTableTableFilterComposer,
          $$ChapterActivityTableTableOrderingComposer,
          $$ChapterActivityTableTableAnnotationComposer,
          $$ChapterActivityTableTableCreateCompanionBuilder,
          $$ChapterActivityTableTableUpdateCompanionBuilder,
          (
            ChapterActivityTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $ChapterActivityTableTable,
              ChapterActivityTableData
            >,
          ),
          ChapterActivityTableData,
          PrefetchHooks Function()
        > {
  $$ChapterActivityTableTableTableManager(
    _$WakaranaiDatabase db,
    $ChapterActivityTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterActivityTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterActivityTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterActivityTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> timestamp = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int> concreteId = const Value.absent(),
                Value<int> readPages = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
              }) => ChapterActivityTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                title: title,
                timestamp: timestamp,
                data: data,
                concreteId: concreteId,
                readPages: readPages,
                totalPages: totalPages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String title,
                Value<String?> timestamp = const Value.absent(),
                Value<String?> data = const Value.absent(),
                required int concreteId,
                required int readPages,
                required int totalPages,
              }) => ChapterActivityTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                title: title,
                timestamp: timestamp,
                data: data,
                concreteId: concreteId,
                readPages: readPages,
                totalPages: totalPages,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterActivityTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $ChapterActivityTableTable,
      ChapterActivityTableData,
      $$ChapterActivityTableTableFilterComposer,
      $$ChapterActivityTableTableOrderingComposer,
      $$ChapterActivityTableTableAnnotationComposer,
      $$ChapterActivityTableTableCreateCompanionBuilder,
      $$ChapterActivityTableTableUpdateCompanionBuilder,
      (
        ChapterActivityTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $ChapterActivityTableTable,
          ChapterActivityTableData
        >,
      ),
      ChapterActivityTableData,
      PrefetchHooks Function()
    >;
typedef $$AnimeEpisodeActivityTableTableCreateCompanionBuilder =
    AnimeEpisodeActivityTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String title,
      Value<String?> timestamp,
      Value<String?> data,
      required int concreteId,
      Value<int?> watchedTime,
      Value<int?> totalTime,
      Value<bool> markedWatched,
    });
typedef $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder =
    AnimeEpisodeActivityTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> title,
      Value<String?> timestamp,
      Value<String?> data,
      Value<int> concreteId,
      Value<int?> watchedTime,
      Value<int?> totalTime,
      Value<bool> markedWatched,
    });

class $$AnimeEpisodeActivityTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $AnimeEpisodeActivityTableTable> {
  $$AnimeEpisodeActivityTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchedTime => $composableBuilder(
    column: $table.watchedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTime => $composableBuilder(
    column: $table.totalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get markedWatched => $composableBuilder(
    column: $table.markedWatched,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimeEpisodeActivityTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $AnimeEpisodeActivityTableTable> {
  $$AnimeEpisodeActivityTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchedTime => $composableBuilder(
    column: $table.watchedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTime => $composableBuilder(
    column: $table.totalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get markedWatched => $composableBuilder(
    column: $table.markedWatched,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimeEpisodeActivityTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $AnimeEpisodeActivityTableTable> {
  $$AnimeEpisodeActivityTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get watchedTime => $composableBuilder(
    column: $table.watchedTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTime =>
      $composableBuilder(column: $table.totalTime, builder: (column) => column);

  GeneratedColumn<bool> get markedWatched => $composableBuilder(
    column: $table.markedWatched,
    builder: (column) => column,
  );
}

class $$AnimeEpisodeActivityTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $AnimeEpisodeActivityTableTable,
          AnimeEpisodeActivityTableData,
          $$AnimeEpisodeActivityTableTableFilterComposer,
          $$AnimeEpisodeActivityTableTableOrderingComposer,
          $$AnimeEpisodeActivityTableTableAnnotationComposer,
          $$AnimeEpisodeActivityTableTableCreateCompanionBuilder,
          $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder,
          (
            AnimeEpisodeActivityTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $AnimeEpisodeActivityTableTable,
              AnimeEpisodeActivityTableData
            >,
          ),
          AnimeEpisodeActivityTableData,
          PrefetchHooks Function()
        > {
  $$AnimeEpisodeActivityTableTableTableManager(
    _$WakaranaiDatabase db,
    $AnimeEpisodeActivityTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimeEpisodeActivityTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AnimeEpisodeActivityTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnimeEpisodeActivityTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> timestamp = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int> concreteId = const Value.absent(),
                Value<int?> watchedTime = const Value.absent(),
                Value<int?> totalTime = const Value.absent(),
                Value<bool> markedWatched = const Value.absent(),
              }) => AnimeEpisodeActivityTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                title: title,
                timestamp: timestamp,
                data: data,
                concreteId: concreteId,
                watchedTime: watchedTime,
                totalTime: totalTime,
                markedWatched: markedWatched,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String title,
                Value<String?> timestamp = const Value.absent(),
                Value<String?> data = const Value.absent(),
                required int concreteId,
                Value<int?> watchedTime = const Value.absent(),
                Value<int?> totalTime = const Value.absent(),
                Value<bool> markedWatched = const Value.absent(),
              }) => AnimeEpisodeActivityTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                title: title,
                timestamp: timestamp,
                data: data,
                concreteId: concreteId,
                watchedTime: watchedTime,
                totalTime: totalTime,
                markedWatched: markedWatched,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimeEpisodeActivityTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $AnimeEpisodeActivityTableTable,
      AnimeEpisodeActivityTableData,
      $$AnimeEpisodeActivityTableTableFilterComposer,
      $$AnimeEpisodeActivityTableTableOrderingComposer,
      $$AnimeEpisodeActivityTableTableAnnotationComposer,
      $$AnimeEpisodeActivityTableTableCreateCompanionBuilder,
      $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder,
      (
        AnimeEpisodeActivityTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $AnimeEpisodeActivityTableTable,
          AnimeEpisodeActivityTableData
        >,
      ),
      AnimeEpisodeActivityTableData,
      PrefetchHooks Function()
    >;
typedef $$CategoryTableTableCreateCompanionBuilder =
    CategoryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String name,
      Value<int> sortOrder,
    });
typedef $$CategoryTableTableUpdateCompanionBuilder =
    CategoryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> name,
      Value<int> sortOrder,
    });

class $$CategoryTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $CategoryTableTable> {
  $$CategoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $CategoryTableTable> {
  $$CategoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $CategoryTableTable> {
  $$CategoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoryTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $CategoryTableTable,
          CategoryTableData,
          $$CategoryTableTableFilterComposer,
          $$CategoryTableTableOrderingComposer,
          $$CategoryTableTableAnnotationComposer,
          $$CategoryTableTableCreateCompanionBuilder,
          $$CategoryTableTableUpdateCompanionBuilder,
          (
            CategoryTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $CategoryTableTable,
              CategoryTableData
            >,
          ),
          CategoryTableData,
          PrefetchHooks Function()
        > {
  $$CategoryTableTableTableManager(
    _$WakaranaiDatabase db,
    $CategoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoryTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => CategoryTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $CategoryTableTable,
      CategoryTableData,
      $$CategoryTableTableFilterComposer,
      $$CategoryTableTableOrderingComposer,
      $$CategoryTableTableAnnotationComposer,
      $$CategoryTableTableCreateCompanionBuilder,
      $$CategoryTableTableUpdateCompanionBuilder,
      (
        CategoryTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $CategoryTableTable,
          CategoryTableData
        >,
      ),
      CategoryTableData,
      PrefetchHooks Function()
    >;
typedef $$LibraryEntryTableTableCreateCompanionBuilder =
    LibraryEntryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String extensionUid,
      required String title,
      Value<String?> cover,
      Value<String?> data,
      Value<int?> categoryId,
      Value<DateTime?> lastReadAt,
      Value<bool> trackUpdates,
      Value<bool> notifyUpdates,
    });
typedef $$LibraryEntryTableTableUpdateCompanionBuilder =
    LibraryEntryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> extensionUid,
      Value<String> title,
      Value<String?> cover,
      Value<String?> data,
      Value<int?> categoryId,
      Value<DateTime?> lastReadAt,
      Value<bool> trackUpdates,
      Value<bool> notifyUpdates,
    });

class $$LibraryEntryTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $LibraryEntryTableTable> {
  $$LibraryEntryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackUpdates => $composableBuilder(
    column: $table.trackUpdates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryEntryTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $LibraryEntryTableTable> {
  $$LibraryEntryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackUpdates => $composableBuilder(
    column: $table.trackUpdates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryEntryTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $LibraryEntryTableTable> {
  $$LibraryEntryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trackUpdates => $composableBuilder(
    column: $table.trackUpdates,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => column,
  );
}

class $$LibraryEntryTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $LibraryEntryTableTable,
          LibraryEntryTableData,
          $$LibraryEntryTableTableFilterComposer,
          $$LibraryEntryTableTableOrderingComposer,
          $$LibraryEntryTableTableAnnotationComposer,
          $$LibraryEntryTableTableCreateCompanionBuilder,
          $$LibraryEntryTableTableUpdateCompanionBuilder,
          (
            LibraryEntryTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $LibraryEntryTableTable,
              LibraryEntryTableData
            >,
          ),
          LibraryEntryTableData,
          PrefetchHooks Function()
        > {
  $$LibraryEntryTableTableTableManager(
    _$WakaranaiDatabase db,
    $LibraryEntryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> extensionUid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<bool> trackUpdates = const Value.absent(),
                Value<bool> notifyUpdates = const Value.absent(),
              }) => LibraryEntryTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                title: title,
                cover: cover,
                data: data,
                categoryId: categoryId,
                lastReadAt: lastReadAt,
                trackUpdates: trackUpdates,
                notifyUpdates: notifyUpdates,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String extensionUid,
                required String title,
                Value<String?> cover = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<bool> trackUpdates = const Value.absent(),
                Value<bool> notifyUpdates = const Value.absent(),
              }) => LibraryEntryTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                title: title,
                cover: cover,
                data: data,
                categoryId: categoryId,
                lastReadAt: lastReadAt,
                trackUpdates: trackUpdates,
                notifyUpdates: notifyUpdates,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $LibraryEntryTableTable,
      LibraryEntryTableData,
      $$LibraryEntryTableTableFilterComposer,
      $$LibraryEntryTableTableOrderingComposer,
      $$LibraryEntryTableTableAnnotationComposer,
      $$LibraryEntryTableTableCreateCompanionBuilder,
      $$LibraryEntryTableTableUpdateCompanionBuilder,
      (
        LibraryEntryTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $LibraryEntryTableTable,
          LibraryEntryTableData
        >,
      ),
      LibraryEntryTableData,
      PrefetchHooks Function()
    >;
typedef $$DownloadTableTableCreateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String extensionUid,
      required String concreteUid,
      required int concreteId,
      required String concreteTitle,
      Value<String?> concreteCover,
      required String title,
      required DownloadStatus status,
      Value<int> downloadedPages,
      Value<int> totalPages,
      required String dirPath,
      Value<String?> headers,
      Value<String?> data,
      Value<DownloadKind> kind,
      Value<int> downloadedBytes,
      Value<int> totalBytes,
      Value<String?> playback,
    });
typedef $$DownloadTableTableUpdateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> extensionUid,
      Value<String> concreteUid,
      Value<int> concreteId,
      Value<String> concreteTitle,
      Value<String?> concreteCover,
      Value<String> title,
      Value<DownloadStatus> status,
      Value<int> downloadedPages,
      Value<int> totalPages,
      Value<String> dirPath,
      Value<String?> headers,
      Value<String?> data,
      Value<DownloadKind> kind,
      Value<int> downloadedBytes,
      Value<int> totalBytes,
      Value<String?> playback,
    });

class $$DownloadTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $DownloadTableTable> {
  $$DownloadTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteUid => $composableBuilder(
    column: $table.concreteUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DownloadStatus, DownloadStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dirPath => $composableBuilder(
    column: $table.dirPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DownloadKind, DownloadKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playback => $composableBuilder(
    column: $table.playback,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $DownloadTableTable> {
  $$DownloadTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteUid => $composableBuilder(
    column: $table.concreteUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dirPath => $composableBuilder(
    column: $table.dirPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playback => $composableBuilder(
    column: $table.playback,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $DownloadTableTable> {
  $$DownloadTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concreteUid => $composableBuilder(
    column: $table.concreteUid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get concreteId => $composableBuilder(
    column: $table.concreteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dirPath =>
      $composableBuilder(column: $table.dirPath, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playback =>
      $composableBuilder(column: $table.playback, builder: (column) => column);
}

class $$DownloadTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $DownloadTableTable,
          DownloadTableData,
          $$DownloadTableTableFilterComposer,
          $$DownloadTableTableOrderingComposer,
          $$DownloadTableTableAnnotationComposer,
          $$DownloadTableTableCreateCompanionBuilder,
          $$DownloadTableTableUpdateCompanionBuilder,
          (
            DownloadTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $DownloadTableTable,
              DownloadTableData
            >,
          ),
          DownloadTableData,
          PrefetchHooks Function()
        > {
  $$DownloadTableTableTableManager(
    _$WakaranaiDatabase db,
    $DownloadTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> extensionUid = const Value.absent(),
                Value<String> concreteUid = const Value.absent(),
                Value<int> concreteId = const Value.absent(),
                Value<String> concreteTitle = const Value.absent(),
                Value<String?> concreteCover = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DownloadStatus> status = const Value.absent(),
                Value<int> downloadedPages = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<String> dirPath = const Value.absent(),
                Value<String?> headers = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<DownloadKind> kind = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<String?> playback = const Value.absent(),
              }) => DownloadTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                concreteUid: concreteUid,
                concreteId: concreteId,
                concreteTitle: concreteTitle,
                concreteCover: concreteCover,
                title: title,
                status: status,
                downloadedPages: downloadedPages,
                totalPages: totalPages,
                dirPath: dirPath,
                headers: headers,
                data: data,
                kind: kind,
                downloadedBytes: downloadedBytes,
                totalBytes: totalBytes,
                playback: playback,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String extensionUid,
                required String concreteUid,
                required int concreteId,
                required String concreteTitle,
                Value<String?> concreteCover = const Value.absent(),
                required String title,
                required DownloadStatus status,
                Value<int> downloadedPages = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                required String dirPath,
                Value<String?> headers = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<DownloadKind> kind = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<String?> playback = const Value.absent(),
              }) => DownloadTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                extensionUid: extensionUid,
                concreteUid: concreteUid,
                concreteId: concreteId,
                concreteTitle: concreteTitle,
                concreteCover: concreteCover,
                title: title,
                status: status,
                downloadedPages: downloadedPages,
                totalPages: totalPages,
                dirPath: dirPath,
                headers: headers,
                data: data,
                kind: kind,
                downloadedBytes: downloadedBytes,
                totalBytes: totalBytes,
                playback: playback,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $DownloadTableTable,
      DownloadTableData,
      $$DownloadTableTableFilterComposer,
      $$DownloadTableTableOrderingComposer,
      $$DownloadTableTableAnnotationComposer,
      $$DownloadTableTableCreateCompanionBuilder,
      $$DownloadTableTableUpdateCompanionBuilder,
      (
        DownloadTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $DownloadTableTable,
          DownloadTableData
        >,
      ),
      DownloadTableData,
      PrefetchHooks Function()
    >;
typedef $$LibraryUpdateTableTableCreateCompanionBuilder =
    LibraryUpdateTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String libraryEntryUid,
      required String extensionUid,
      required String title,
      required String concreteTitle,
      Value<String?> concreteCover,
      required UpdateMediaType mediaType,
      Value<String?> data,
      Value<bool> seen,
    });
typedef $$LibraryUpdateTableTableUpdateCompanionBuilder =
    LibraryUpdateTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> libraryEntryUid,
      Value<String> extensionUid,
      Value<String> title,
      Value<String> concreteTitle,
      Value<String?> concreteCover,
      Value<UpdateMediaType> mediaType,
      Value<String?> data,
      Value<bool> seen,
    });

class $$LibraryUpdateTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $LibraryUpdateTableTable> {
  $$LibraryUpdateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryEntryUid => $composableBuilder(
    column: $table.libraryEntryUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UpdateMediaType, UpdateMediaType, int>
  get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryUpdateTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $LibraryUpdateTableTable> {
  $$LibraryUpdateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryEntryUid => $composableBuilder(
    column: $table.libraryEntryUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryUpdateTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $LibraryUpdateTableTable> {
  $$LibraryUpdateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get libraryEntryUid => $composableBuilder(
    column: $table.libraryEntryUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get concreteTitle => $composableBuilder(
    column: $table.concreteTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concreteCover => $composableBuilder(
    column: $table.concreteCover,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UpdateMediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$LibraryUpdateTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $LibraryUpdateTableTable,
          LibraryUpdateTableData,
          $$LibraryUpdateTableTableFilterComposer,
          $$LibraryUpdateTableTableOrderingComposer,
          $$LibraryUpdateTableTableAnnotationComposer,
          $$LibraryUpdateTableTableCreateCompanionBuilder,
          $$LibraryUpdateTableTableUpdateCompanionBuilder,
          (
            LibraryUpdateTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $LibraryUpdateTableTable,
              LibraryUpdateTableData
            >,
          ),
          LibraryUpdateTableData,
          PrefetchHooks Function()
        > {
  $$LibraryUpdateTableTableTableManager(
    _$WakaranaiDatabase db,
    $LibraryUpdateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryUpdateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryUpdateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryUpdateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> libraryEntryUid = const Value.absent(),
                Value<String> extensionUid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> concreteTitle = const Value.absent(),
                Value<String?> concreteCover = const Value.absent(),
                Value<UpdateMediaType> mediaType = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<bool> seen = const Value.absent(),
              }) => LibraryUpdateTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                libraryEntryUid: libraryEntryUid,
                extensionUid: extensionUid,
                title: title,
                concreteTitle: concreteTitle,
                concreteCover: concreteCover,
                mediaType: mediaType,
                data: data,
                seen: seen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String libraryEntryUid,
                required String extensionUid,
                required String title,
                required String concreteTitle,
                Value<String?> concreteCover = const Value.absent(),
                required UpdateMediaType mediaType,
                Value<String?> data = const Value.absent(),
                Value<bool> seen = const Value.absent(),
              }) => LibraryUpdateTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                libraryEntryUid: libraryEntryUid,
                extensionUid: extensionUid,
                title: title,
                concreteTitle: concreteTitle,
                concreteCover: concreteCover,
                mediaType: mediaType,
                data: data,
                seen: seen,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryUpdateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $LibraryUpdateTableTable,
      LibraryUpdateTableData,
      $$LibraryUpdateTableTableFilterComposer,
      $$LibraryUpdateTableTableOrderingComposer,
      $$LibraryUpdateTableTableAnnotationComposer,
      $$LibraryUpdateTableTableCreateCompanionBuilder,
      $$LibraryUpdateTableTableUpdateCompanionBuilder,
      (
        LibraryUpdateTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $LibraryUpdateTableTable,
          LibraryUpdateTableData
        >,
      ),
      LibraryUpdateTableData,
      PrefetchHooks Function()
    >;
typedef $$PageTranslationTableTableCreateCompanionBuilder =
    PageTranslationTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String uid,
      required String pagePath,
      required String engine,
      required String sourceLanguage,
      required String targetLanguage,
      required String resultJson,
    });
typedef $$PageTranslationTableTableUpdateCompanionBuilder =
    PageTranslationTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> uid,
      Value<String> pagePath,
      Value<String> engine,
      Value<String> sourceLanguage,
      Value<String> targetLanguage,
      Value<String> resultJson,
    });

class $$PageTranslationTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $PageTranslationTableTable> {
  $$PageTranslationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pagePath => $composableBuilder(
    column: $table.pagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PageTranslationTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $PageTranslationTableTable> {
  $$PageTranslationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pagePath => $composableBuilder(
    column: $table.pagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PageTranslationTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $PageTranslationTableTable> {
  $$PageTranslationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get pagePath =>
      $composableBuilder(column: $table.pagePath, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );
}

class $$PageTranslationTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $PageTranslationTableTable,
          PageTranslationTableData,
          $$PageTranslationTableTableFilterComposer,
          $$PageTranslationTableTableOrderingComposer,
          $$PageTranslationTableTableAnnotationComposer,
          $$PageTranslationTableTableCreateCompanionBuilder,
          $$PageTranslationTableTableUpdateCompanionBuilder,
          (
            PageTranslationTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $PageTranslationTableTable,
              PageTranslationTableData
            >,
          ),
          PageTranslationTableData,
          PrefetchHooks Function()
        > {
  $$PageTranslationTableTableTableManager(
    _$WakaranaiDatabase db,
    $PageTranslationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PageTranslationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PageTranslationTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PageTranslationTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> pagePath = const Value.absent(),
                Value<String> engine = const Value.absent(),
                Value<String> sourceLanguage = const Value.absent(),
                Value<String> targetLanguage = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
              }) => PageTranslationTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                pagePath: pagePath,
                engine: engine,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                resultJson: resultJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String uid,
                required String pagePath,
                required String engine,
                required String sourceLanguage,
                required String targetLanguage,
                required String resultJson,
              }) => PageTranslationTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                uid: uid,
                pagePath: pagePath,
                engine: engine,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                resultJson: resultJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PageTranslationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $PageTranslationTableTable,
      PageTranslationTableData,
      $$PageTranslationTableTableFilterComposer,
      $$PageTranslationTableTableOrderingComposer,
      $$PageTranslationTableTableAnnotationComposer,
      $$PageTranslationTableTableCreateCompanionBuilder,
      $$PageTranslationTableTableUpdateCompanionBuilder,
      (
        PageTranslationTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $PageTranslationTableTable,
          PageTranslationTableData
        >,
      ),
      PageTranslationTableData,
      PrefetchHooks Function()
    >;
typedef $$ExtensionStorageTableTableCreateCompanionBuilder =
    ExtensionStorageTableCompanion Function({
      required String extensionUid,
      required String entryKey,
      required String value,
      Value<int?> expiresAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ExtensionStorageTableTableUpdateCompanionBuilder =
    ExtensionStorageTableCompanion Function({
      Value<String> extensionUid,
      Value<String> entryKey,
      Value<String> value,
      Value<int?> expiresAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ExtensionStorageTableTableFilterComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionStorageTableTable> {
  $$ExtensionStorageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtensionStorageTableTableOrderingComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionStorageTableTable> {
  $$ExtensionStorageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtensionStorageTableTableAnnotationComposer
    extends Composer<_$WakaranaiDatabase, $ExtensionStorageTableTable> {
  $$ExtensionStorageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get extensionUid => $composableBuilder(
    column: $table.extensionUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExtensionStorageTableTableTableManager
    extends
        RootTableManager<
          _$WakaranaiDatabase,
          $ExtensionStorageTableTable,
          ExtensionStorageTableData,
          $$ExtensionStorageTableTableFilterComposer,
          $$ExtensionStorageTableTableOrderingComposer,
          $$ExtensionStorageTableTableAnnotationComposer,
          $$ExtensionStorageTableTableCreateCompanionBuilder,
          $$ExtensionStorageTableTableUpdateCompanionBuilder,
          (
            ExtensionStorageTableData,
            BaseReferences<
              _$WakaranaiDatabase,
              $ExtensionStorageTableTable,
              ExtensionStorageTableData
            >,
          ),
          ExtensionStorageTableData,
          PrefetchHooks Function()
        > {
  $$ExtensionStorageTableTableTableManager(
    _$WakaranaiDatabase db,
    $ExtensionStorageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtensionStorageTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExtensionStorageTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExtensionStorageTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> extensionUid = const Value.absent(),
                Value<String> entryKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExtensionStorageTableCompanion(
                extensionUid: extensionUid,
                entryKey: entryKey,
                value: value,
                expiresAt: expiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String extensionUid,
                required String entryKey,
                required String value,
                Value<int?> expiresAt = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExtensionStorageTableCompanion.insert(
                extensionUid: extensionUid,
                entryKey: entryKey,
                value: value,
                expiresAt: expiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtensionStorageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WakaranaiDatabase,
      $ExtensionStorageTableTable,
      ExtensionStorageTableData,
      $$ExtensionStorageTableTableFilterComposer,
      $$ExtensionStorageTableTableOrderingComposer,
      $$ExtensionStorageTableTableAnnotationComposer,
      $$ExtensionStorageTableTableCreateCompanionBuilder,
      $$ExtensionStorageTableTableUpdateCompanionBuilder,
      (
        ExtensionStorageTableData,
        BaseReferences<
          _$WakaranaiDatabase,
          $ExtensionStorageTableTable,
          ExtensionStorageTableData
        >,
      ),
      ExtensionStorageTableData,
      PrefetchHooks Function()
    >;

class $WakaranaiDatabaseManager {
  final _$WakaranaiDatabase _db;
  $WakaranaiDatabaseManager(this._db);
  $$ExtensionSourceTableTableTableManager get extensionSourceTable =>
      $$ExtensionSourceTableTableTableManager(_db, _db.extensionSourceTable);
  $$ExtensionTableTableTableManager get extensionTable =>
      $$ExtensionTableTableTableManager(_db, _db.extensionTable);
  $$ConcreteDataTableTableTableManager get concreteDataTable =>
      $$ConcreteDataTableTableTableManager(_db, _db.concreteDataTable);
  $$ChapterActivityTableTableTableManager get chapterActivityTable =>
      $$ChapterActivityTableTableTableManager(_db, _db.chapterActivityTable);
  $$AnimeEpisodeActivityTableTableTableManager get animeEpisodeActivityTable =>
      $$AnimeEpisodeActivityTableTableTableManager(
        _db,
        _db.animeEpisodeActivityTable,
      );
  $$CategoryTableTableTableManager get categoryTable =>
      $$CategoryTableTableTableManager(_db, _db.categoryTable);
  $$LibraryEntryTableTableTableManager get libraryEntryTable =>
      $$LibraryEntryTableTableTableManager(_db, _db.libraryEntryTable);
  $$DownloadTableTableTableManager get downloadTable =>
      $$DownloadTableTableTableManager(_db, _db.downloadTable);
  $$LibraryUpdateTableTableTableManager get libraryUpdateTable =>
      $$LibraryUpdateTableTableTableManager(_db, _db.libraryUpdateTable);
  $$PageTranslationTableTableTableManager get pageTranslationTable =>
      $$PageTranslationTableTableTableManager(_db, _db.pageTranslationTable);
  $$ExtensionStorageTableTableTableManager get extensionStorageTable =>
      $$ExtensionStorageTableTableTableManager(_db, _db.extensionStorageTable);
}
