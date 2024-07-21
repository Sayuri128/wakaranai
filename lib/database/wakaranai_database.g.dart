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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, type, name, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extension_source_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExtensionSourceTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtensionSourceTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtensionSourceTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
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
  const ExtensionSourceTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.type,
      required this.name,
      required this.url});
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
    );
  }

  factory ExtensionSourceTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtensionSourceTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
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
    };
  }

  ExtensionSourceTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? type,
          String? name,
          String? url}) =>
      ExtensionSourceTableData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        type: type ?? this.type,
        name: name ?? this.name,
        url: url ?? this.url,
      );
  ExtensionSourceTableData copyWithCompanion(
      ExtensionSourceTableCompanion data) {
    return ExtensionSourceTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
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
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, type, name, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtensionSourceTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type &&
          other.name == this.name &&
          other.url == this.url);
}

class ExtensionSourceTableCompanion
    extends UpdateCompanion<ExtensionSourceTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> type;
  final Value<String> name;
  final Value<String> url;
  const ExtensionSourceTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
  });
  ExtensionSourceTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String type,
    required String name,
    required String url,
  })  : type = Value(type),
        name = Value(name),
        url = Value(url);
  static Insertable<ExtensionSourceTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
    });
  }

  ExtensionSourceTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? type,
      Value<String>? name,
      Value<String>? url}) {
    return ExtensionSourceTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
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
          ..write('url: $url')
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nsfwMeta = const VerificationMeta('nsfw');
  @override
  late final GeneratedColumn<bool> nsfw = GeneratedColumn<bool>(
      'nsfw', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("nsfw" IN (0, 1))'));
  static const VerificationMeta _sourceCodeMeta =
      const VerificationMeta('sourceCode');
  @override
  late final GeneratedColumn<String> sourceCode = GeneratedColumn<String>(
      'source_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _searchAvailableMeta =
      const VerificationMeta('searchAvailable');
  @override
  late final GeneratedColumn<bool> searchAvailable = GeneratedColumn<bool>(
      'search_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("search_available" IN (0, 1))'));
  static const VerificationMeta _protectorConfigMeta =
      const VerificationMeta('protectorConfig');
  @override
  late final GeneratedColumn<String> protectorConfig = GeneratedColumn<String>(
      'protector_config', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        protectorConfig
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extension_table';
  @override
  VerificationContext validateIntegrity(Insertable<ExtensionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    } else if (isInserting) {
      context.missing(_logoUrlMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('nsfw')) {
      context.handle(
          _nsfwMeta, nsfw.isAcceptableOrUnknown(data['nsfw']!, _nsfwMeta));
    } else if (isInserting) {
      context.missing(_nsfwMeta);
    }
    if (data.containsKey('source_code')) {
      context.handle(
          _sourceCodeMeta,
          sourceCode.isAcceptableOrUnknown(
              data['source_code']!, _sourceCodeMeta));
    } else if (isInserting) {
      context.missing(_sourceCodeMeta);
    }
    if (data.containsKey('search_available')) {
      context.handle(
          _searchAvailableMeta,
          searchAvailable.isAcceptableOrUnknown(
              data['search_available']!, _searchAvailableMeta));
    } else if (isInserting) {
      context.missing(_searchAvailableMeta);
    }
    if (data.containsKey('protector_config')) {
      context.handle(
          _protectorConfigMeta,
          protectorConfig.isAcceptableOrUnknown(
              data['protector_config']!, _protectorConfigMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtensionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtensionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      nsfw: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}nsfw'])!,
      sourceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_code'])!,
      searchAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}search_available'])!,
      protectorConfig: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}protector_config']),
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
  const ExtensionTableData(
      {required this.id,
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
      this.protectorConfig});
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
    );
  }

  factory ExtensionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
    };
  }

  ExtensionTableData copyWith(
          {int? id,
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
          Value<String?> protectorConfig = const Value.absent()}) =>
      ExtensionTableData(
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
      sourceCode:
          data.sourceCode.present ? data.sourceCode.value : this.sourceCode,
      searchAvailable: data.searchAvailable.present
          ? data.searchAvailable.value
          : this.searchAvailable,
      protectorConfig: data.protectorConfig.present
          ? data.protectorConfig.value
          : this.protectorConfig,
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
          ..write('protectorConfig: $protectorConfig')
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
      protectorConfig);
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
          other.protectorConfig == this.protectorConfig);
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
  })  : uid = Value(uid),
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
    });
  }

  ExtensionTableCompanion copyWith(
      {Value<int>? id,
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
      Value<String?>? protectorConfig}) {
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
          ..write('protectorConfig: $protectorConfig')
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extensionUidMeta =
      const VerificationMeta('extensionUid');
  @override
  late final GeneratedColumn<String> extensionUid = GeneratedColumn<String>(
      'extension_uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES extension_table (uid)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, uid, extensionUid, title, cover, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concrete_data_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConcreteDataTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('extension_uid')) {
      context.handle(
          _extensionUidMeta,
          extensionUid.isAcceptableOrUnknown(
              data['extension_uid']!, _extensionUidMeta));
    } else if (isInserting) {
      context.missing(_extensionUidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConcreteDataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcreteDataTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      extensionUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extension_uid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
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
  const ConcreteDataTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.extensionUid,
      required this.title,
      this.cover,
      this.data});
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
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  factory ConcreteDataTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
    };
  }

  ConcreteDataTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? extensionUid,
          String? title,
          Value<String?> cover = const Value.absent(),
          Value<String?> data = const Value.absent()}) =>
      ConcreteDataTableData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        uid: uid ?? this.uid,
        extensionUid: extensionUid ?? this.extensionUid,
        title: title ?? this.title,
        cover: cover.present ? cover.value : this.cover,
        data: data.present ? data.value : this.data,
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
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, updatedAt, uid, extensionUid, title, cover, data);
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
          other.data == this.data);
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
  const ConcreteDataTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.title = const Value.absent(),
    this.cover = const Value.absent(),
    this.data = const Value.absent(),
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
  })  : uid = Value(uid),
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
    });
  }

  ConcreteDataTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? extensionUid,
      Value<String>? title,
      Value<String?>? cover,
      Value<String?>? data}) {
    return ConcreteDataTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      extensionUid: extensionUid ?? this.extensionUid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      data: data ?? this.data,
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
          ..write('data: $data')
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _concreteIdMeta =
      const VerificationMeta('concreteId');
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
      'concrete_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES concrete_data_table (id)'));
  static const VerificationMeta _readPagesMeta =
      const VerificationMeta('readPages');
  @override
  late final GeneratedColumn<int> readPages = GeneratedColumn<int>(
      'read_pages', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
        totalPages
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_activity_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChapterActivityTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
          _concreteIdMeta,
          concreteId.isAcceptableOrUnknown(
              data['concrete_id']!, _concreteIdMeta));
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('read_pages')) {
      context.handle(_readPagesMeta,
          readPages.isAcceptableOrUnknown(data['read_pages']!, _readPagesMeta));
    } else if (isInserting) {
      context.missing(_readPagesMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    } else if (isInserting) {
      context.missing(_totalPagesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterActivityTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterActivityTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      concreteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}concrete_id'])!,
      readPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_pages'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
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
  const ChapterActivityTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.title,
      this.timestamp,
      this.data,
      required this.concreteId,
      required this.readPages,
      required this.totalPages});
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

  factory ChapterActivityTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  ChapterActivityTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? title,
          Value<String?> timestamp = const Value.absent(),
          Value<String?> data = const Value.absent(),
          int? concreteId,
          int? readPages,
          int? totalPages}) =>
      ChapterActivityTableData(
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
      ChapterActivityTableCompanion data) {
    return ChapterActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
      concreteId:
          data.concreteId.present ? data.concreteId.value : this.concreteId,
      readPages: data.readPages.present ? data.readPages.value : this.readPages,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
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
  int get hashCode => Object.hash(id, createdAt, updatedAt, uid, title,
      timestamp, data, concreteId, readPages, totalPages);
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
  })  : uid = Value(uid),
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

  ChapterActivityTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? title,
      Value<String?>? timestamp,
      Value<String?>? data,
      Value<int>? concreteId,
      Value<int>? readPages,
      Value<int>? totalPages}) {
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
        TableInfo<$AnimeEpisodeActivityTableTable,
            AnimeEpisodeActivityTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeEpisodeActivityTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _concreteIdMeta =
      const VerificationMeta('concreteId');
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
      'concrete_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES concrete_data_table (id)'));
  static const VerificationMeta _watchedTimeMeta =
      const VerificationMeta('watchedTime');
  @override
  late final GeneratedColumn<int> watchedTime = GeneratedColumn<int>(
      'watched_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalTimeMeta =
      const VerificationMeta('totalTime');
  @override
  late final GeneratedColumn<int> totalTime = GeneratedColumn<int>(
      'total_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
        totalTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_episode_activity_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimeEpisodeActivityTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
          _concreteIdMeta,
          concreteId.isAcceptableOrUnknown(
              data['concrete_id']!, _concreteIdMeta));
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('watched_time')) {
      context.handle(
          _watchedTimeMeta,
          watchedTime.isAcceptableOrUnknown(
              data['watched_time']!, _watchedTimeMeta));
    }
    if (data.containsKey('total_time')) {
      context.handle(_totalTimeMeta,
          totalTime.isAcceptableOrUnknown(data['total_time']!, _totalTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimeEpisodeActivityTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeEpisodeActivityTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      concreteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}concrete_id'])!,
      watchedTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}watched_time']),
      totalTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_time']),
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
  const AnimeEpisodeActivityTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.title,
      this.timestamp,
      this.data,
      required this.concreteId,
      this.watchedTime,
      this.totalTime});
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
    );
  }

  factory AnimeEpisodeActivityTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
    };
  }

  AnimeEpisodeActivityTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? title,
          Value<String?> timestamp = const Value.absent(),
          Value<String?> data = const Value.absent(),
          int? concreteId,
          Value<int?> watchedTime = const Value.absent(),
          Value<int?> totalTime = const Value.absent()}) =>
      AnimeEpisodeActivityTableData(
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
      );
  AnimeEpisodeActivityTableData copyWithCompanion(
      AnimeEpisodeActivityTableCompanion data) {
    return AnimeEpisodeActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
      concreteId:
          data.concreteId.present ? data.concreteId.value : this.concreteId,
      watchedTime:
          data.watchedTime.present ? data.watchedTime.value : this.watchedTime,
      totalTime: data.totalTime.present ? data.totalTime.value : this.totalTime,
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
          ..write('totalTime: $totalTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, uid, title,
      timestamp, data, concreteId, watchedTime, totalTime);
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
          other.totalTime == this.totalTime);
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
  })  : uid = Value(uid),
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
    });
  }

  AnimeEpisodeActivityTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? title,
      Value<String?>? timestamp,
      Value<String?>? data,
      Value<int>? concreteId,
      Value<int?>? watchedTime,
      Value<int?>? totalTime}) {
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
          ..write('totalTime: $totalTime')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        extensionSourceTable,
        extensionTable,
        concreteDataTable,
        chapterActivityTable,
        animeEpisodeActivityTable
      ];
}

