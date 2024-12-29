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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));
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
}

class $$ExtensionSourceTableTableTableManager extends RootTableManager<
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
      BaseReferences<_$WakaranaiDatabase, $ExtensionSourceTableTable,
          ExtensionSourceTableData>
    ),
    ExtensionSourceTableData,
    PrefetchHooks Function()> {
  $$ExtensionSourceTableTableTableManager(
      _$WakaranaiDatabase db, $ExtensionSourceTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtensionSourceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtensionSourceTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtensionSourceTableTableAnnotationComposer(
                  $db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExtensionSourceTableTableProcessedTableManager
    = ProcessedTableManager<
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
          BaseReferences<_$WakaranaiDatabase, $ExtensionSourceTableTable,
              ExtensionSourceTableData>
        ),
        ExtensionSourceTableData,
        PrefetchHooks Function()>;
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

final class $$ExtensionTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $ExtensionTableTable, ExtensionTableData> {
  $$ExtensionTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConcreteDataTableTable,
      List<ConcreteDataTableData>> _concreteDataTableRefsTable(
          _$WakaranaiDatabase db) =>
      MultiTypedResultKey.fromTable(db.concreteDataTable,
          aliasName: $_aliasNameGenerator(
              db.extensionTable.uid, db.concreteDataTable.extensionUid));

  $$ConcreteDataTableTableProcessedTableManager get concreteDataTableRefs {
    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.extensionUid.uid($_item.uid));

    final cache =
        $_typedResult.readTableOrNull(_concreteDataTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nsfw => $composableBuilder(
      column: $table.nsfw, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceCode => $composableBuilder(
      column: $table.sourceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get searchAvailable => $composableBuilder(
      column: $table.searchAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get protectorConfig => $composableBuilder(
      column: $table.protectorConfig,
      builder: (column) => ColumnFilters(column));

  Expression<bool> concreteDataTableRefs(
      Expression<bool> Function($$ConcreteDataTableTableFilterComposer f) f) {
    final $$ConcreteDataTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uid,
        referencedTable: $db.concreteDataTable,
        getReferencedColumn: (t) => t.extensionUid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConcreteDataTableTableFilterComposer(
              $db: $db,
              $table: $db.concreteDataTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nsfw => $composableBuilder(
      column: $table.nsfw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceCode => $composableBuilder(
      column: $table.sourceCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get searchAvailable => $composableBuilder(
      column: $table.searchAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get protectorConfig => $composableBuilder(
      column: $table.protectorConfig,
      builder: (column) => ColumnOrderings(column));
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
      column: $table.sourceCode, builder: (column) => column);

  GeneratedColumn<bool> get searchAvailable => $composableBuilder(
      column: $table.searchAvailable, builder: (column) => column);

  GeneratedColumn<String> get protectorConfig => $composableBuilder(
      column: $table.protectorConfig, builder: (column) => column);

  Expression<T> concreteDataTableRefs<T extends Object>(
      Expression<T> Function($$ConcreteDataTableTableAnnotationComposer a) f) {
    final $$ConcreteDataTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uid,
            referencedTable: $db.concreteDataTable,
            getReferencedColumn: (t) => t.extensionUid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConcreteDataTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.concreteDataTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ExtensionTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ExtensionTableTable,
    ExtensionTableData,
    $$ExtensionTableTableFilterComposer,
    $$ExtensionTableTableOrderingComposer,
    $$ExtensionTableTableAnnotationComposer,
    $$ExtensionTableTableCreateCompanionBuilder,
    $$ExtensionTableTableUpdateCompanionBuilder,
    (ExtensionTableData, $$ExtensionTableTableReferences),
    ExtensionTableData,
    PrefetchHooks Function({bool concreteDataTableRefs})> {
  $$ExtensionTableTableTableManager(
      _$WakaranaiDatabase db, $ExtensionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtensionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtensionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtensionTableTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExtensionTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({concreteDataTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (concreteDataTableRefs) db.concreteDataTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (concreteDataTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ExtensionTableTableReferences
                            ._concreteDataTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExtensionTableTableReferences(db, table, p0)
                                .concreteDataTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.extensionUid == item.uid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExtensionTableTableProcessedTableManager = ProcessedTableManager<
    _$WakaranaiDatabase,
    $ExtensionTableTable,
    ExtensionTableData,
    $$ExtensionTableTableFilterComposer,
    $$ExtensionTableTableOrderingComposer,
    $$ExtensionTableTableAnnotationComposer,
    $$ExtensionTableTableCreateCompanionBuilder,
    $$ExtensionTableTableUpdateCompanionBuilder,
    (ExtensionTableData, $$ExtensionTableTableReferences),
    ExtensionTableData,
    PrefetchHooks Function({bool concreteDataTableRefs})>;
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

final class $$ConcreteDataTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $ConcreteDataTableTable, ConcreteDataTableData> {
  $$ConcreteDataTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExtensionTableTable _extensionUidTable(_$WakaranaiDatabase db) =>
      db.extensionTable.createAlias($_aliasNameGenerator(
          db.concreteDataTable.extensionUid, db.extensionTable.uid));

  $$ExtensionTableTableProcessedTableManager get extensionUid {
    final manager = $$ExtensionTableTableTableManager($_db, $_db.extensionTable)
        .filter((f) => f.uid($_item.extensionUid!));
    final item = $_typedResult.readTableOrNull(_extensionUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ChapterActivityTableTable,
      List<ChapterActivityTableData>> _chapterActivityTableRefsTable(
          _$WakaranaiDatabase db) =>
      MultiTypedResultKey.fromTable(db.chapterActivityTable,
          aliasName: $_aliasNameGenerator(
              db.concreteDataTable.id, db.chapterActivityTable.concreteId));

  $$ChapterActivityTableTableProcessedTableManager
      get chapterActivityTableRefs {
    final manager =
        $$ChapterActivityTableTableTableManager($_db, $_db.chapterActivityTable)
            .filter((f) => f.concreteId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_chapterActivityTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AnimeEpisodeActivityTableTable,
      List<AnimeEpisodeActivityTableData>> _animeEpisodeActivityTableRefsTable(
          _$WakaranaiDatabase db) =>
      MultiTypedResultKey.fromTable(db.animeEpisodeActivityTable,
          aliasName: $_aliasNameGenerator(db.concreteDataTable.id,
              db.animeEpisodeActivityTable.concreteId));

  $$AnimeEpisodeActivityTableTableProcessedTableManager
      get animeEpisodeActivityTableRefs {
    final manager = $$AnimeEpisodeActivityTableTableTableManager(
            $_db, $_db.animeEpisodeActivityTable)
        .filter((f) => f.concreteId.id($_item.id));

    final cache = $_typedResult
        .readTableOrNull(_animeEpisodeActivityTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  $$ExtensionTableTableFilterComposer get extensionUid {
    final $$ExtensionTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.extensionUid,
        referencedTable: $db.extensionTable,
        getReferencedColumn: (t) => t.uid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExtensionTableTableFilterComposer(
              $db: $db,
              $table: $db.extensionTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> chapterActivityTableRefs(
      Expression<bool> Function($$ChapterActivityTableTableFilterComposer f)
          f) {
    final $$ChapterActivityTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapterActivityTable,
        getReferencedColumn: (t) => t.concreteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChapterActivityTableTableFilterComposer(
              $db: $db,
              $table: $db.chapterActivityTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> animeEpisodeActivityTableRefs(
      Expression<bool> Function(
              $$AnimeEpisodeActivityTableTableFilterComposer f)
          f) {
    final $$AnimeEpisodeActivityTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.animeEpisodeActivityTable,
            getReferencedColumn: (t) => t.concreteId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AnimeEpisodeActivityTableTableFilterComposer(
                  $db: $db,
                  $table: $db.animeEpisodeActivityTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  $$ExtensionTableTableOrderingComposer get extensionUid {
    final $$ExtensionTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.extensionUid,
        referencedTable: $db.extensionTable,
        getReferencedColumn: (t) => t.uid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExtensionTableTableOrderingComposer(
              $db: $db,
              $table: $db.extensionTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$ExtensionTableTableAnnotationComposer get extensionUid {
    final $$ExtensionTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.extensionUid,
        referencedTable: $db.extensionTable,
        getReferencedColumn: (t) => t.uid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExtensionTableTableAnnotationComposer(
              $db: $db,
              $table: $db.extensionTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> chapterActivityTableRefs<T extends Object>(
      Expression<T> Function($$ChapterActivityTableTableAnnotationComposer a)
          f) {
    final $$ChapterActivityTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.chapterActivityTable,
            getReferencedColumn: (t) => t.concreteId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ChapterActivityTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.chapterActivityTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> animeEpisodeActivityTableRefs<T extends Object>(
      Expression<T> Function(
              $$AnimeEpisodeActivityTableTableAnnotationComposer a)
          f) {
    final $$AnimeEpisodeActivityTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.animeEpisodeActivityTable,
            getReferencedColumn: (t) => t.concreteId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AnimeEpisodeActivityTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.animeEpisodeActivityTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ConcreteDataTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ConcreteDataTableTable,
    ConcreteDataTableData,
    $$ConcreteDataTableTableFilterComposer,
    $$ConcreteDataTableTableOrderingComposer,
    $$ConcreteDataTableTableAnnotationComposer,
    $$ConcreteDataTableTableCreateCompanionBuilder,
    $$ConcreteDataTableTableUpdateCompanionBuilder,
    (ConcreteDataTableData, $$ConcreteDataTableTableReferences),
    ConcreteDataTableData,
    PrefetchHooks Function(
        {bool extensionUid,
        bool chapterActivityTableRefs,
        bool animeEpisodeActivityTableRefs})> {
  $$ConcreteDataTableTableTableManager(
      _$WakaranaiDatabase db, $ConcreteDataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConcreteDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConcreteDataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConcreteDataTableTableAnnotationComposer(
                  $db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConcreteDataTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {extensionUid = false,
              chapterActivityTableRefs = false,
              animeEpisodeActivityTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chapterActivityTableRefs) db.chapterActivityTable,
                if (animeEpisodeActivityTableRefs) db.animeEpisodeActivityTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (extensionUid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.extensionUid,
                    referencedTable: $$ConcreteDataTableTableReferences
                        ._extensionUidTable(db),
                    referencedColumn: $$ConcreteDataTableTableReferences
                        ._extensionUidTable(db)
                        .uid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chapterActivityTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ConcreteDataTableTableReferences
                            ._chapterActivityTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConcreteDataTableTableReferences(db, table, p0)
                                .chapterActivityTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.concreteId == item.id),
                        typedResults: items),
                  if (animeEpisodeActivityTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ConcreteDataTableTableReferences
                            ._animeEpisodeActivityTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConcreteDataTableTableReferences(db, table, p0)
                                .animeEpisodeActivityTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.concreteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ConcreteDataTableTableProcessedTableManager = ProcessedTableManager<
    _$WakaranaiDatabase,
    $ConcreteDataTableTable,
    ConcreteDataTableData,
    $$ConcreteDataTableTableFilterComposer,
    $$ConcreteDataTableTableOrderingComposer,
    $$ConcreteDataTableTableAnnotationComposer,
    $$ConcreteDataTableTableCreateCompanionBuilder,
    $$ConcreteDataTableTableUpdateCompanionBuilder,
    (ConcreteDataTableData, $$ConcreteDataTableTableReferences),
    ConcreteDataTableData,
    PrefetchHooks Function(
        {bool extensionUid,
        bool chapterActivityTableRefs,
        bool animeEpisodeActivityTableRefs})>;
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

final class $$ChapterActivityTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $ChapterActivityTableTable, ChapterActivityTableData> {
  $$ChapterActivityTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ConcreteDataTableTable _concreteIdTable(_$WakaranaiDatabase db) =>
      db.concreteDataTable.createAlias($_aliasNameGenerator(
          db.chapterActivityTable.concreteId, db.concreteDataTable.id));

  $$ConcreteDataTableTableProcessedTableManager get concreteId {
    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.id($_item.concreteId!));
    final item = $_typedResult.readTableOrNull(_concreteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readPages => $composableBuilder(
      column: $table.readPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  $$ConcreteDataTableTableFilterComposer get concreteId {
    final $$ConcreteDataTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.concreteId,
        referencedTable: $db.concreteDataTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConcreteDataTableTableFilterComposer(
              $db: $db,
              $table: $db.concreteDataTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readPages => $composableBuilder(
      column: $table.readPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  $$ConcreteDataTableTableOrderingComposer get concreteId {
    final $$ConcreteDataTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.concreteId,
        referencedTable: $db.concreteDataTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConcreteDataTableTableOrderingComposer(
              $db: $db,
              $table: $db.concreteDataTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<int> get readPages =>
      $composableBuilder(column: $table.readPages, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  $$ConcreteDataTableTableAnnotationComposer get concreteId {
    final $$ConcreteDataTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConcreteDataTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.concreteDataTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ChapterActivityTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $ChapterActivityTableTable,
    ChapterActivityTableData,
    $$ChapterActivityTableTableFilterComposer,
    $$ChapterActivityTableTableOrderingComposer,
    $$ChapterActivityTableTableAnnotationComposer,
    $$ChapterActivityTableTableCreateCompanionBuilder,
    $$ChapterActivityTableTableUpdateCompanionBuilder,
    (ChapterActivityTableData, $$ChapterActivityTableTableReferences),
    ChapterActivityTableData,
    PrefetchHooks Function({bool concreteId})> {
  $$ChapterActivityTableTableTableManager(
      _$WakaranaiDatabase db, $ChapterActivityTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterActivityTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterActivityTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterActivityTableTableAnnotationComposer(
                  $db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChapterActivityTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({concreteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (concreteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.concreteId,
                    referencedTable: $$ChapterActivityTableTableReferences
                        ._concreteIdTable(db),
                    referencedColumn: $$ChapterActivityTableTableReferences
                        ._concreteIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChapterActivityTableTableProcessedTableManager
    = ProcessedTableManager<
        _$WakaranaiDatabase,
        $ChapterActivityTableTable,
        ChapterActivityTableData,
        $$ChapterActivityTableTableFilterComposer,
        $$ChapterActivityTableTableOrderingComposer,
        $$ChapterActivityTableTableAnnotationComposer,
        $$ChapterActivityTableTableCreateCompanionBuilder,
        $$ChapterActivityTableTableUpdateCompanionBuilder,
        (ChapterActivityTableData, $$ChapterActivityTableTableReferences),
        ChapterActivityTableData,
        PrefetchHooks Function({bool concreteId})>;
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

final class $$AnimeEpisodeActivityTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase,
    $AnimeEpisodeActivityTableTable,
    AnimeEpisodeActivityTableData> {
  $$AnimeEpisodeActivityTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ConcreteDataTableTable _concreteIdTable(_$WakaranaiDatabase db) =>
      db.concreteDataTable.createAlias($_aliasNameGenerator(
          db.animeEpisodeActivityTable.concreteId, db.concreteDataTable.id));

  $$ConcreteDataTableTableProcessedTableManager get concreteId {
    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.id($_item.concreteId!));
    final item = $_typedResult.readTableOrNull(_concreteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get watchedTime => $composableBuilder(
      column: $table.watchedTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTime => $composableBuilder(
      column: $table.totalTime, builder: (column) => ColumnFilters(column));

  $$ConcreteDataTableTableFilterComposer get concreteId {
    final $$ConcreteDataTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.concreteId,
        referencedTable: $db.concreteDataTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConcreteDataTableTableFilterComposer(
              $db: $db,
              $table: $db.concreteDataTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get watchedTime => $composableBuilder(
      column: $table.watchedTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTime => $composableBuilder(
      column: $table.totalTime, builder: (column) => ColumnOrderings(column));

  $$ConcreteDataTableTableOrderingComposer get concreteId {
    final $$ConcreteDataTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.concreteId,
        referencedTable: $db.concreteDataTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConcreteDataTableTableOrderingComposer(
              $db: $db,
              $table: $db.concreteDataTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<int> get watchedTime => $composableBuilder(
      column: $table.watchedTime, builder: (column) => column);

  GeneratedColumn<int> get totalTime =>
      $composableBuilder(column: $table.totalTime, builder: (column) => column);

  $$ConcreteDataTableTableAnnotationComposer get concreteId {
    final $$ConcreteDataTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.concreteId,
            referencedTable: $db.concreteDataTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConcreteDataTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.concreteDataTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$AnimeEpisodeActivityTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $AnimeEpisodeActivityTableTable,
    AnimeEpisodeActivityTableData,
    $$AnimeEpisodeActivityTableTableFilterComposer,
    $$AnimeEpisodeActivityTableTableOrderingComposer,
    $$AnimeEpisodeActivityTableTableAnnotationComposer,
    $$AnimeEpisodeActivityTableTableCreateCompanionBuilder,
    $$AnimeEpisodeActivityTableTableUpdateCompanionBuilder,
    (AnimeEpisodeActivityTableData, $$AnimeEpisodeActivityTableTableReferences),
    AnimeEpisodeActivityTableData,
    PrefetchHooks Function({bool concreteId})> {
  $$AnimeEpisodeActivityTableTableTableManager(
      _$WakaranaiDatabase db, $AnimeEpisodeActivityTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimeEpisodeActivityTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimeEpisodeActivityTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimeEpisodeActivityTableTableAnnotationComposer(
                  $db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnimeEpisodeActivityTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({concreteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (concreteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.concreteId,
                    referencedTable: $$AnimeEpisodeActivityTableTableReferences
                        ._concreteIdTable(db),
                    referencedColumn: $$AnimeEpisodeActivityTableTableReferences
                        ._concreteIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AnimeEpisodeActivityTableTableProcessedTableManager
    = ProcessedTableManager<
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
          $$AnimeEpisodeActivityTableTableReferences
        ),
        AnimeEpisodeActivityTableData,
        PrefetchHooks Function({bool concreteId})>;

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
