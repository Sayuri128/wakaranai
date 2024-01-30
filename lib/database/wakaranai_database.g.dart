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
      type: DriftSqlType.string, requiredDuringInsert: true);
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

abstract class _$WakaranaiDatabase extends GeneratedDatabase {
  _$WakaranaiDatabase(QueryExecutor e) : super(e);
  late final $ExtensionSourceTableTable extensionSourceTable =
      $ExtensionSourceTableTable(this);
  late final $ExtensionTableTable extensionTable = $ExtensionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [extensionSourceTable, extensionTable];
}