typedef $$ExtensionSourceTableTableCreateCompanionBuilder
    = ExtensionSourceTableCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  required String type,
  required String name,
  required String url,
});
typedef $$ExtensionSourceTableTableUpdateCompanionBuilder
    = ExtensionSourceTableCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> type,
  Value<String> name,
  Value<String> url,
});

class $$ExtensionSourceTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ExtensionSourceTableTable,
    ExtensionSourceTableData,
    $$ExtensionSourceTableTableFilterComposer,
    $$ExtensionSourceTableTableOrderingComposer,
    $$ExtensionSourceTableTableCreateCompanionBuilder,
    $$ExtensionSourceTableTableUpdateCompanionBuilder> {
  $$ExtensionSourceTableTableTableManager(
      _$WakaranaiDatabase db, $ExtensionSourceTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ExtensionSourceTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$ExtensionSourceTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> url = const Value.absent(),
          }) =>
              ExtensionSourceTableCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            type: type,
            name: name,
            url: url,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            required String type,
            required String name,
            required String url,
          }) =>
              ExtensionSourceTableCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            type: type,
            name: name,
            url: url,
          ),
        ));
}

class $$ExtensionSourceTableTableFilterComposer
    extends FilterComposer<_$WakaranaiDatabase, $ExtensionSourceTableTable> {
  $$ExtensionSourceTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExtensionSourceTableTableOrderingComposer
    extends OrderingComposer<_$WakaranaiDatabase, $ExtensionSourceTableTable> {
  $$ExtensionSourceTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExtensionTableTableCreateCompanionBuilder = ExtensionTableCompanion
    Function({
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
});
typedef $$ExtensionTableTableUpdateCompanionBuilder = ExtensionTableCompanion
    Function({
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
});

class $$ExtensionTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ExtensionTableTable,
    ExtensionTableData,
    $$ExtensionTableTableFilterComposer,
    $$ExtensionTableTableOrderingComposer,
    $$ExtensionTableTableCreateCompanionBuilder,
    $$ExtensionTableTableUpdateCompanionBuilder> {
  $$ExtensionTableTableTableManager(
      _$WakaranaiDatabase db, $ExtensionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExtensionTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExtensionTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
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
          }) =>
              ExtensionTableCompanion(
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
          ),
          createCompanionCallback: ({
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
          }) =>
              ExtensionTableCompanion.insert(
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
          ),
        ));
}

