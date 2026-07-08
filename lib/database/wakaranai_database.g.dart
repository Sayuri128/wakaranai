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
  static const VerificationMeta _concreteJsonMeta =
      const VerificationMeta('concreteJson');
  @override
  late final GeneratedColumn<String> concreteJson = GeneratedColumn<String>(
      'concrete_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        concreteJson
      ];
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
    if (data.containsKey('concrete_json')) {
      context.handle(
          _concreteJsonMeta,
          concreteJson.isAcceptableOrUnknown(
              data['concrete_json']!, _concreteJsonMeta));
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
      concreteJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concrete_json']),
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
  const ConcreteDataTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.extensionUid,
      required this.title,
      this.cover,
      this.data,
      this.concreteJson});
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
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      concreteJson: concreteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(concreteJson),
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

  ConcreteDataTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? extensionUid,
          String? title,
          Value<String?> cover = const Value.absent(),
          Value<String?> data = const Value.absent(),
          Value<String?> concreteJson = const Value.absent()}) =>
      ConcreteDataTableData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        uid: uid ?? this.uid,
        extensionUid: extensionUid ?? this.extensionUid,
        title: title ?? this.title,
        cover: cover.present ? cover.value : this.cover,
        data: data.present ? data.value : this.data,
        concreteJson:
            concreteJson.present ? concreteJson.value : this.concreteJson,
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
  int get hashCode => Object.hash(id, createdAt, updatedAt, uid, extensionUid,
      title, cover, data, concreteJson);
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

  ConcreteDataTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? extensionUid,
      Value<String>? title,
      Value<String?>? cover,
      Value<String?>? data,
      Value<String?>? concreteJson}) {
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

class $CategoryTableTable extends CategoryTable
    with TableInfo<$CategoryTableTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_table';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryTableData> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
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
  const CategoryTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.name,
      required this.sortOrder});
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

  factory CategoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  CategoryTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? name,
          int? sortOrder}) =>
      CategoryTableData(
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

  CategoryTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? name,
      Value<int>? sortOrder}) {
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
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES category_table (id)'));
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
      'last_read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        lastReadAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<LibraryEntryTableData> instance,
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
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryTableData(
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
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_read_at']),
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
  const LibraryEntryTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.extensionUid,
      required this.title,
      this.cover,
      this.data,
      this.categoryId,
      this.lastReadAt});
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
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
    );
  }

  factory LibraryEntryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
    };
  }

  LibraryEntryTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? extensionUid,
          String? title,
          Value<String?> cover = const Value.absent(),
          Value<String?> data = const Value.absent(),
          Value<int?> categoryId = const Value.absent(),
          Value<DateTime?> lastReadAt = const Value.absent()}) =>
      LibraryEntryTableData(
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
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
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
          ..write('lastReadAt: $lastReadAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, uid, extensionUid,
      title, cover, data, categoryId, lastReadAt);
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
          other.lastReadAt == this.lastReadAt);
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
  })  : uid = Value(uid),
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
    });
  }

  LibraryEntryTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? extensionUid,
      Value<String>? title,
      Value<String?>? cover,
      Value<String?>? data,
      Value<int?>? categoryId,
      Value<DateTime?>? lastReadAt}) {
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
          ..write('lastReadAt: $lastReadAt')
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _concreteUidMeta =
      const VerificationMeta('concreteUid');
  @override
  late final GeneratedColumn<String> concreteUid = GeneratedColumn<String>(
      'concrete_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _concreteIdMeta =
      const VerificationMeta('concreteId');
  @override
  late final GeneratedColumn<int> concreteId = GeneratedColumn<int>(
      'concrete_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES concrete_data_table (id)'));
  static const VerificationMeta _concreteTitleMeta =
      const VerificationMeta('concreteTitle');
  @override
  late final GeneratedColumn<String> concreteTitle = GeneratedColumn<String>(
      'concrete_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DownloadStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DownloadStatus>($DownloadTableTable.$converterstatus);
  static const VerificationMeta _downloadedPagesMeta =
      const VerificationMeta('downloadedPages');
  @override
  late final GeneratedColumn<int> downloadedPages = GeneratedColumn<int>(
      'downloaded_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dirPathMeta =
      const VerificationMeta('dirPath');
  @override
  late final GeneratedColumn<String> dirPath = GeneratedColumn<String>(
      'dir_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _headersMeta =
      const VerificationMeta('headers');
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
      'headers', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        title,
        status,
        downloadedPages,
        totalPages,
        dirPath,
        headers,
        data
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_table';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadTableData> instance,
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
    if (data.containsKey('concrete_uid')) {
      context.handle(
          _concreteUidMeta,
          concreteUid.isAcceptableOrUnknown(
              data['concrete_uid']!, _concreteUidMeta));
    } else if (isInserting) {
      context.missing(_concreteUidMeta);
    }
    if (data.containsKey('concrete_id')) {
      context.handle(
          _concreteIdMeta,
          concreteId.isAcceptableOrUnknown(
              data['concrete_id']!, _concreteIdMeta));
    } else if (isInserting) {
      context.missing(_concreteIdMeta);
    }
    if (data.containsKey('concrete_title')) {
      context.handle(
          _concreteTitleMeta,
          concreteTitle.isAcceptableOrUnknown(
              data['concrete_title']!, _concreteTitleMeta));
    } else if (isInserting) {
      context.missing(_concreteTitleMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('downloaded_pages')) {
      context.handle(
          _downloadedPagesMeta,
          downloadedPages.isAcceptableOrUnknown(
              data['downloaded_pages']!, _downloadedPagesMeta));
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('dir_path')) {
      context.handle(_dirPathMeta,
          dirPath.isAcceptableOrUnknown(data['dir_path']!, _dirPathMeta));
    } else if (isInserting) {
      context.missing(_dirPathMeta);
    }
    if (data.containsKey('headers')) {
      context.handle(_headersMeta,
          headers.isAcceptableOrUnknown(data['headers']!, _headersMeta));
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
  DownloadTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTableData(
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
      concreteUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concrete_uid'])!,
      concreteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}concrete_id'])!,
      concreteTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concrete_title'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: $DownloadTableTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      downloadedPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downloaded_pages'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      dirPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dir_path'])!,
      headers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headers']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
    );
  }

  @override
  $DownloadTableTable createAlias(String alias) {
    return $DownloadTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadStatus, int, int> $converterstatus =
      const EnumIndexConverter<DownloadStatus>(DownloadStatus.values);
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
  final String title;
  final DownloadStatus status;
  final int downloadedPages;
  final int totalPages;
  final String dirPath;
  final String? headers;
  final String? data;
  const DownloadTableData(
      {required this.id,
      required this.createdAt,
      this.updatedAt,
      required this.uid,
      required this.extensionUid,
      required this.concreteUid,
      required this.concreteId,
      required this.concreteTitle,
      required this.title,
      required this.status,
      required this.downloadedPages,
      required this.totalPages,
      required this.dirPath,
      this.headers,
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
    map['concrete_uid'] = Variable<String>(concreteUid);
    map['concrete_id'] = Variable<int>(concreteId);
    map['concrete_title'] = Variable<String>(concreteTitle);
    map['title'] = Variable<String>(title);
    {
      map['status'] =
          Variable<int>($DownloadTableTable.$converterstatus.toSql(status));
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
      title: Value(title),
      status: Value(status),
      downloadedPages: Value(downloadedPages),
      totalPages: Value(totalPages),
      dirPath: Value(dirPath),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  factory DownloadTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
      title: serializer.fromJson<String>(json['title']),
      status: $DownloadTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      downloadedPages: serializer.fromJson<int>(json['downloadedPages']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      dirPath: serializer.fromJson<String>(json['dirPath']),
      headers: serializer.fromJson<String?>(json['headers']),
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
      'concreteUid': serializer.toJson<String>(concreteUid),
      'concreteId': serializer.toJson<int>(concreteId),
      'concreteTitle': serializer.toJson<String>(concreteTitle),
      'title': serializer.toJson<String>(title),
      'status': serializer
          .toJson<int>($DownloadTableTable.$converterstatus.toJson(status)),
      'downloadedPages': serializer.toJson<int>(downloadedPages),
      'totalPages': serializer.toJson<int>(totalPages),
      'dirPath': serializer.toJson<String>(dirPath),
      'headers': serializer.toJson<String?>(headers),
      'data': serializer.toJson<String?>(data),
    };
  }

  DownloadTableData copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? uid,
          String? extensionUid,
          String? concreteUid,
          int? concreteId,
          String? concreteTitle,
          String? title,
          DownloadStatus? status,
          int? downloadedPages,
          int? totalPages,
          String? dirPath,
          Value<String?> headers = const Value.absent(),
          Value<String?> data = const Value.absent()}) =>
      DownloadTableData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        uid: uid ?? this.uid,
        extensionUid: extensionUid ?? this.extensionUid,
        concreteUid: concreteUid ?? this.concreteUid,
        concreteId: concreteId ?? this.concreteId,
        concreteTitle: concreteTitle ?? this.concreteTitle,
        title: title ?? this.title,
        status: status ?? this.status,
        downloadedPages: downloadedPages ?? this.downloadedPages,
        totalPages: totalPages ?? this.totalPages,
        dirPath: dirPath ?? this.dirPath,
        headers: headers.present ? headers.value : this.headers,
        data: data.present ? data.value : this.data,
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
      concreteUid:
          data.concreteUid.present ? data.concreteUid.value : this.concreteUid,
      concreteId:
          data.concreteId.present ? data.concreteId.value : this.concreteId,
      concreteTitle: data.concreteTitle.present
          ? data.concreteTitle.value
          : this.concreteTitle,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      downloadedPages: data.downloadedPages.present
          ? data.downloadedPages.value
          : this.downloadedPages,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      dirPath: data.dirPath.present ? data.dirPath.value : this.dirPath,
      headers: data.headers.present ? data.headers.value : this.headers,
      data: data.data.present ? data.data.value : this.data,
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
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('dirPath: $dirPath, ')
          ..write('headers: $headers, ')
          ..write('data: $data')
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
      title,
      status,
      downloadedPages,
      totalPages,
      dirPath,
      headers,
      data);
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
          other.title == this.title &&
          other.status == this.status &&
          other.downloadedPages == this.downloadedPages &&
          other.totalPages == this.totalPages &&
          other.dirPath == this.dirPath &&
          other.headers == this.headers &&
          other.data == this.data);
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
  final Value<String> title;
  final Value<DownloadStatus> status;
  final Value<int> downloadedPages;
  final Value<int> totalPages;
  final Value<String> dirPath;
  final Value<String?> headers;
  final Value<String?> data;
  const DownloadTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.extensionUid = const Value.absent(),
    this.concreteUid = const Value.absent(),
    this.concreteId = const Value.absent(),
    this.concreteTitle = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedPages = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.dirPath = const Value.absent(),
    this.headers = const Value.absent(),
    this.data = const Value.absent(),
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
    required String title,
    required DownloadStatus status,
    this.downloadedPages = const Value.absent(),
    this.totalPages = const Value.absent(),
    required String dirPath,
    this.headers = const Value.absent(),
    this.data = const Value.absent(),
  })  : uid = Value(uid),
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
    Expression<String>? title,
    Expression<int>? status,
    Expression<int>? downloadedPages,
    Expression<int>? totalPages,
    Expression<String>? dirPath,
    Expression<String>? headers,
    Expression<String>? data,
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
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (downloadedPages != null) 'downloaded_pages': downloadedPages,
      if (totalPages != null) 'total_pages': totalPages,
      if (dirPath != null) 'dir_path': dirPath,
      if (headers != null) 'headers': headers,
      if (data != null) 'data': data,
    });
  }

  DownloadTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? uid,
      Value<String>? extensionUid,
      Value<String>? concreteUid,
      Value<int>? concreteId,
      Value<String>? concreteTitle,
      Value<String>? title,
      Value<DownloadStatus>? status,
      Value<int>? downloadedPages,
      Value<int>? totalPages,
      Value<String>? dirPath,
      Value<String?>? headers,
      Value<String?>? data}) {
    return DownloadTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uid: uid ?? this.uid,
      extensionUid: extensionUid ?? this.extensionUid,
      concreteUid: concreteUid ?? this.concreteUid,
      concreteId: concreteId ?? this.concreteId,
      concreteTitle: concreteTitle ?? this.concreteTitle,
      title: title ?? this.title,
      status: status ?? this.status,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      totalPages: totalPages ?? this.totalPages,
      dirPath: dirPath ?? this.dirPath,
      headers: headers ?? this.headers,
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
    if (concreteUid.present) {
      map['concrete_uid'] = Variable<String>(concreteUid.value);
    }
    if (concreteId.present) {
      map['concrete_id'] = Variable<int>(concreteId.value);
    }
    if (concreteTitle.present) {
      map['concrete_title'] = Variable<String>(concreteTitle.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $DownloadTableTable.$converterstatus.toSql(status.value));
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
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('dirPath: $dirPath, ')
          ..write('headers: $headers, ')
          ..write('data: $data')
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
        downloadTable
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
    final manager = $$ConcreteDataTableTableTableManager(
            $_db, $_db.concreteDataTable)
        .filter(
            (f) => f.extensionUid.uid.sqlEquals($_itemColumn<String>('uid')!));

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
                    await $_getPrefetchedData<ExtensionTableData,
                            $ExtensionTableTable, ConcreteDataTableData>(
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
  Value<String?> concreteJson,
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
  Value<String?> concreteJson,
});

final class $$ConcreteDataTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $ConcreteDataTableTable, ConcreteDataTableData> {
  $$ConcreteDataTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExtensionTableTable _extensionUidTable(_$WakaranaiDatabase db) =>
      db.extensionTable.createAlias($_aliasNameGenerator(
          db.concreteDataTable.extensionUid, db.extensionTable.uid));

  $$ExtensionTableTableProcessedTableManager get extensionUid {
    final $_column = $_itemColumn<String>('extension_uid')!;

    final manager = $$ExtensionTableTableTableManager($_db, $_db.extensionTable)
        .filter((f) => f.uid.sqlEquals($_column));
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
            .filter((f) => f.concreteId.id.sqlEquals($_itemColumn<int>('id')!));

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
        .filter((f) => f.concreteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_animeEpisodeActivityTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DownloadTableTable, List<DownloadTableData>>
      _downloadTableRefsTable(_$WakaranaiDatabase db) =>
          MultiTypedResultKey.fromTable(db.downloadTable,
              aliasName: $_aliasNameGenerator(
                  db.concreteDataTable.id, db.downloadTable.concreteId));

  $$DownloadTableTableProcessedTableManager get downloadTableRefs {
    final manager = $$DownloadTableTableTableManager($_db, $_db.downloadTable)
        .filter((f) => f.concreteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadTableRefsTable($_db));
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

  ColumnFilters<String> get concreteJson => $composableBuilder(
      column: $table.concreteJson, builder: (column) => ColumnFilters(column));

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

  Expression<bool> downloadTableRefs(
      Expression<bool> Function($$DownloadTableTableFilterComposer f) f) {
    final $$DownloadTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadTable,
        getReferencedColumn: (t) => t.concreteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadTableTableFilterComposer(
              $db: $db,
              $table: $db.downloadTable,
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

  ColumnOrderings<String> get concreteJson => $composableBuilder(
      column: $table.concreteJson,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get concreteJson => $composableBuilder(
      column: $table.concreteJson, builder: (column) => column);

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

  Expression<T> downloadTableRefs<T extends Object>(
      Expression<T> Function($$DownloadTableTableAnnotationComposer a) f) {
    final $$DownloadTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadTable,
        getReferencedColumn: (t) => t.concreteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadTableTableAnnotationComposer(
              $db: $db,
              $table: $db.downloadTable,
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
        bool animeEpisodeActivityTableRefs,
        bool downloadTableRefs})> {
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
            Value<String?> concreteJson = const Value.absent(),
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
            concreteJson: concreteJson,
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
            Value<String?> concreteJson = const Value.absent(),
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
            concreteJson: concreteJson,
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
              animeEpisodeActivityTableRefs = false,
              downloadTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chapterActivityTableRefs) db.chapterActivityTable,
                if (animeEpisodeActivityTableRefs) db.animeEpisodeActivityTable,
                if (downloadTableRefs) db.downloadTable
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
                    await $_getPrefetchedData<ConcreteDataTableData,
                            $ConcreteDataTableTable, ChapterActivityTableData>(
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
                    await $_getPrefetchedData<
                            ConcreteDataTableData,
                            $ConcreteDataTableTable,
                            AnimeEpisodeActivityTableData>(
                        currentTable: table,
                        referencedTable: $$ConcreteDataTableTableReferences
                            ._animeEpisodeActivityTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConcreteDataTableTableReferences(db, table, p0)
                                .animeEpisodeActivityTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.concreteId == item.id),
                        typedResults: items),
                  if (downloadTableRefs)
                    await $_getPrefetchedData<ConcreteDataTableData,
                            $ConcreteDataTableTable, DownloadTableData>(
                        currentTable: table,
                        referencedTable: $$ConcreteDataTableTableReferences
                            ._downloadTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConcreteDataTableTableReferences(db, table, p0)
                                .downloadTableRefs,
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
        bool animeEpisodeActivityTableRefs,
        bool downloadTableRefs})>;
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
    final $_column = $_itemColumn<int>('concrete_id')!;

    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.id.sqlEquals($_column));
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
    final $_column = $_itemColumn<int>('concrete_id')!;

    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.id.sqlEquals($_column));
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
typedef $$CategoryTableTableCreateCompanionBuilder = CategoryTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  required String name,
  Value<int> sortOrder,
});
typedef $$CategoryTableTableUpdateCompanionBuilder = CategoryTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> name,
  Value<int> sortOrder,
});

final class $$CategoryTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $CategoryTableTable, CategoryTableData> {
  $$CategoryTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LibraryEntryTableTable,
      List<LibraryEntryTableData>> _libraryEntryTableRefsTable(
          _$WakaranaiDatabase db) =>
      MultiTypedResultKey.fromTable(db.libraryEntryTable,
          aliasName: $_aliasNameGenerator(
              db.categoryTable.id, db.libraryEntryTable.categoryId));

  $$LibraryEntryTableTableProcessedTableManager get libraryEntryTableRefs {
    final manager =
        $$LibraryEntryTableTableTableManager($_db, $_db.libraryEntryTable)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_libraryEntryTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  Expression<bool> libraryEntryTableRefs(
      Expression<bool> Function($$LibraryEntryTableTableFilterComposer f) f) {
    final $$LibraryEntryTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.libraryEntryTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibraryEntryTableTableFilterComposer(
              $db: $db,
              $table: $db.libraryEntryTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
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

  Expression<T> libraryEntryTableRefs<T extends Object>(
      Expression<T> Function($$LibraryEntryTableTableAnnotationComposer a) f) {
    final $$LibraryEntryTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.libraryEntryTable,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LibraryEntryTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.libraryEntryTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoryTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $CategoryTableTable,
    CategoryTableData,
    $$CategoryTableTableFilterComposer,
    $$CategoryTableTableOrderingComposer,
    $$CategoryTableTableAnnotationComposer,
    $$CategoryTableTableCreateCompanionBuilder,
    $$CategoryTableTableUpdateCompanionBuilder,
    (CategoryTableData, $$CategoryTableTableReferences),
    CategoryTableData,
    PrefetchHooks Function({bool libraryEntryTableRefs})> {
  $$CategoryTableTableTableManager(
      _$WakaranaiDatabase db, $CategoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoryTableCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            required String name,
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoryTableCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({libraryEntryTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryEntryTableRefs) db.libraryEntryTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryEntryTableRefs)
                    await $_getPrefetchedData<CategoryTableData,
                            $CategoryTableTable, LibraryEntryTableData>(
                        currentTable: table,
                        referencedTable: $$CategoryTableTableReferences
                            ._libraryEntryTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryTableTableReferences(db, table, p0)
                                .libraryEntryTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoryTableTableProcessedTableManager = ProcessedTableManager<
    _$WakaranaiDatabase,
    $CategoryTableTable,
    CategoryTableData,
    $$CategoryTableTableFilterComposer,
    $$CategoryTableTableOrderingComposer,
    $$CategoryTableTableAnnotationComposer,
    $$CategoryTableTableCreateCompanionBuilder,
    $$CategoryTableTableUpdateCompanionBuilder,
    (CategoryTableData, $$CategoryTableTableReferences),
    CategoryTableData,
    PrefetchHooks Function({bool libraryEntryTableRefs})>;
typedef $$LibraryEntryTableTableCreateCompanionBuilder
    = LibraryEntryTableCompanion Function({
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
});
typedef $$LibraryEntryTableTableUpdateCompanionBuilder
    = LibraryEntryTableCompanion Function({
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
});

final class $$LibraryEntryTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $LibraryEntryTableTable, LibraryEntryTableData> {
  $$LibraryEntryTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoryTableTable _categoryIdTable(_$WakaranaiDatabase db) =>
      db.categoryTable.createAlias($_aliasNameGenerator(
          db.libraryEntryTable.categoryId, db.categoryTable.id));

  $$CategoryTableTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoryTableTableTableManager($_db, $_db.categoryTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extensionUid => $composableBuilder(
      column: $table.extensionUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  $$CategoryTableTableFilterComposer get categoryId {
    final $$CategoryTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableTableFilterComposer(
              $db: $db,
              $table: $db.categoryTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extensionUid => $composableBuilder(
      column: $table.extensionUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  $$CategoryTableTableOrderingComposer get categoryId {
    final $$CategoryTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableTableOrderingComposer(
              $db: $db,
              $table: $db.categoryTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
      column: $table.extensionUid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  $$CategoryTableTableAnnotationComposer get categoryId {
    final $$CategoryTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryTableTableAnnotationComposer(
              $db: $db,
              $table: $db.categoryTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LibraryEntryTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $LibraryEntryTableTable,
    LibraryEntryTableData,
    $$LibraryEntryTableTableFilterComposer,
    $$LibraryEntryTableTableOrderingComposer,
    $$LibraryEntryTableTableAnnotationComposer,
    $$LibraryEntryTableTableCreateCompanionBuilder,
    $$LibraryEntryTableTableUpdateCompanionBuilder,
    (LibraryEntryTableData, $$LibraryEntryTableTableReferences),
    LibraryEntryTableData,
    PrefetchHooks Function({bool categoryId})> {
  $$LibraryEntryTableTableTableManager(
      _$WakaranaiDatabase db, $LibraryEntryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntryTableTableAnnotationComposer(
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
            Value<int?> categoryId = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
          }) =>
              LibraryEntryTableCompanion(
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
            Value<int?> categoryId = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
          }) =>
              LibraryEntryTableCompanion.insert(
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
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LibraryEntryTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$LibraryEntryTableTableReferences._categoryIdTable(db),
                    referencedColumn: $$LibraryEntryTableTableReferences
                        ._categoryIdTable(db)
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

typedef $$LibraryEntryTableTableProcessedTableManager = ProcessedTableManager<
    _$WakaranaiDatabase,
    $LibraryEntryTableTable,
    LibraryEntryTableData,
    $$LibraryEntryTableTableFilterComposer,
    $$LibraryEntryTableTableOrderingComposer,
    $$LibraryEntryTableTableAnnotationComposer,
    $$LibraryEntryTableTableCreateCompanionBuilder,
    $$LibraryEntryTableTableUpdateCompanionBuilder,
    (LibraryEntryTableData, $$LibraryEntryTableTableReferences),
    LibraryEntryTableData,
    PrefetchHooks Function({bool categoryId})>;
typedef $$DownloadTableTableCreateCompanionBuilder = DownloadTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  required String uid,
  required String extensionUid,
  required String concreteUid,
  required int concreteId,
  required String concreteTitle,
  required String title,
  required DownloadStatus status,
  Value<int> downloadedPages,
  Value<int> totalPages,
  required String dirPath,
  Value<String?> headers,
  Value<String?> data,
});
typedef $$DownloadTableTableUpdateCompanionBuilder = DownloadTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> uid,
  Value<String> extensionUid,
  Value<String> concreteUid,
  Value<int> concreteId,
  Value<String> concreteTitle,
  Value<String> title,
  Value<DownloadStatus> status,
  Value<int> downloadedPages,
  Value<int> totalPages,
  Value<String> dirPath,
  Value<String?> headers,
  Value<String?> data,
});

final class $$DownloadTableTableReferences extends BaseReferences<
    _$WakaranaiDatabase, $DownloadTableTable, DownloadTableData> {
  $$DownloadTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ConcreteDataTableTable _concreteIdTable(_$WakaranaiDatabase db) =>
      db.concreteDataTable.createAlias($_aliasNameGenerator(
          db.downloadTable.concreteId, db.concreteDataTable.id));

  $$ConcreteDataTableTableProcessedTableManager get concreteId {
    final $_column = $_itemColumn<int>('concrete_id')!;

    final manager =
        $$ConcreteDataTableTableTableManager($_db, $_db.concreteDataTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_concreteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extensionUid => $composableBuilder(
      column: $table.extensionUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concreteUid => $composableBuilder(
      column: $table.concreteUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concreteTitle => $composableBuilder(
      column: $table.concreteTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DownloadStatus, DownloadStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get downloadedPages => $composableBuilder(
      column: $table.downloadedPages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dirPath => $composableBuilder(
      column: $table.dirPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extensionUid => $composableBuilder(
      column: $table.extensionUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concreteUid => $composableBuilder(
      column: $table.concreteUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concreteTitle => $composableBuilder(
      column: $table.concreteTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedPages => $composableBuilder(
      column: $table.downloadedPages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dirPath => $composableBuilder(
      column: $table.dirPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

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
      column: $table.extensionUid, builder: (column) => column);

  GeneratedColumn<String> get concreteUid => $composableBuilder(
      column: $table.concreteUid, builder: (column) => column);

  GeneratedColumn<String> get concreteTitle => $composableBuilder(
      column: $table.concreteTitle, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get downloadedPages => $composableBuilder(
      column: $table.downloadedPages, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<String> get dirPath =>
      $composableBuilder(column: $table.dirPath, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

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

class $$DownloadTableTableTableManager extends RootTableManager<
    _$WakaranaiDatabase,
    $DownloadTableTable,
    DownloadTableData,
    $$DownloadTableTableFilterComposer,
    $$DownloadTableTableOrderingComposer,
    $$DownloadTableTableAnnotationComposer,
    $$DownloadTableTableCreateCompanionBuilder,
    $$DownloadTableTableUpdateCompanionBuilder,
    (DownloadTableData, $$DownloadTableTableReferences),
    DownloadTableData,
    PrefetchHooks Function({bool concreteId})> {
  $$DownloadTableTableTableManager(
      _$WakaranaiDatabase db, $DownloadTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> uid = const Value.absent(),
            Value<String> extensionUid = const Value.absent(),
            Value<String> concreteUid = const Value.absent(),
            Value<int> concreteId = const Value.absent(),
            Value<String> concreteTitle = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DownloadStatus> status = const Value.absent(),
            Value<int> downloadedPages = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<String> dirPath = const Value.absent(),
            Value<String?> headers = const Value.absent(),
            Value<String?> data = const Value.absent(),
          }) =>
              DownloadTableCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uid: uid,
            extensionUid: extensionUid,
            concreteUid: concreteUid,
            concreteId: concreteId,
            concreteTitle: concreteTitle,
            title: title,
            status: status,
            downloadedPages: downloadedPages,
            totalPages: totalPages,
            dirPath: dirPath,
            headers: headers,
            data: data,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            required String uid,
            required String extensionUid,
            required String concreteUid,
            required int concreteId,
            required String concreteTitle,
            required String title,
            required DownloadStatus status,
            Value<int> downloadedPages = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            required String dirPath,
            Value<String?> headers = const Value.absent(),
            Value<String?> data = const Value.absent(),
          }) =>
              DownloadTableCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uid: uid,
            extensionUid: extensionUid,
            concreteUid: concreteUid,
            concreteId: concreteId,
            concreteTitle: concreteTitle,
            title: title,
            status: status,
            downloadedPages: downloadedPages,
            totalPages: totalPages,
            dirPath: dirPath,
            headers: headers,
            data: data,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DownloadTableTableReferences(db, table, e)
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
                    referencedTable:
                        $$DownloadTableTableReferences._concreteIdTable(db),
                    referencedColumn:
                        $$DownloadTableTableReferences._concreteIdTable(db).id,
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

typedef $$DownloadTableTableProcessedTableManager = ProcessedTableManager<
    _$WakaranaiDatabase,
    $DownloadTableTable,
    DownloadTableData,
    $$DownloadTableTableFilterComposer,
    $$DownloadTableTableOrderingComposer,
    $$DownloadTableTableAnnotationComposer,
    $$DownloadTableTableCreateCompanionBuilder,
    $$DownloadTableTableUpdateCompanionBuilder,
    (DownloadTableData, $$DownloadTableTableReferences),
    DownloadTableData,
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
  $$CategoryTableTableTableManager get categoryTable =>
      $$CategoryTableTableTableManager(_db, _db.categoryTable);
  $$LibraryEntryTableTableTableManager get libraryEntryTable =>
      $$LibraryEntryTableTableTableManager(_db, _db.libraryEntryTable);
  $$DownloadTableTableTableManager get downloadTable =>
      $$DownloadTableTableTableManager(_db, _db.downloadTable);
}