class $$ExtensionTableTableFilterComposer
    extends FilterComposer<_$WakaranaiDatabase, $ExtensionTableTable> {
  $$ExtensionTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get logoUrl => $state.composableBuilder(
      column: $state.table.logoUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get language => $state.composableBuilder(
      column: $state.table.language,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get nsfw => $state.composableBuilder(
      column: $state.table.nsfw,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sourceCode => $state.composableBuilder(
      column: $state.table.sourceCode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get searchAvailable => $state.composableBuilder(
      column: $state.table.searchAvailable,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get protectorConfig => $state.composableBuilder(
      column: $state.table.protectorConfig,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter concreteDataTableRefs(
      ComposableFilter Function($$ConcreteDataTableTableFilterComposer f) f) {
    final $$ConcreteDataTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uid,
            referencedTable: $state.db.concreteDataTable,
            getReferencedColumn: (t) => t.extensionUid,
            builder: (joinBuilder, parentComposers) =>
                $$ConcreteDataTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.concreteDataTable,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$ExtensionTableTableOrderingComposer
    extends OrderingComposer<_$WakaranaiDatabase, $ExtensionTableTable> {
  $$ExtensionTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get logoUrl => $state.composableBuilder(
      column: $state.table.logoUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get language => $state.composableBuilder(
      column: $state.table.language,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get nsfw => $state.composableBuilder(
      column: $state.table.nsfw,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sourceCode => $state.composableBuilder(
      column: $state.table.sourceCode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get searchAvailable => $state.composableBuilder(
      column: $state.table.searchAvailable,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get protectorConfig => $state.composableBuilder(
      column: $state.table.protectorConfig,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ConcreteDataTableTableCreateCompanionBuilder
    = ConcreteDataTableCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  required String uid,
  required String extensionUid,
  required String title,
  Value<String?> cover,
  Value<String?> data,
});
typedef $$ConcreteDataTableTableUpdateCompanionBuilder
    = ConcreteDataTableCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> uid,
  Value<String> extensionUid,
  Value<String> title,
  Value<String?> cover,
  Value<String?> data,
});

class $$ConcreteDataTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ConcreteDataTableTable,
    ConcreteDataTableData,
    $$ConcreteDataTableTableFilterComposer,
    $$ConcreteDataTableTableOrderingComposer,
    $$ConcreteDataTableTableCreateCompanionBuilder,
    $$ConcreteDataTableTableUpdateCompanionBuilder> {
  $$ConcreteDataTableTableTableManager(
      _$WakaranaiDatabase db, $ConcreteDataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ConcreteDataTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ConcreteDataTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> uid = const Value.absent(),
            Value<String> extensionUid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> cover = const Value.absent(),
            Value<String?> data = const Value.absent(),
          }) =>
              ConcreteDataTableCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uid: uid,
            extensionUid: extensionUid,
            title: title,
            cover: cover,
            data: data,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            required String uid,
            required String extensionUid,
            required String title,
            Value<String?> cover = const Value.absent(),
            Value<String?> data = const Value.absent(),
          }) =>
              ConcreteDataTableCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uid: uid,
            extensionUid: extensionUid,
            title: title,
            cover: cover,
            data: data,
          ),
        ));
}

class $$ConcreteDataTableTableFilterComposer
    extends FilterComposer<_$WakaranaiDatabase, $ConcreteDataTableTable> {
  $$ConcreteDataTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cover => $state.composableBuilder(
      column: $state.table.cover,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ExtensionTableTableFilterComposer get extensionUid {
    final $$ExtensionTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.extensionUid,
        referencedTable: $state.db.extensionTable,
        getReferencedColumn: (t) => t.uid,
        builder: (joinBuilder, parentComposers) =>
            $$ExtensionTableTableFilterComposer(ComposerState($state.db,
                $state.db.extensionTable, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter chapterActivityTableRefs(
      ComposableFilter Function($$ChapterActivityTableTableFilterComposer f)
          f) {
    final $$ChapterActivityTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.chapterActivityTable,
            getReferencedColumn: (t) => t.concreteId,
            builder: (joinBuilder, parentComposers) =>
                $$ChapterActivityTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.chapterActivityTable,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter animeEpisodeActivityTableRefs(
      ComposableFilter Function(
              $$AnimeEpisodeActivityTableTableFilterComposer f)
          f) {
    final $$AnimeEpisodeActivityTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.animeEpisodeActivityTable,
            getReferencedColumn: (t) => t.concreteId,
            builder: (joinBuilder, parentComposers) =>
                $$AnimeEpisodeActivityTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.animeEpisodeActivityTable,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$ConcreteDataTableTableOrderingComposer
    extends OrderingComposer<_$WakaranaiDatabase, $ConcreteDataTableTable> {
  $$ConcreteDataTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cover => $state.composableBuilder(
      column: $state.table.cover,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ExtensionTableTableOrderingComposer get extensionUid {
    final $$ExtensionTableTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.extensionUid,
            referencedTable: $state.db.extensionTable,
            getReferencedColumn: (t) => t.uid,
            builder: (joinBuilder, parentComposers) =>
                $$ExtensionTableTableOrderingComposer(ComposerState($state.db,
                    $state.db.extensionTable, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ChapterActivityTableTableCreateCompanionBuilder
    = ChapterActivityTableCompanion Function({
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
typedef $$ChapterActivityTableTableUpdateCompanionBuilder
    = ChapterActivityTableCompanion Function({
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

class $$ChapterActivityTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ChapterActivityTableTable,
    ChapterActivityTableData,
    $$ChapterActivityTableTableFilterComposer,
    $$ChapterActivityTableTableOrderingComposer,
    $$ChapterActivityTableTableCreateCompanionBuilder,
    $$ChapterActivityTableTableUpdateCompanionBuilder> {
  $$ChapterActivityTableTableTableManager(
      _$WakaranaiDatabase db, $ChapterActivityTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ChapterActivityTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$ChapterActivityTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
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
          }) =>
              ChapterActivityTableCompanion(
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
          createCompanionCallback: ({
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
          }) =>
              ChapterActivityTableCompanion.insert(
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
        ));
}

class $$ChapterActivityTableTableFilterComposer
    extends FilterComposer<_$WakaranaiDatabase, $ChapterActivityTableTable> {
  $$ChapterActivityTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get readPages => $state.composableBuilder(
      column: $state.table.readPages,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalPages => $state.composableBuilder(
      column: $state.table.totalPages,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConcreteDataTableTableFilterComposer get concreteId {
    final $$ConcreteDataTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $state.db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConcreteDataTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.concreteDataTable,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$ChapterActivityTableTableOrderingComposer
    extends OrderingComposer<_$WakaranaiDatabase, $ChapterActivityTableTable> {
  $$ChapterActivityTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get readPages => $state.composableBuilder(
      column: $state.table.readPages,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalPages => $state.composableBuilder(
      column: $state.table.totalPages,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConcreteDataTableTableOrderingComposer get concreteId {
    final $$ConcreteDataTableTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $state.db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConcreteDataTableTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.concreteDataTable,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$AnimeEpisodeActivityTableTableCreateCompanionBuilder
    = AnimeEpisodeActivityTableCompanion Function({
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
});
typedef $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder
    = AnimeEpisodeActivityTableCompanion Function({
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
});

class $$AnimeEpisodeActivityTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $AnimeEpisodeActivityTableTable,
    AnimeEpisodeActivityTableData,
    $$AnimeEpisodeActivityTableTableFilterComposer,
    $$AnimeEpisodeActivityTableTableOrderingComposer,
    $$AnimeEpisodeActivityTableTableCreateCompanionBuilder,
    $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder> {
  $$AnimeEpisodeActivityTableTableTableManager(
      _$WakaranaiDatabase db, $AnimeEpisodeActivityTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AnimeEpisodeActivityTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$AnimeEpisodeActivityTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
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
          }) =>
              AnimeEpisodeActivityTableCompanion(
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
          ),
          createCompanionCallback: ({
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
          }) =>
              AnimeEpisodeActivityTableCompanion.insert(
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
          ),
        ));
}

class $$AnimeEpisodeActivityTableTableFilterComposer extends FilterComposer<
    _$WakaranaiDatabase, $AnimeEpisodeActivityTableTable> {
  $$AnimeEpisodeActivityTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get watchedTime => $state.composableBuilder(
      column: $state.table.watchedTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalTime => $state.composableBuilder(
      column: $state.table.totalTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConcreteDataTableTableFilterComposer get concreteId {
    final $$ConcreteDataTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $state.db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConcreteDataTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.concreteDataTable,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$AnimeEpisodeActivityTableTableOrderingComposer extends OrderingComposer<
    _$WakaranaiDatabase, $AnimeEpisodeActivityTableTable> {
  $$AnimeEpisodeActivityTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get watchedTime => $state.composableBuilder(
      column: $state.table.watchedTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalTime => $state.composableBuilder(
      column: $state.table.totalTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConcreteDataTableTableOrderingComposer get concreteId {
    final $$ConcreteDataTableTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $state.db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConcreteDataTableTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.concreteDataTable,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

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
          _db, _db.animeEpisodeActivityTable);
}
