// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wakaranai_db.dart';

// ignore_for_file: type=lint
class $LocalProtectorConfigTableTable extends LocalProtectorConfigTable
    with TableInfo<$LocalProtectorConfigTableTable, DriftLocalProtectorConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProtectorConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _pingUrlMeta =
      const VerificationMeta('pingUrl');
  @override
  late final GeneratedColumn<String> pingUrl = GeneratedColumn<String>(
      'ping_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _needToLoginMeta =
      const VerificationMeta('needToLogin');
  @override
  late final GeneratedColumn<bool> needToLogin =
      GeneratedColumn<bool>('need_to_login', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("need_to_login" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _inAppBrowserInterceptorMeta =
      const VerificationMeta('inAppBrowserInterceptor');
  @override
  late final GeneratedColumn<bool> inAppBrowserInterceptor =
      GeneratedColumn<bool>('in_app_browser_interceptor', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("in_app_browser_interceptor" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  @override
  List<GeneratedColumn> get $columns =>
      [id, created, pingUrl, needToLogin, inAppBrowserInterceptor];
  @override
  String get aliasedName => _alias ?? 'local_protector_config_table';
  @override
  String get actualTableName => 'local_protector_config_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalProtectorConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('ping_url')) {
      context.handle(_pingUrlMeta,
          pingUrl.isAcceptableOrUnknown(data['ping_url']!, _pingUrlMeta));
    } else if (isInserting) {
      context.missing(_pingUrlMeta);
    }
    if (data.containsKey('need_to_login')) {
      context.handle(
          _needToLoginMeta,
          needToLogin.isAcceptableOrUnknown(
              data['need_to_login']!, _needToLoginMeta));
    } else if (isInserting) {
      context.missing(_needToLoginMeta);
    }
    if (data.containsKey('in_app_browser_interceptor')) {
      context.handle(
          _inAppBrowserInterceptorMeta,
          inAppBrowserInterceptor.isAcceptableOrUnknown(
              data['in_app_browser_interceptor']!,
              _inAppBrowserInterceptorMeta));
    } else if (isInserting) {
      context.missing(_inAppBrowserInterceptorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalProtectorConfig map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalProtectorConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      pingUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ping_url'])!,
      needToLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}need_to_login'])!,
      inAppBrowserInterceptor: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}in_app_browser_interceptor'])!,
    );
  }

  @override
  $LocalProtectorConfigTableTable createAlias(String alias) {
    return $LocalProtectorConfigTableTable(attachedDatabase, alias);
  }
}

class DriftLocalProtectorConfig extends DataClass
    implements Insertable<DriftLocalProtectorConfig> {
  final int id;
  final DateTime created;
  final String pingUrl;
  final bool needToLogin;
  final bool inAppBrowserInterceptor;
  const DriftLocalProtectorConfig(
      {required this.id,
      required this.created,
      required this.pingUrl,
      required this.needToLogin,
      required this.inAppBrowserInterceptor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['ping_url'] = Variable<String>(pingUrl);
    map['need_to_login'] = Variable<bool>(needToLogin);
    map['in_app_browser_interceptor'] = Variable<bool>(inAppBrowserInterceptor);
    return map;
  }

  LocalProtectorConfigTableCompanion toCompanion(bool nullToAbsent) {
    return LocalProtectorConfigTableCompanion(
      id: Value(id),
      created: Value(created),
      pingUrl: Value(pingUrl),
      needToLogin: Value(needToLogin),
      inAppBrowserInterceptor: Value(inAppBrowserInterceptor),
    );
  }

  factory DriftLocalProtectorConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalProtectorConfig(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      pingUrl: serializer.fromJson<String>(json['pingUrl']),
      needToLogin: serializer.fromJson<bool>(json['needToLogin']),
      inAppBrowserInterceptor:
          serializer.fromJson<bool>(json['inAppBrowserInterceptor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'pingUrl': serializer.toJson<String>(pingUrl),
      'needToLogin': serializer.toJson<bool>(needToLogin),
      'inAppBrowserInterceptor':
          serializer.toJson<bool>(inAppBrowserInterceptor),
    };
  }

  DriftLocalProtectorConfig copyWith(
          {int? id,
          DateTime? created,
          String? pingUrl,
          bool? needToLogin,
          bool? inAppBrowserInterceptor}) =>
      DriftLocalProtectorConfig(
        id: id ?? this.id,
        created: created ?? this.created,
        pingUrl: pingUrl ?? this.pingUrl,
        needToLogin: needToLogin ?? this.needToLogin,
        inAppBrowserInterceptor:
            inAppBrowserInterceptor ?? this.inAppBrowserInterceptor,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalProtectorConfig(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('pingUrl: $pingUrl, ')
          ..write('needToLogin: $needToLogin, ')
          ..write('inAppBrowserInterceptor: $inAppBrowserInterceptor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, created, pingUrl, needToLogin, inAppBrowserInterceptor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalProtectorConfig &&
          other.id == this.id &&
          other.created == this.created &&
          other.pingUrl == this.pingUrl &&
          other.needToLogin == this.needToLogin &&
          other.inAppBrowserInterceptor == this.inAppBrowserInterceptor);
}

class LocalProtectorConfigTableCompanion
    extends UpdateCompanion<DriftLocalProtectorConfig> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> pingUrl;
  final Value<bool> needToLogin;
  final Value<bool> inAppBrowserInterceptor;
  const LocalProtectorConfigTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.pingUrl = const Value.absent(),
    this.needToLogin = const Value.absent(),
    this.inAppBrowserInterceptor = const Value.absent(),
  });
  LocalProtectorConfigTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String pingUrl,
    required bool needToLogin,
    required bool inAppBrowserInterceptor,
  })  : pingUrl = Value(pingUrl),
        needToLogin = Value(needToLogin),
        inAppBrowserInterceptor = Value(inAppBrowserInterceptor);
  static Insertable<DriftLocalProtectorConfig> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? pingUrl,
    Expression<bool>? needToLogin,
    Expression<bool>? inAppBrowserInterceptor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (pingUrl != null) 'ping_url': pingUrl,
      if (needToLogin != null) 'need_to_login': needToLogin,
      if (inAppBrowserInterceptor != null)
        'in_app_browser_interceptor': inAppBrowserInterceptor,
    });
  }

  LocalProtectorConfigTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? pingUrl,
      Value<bool>? needToLogin,
      Value<bool>? inAppBrowserInterceptor}) {
    return LocalProtectorConfigTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      pingUrl: pingUrl ?? this.pingUrl,
      needToLogin: needToLogin ?? this.needToLogin,
      inAppBrowserInterceptor:
          inAppBrowserInterceptor ?? this.inAppBrowserInterceptor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (pingUrl.present) {
      map['ping_url'] = Variable<String>(pingUrl.value);
    }
    if (needToLogin.present) {
      map['need_to_login'] = Variable<bool>(needToLogin.value);
    }
    if (inAppBrowserInterceptor.present) {
      map['in_app_browser_interceptor'] =
          Variable<bool>(inAppBrowserInterceptor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProtectorConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('pingUrl: $pingUrl, ')
          ..write('needToLogin: $needToLogin, ')
          ..write('inAppBrowserInterceptor: $inAppBrowserInterceptor')
          ..write(')'))
        .toString();
  }
}

class $LocalConfigInfoTableTable extends LocalConfigInfoTable
    with TableInfo<$LocalConfigInfoTableTable, DriftLocalConfigInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConfigInfoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
  late final GeneratedColumn<bool> nsfw =
      GeneratedColumn<bool>('nsfw', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("nsfw" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<ConfigInfoType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ConfigInfoType>(
              $LocalConfigInfoTableTable.$convertertype);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localProtectorConfigIdMeta =
      const VerificationMeta('localProtectorConfigId');
  @override
  late final GeneratedColumn<int> localProtectorConfigId = GeneratedColumn<int>(
      'local_protector_config_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_protector_config_table (id)'));
  static const VerificationMeta _searchAvailableMeta =
      const VerificationMeta('searchAvailable');
  @override
  late final GeneratedColumn<bool> searchAvailable =
      GeneratedColumn<bool>('search_available', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("search_available" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        created,
        uid,
        name,
        logoUrl,
        language,
        nsfw,
        type,
        version,
        localProtectorConfigId,
        searchAvailable
      ];
  @override
  String get aliasedName => _alias ?? 'local_config_info_table';
  @override
  String get actualTableName => 'local_config_info_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalConfigInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
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
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('local_protector_config_id')) {
      context.handle(
          _localProtectorConfigIdMeta,
          localProtectorConfigId.isAcceptableOrUnknown(
              data['local_protector_config_id']!, _localProtectorConfigIdMeta));
    }
    if (data.containsKey('search_available')) {
      context.handle(
          _searchAvailableMeta,
          searchAvailable.isAcceptableOrUnknown(
              data['search_available']!, _searchAvailableMeta));
    } else if (isInserting) {
      context.missing(_searchAvailableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalConfigInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalConfigInfo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      nsfw: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}nsfw'])!,
      type: $LocalConfigInfoTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      localProtectorConfigId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_protector_config_id']),
      searchAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}search_available'])!,
    );
  }

  @override
  $LocalConfigInfoTableTable createAlias(String alias) {
    return $LocalConfigInfoTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConfigInfoType, int, int> $convertertype =
      const EnumIndexConverter<ConfigInfoType>(ConfigInfoType.values);
}

class DriftLocalConfigInfo extends DataClass
    implements Insertable<DriftLocalConfigInfo> {
  final int id;
  final DateTime created;
  final String uid;
  final String name;
  final String logoUrl;
  final String language;
  final bool nsfw;
  final ConfigInfoType type;
  final int version;
  final int? localProtectorConfigId;
  final bool searchAvailable;
  const DriftLocalConfigInfo(
      {required this.id,
      required this.created,
      required this.uid,
      required this.name,
      required this.logoUrl,
      required this.language,
      required this.nsfw,
      required this.type,
      required this.version,
      this.localProtectorConfigId,
      required this.searchAvailable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['logo_url'] = Variable<String>(logoUrl);
    map['language'] = Variable<String>(language);
    map['nsfw'] = Variable<bool>(nsfw);
    {
      final converter = $LocalConfigInfoTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || localProtectorConfigId != null) {
      map['local_protector_config_id'] = Variable<int>(localProtectorConfigId);
    }
    map['search_available'] = Variable<bool>(searchAvailable);
    return map;
  }

  LocalConfigInfoTableCompanion toCompanion(bool nullToAbsent) {
    return LocalConfigInfoTableCompanion(
      id: Value(id),
      created: Value(created),
      uid: Value(uid),
      name: Value(name),
      logoUrl: Value(logoUrl),
      language: Value(language),
      nsfw: Value(nsfw),
      type: Value(type),
      version: Value(version),
      localProtectorConfigId: localProtectorConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(localProtectorConfigId),
      searchAvailable: Value(searchAvailable),
    );
  }

  factory DriftLocalConfigInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalConfigInfo(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String>(json['logoUrl']),
      language: serializer.fromJson<String>(json['language']),
      nsfw: serializer.fromJson<bool>(json['nsfw']),
      type: $LocalConfigInfoTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      version: serializer.fromJson<int>(json['version']),
      localProtectorConfigId:
          serializer.fromJson<int?>(json['localProtectorConfigId']),
      searchAvailable: serializer.fromJson<bool>(json['searchAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String>(logoUrl),
      'language': serializer.toJson<String>(language),
      'nsfw': serializer.toJson<bool>(nsfw),
      'type': serializer
          .toJson<int>($LocalConfigInfoTableTable.$convertertype.toJson(type)),
      'version': serializer.toJson<int>(version),
      'localProtectorConfigId': serializer.toJson<int?>(localProtectorConfigId),
      'searchAvailable': serializer.toJson<bool>(searchAvailable),
    };
  }

  DriftLocalConfigInfo copyWith(
          {int? id,
          DateTime? created,
          String? uid,
          String? name,
          String? logoUrl,
          String? language,
          bool? nsfw,
          ConfigInfoType? type,
          int? version,
          Value<int?> localProtectorConfigId = const Value.absent(),
          bool? searchAvailable}) =>
      DriftLocalConfigInfo(
        id: id ?? this.id,
        created: created ?? this.created,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        language: language ?? this.language,
        nsfw: nsfw ?? this.nsfw,
        type: type ?? this.type,
        version: version ?? this.version,
        localProtectorConfigId: localProtectorConfigId.present
            ? localProtectorConfigId.value
            : this.localProtectorConfigId,
        searchAvailable: searchAvailable ?? this.searchAvailable,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalConfigInfo(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('localProtectorConfigId: $localProtectorConfigId, ')
          ..write('searchAvailable: $searchAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, uid, name, logoUrl, language,
      nsfw, type, version, localProtectorConfigId, searchAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalConfigInfo &&
          other.id == this.id &&
          other.created == this.created &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.language == this.language &&
          other.nsfw == this.nsfw &&
          other.type == this.type &&
          other.version == this.version &&
          other.localProtectorConfigId == this.localProtectorConfigId &&
          other.searchAvailable == this.searchAvailable);
}

class LocalConfigInfoTableCompanion
    extends UpdateCompanion<DriftLocalConfigInfo> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> uid;
  final Value<String> name;
  final Value<String> logoUrl;
  final Value<String> language;
  final Value<bool> nsfw;
  final Value<ConfigInfoType> type;
  final Value<int> version;
  final Value<int?> localProtectorConfigId;
  final Value<bool> searchAvailable;
  const LocalConfigInfoTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.language = const Value.absent(),
    this.nsfw = const Value.absent(),
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.localProtectorConfigId = const Value.absent(),
    this.searchAvailable = const Value.absent(),
  });
  LocalConfigInfoTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String uid,
    required String name,
    required String logoUrl,
    required String language,
    required bool nsfw,
    required ConfigInfoType type,
    required int version,
    this.localProtectorConfigId = const Value.absent(),
    required bool searchAvailable,
  })  : uid = Value(uid),
        name = Value(name),
        logoUrl = Value(logoUrl),
        language = Value(language),
        nsfw = Value(nsfw),
        type = Value(type),
        version = Value(version),
        searchAvailable = Value(searchAvailable);
  static Insertable<DriftLocalConfigInfo> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? language,
    Expression<bool>? nsfw,
    Expression<int>? type,
    Expression<int>? version,
    Expression<int>? localProtectorConfigId,
    Expression<bool>? searchAvailable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (language != null) 'language': language,
      if (nsfw != null) 'nsfw': nsfw,
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (localProtectorConfigId != null)
        'local_protector_config_id': localProtectorConfigId,
      if (searchAvailable != null) 'search_available': searchAvailable,
    });
  }

  LocalConfigInfoTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? uid,
      Value<String>? name,
      Value<String>? logoUrl,
      Value<String>? language,
      Value<bool>? nsfw,
      Value<ConfigInfoType>? type,
      Value<int>? version,
      Value<int?>? localProtectorConfigId,
      Value<bool>? searchAvailable}) {
    return LocalConfigInfoTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      language: language ?? this.language,
      nsfw: nsfw ?? this.nsfw,
      type: type ?? this.type,
      version: version ?? this.version,
      localProtectorConfigId:
          localProtectorConfigId ?? this.localProtectorConfigId,
      searchAvailable: searchAvailable ?? this.searchAvailable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    if (type.present) {
      final converter = $LocalConfigInfoTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (localProtectorConfigId.present) {
      map['local_protector_config_id'] =
          Variable<int>(localProtectorConfigId.value);
    }
    if (searchAvailable.present) {
      map['search_available'] = Variable<bool>(searchAvailable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConfigInfoTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('localProtectorConfigId: $localProtectorConfigId, ')
          ..write('searchAvailable: $searchAvailable')
          ..write(')'))
        .toString();
  }
}

class $LocalApiSourceTableTable extends LocalApiSourceTable
    with TableInfo<$LocalApiSourceTableTable, DriftLocalApiSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalApiSourceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<ConfigInfoType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ConfigInfoType>(
              $LocalApiSourceTableTable.$convertertype);
  static const VerificationMeta _localConfigInfoIdMeta =
      const VerificationMeta('localConfigInfoId');
  @override
  late final GeneratedColumn<int> localConfigInfoId = GeneratedColumn<int>(
      'local_config_info_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_config_info_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, created, code, type, localConfigInfoId];
  @override
  String get aliasedName => _alias ?? 'local_api_source_table';
  @override
  String get actualTableName => 'local_api_source_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalApiSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('local_config_info_id')) {
      context.handle(
          _localConfigInfoIdMeta,
          localConfigInfoId.isAcceptableOrUnknown(
              data['local_config_info_id']!, _localConfigInfoIdMeta));
    } else if (isInserting) {
      context.missing(_localConfigInfoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalApiSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalApiSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      type: $LocalApiSourceTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      localConfigInfoId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_config_info_id'])!,
    );
  }

  @override
  $LocalApiSourceTableTable createAlias(String alias) {
    return $LocalApiSourceTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConfigInfoType, int, int> $convertertype =
      const EnumIndexConverter<ConfigInfoType>(ConfigInfoType.values);
}

class DriftLocalApiSource extends DataClass
    implements Insertable<DriftLocalApiSource> {
  final int id;
  final DateTime created;
  final String code;
  final ConfigInfoType type;
  final int localConfigInfoId;
  const DriftLocalApiSource(
      {required this.id,
      required this.created,
      required this.code,
      required this.type,
      required this.localConfigInfoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['code'] = Variable<String>(code);
    {
      final converter = $LocalApiSourceTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['local_config_info_id'] = Variable<int>(localConfigInfoId);
    return map;
  }

  LocalApiSourceTableCompanion toCompanion(bool nullToAbsent) {
    return LocalApiSourceTableCompanion(
      id: Value(id),
      created: Value(created),
      code: Value(code),
      type: Value(type),
      localConfigInfoId: Value(localConfigInfoId),
    );
  }

  factory DriftLocalApiSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalApiSource(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      code: serializer.fromJson<String>(json['code']),
      type: $LocalApiSourceTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      localConfigInfoId: serializer.fromJson<int>(json['localConfigInfoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'code': serializer.toJson<String>(code),
      'type': serializer
          .toJson<int>($LocalApiSourceTableTable.$convertertype.toJson(type)),
      'localConfigInfoId': serializer.toJson<int>(localConfigInfoId),
    };
  }

  DriftLocalApiSource copyWith(
          {int? id,
          DateTime? created,
          String? code,
          ConfigInfoType? type,
          int? localConfigInfoId}) =>
      DriftLocalApiSource(
        id: id ?? this.id,
        created: created ?? this.created,
        code: code ?? this.code,
        type: type ?? this.type,
        localConfigInfoId: localConfigInfoId ?? this.localConfigInfoId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalApiSource(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('localConfigInfoId: $localConfigInfoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, code, type, localConfigInfoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalApiSource &&
          other.id == this.id &&
          other.created == this.created &&
          other.code == this.code &&
          other.type == this.type &&
          other.localConfigInfoId == this.localConfigInfoId);
}

class LocalApiSourceTableCompanion
    extends UpdateCompanion<DriftLocalApiSource> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> code;
  final Value<ConfigInfoType> type;
  final Value<int> localConfigInfoId;
  const LocalApiSourceTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.code = const Value.absent(),
    this.type = const Value.absent(),
    this.localConfigInfoId = const Value.absent(),
  });
  LocalApiSourceTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String code,
    required ConfigInfoType type,
    required int localConfigInfoId,
  })  : code = Value(code),
        type = Value(type),
        localConfigInfoId = Value(localConfigInfoId);
  static Insertable<DriftLocalApiSource> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? code,
    Expression<int>? type,
    Expression<int>? localConfigInfoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (code != null) 'code': code,
      if (type != null) 'type': type,
      if (localConfigInfoId != null) 'local_config_info_id': localConfigInfoId,
    });
  }

  LocalApiSourceTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? code,
      Value<ConfigInfoType>? type,
      Value<int>? localConfigInfoId}) {
    return LocalApiSourceTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      code: code ?? this.code,
      type: type ?? this.type,
      localConfigInfoId: localConfigInfoId ?? this.localConfigInfoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (type.present) {
      final converter = $LocalApiSourceTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    if (localConfigInfoId.present) {
      map['local_config_info_id'] = Variable<int>(localConfigInfoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalApiSourceTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('localConfigInfoId: $localConfigInfoId')
          ..write(')'))
        .toString();
  }
}

class $LocalMangaGalleryViewTableTable extends LocalMangaGalleryViewTable
    with
        TableInfo<$LocalMangaGalleryViewTableTable,
            DriftLocalMangaGalleryView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMangaGalleryViewTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, created, uid, cover, title, data];
  @override
  String get aliasedName => _alias ?? 'local_manga_gallery_view_table';
  @override
  String get actualTableName => 'local_manga_gallery_view_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalMangaGalleryView> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalMangaGalleryView map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalMangaGalleryView(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $LocalMangaGalleryViewTableTable createAlias(String alias) {
    return $LocalMangaGalleryViewTableTable(attachedDatabase, alias);
  }
}

class DriftLocalMangaGalleryView extends DataClass
    implements Insertable<DriftLocalMangaGalleryView> {
  final int id;
  final DateTime created;
  final String uid;
  final String cover;
  final String title;
  final String data;
  const DriftLocalMangaGalleryView(
      {required this.id,
      required this.created,
      required this.uid,
      required this.cover,
      required this.title,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['uid'] = Variable<String>(uid);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    return map;
  }

  LocalMangaGalleryViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalMangaGalleryViewTableCompanion(
      id: Value(id),
      created: Value(created),
      uid: Value(uid),
      cover: Value(cover),
      title: Value(title),
      data: Value(data),
    );
  }

  factory DriftLocalMangaGalleryView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalMangaGalleryView(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      uid: serializer.fromJson<String>(json['uid']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'uid': serializer.toJson<String>(uid),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
    };
  }

  DriftLocalMangaGalleryView copyWith(
          {int? id,
          DateTime? created,
          String? uid,
          String? cover,
          String? title,
          String? data}) =>
      DriftLocalMangaGalleryView(
        id: id ?? this.id,
        created: created ?? this.created,
        uid: uid ?? this.uid,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalMangaGalleryView(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, uid, cover, title, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalMangaGalleryView &&
          other.id == this.id &&
          other.created == this.created &&
          other.uid == this.uid &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.data == this.data);
}

class LocalMangaGalleryViewTableCompanion
    extends UpdateCompanion<DriftLocalMangaGalleryView> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> uid;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> data;
  const LocalMangaGalleryViewTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.uid = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
  });
  LocalMangaGalleryViewTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String uid,
    required String cover,
    required String title,
    required String data,
  })  : uid = Value(uid),
        cover = Value(cover),
        title = Value(title),
        data = Value(data);
  static Insertable<DriftLocalMangaGalleryView> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? uid,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (uid != null) 'uid': uid,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
    });
  }

  LocalMangaGalleryViewTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? uid,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? data}) {
    return LocalMangaGalleryViewTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      uid: uid ?? this.uid,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMangaGalleryViewTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $MangaLibraryItemTableTable extends MangaLibraryItemTable
    with TableInfo<$MangaLibraryItemTableTable, DriftMangaLibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaLibraryItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localApiClientIdMeta =
      const VerificationMeta('localApiClientId');
  @override
  late final GeneratedColumn<int> localApiClientId = GeneratedColumn<int>(
      'local_api_client_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_api_source_table (id)'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _localMangaGalleryViewIdMeta =
      const VerificationMeta('localMangaGalleryViewId');
  @override
  late final GeneratedColumn<int> localMangaGalleryViewId =
      GeneratedColumn<int>('local_manga_gallery_view_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES local_manga_gallery_view_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [localApiClientId, id, created, localMangaGalleryViewId];
  @override
  String get aliasedName => _alias ?? 'manga_library_item_table';
  @override
  String get actualTableName => 'manga_library_item_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftMangaLibraryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_api_client_id')) {
      context.handle(
          _localApiClientIdMeta,
          localApiClientId.isAcceptableOrUnknown(
              data['local_api_client_id']!, _localApiClientIdMeta));
    } else if (isInserting) {
      context.missing(_localApiClientIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('local_manga_gallery_view_id')) {
      context.handle(
          _localMangaGalleryViewIdMeta,
          localMangaGalleryViewId.isAcceptableOrUnknown(
              data['local_manga_gallery_view_id']!,
              _localMangaGalleryViewIdMeta));
    } else if (isInserting) {
      context.missing(_localMangaGalleryViewIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftMangaLibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftMangaLibraryItem(
      localApiClientId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_api_client_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      localMangaGalleryViewId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_manga_gallery_view_id'])!,
    );
  }

  @override
  $MangaLibraryItemTableTable createAlias(String alias) {
    return $MangaLibraryItemTableTable(attachedDatabase, alias);
  }
}

class DriftMangaLibraryItem extends DataClass
    implements Insertable<DriftMangaLibraryItem> {
  final int localApiClientId;
  final int id;
  final DateTime created;
  final int localMangaGalleryViewId;
  const DriftMangaLibraryItem(
      {required this.localApiClientId,
      required this.id,
      required this.created,
      required this.localMangaGalleryViewId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_api_client_id'] = Variable<int>(localApiClientId);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['local_manga_gallery_view_id'] = Variable<int>(localMangaGalleryViewId);
    return map;
  }

  MangaLibraryItemTableCompanion toCompanion(bool nullToAbsent) {
    return MangaLibraryItemTableCompanion(
      localApiClientId: Value(localApiClientId),
      id: Value(id),
      created: Value(created),
      localMangaGalleryViewId: Value(localMangaGalleryViewId),
    );
  }

  factory DriftMangaLibraryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftMangaLibraryItem(
      localApiClientId: serializer.fromJson<int>(json['localApiClientId']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      localMangaGalleryViewId:
          serializer.fromJson<int>(json['localMangaGalleryViewId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localApiClientId': serializer.toJson<int>(localApiClientId),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'localMangaGalleryViewId':
          serializer.toJson<int>(localMangaGalleryViewId),
    };
  }

  DriftMangaLibraryItem copyWith(
          {int? localApiClientId,
          int? id,
          DateTime? created,
          int? localMangaGalleryViewId}) =>
      DriftMangaLibraryItem(
        localApiClientId: localApiClientId ?? this.localApiClientId,
        id: id ?? this.id,
        created: created ?? this.created,
        localMangaGalleryViewId:
            localMangaGalleryViewId ?? this.localMangaGalleryViewId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftMangaLibraryItem(')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('localMangaGalleryViewId: $localMangaGalleryViewId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localApiClientId, id, created, localMangaGalleryViewId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftMangaLibraryItem &&
          other.localApiClientId == this.localApiClientId &&
          other.id == this.id &&
          other.created == this.created &&
          other.localMangaGalleryViewId == this.localMangaGalleryViewId);
}

class MangaLibraryItemTableCompanion
    extends UpdateCompanion<DriftMangaLibraryItem> {
  final Value<int> localApiClientId;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> localMangaGalleryViewId;
  const MangaLibraryItemTableCompanion({
    this.localApiClientId = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.localMangaGalleryViewId = const Value.absent(),
  });
  MangaLibraryItemTableCompanion.insert({
    required int localApiClientId,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int localMangaGalleryViewId,
  })  : localApiClientId = Value(localApiClientId),
        localMangaGalleryViewId = Value(localMangaGalleryViewId);
  static Insertable<DriftMangaLibraryItem> custom({
    Expression<int>? localApiClientId,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? localMangaGalleryViewId,
  }) {
    return RawValuesInsertable({
      if (localApiClientId != null) 'local_api_client_id': localApiClientId,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (localMangaGalleryViewId != null)
        'local_manga_gallery_view_id': localMangaGalleryViewId,
    });
  }

  MangaLibraryItemTableCompanion copyWith(
      {Value<int>? localApiClientId,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? localMangaGalleryViewId}) {
    return MangaLibraryItemTableCompanion(
      localApiClientId: localApiClientId ?? this.localApiClientId,
      id: id ?? this.id,
      created: created ?? this.created,
      localMangaGalleryViewId:
          localMangaGalleryViewId ?? this.localMangaGalleryViewId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localApiClientId.present) {
      map['local_api_client_id'] = Variable<int>(localApiClientId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (localMangaGalleryViewId.present) {
      map['local_manga_gallery_view_id'] =
          Variable<int>(localMangaGalleryViewId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaLibraryItemTableCompanion(')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('localMangaGalleryViewId: $localMangaGalleryViewId')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimeGalleryViewTableTable extends LocalAnimeGalleryViewTable
    with
        TableInfo<$LocalAnimeGalleryViewTableTable,
            DriftLocalAnimeGalleryView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimeGalleryViewTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<AnimeStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AnimeStatus>(
              $LocalAnimeGalleryViewTableTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, created, uid, cover, title, data, status];
  @override
  String get aliasedName => _alias ?? 'local_anime_gallery_view_table';
  @override
  String get actualTableName => 'local_anime_gallery_view_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalAnimeGalleryView> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalAnimeGalleryView map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalAnimeGalleryView(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      status: $LocalAnimeGalleryViewTableTable.$converterstatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $LocalAnimeGalleryViewTableTable createAlias(String alias) {
    return $LocalAnimeGalleryViewTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AnimeStatus, int, int> $converterstatus =
      const EnumIndexConverter<AnimeStatus>(AnimeStatus.values);
}

class DriftLocalAnimeGalleryView extends DataClass
    implements Insertable<DriftLocalAnimeGalleryView> {
  final int id;
  final DateTime created;
  final String uid;
  final String cover;
  final String title;
  final String data;
  final AnimeStatus status;
  const DriftLocalAnimeGalleryView(
      {required this.id,
      required this.created,
      required this.uid,
      required this.cover,
      required this.title,
      required this.data,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['uid'] = Variable<String>(uid);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    {
      final converter = $LocalAnimeGalleryViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status));
    }
    return map;
  }

  LocalAnimeGalleryViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimeGalleryViewTableCompanion(
      id: Value(id),
      created: Value(created),
      uid: Value(uid),
      cover: Value(cover),
      title: Value(title),
      data: Value(data),
      status: Value(status),
    );
  }

  factory DriftLocalAnimeGalleryView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalAnimeGalleryView(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      uid: serializer.fromJson<String>(json['uid']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      status: $LocalAnimeGalleryViewTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'uid': serializer.toJson<String>(uid),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'status': serializer.toJson<int>(
          $LocalAnimeGalleryViewTableTable.$converterstatus.toJson(status)),
    };
  }

  DriftLocalAnimeGalleryView copyWith(
          {int? id,
          DateTime? created,
          String? uid,
          String? cover,
          String? title,
          String? data,
          AnimeStatus? status}) =>
      DriftLocalAnimeGalleryView(
        id: id ?? this.id,
        created: created ?? this.created,
        uid: uid ?? this.uid,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        data: data ?? this.data,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalAnimeGalleryView(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, uid, cover, title, data, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalAnimeGalleryView &&
          other.id == this.id &&
          other.created == this.created &&
          other.uid == this.uid &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.data == this.data &&
          other.status == this.status);
}

class LocalAnimeGalleryViewTableCompanion
    extends UpdateCompanion<DriftLocalAnimeGalleryView> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> uid;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> data;
  final Value<AnimeStatus> status;
  const LocalAnimeGalleryViewTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.uid = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.status = const Value.absent(),
  });
  LocalAnimeGalleryViewTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String uid,
    required String cover,
    required String title,
    required String data,
    required AnimeStatus status,
  })  : uid = Value(uid),
        cover = Value(cover),
        title = Value(title),
        data = Value(data),
        status = Value(status);
  static Insertable<DriftLocalAnimeGalleryView> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? uid,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (uid != null) 'uid': uid,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (status != null) 'status': status,
    });
  }

  LocalAnimeGalleryViewTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? uid,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? data,
      Value<AnimeStatus>? status}) {
    return LocalAnimeGalleryViewTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      uid: uid ?? this.uid,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (status.present) {
      final converter = $LocalAnimeGalleryViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimeGalleryViewTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $LocalMangaConcreteViewTableTable extends LocalMangaConcreteViewTable
    with
        TableInfo<$LocalMangaConcreteViewTableTable,
            DriftLocalMangaConcreteView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMangaConcreteViewTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _galleryViewIdMeta =
      const VerificationMeta('galleryViewId');
  @override
  late final GeneratedColumn<int> galleryViewId = GeneratedColumn<int>(
      'gallery_view_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_anime_gallery_view_table (id)'));
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alternativeTitlesMeta =
      const VerificationMeta('alternativeTitles');
  @override
  late final GeneratedColumn<String> alternativeTitles =
      GeneratedColumn<String>('alternative_titles', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<MangaStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MangaStatus>(
              $LocalMangaConcreteViewTableTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
        uid,
        id,
        created,
        galleryViewId,
        cover,
        title,
        alternativeTitles,
        tags,
        description,
        status
      ];
  @override
  String get aliasedName => _alias ?? 'local_manga_concrete_view_table';
  @override
  String get actualTableName => 'local_manga_concrete_view_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalMangaConcreteView> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('gallery_view_id')) {
      context.handle(
          _galleryViewIdMeta,
          galleryViewId.isAcceptableOrUnknown(
              data['gallery_view_id']!, _galleryViewIdMeta));
    } else if (isInserting) {
      context.missing(_galleryViewIdMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('alternative_titles')) {
      context.handle(
          _alternativeTitlesMeta,
          alternativeTitles.isAcceptableOrUnknown(
              data['alternative_titles']!, _alternativeTitlesMeta));
    } else if (isInserting) {
      context.missing(_alternativeTitlesMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalMangaConcreteView map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalMangaConcreteView(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      galleryViewId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gallery_view_id'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      alternativeTitles: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}alternative_titles'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: $LocalMangaConcreteViewTableTable.$converterstatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $LocalMangaConcreteViewTableTable createAlias(String alias) {
    return $LocalMangaConcreteViewTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MangaStatus, int, int> $converterstatus =
      const EnumIndexConverter<MangaStatus>(MangaStatus.values);
}

class DriftLocalMangaConcreteView extends DataClass
    implements Insertable<DriftLocalMangaConcreteView> {
  final String uid;
  final int id;
  final DateTime created;
  final int galleryViewId;
  final String cover;
  final String title;
  final String alternativeTitles;
  final String tags;
  final String description;
  final MangaStatus status;
  const DriftLocalMangaConcreteView(
      {required this.uid,
      required this.id,
      required this.created,
      required this.galleryViewId,
      required this.cover,
      required this.title,
      required this.alternativeTitles,
      required this.tags,
      required this.description,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['gallery_view_id'] = Variable<int>(galleryViewId);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['alternative_titles'] = Variable<String>(alternativeTitles);
    map['tags'] = Variable<String>(tags);
    map['description'] = Variable<String>(description);
    {
      final converter = $LocalMangaConcreteViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status));
    }
    return map;
  }

  LocalMangaConcreteViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalMangaConcreteViewTableCompanion(
      uid: Value(uid),
      id: Value(id),
      created: Value(created),
      galleryViewId: Value(galleryViewId),
      cover: Value(cover),
      title: Value(title),
      alternativeTitles: Value(alternativeTitles),
      tags: Value(tags),
      description: Value(description),
      status: Value(status),
    );
  }

  factory DriftLocalMangaConcreteView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalMangaConcreteView(
      uid: serializer.fromJson<String>(json['uid']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      galleryViewId: serializer.fromJson<int>(json['galleryViewId']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      alternativeTitles: serializer.fromJson<String>(json['alternativeTitles']),
      tags: serializer.fromJson<String>(json['tags']),
      description: serializer.fromJson<String>(json['description']),
      status: $LocalMangaConcreteViewTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'galleryViewId': serializer.toJson<int>(galleryViewId),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'alternativeTitles': serializer.toJson<String>(alternativeTitles),
      'tags': serializer.toJson<String>(tags),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<int>(
          $LocalMangaConcreteViewTableTable.$converterstatus.toJson(status)),
    };
  }

  DriftLocalMangaConcreteView copyWith(
          {String? uid,
          int? id,
          DateTime? created,
          int? galleryViewId,
          String? cover,
          String? title,
          String? alternativeTitles,
          String? tags,
          String? description,
          MangaStatus? status}) =>
      DriftLocalMangaConcreteView(
        uid: uid ?? this.uid,
        id: id ?? this.id,
        created: created ?? this.created,
        galleryViewId: galleryViewId ?? this.galleryViewId,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        alternativeTitles: alternativeTitles ?? this.alternativeTitles,
        tags: tags ?? this.tags,
        description: description ?? this.description,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalMangaConcreteView(')
          ..write('uid: $uid, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('galleryViewId: $galleryViewId, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('alternativeTitles: $alternativeTitles, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, id, created, galleryViewId, cover, title,
      alternativeTitles, tags, description, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalMangaConcreteView &&
          other.uid == this.uid &&
          other.id == this.id &&
          other.created == this.created &&
          other.galleryViewId == this.galleryViewId &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.alternativeTitles == this.alternativeTitles &&
          other.tags == this.tags &&
          other.description == this.description &&
          other.status == this.status);
}

class LocalMangaConcreteViewTableCompanion
    extends UpdateCompanion<DriftLocalMangaConcreteView> {
  final Value<String> uid;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> galleryViewId;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> alternativeTitles;
  final Value<String> tags;
  final Value<String> description;
  final Value<MangaStatus> status;
  const LocalMangaConcreteViewTableCompanion({
    this.uid = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.galleryViewId = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.alternativeTitles = const Value.absent(),
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
  });
  LocalMangaConcreteViewTableCompanion.insert({
    required String uid,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int galleryViewId,
    required String cover,
    required String title,
    required String alternativeTitles,
    required String tags,
    required String description,
    required MangaStatus status,
  })  : uid = Value(uid),
        galleryViewId = Value(galleryViewId),
        cover = Value(cover),
        title = Value(title),
        alternativeTitles = Value(alternativeTitles),
        tags = Value(tags),
        description = Value(description),
        status = Value(status);
  static Insertable<DriftLocalMangaConcreteView> custom({
    Expression<String>? uid,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? galleryViewId,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? alternativeTitles,
    Expression<String>? tags,
    Expression<String>? description,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (galleryViewId != null) 'gallery_view_id': galleryViewId,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (alternativeTitles != null) 'alternative_titles': alternativeTitles,
      if (tags != null) 'tags': tags,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    });
  }

  LocalMangaConcreteViewTableCompanion copyWith(
      {Value<String>? uid,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? galleryViewId,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? alternativeTitles,
      Value<String>? tags,
      Value<String>? description,
      Value<MangaStatus>? status}) {
    return LocalMangaConcreteViewTableCompanion(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      created: created ?? this.created,
      galleryViewId: galleryViewId ?? this.galleryViewId,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      alternativeTitles: alternativeTitles ?? this.alternativeTitles,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (galleryViewId.present) {
      map['gallery_view_id'] = Variable<int>(galleryViewId.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (alternativeTitles.present) {
      map['alternative_titles'] = Variable<String>(alternativeTitles.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      final converter = $LocalMangaConcreteViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMangaConcreteViewTableCompanion(')
          ..write('uid: $uid, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('galleryViewId: $galleryViewId, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('alternativeTitles: $alternativeTitles, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $LocalChaptersGroupTableTable extends LocalChaptersGroupTable
    with TableInfo<$LocalChaptersGroupTableTable, DriftLocalChaptersGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChaptersGroupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _mangaConcreteIdMeta =
      const VerificationMeta('mangaConcreteId');
  @override
  late final GeneratedColumn<int> mangaConcreteId = GeneratedColumn<int>(
      'manga_concrete_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_manga_concrete_view_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [title, data, id, created, mangaConcreteId];
  @override
  String get aliasedName => _alias ?? 'local_chapters_group_table';
  @override
  String get actualTableName => 'local_chapters_group_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalChaptersGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('manga_concrete_id')) {
      context.handle(
          _mangaConcreteIdMeta,
          mangaConcreteId.isAcceptableOrUnknown(
              data['manga_concrete_id']!, _mangaConcreteIdMeta));
    } else if (isInserting) {
      context.missing(_mangaConcreteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalChaptersGroup map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalChaptersGroup(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      mangaConcreteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}manga_concrete_id'])!,
    );
  }

  @override
  $LocalChaptersGroupTableTable createAlias(String alias) {
    return $LocalChaptersGroupTableTable(attachedDatabase, alias);
  }
}

class DriftLocalChaptersGroup extends DataClass
    implements Insertable<DriftLocalChaptersGroup> {
  final String title;
  final String data;
  final int id;
  final DateTime created;
  final int mangaConcreteId;
  const DriftLocalChaptersGroup(
      {required this.title,
      required this.data,
      required this.id,
      required this.created,
      required this.mangaConcreteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['manga_concrete_id'] = Variable<int>(mangaConcreteId);
    return map;
  }

  LocalChaptersGroupTableCompanion toCompanion(bool nullToAbsent) {
    return LocalChaptersGroupTableCompanion(
      title: Value(title),
      data: Value(data),
      id: Value(id),
      created: Value(created),
      mangaConcreteId: Value(mangaConcreteId),
    );
  }

  factory DriftLocalChaptersGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalChaptersGroup(
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      mangaConcreteId: serializer.fromJson<int>(json['mangaConcreteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'mangaConcreteId': serializer.toJson<int>(mangaConcreteId),
    };
  }

  DriftLocalChaptersGroup copyWith(
          {String? title,
          String? data,
          int? id,
          DateTime? created,
          int? mangaConcreteId}) =>
      DriftLocalChaptersGroup(
        title: title ?? this.title,
        data: data ?? this.data,
        id: id ?? this.id,
        created: created ?? this.created,
        mangaConcreteId: mangaConcreteId ?? this.mangaConcreteId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalChaptersGroup(')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('mangaConcreteId: $mangaConcreteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, data, id, created, mangaConcreteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalChaptersGroup &&
          other.title == this.title &&
          other.data == this.data &&
          other.id == this.id &&
          other.created == this.created &&
          other.mangaConcreteId == this.mangaConcreteId);
}

class LocalChaptersGroupTableCompanion
    extends UpdateCompanion<DriftLocalChaptersGroup> {
  final Value<String> title;
  final Value<String> data;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> mangaConcreteId;
  const LocalChaptersGroupTableCompanion({
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.mangaConcreteId = const Value.absent(),
  });
  LocalChaptersGroupTableCompanion.insert({
    required String title,
    required String data,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int mangaConcreteId,
  })  : title = Value(title),
        data = Value(data),
        mangaConcreteId = Value(mangaConcreteId);
  static Insertable<DriftLocalChaptersGroup> custom({
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? mangaConcreteId,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (mangaConcreteId != null) 'manga_concrete_id': mangaConcreteId,
    });
  }

  LocalChaptersGroupTableCompanion copyWith(
      {Value<String>? title,
      Value<String>? data,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? mangaConcreteId}) {
    return LocalChaptersGroupTableCompanion(
      title: title ?? this.title,
      data: data ?? this.data,
      id: id ?? this.id,
      created: created ?? this.created,
      mangaConcreteId: mangaConcreteId ?? this.mangaConcreteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (mangaConcreteId.present) {
      map['manga_concrete_id'] = Variable<int>(mangaConcreteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChaptersGroupTableCompanion(')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('mangaConcreteId: $mangaConcreteId')
          ..write(')'))
        .toString();
  }
}

class $LocalChapterTableTable extends LocalChapterTable
    with TableInfo<$LocalChapterTableTable, DriftLocalChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChapterTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _chaptersGroupIdMeta =
      const VerificationMeta('chaptersGroupId');
  @override
  late final GeneratedColumn<int> chaptersGroupId = GeneratedColumn<int>(
      'chapters_group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_chapters_group_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [uid, title, data, id, created, chaptersGroupId];
  @override
  String get aliasedName => _alias ?? 'local_chapter_table';
  @override
  String get actualTableName => 'local_chapter_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftLocalChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('chapters_group_id')) {
      context.handle(
          _chaptersGroupIdMeta,
          chaptersGroupId.isAcceptableOrUnknown(
              data['chapters_group_id']!, _chaptersGroupIdMeta));
    } else if (isInserting) {
      context.missing(_chaptersGroupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalChapter(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      chaptersGroupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapters_group_id'])!,
    );
  }

  @override
  $LocalChapterTableTable createAlias(String alias) {
    return $LocalChapterTableTable(attachedDatabase, alias);
  }
}

class DriftLocalChapter extends DataClass
    implements Insertable<DriftLocalChapter> {
  final String uid;
  final String title;
  final String data;
  final int id;
  final DateTime created;
  final int chaptersGroupId;
  const DriftLocalChapter(
      {required this.uid,
      required this.title,
      required this.data,
      required this.id,
      required this.created,
      required this.chaptersGroupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['chapters_group_id'] = Variable<int>(chaptersGroupId);
    return map;
  }

  LocalChapterTableCompanion toCompanion(bool nullToAbsent) {
    return LocalChapterTableCompanion(
      uid: Value(uid),
      title: Value(title),
      data: Value(data),
      id: Value(id),
      created: Value(created),
      chaptersGroupId: Value(chaptersGroupId),
    );
  }

  factory DriftLocalChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalChapter(
      uid: serializer.fromJson<String>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      chaptersGroupId: serializer.fromJson<int>(json['chaptersGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'chaptersGroupId': serializer.toJson<int>(chaptersGroupId),
    };
  }

  DriftLocalChapter copyWith(
          {String? uid,
          String? title,
          String? data,
          int? id,
          DateTime? created,
          int? chaptersGroupId}) =>
      DriftLocalChapter(
        uid: uid ?? this.uid,
        title: title ?? this.title,
        data: data ?? this.data,
        id: id ?? this.id,
        created: created ?? this.created,
        chaptersGroupId: chaptersGroupId ?? this.chaptersGroupId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalChapter(')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('chaptersGroupId: $chaptersGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, title, data, id, created, chaptersGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalChapter &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.data == this.data &&
          other.id == this.id &&
          other.created == this.created &&
          other.chaptersGroupId == this.chaptersGroupId);
}

class LocalChapterTableCompanion extends UpdateCompanion<DriftLocalChapter> {
  final Value<String> uid;
  final Value<String> title;
  final Value<String> data;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> chaptersGroupId;
  const LocalChapterTableCompanion({
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.chaptersGroupId = const Value.absent(),
  });
  LocalChapterTableCompanion.insert({
    required String uid,
    required String title,
    required String data,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int chaptersGroupId,
  })  : uid = Value(uid),
        title = Value(title),
        data = Value(data),
        chaptersGroupId = Value(chaptersGroupId);
  static Insertable<DriftLocalChapter> custom({
    Expression<String>? uid,
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? chaptersGroupId,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (chaptersGroupId != null) 'chapters_group_id': chaptersGroupId,
    });
  }

  LocalChapterTableCompanion copyWith(
      {Value<String>? uid,
      Value<String>? title,
      Value<String>? data,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? chaptersGroupId}) {
    return LocalChapterTableCompanion(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      data: data ?? this.data,
      id: id ?? this.id,
      created: created ?? this.created,
      chaptersGroupId: chaptersGroupId ?? this.chaptersGroupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (chaptersGroupId.present) {
      map['chapters_group_id'] = Variable<int>(chaptersGroupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChapterTableCompanion(')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('chaptersGroupId: $chaptersGroupId')
          ..write(')'))
        .toString();
  }
}

class $LocalPagesTableTable extends LocalPagesTable
    with TableInfo<$LocalPagesTableTable, DriftLocalPages> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _chapterUidMeta =
      const VerificationMeta('chapterUid');
  @override
  late final GeneratedColumn<String> chapterUid = GeneratedColumn<String>(
      'chapter_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_chapter_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, created, chapterUid, chapterId];
  @override
  String get aliasedName => _alias ?? 'local_pages_table';
  @override
  String get actualTableName => 'local_pages_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftLocalPages> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('chapter_uid')) {
      context.handle(
          _chapterUidMeta,
          chapterUid.isAcceptableOrUnknown(
              data['chapter_uid']!, _chapterUidMeta));
    } else if (isInserting) {
      context.missing(_chapterUidMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalPages map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalPages(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      chapterUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_uid'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_id'])!,
    );
  }

  @override
  $LocalPagesTableTable createAlias(String alias) {
    return $LocalPagesTableTable(attachedDatabase, alias);
  }
}

class DriftLocalPages extends DataClass implements Insertable<DriftLocalPages> {
  final int id;
  final DateTime created;
  final String chapterUid;
  final int chapterId;
  const DriftLocalPages(
      {required this.id,
      required this.created,
      required this.chapterUid,
      required this.chapterId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['chapter_uid'] = Variable<String>(chapterUid);
    map['chapter_id'] = Variable<int>(chapterId);
    return map;
  }

  LocalPagesTableCompanion toCompanion(bool nullToAbsent) {
    return LocalPagesTableCompanion(
      id: Value(id),
      created: Value(created),
      chapterUid: Value(chapterUid),
      chapterId: Value(chapterId),
    );
  }

  factory DriftLocalPages.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalPages(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      chapterUid: serializer.fromJson<String>(json['chapterUid']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'chapterUid': serializer.toJson<String>(chapterUid),
      'chapterId': serializer.toJson<int>(chapterId),
    };
  }

  DriftLocalPages copyWith(
          {int? id, DateTime? created, String? chapterUid, int? chapterId}) =>
      DriftLocalPages(
        id: id ?? this.id,
        created: created ?? this.created,
        chapterUid: chapterUid ?? this.chapterUid,
        chapterId: chapterId ?? this.chapterId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalPages(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('chapterUid: $chapterUid, ')
          ..write('chapterId: $chapterId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, chapterUid, chapterId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalPages &&
          other.id == this.id &&
          other.created == this.created &&
          other.chapterUid == this.chapterUid &&
          other.chapterId == this.chapterId);
}

class LocalPagesTableCompanion extends UpdateCompanion<DriftLocalPages> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> chapterUid;
  final Value<int> chapterId;
  const LocalPagesTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.chapterUid = const Value.absent(),
    this.chapterId = const Value.absent(),
  });
  LocalPagesTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String chapterUid,
    required int chapterId,
  })  : chapterUid = Value(chapterUid),
        chapterId = Value(chapterId);
  static Insertable<DriftLocalPages> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? chapterUid,
    Expression<int>? chapterId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (chapterUid != null) 'chapter_uid': chapterUid,
      if (chapterId != null) 'chapter_id': chapterId,
    });
  }

  LocalPagesTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? chapterUid,
      Value<int>? chapterId}) {
    return LocalPagesTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      chapterUid: chapterUid ?? this.chapterUid,
      chapterId: chapterId ?? this.chapterId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (chapterUid.present) {
      map['chapter_uid'] = Variable<String>(chapterUid.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPagesTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('chapterUid: $chapterUid, ')
          ..write('chapterId: $chapterId')
          ..write(')'))
        .toString();
  }
}

class $LocalPageTableTable extends LocalPageTable
    with TableInfo<$LocalPageTableTable, DriftLocalPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pagesIdMeta =
      const VerificationMeta('pagesId');
  @override
  late final GeneratedColumn<int> pagesId = GeneratedColumn<int>(
      'pages_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_pages_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, created, url, pagesId];
  @override
  String get aliasedName => _alias ?? 'local_page_table';
  @override
  String get actualTableName => 'local_page_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftLocalPage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('pages_id')) {
      context.handle(_pagesIdMeta,
          pagesId.isAcceptableOrUnknown(data['pages_id']!, _pagesIdMeta));
    } else if (isInserting) {
      context.missing(_pagesIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalPage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      pagesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pages_id'])!,
    );
  }

  @override
  $LocalPageTableTable createAlias(String alias) {
    return $LocalPageTableTable(attachedDatabase, alias);
  }
}

class DriftLocalPage extends DataClass implements Insertable<DriftLocalPage> {
  final int id;
  final DateTime created;
  final String url;
  final int pagesId;
  const DriftLocalPage(
      {required this.id,
      required this.created,
      required this.url,
      required this.pagesId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['url'] = Variable<String>(url);
    map['pages_id'] = Variable<int>(pagesId);
    return map;
  }

  LocalPageTableCompanion toCompanion(bool nullToAbsent) {
    return LocalPageTableCompanion(
      id: Value(id),
      created: Value(created),
      url: Value(url),
      pagesId: Value(pagesId),
    );
  }

  factory DriftLocalPage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalPage(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      url: serializer.fromJson<String>(json['url']),
      pagesId: serializer.fromJson<int>(json['pagesId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'url': serializer.toJson<String>(url),
      'pagesId': serializer.toJson<int>(pagesId),
    };
  }

  DriftLocalPage copyWith(
          {int? id, DateTime? created, String? url, int? pagesId}) =>
      DriftLocalPage(
        id: id ?? this.id,
        created: created ?? this.created,
        url: url ?? this.url,
        pagesId: pagesId ?? this.pagesId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalPage(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('url: $url, ')
          ..write('pagesId: $pagesId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, url, pagesId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalPage &&
          other.id == this.id &&
          other.created == this.created &&
          other.url == this.url &&
          other.pagesId == this.pagesId);
}

class LocalPageTableCompanion extends UpdateCompanion<DriftLocalPage> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> url;
  final Value<int> pagesId;
  const LocalPageTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.url = const Value.absent(),
    this.pagesId = const Value.absent(),
  });
  LocalPageTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String url,
    required int pagesId,
  })  : url = Value(url),
        pagesId = Value(pagesId);
  static Insertable<DriftLocalPage> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? url,
    Expression<int>? pagesId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (url != null) 'url': url,
      if (pagesId != null) 'pages_id': pagesId,
    });
  }

  LocalPageTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? url,
      Value<int>? pagesId}) {
    return LocalPageTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      url: url ?? this.url,
      pagesId: pagesId ?? this.pagesId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (pagesId.present) {
      map['pages_id'] = Variable<int>(pagesId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPageTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('url: $url, ')
          ..write('pagesId: $pagesId')
          ..write(')'))
        .toString();
  }
}

class $AnimeLibraryItemTableTable extends AnimeLibraryItemTable
    with TableInfo<$AnimeLibraryItemTableTable, DriftAnimeLibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeLibraryItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localApiClientIdMeta =
      const VerificationMeta('localApiClientId');
  @override
  late final GeneratedColumn<int> localApiClientId = GeneratedColumn<int>(
      'local_api_client_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_api_source_table (id)'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _localAnimeGalleryViewIdMeta =
      const VerificationMeta('localAnimeGalleryViewId');
  @override
  late final GeneratedColumn<int> localAnimeGalleryViewId =
      GeneratedColumn<int>('local_anime_gallery_view_id', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES local_anime_gallery_view_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [localApiClientId, id, created, localAnimeGalleryViewId];
  @override
  String get aliasedName => _alias ?? 'anime_library_item_table';
  @override
  String get actualTableName => 'anime_library_item_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftAnimeLibraryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_api_client_id')) {
      context.handle(
          _localApiClientIdMeta,
          localApiClientId.isAcceptableOrUnknown(
              data['local_api_client_id']!, _localApiClientIdMeta));
    } else if (isInserting) {
      context.missing(_localApiClientIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('local_anime_gallery_view_id')) {
      context.handle(
          _localAnimeGalleryViewIdMeta,
          localAnimeGalleryViewId.isAcceptableOrUnknown(
              data['local_anime_gallery_view_id']!,
              _localAnimeGalleryViewIdMeta));
    } else if (isInserting) {
      context.missing(_localAnimeGalleryViewIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftAnimeLibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftAnimeLibraryItem(
      localApiClientId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_api_client_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      localAnimeGalleryViewId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_anime_gallery_view_id'])!,
    );
  }

  @override
  $AnimeLibraryItemTableTable createAlias(String alias) {
    return $AnimeLibraryItemTableTable(attachedDatabase, alias);
  }
}

class DriftAnimeLibraryItem extends DataClass
    implements Insertable<DriftAnimeLibraryItem> {
  final int localApiClientId;
  final int id;
  final DateTime created;
  final int localAnimeGalleryViewId;
  const DriftAnimeLibraryItem(
      {required this.localApiClientId,
      required this.id,
      required this.created,
      required this.localAnimeGalleryViewId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_api_client_id'] = Variable<int>(localApiClientId);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['local_anime_gallery_view_id'] = Variable<int>(localAnimeGalleryViewId);
    return map;
  }

  AnimeLibraryItemTableCompanion toCompanion(bool nullToAbsent) {
    return AnimeLibraryItemTableCompanion(
      localApiClientId: Value(localApiClientId),
      id: Value(id),
      created: Value(created),
      localAnimeGalleryViewId: Value(localAnimeGalleryViewId),
    );
  }

  factory DriftAnimeLibraryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftAnimeLibraryItem(
      localApiClientId: serializer.fromJson<int>(json['localApiClientId']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      localAnimeGalleryViewId:
          serializer.fromJson<int>(json['localAnimeGalleryViewId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localApiClientId': serializer.toJson<int>(localApiClientId),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'localAnimeGalleryViewId':
          serializer.toJson<int>(localAnimeGalleryViewId),
    };
  }

  DriftAnimeLibraryItem copyWith(
          {int? localApiClientId,
          int? id,
          DateTime? created,
          int? localAnimeGalleryViewId}) =>
      DriftAnimeLibraryItem(
        localApiClientId: localApiClientId ?? this.localApiClientId,
        id: id ?? this.id,
        created: created ?? this.created,
        localAnimeGalleryViewId:
            localAnimeGalleryViewId ?? this.localAnimeGalleryViewId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftAnimeLibraryItem(')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('localAnimeGalleryViewId: $localAnimeGalleryViewId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localApiClientId, id, created, localAnimeGalleryViewId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftAnimeLibraryItem &&
          other.localApiClientId == this.localApiClientId &&
          other.id == this.id &&
          other.created == this.created &&
          other.localAnimeGalleryViewId == this.localAnimeGalleryViewId);
}

class AnimeLibraryItemTableCompanion
    extends UpdateCompanion<DriftAnimeLibraryItem> {
  final Value<int> localApiClientId;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> localAnimeGalleryViewId;
  const AnimeLibraryItemTableCompanion({
    this.localApiClientId = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.localAnimeGalleryViewId = const Value.absent(),
  });
  AnimeLibraryItemTableCompanion.insert({
    required int localApiClientId,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int localAnimeGalleryViewId,
  })  : localApiClientId = Value(localApiClientId),
        localAnimeGalleryViewId = Value(localAnimeGalleryViewId);
  static Insertable<DriftAnimeLibraryItem> custom({
    Expression<int>? localApiClientId,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? localAnimeGalleryViewId,
  }) {
    return RawValuesInsertable({
      if (localApiClientId != null) 'local_api_client_id': localApiClientId,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (localAnimeGalleryViewId != null)
        'local_anime_gallery_view_id': localAnimeGalleryViewId,
    });
  }

  AnimeLibraryItemTableCompanion copyWith(
      {Value<int>? localApiClientId,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? localAnimeGalleryViewId}) {
    return AnimeLibraryItemTableCompanion(
      localApiClientId: localApiClientId ?? this.localApiClientId,
      id: id ?? this.id,
      created: created ?? this.created,
      localAnimeGalleryViewId:
          localAnimeGalleryViewId ?? this.localAnimeGalleryViewId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localApiClientId.present) {
      map['local_api_client_id'] = Variable<int>(localApiClientId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (localAnimeGalleryViewId.present) {
      map['local_anime_gallery_view_id'] =
          Variable<int>(localAnimeGalleryViewId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimeLibraryItemTableCompanion(')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('localAnimeGalleryViewId: $localAnimeGalleryViewId')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimeConcreteViewTableTable extends LocalAnimeConcreteViewTable
    with
        TableInfo<$LocalAnimeConcreteViewTableTable,
            DriftLocalAnimeConcreteView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimeConcreteViewTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _galleryViewIdMeta =
      const VerificationMeta('galleryViewId');
  @override
  late final GeneratedColumn<int> galleryViewId = GeneratedColumn<int>(
      'gallery_view_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_manga_gallery_view_table (id)'));
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alternativeTitlesMeta =
      const VerificationMeta('alternativeTitles');
  @override
  late final GeneratedColumn<String> alternativeTitles =
      GeneratedColumn<String>('alternative_titles', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<AnimeStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AnimeStatus>(
              $LocalAnimeConcreteViewTableTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
        uid,
        id,
        created,
        galleryViewId,
        cover,
        title,
        alternativeTitles,
        tags,
        description,
        status
      ];
  @override
  String get aliasedName => _alias ?? 'local_anime_concrete_view_table';
  @override
  String get actualTableName => 'local_anime_concrete_view_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalAnimeConcreteView> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('gallery_view_id')) {
      context.handle(
          _galleryViewIdMeta,
          galleryViewId.isAcceptableOrUnknown(
              data['gallery_view_id']!, _galleryViewIdMeta));
    } else if (isInserting) {
      context.missing(_galleryViewIdMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    } else if (isInserting) {
      context.missing(_coverMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('alternative_titles')) {
      context.handle(
          _alternativeTitlesMeta,
          alternativeTitles.isAcceptableOrUnknown(
              data['alternative_titles']!, _alternativeTitlesMeta));
    } else if (isInserting) {
      context.missing(_alternativeTitlesMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalAnimeConcreteView map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalAnimeConcreteView(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      galleryViewId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gallery_view_id'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      alternativeTitles: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}alternative_titles'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: $LocalAnimeConcreteViewTableTable.$converterstatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $LocalAnimeConcreteViewTableTable createAlias(String alias) {
    return $LocalAnimeConcreteViewTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AnimeStatus, int, int> $converterstatus =
      const EnumIndexConverter<AnimeStatus>(AnimeStatus.values);
}

class DriftLocalAnimeConcreteView extends DataClass
    implements Insertable<DriftLocalAnimeConcreteView> {
  final String uid;
  final int id;
  final DateTime created;
  final int galleryViewId;
  final String cover;
  final String title;
  final String alternativeTitles;
  final String tags;
  final String description;
  final AnimeStatus status;
  const DriftLocalAnimeConcreteView(
      {required this.uid,
      required this.id,
      required this.created,
      required this.galleryViewId,
      required this.cover,
      required this.title,
      required this.alternativeTitles,
      required this.tags,
      required this.description,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['gallery_view_id'] = Variable<int>(galleryViewId);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['alternative_titles'] = Variable<String>(alternativeTitles);
    map['tags'] = Variable<String>(tags);
    map['description'] = Variable<String>(description);
    {
      final converter = $LocalAnimeConcreteViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status));
    }
    return map;
  }

  LocalAnimeConcreteViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimeConcreteViewTableCompanion(
      uid: Value(uid),
      id: Value(id),
      created: Value(created),
      galleryViewId: Value(galleryViewId),
      cover: Value(cover),
      title: Value(title),
      alternativeTitles: Value(alternativeTitles),
      tags: Value(tags),
      description: Value(description),
      status: Value(status),
    );
  }

  factory DriftLocalAnimeConcreteView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalAnimeConcreteView(
      uid: serializer.fromJson<String>(json['uid']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      galleryViewId: serializer.fromJson<int>(json['galleryViewId']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      alternativeTitles: serializer.fromJson<String>(json['alternativeTitles']),
      tags: serializer.fromJson<String>(json['tags']),
      description: serializer.fromJson<String>(json['description']),
      status: $LocalAnimeConcreteViewTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'galleryViewId': serializer.toJson<int>(galleryViewId),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'alternativeTitles': serializer.toJson<String>(alternativeTitles),
      'tags': serializer.toJson<String>(tags),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<int>(
          $LocalAnimeConcreteViewTableTable.$converterstatus.toJson(status)),
    };
  }

  DriftLocalAnimeConcreteView copyWith(
          {String? uid,
          int? id,
          DateTime? created,
          int? galleryViewId,
          String? cover,
          String? title,
          String? alternativeTitles,
          String? tags,
          String? description,
          AnimeStatus? status}) =>
      DriftLocalAnimeConcreteView(
        uid: uid ?? this.uid,
        id: id ?? this.id,
        created: created ?? this.created,
        galleryViewId: galleryViewId ?? this.galleryViewId,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        alternativeTitles: alternativeTitles ?? this.alternativeTitles,
        tags: tags ?? this.tags,
        description: description ?? this.description,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalAnimeConcreteView(')
          ..write('uid: $uid, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('galleryViewId: $galleryViewId, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('alternativeTitles: $alternativeTitles, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, id, created, galleryViewId, cover, title,
      alternativeTitles, tags, description, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalAnimeConcreteView &&
          other.uid == this.uid &&
          other.id == this.id &&
          other.created == this.created &&
          other.galleryViewId == this.galleryViewId &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.alternativeTitles == this.alternativeTitles &&
          other.tags == this.tags &&
          other.description == this.description &&
          other.status == this.status);
}

class LocalAnimeConcreteViewTableCompanion
    extends UpdateCompanion<DriftLocalAnimeConcreteView> {
  final Value<String> uid;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> galleryViewId;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> alternativeTitles;
  final Value<String> tags;
  final Value<String> description;
  final Value<AnimeStatus> status;
  const LocalAnimeConcreteViewTableCompanion({
    this.uid = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.galleryViewId = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.alternativeTitles = const Value.absent(),
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
  });
  LocalAnimeConcreteViewTableCompanion.insert({
    required String uid,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int galleryViewId,
    required String cover,
    required String title,
    required String alternativeTitles,
    required String tags,
    required String description,
    required AnimeStatus status,
  })  : uid = Value(uid),
        galleryViewId = Value(galleryViewId),
        cover = Value(cover),
        title = Value(title),
        alternativeTitles = Value(alternativeTitles),
        tags = Value(tags),
        description = Value(description),
        status = Value(status);
  static Insertable<DriftLocalAnimeConcreteView> custom({
    Expression<String>? uid,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? galleryViewId,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? alternativeTitles,
    Expression<String>? tags,
    Expression<String>? description,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (galleryViewId != null) 'gallery_view_id': galleryViewId,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (alternativeTitles != null) 'alternative_titles': alternativeTitles,
      if (tags != null) 'tags': tags,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    });
  }

  LocalAnimeConcreteViewTableCompanion copyWith(
      {Value<String>? uid,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? galleryViewId,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? alternativeTitles,
      Value<String>? tags,
      Value<String>? description,
      Value<AnimeStatus>? status}) {
    return LocalAnimeConcreteViewTableCompanion(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      created: created ?? this.created,
      galleryViewId: galleryViewId ?? this.galleryViewId,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      alternativeTitles: alternativeTitles ?? this.alternativeTitles,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (galleryViewId.present) {
      map['gallery_view_id'] = Variable<int>(galleryViewId.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (alternativeTitles.present) {
      map['alternative_titles'] = Variable<String>(alternativeTitles.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      final converter = $LocalAnimeConcreteViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimeConcreteViewTableCompanion(')
          ..write('uid: $uid, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('galleryViewId: $galleryViewId, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('alternativeTitles: $alternativeTitles, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimeVideosGroupTableTable extends LocalAnimeVideosGroupTable
    with
        TableInfo<$LocalAnimeVideosGroupTableTable,
            DriftLocalAnimeVideosGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimeVideosGroupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _animeConcreteIdMeta =
      const VerificationMeta('animeConcreteId');
  @override
  late final GeneratedColumn<int> animeConcreteId = GeneratedColumn<int>(
      'anime_concrete_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_anime_concrete_view_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [title, data, id, created, animeConcreteId];
  @override
  String get aliasedName => _alias ?? 'local_anime_videos_group_table';
  @override
  String get actualTableName => 'local_anime_videos_group_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalAnimeVideosGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('anime_concrete_id')) {
      context.handle(
          _animeConcreteIdMeta,
          animeConcreteId.isAcceptableOrUnknown(
              data['anime_concrete_id']!, _animeConcreteIdMeta));
    } else if (isInserting) {
      context.missing(_animeConcreteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalAnimeVideosGroup map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalAnimeVideosGroup(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      animeConcreteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}anime_concrete_id'])!,
    );
  }

  @override
  $LocalAnimeVideosGroupTableTable createAlias(String alias) {
    return $LocalAnimeVideosGroupTableTable(attachedDatabase, alias);
  }
}

class DriftLocalAnimeVideosGroup extends DataClass
    implements Insertable<DriftLocalAnimeVideosGroup> {
  final String title;
  final String data;
  final int id;
  final DateTime created;
  final int animeConcreteId;
  const DriftLocalAnimeVideosGroup(
      {required this.title,
      required this.data,
      required this.id,
      required this.created,
      required this.animeConcreteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['anime_concrete_id'] = Variable<int>(animeConcreteId);
    return map;
  }

  LocalAnimeVideosGroupTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimeVideosGroupTableCompanion(
      title: Value(title),
      data: Value(data),
      id: Value(id),
      created: Value(created),
      animeConcreteId: Value(animeConcreteId),
    );
  }

  factory DriftLocalAnimeVideosGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalAnimeVideosGroup(
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      animeConcreteId: serializer.fromJson<int>(json['animeConcreteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'animeConcreteId': serializer.toJson<int>(animeConcreteId),
    };
  }

  DriftLocalAnimeVideosGroup copyWith(
          {String? title,
          String? data,
          int? id,
          DateTime? created,
          int? animeConcreteId}) =>
      DriftLocalAnimeVideosGroup(
        title: title ?? this.title,
        data: data ?? this.data,
        id: id ?? this.id,
        created: created ?? this.created,
        animeConcreteId: animeConcreteId ?? this.animeConcreteId,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalAnimeVideosGroup(')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('animeConcreteId: $animeConcreteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, data, id, created, animeConcreteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalAnimeVideosGroup &&
          other.title == this.title &&
          other.data == this.data &&
          other.id == this.id &&
          other.created == this.created &&
          other.animeConcreteId == this.animeConcreteId);
}

class LocalAnimeVideosGroupTableCompanion
    extends UpdateCompanion<DriftLocalAnimeVideosGroup> {
  final Value<String> title;
  final Value<String> data;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> animeConcreteId;
  const LocalAnimeVideosGroupTableCompanion({
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.animeConcreteId = const Value.absent(),
  });
  LocalAnimeVideosGroupTableCompanion.insert({
    required String title,
    required String data,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int animeConcreteId,
  })  : title = Value(title),
        data = Value(data),
        animeConcreteId = Value(animeConcreteId);
  static Insertable<DriftLocalAnimeVideosGroup> custom({
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? animeConcreteId,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (animeConcreteId != null) 'anime_concrete_id': animeConcreteId,
    });
  }

  LocalAnimeVideosGroupTableCompanion copyWith(
      {Value<String>? title,
      Value<String>? data,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? animeConcreteId}) {
    return LocalAnimeVideosGroupTableCompanion(
      title: title ?? this.title,
      data: data ?? this.data,
      id: id ?? this.id,
      created: created ?? this.created,
      animeConcreteId: animeConcreteId ?? this.animeConcreteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (animeConcreteId.present) {
      map['anime_concrete_id'] = Variable<int>(animeConcreteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimeVideosGroupTableCompanion(')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('animeConcreteId: $animeConcreteId')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimeVideoTableTable extends LocalAnimeVideoTable
    with TableInfo<$LocalAnimeVideoTableTable, DriftLocalAnimeVideo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimeVideoTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _animeVideosGroupIdMeta =
      const VerificationMeta('animeVideosGroupId');
  @override
  late final GeneratedColumn<int> animeVideosGroupId = GeneratedColumn<int>(
      'anime_videos_group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_anime_videos_group_table (id)'));
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<String> src = GeneratedColumn<String>(
      'src', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<AnimeVideoType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AnimeVideoType>(
              $LocalAnimeVideoTableTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns =>
      [uid, title, data, id, created, animeVideosGroupId, src, type];
  @override
  String get aliasedName => _alias ?? 'local_anime_video_table';
  @override
  String get actualTableName => 'local_anime_video_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalAnimeVideo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('anime_videos_group_id')) {
      context.handle(
          _animeVideosGroupIdMeta,
          animeVideosGroupId.isAcceptableOrUnknown(
              data['anime_videos_group_id']!, _animeVideosGroupIdMeta));
    } else if (isInserting) {
      context.missing(_animeVideosGroupIdMeta);
    }
    if (data.containsKey('src')) {
      context.handle(
          _srcMeta, src.isAcceptableOrUnknown(data['src']!, _srcMeta));
    } else if (isInserting) {
      context.missing(_srcMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalAnimeVideo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalAnimeVideo(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      animeVideosGroupId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}anime_videos_group_id'])!,
      src: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}src'])!,
      type: $LocalAnimeVideoTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $LocalAnimeVideoTableTable createAlias(String alias) {
    return $LocalAnimeVideoTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AnimeVideoType, int, int> $convertertype =
      const EnumIndexConverter<AnimeVideoType>(AnimeVideoType.values);
}

class DriftLocalAnimeVideo extends DataClass
    implements Insertable<DriftLocalAnimeVideo> {
  final String uid;
  final String title;
  final String data;
  final int id;
  final DateTime created;
  final int animeVideosGroupId;
  final String src;
  final AnimeVideoType type;
  const DriftLocalAnimeVideo(
      {required this.uid,
      required this.title,
      required this.data,
      required this.id,
      required this.created,
      required this.animeVideosGroupId,
      required this.src,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['anime_videos_group_id'] = Variable<int>(animeVideosGroupId);
    map['src'] = Variable<String>(src);
    {
      final converter = $LocalAnimeVideoTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    return map;
  }

  LocalAnimeVideoTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimeVideoTableCompanion(
      uid: Value(uid),
      title: Value(title),
      data: Value(data),
      id: Value(id),
      created: Value(created),
      animeVideosGroupId: Value(animeVideosGroupId),
      src: Value(src),
      type: Value(type),
    );
  }

  factory DriftLocalAnimeVideo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalAnimeVideo(
      uid: serializer.fromJson<String>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      animeVideosGroupId: serializer.fromJson<int>(json['animeVideosGroupId']),
      src: serializer.fromJson<String>(json['src']),
      type: $LocalAnimeVideoTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'animeVideosGroupId': serializer.toJson<int>(animeVideosGroupId),
      'src': serializer.toJson<String>(src),
      'type': serializer
          .toJson<int>($LocalAnimeVideoTableTable.$convertertype.toJson(type)),
    };
  }

  DriftLocalAnimeVideo copyWith(
          {String? uid,
          String? title,
          String? data,
          int? id,
          DateTime? created,
          int? animeVideosGroupId,
          String? src,
          AnimeVideoType? type}) =>
      DriftLocalAnimeVideo(
        uid: uid ?? this.uid,
        title: title ?? this.title,
        data: data ?? this.data,
        id: id ?? this.id,
        created: created ?? this.created,
        animeVideosGroupId: animeVideosGroupId ?? this.animeVideosGroupId,
        src: src ?? this.src,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalAnimeVideo(')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('animeVideosGroupId: $animeVideosGroupId, ')
          ..write('src: $src, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, title, data, id, created, animeVideosGroupId, src, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalAnimeVideo &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.data == this.data &&
          other.id == this.id &&
          other.created == this.created &&
          other.animeVideosGroupId == this.animeVideosGroupId &&
          other.src == this.src &&
          other.type == this.type);
}

class LocalAnimeVideoTableCompanion
    extends UpdateCompanion<DriftLocalAnimeVideo> {
  final Value<String> uid;
  final Value<String> title;
  final Value<String> data;
  final Value<int> id;
  final Value<DateTime> created;
  final Value<int> animeVideosGroupId;
  final Value<String> src;
  final Value<AnimeVideoType> type;
  const LocalAnimeVideoTableCompanion({
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.animeVideosGroupId = const Value.absent(),
    this.src = const Value.absent(),
    this.type = const Value.absent(),
  });
  LocalAnimeVideoTableCompanion.insert({
    required String uid,
    required String title,
    required String data,
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required int animeVideosGroupId,
    required String src,
    required AnimeVideoType type,
  })  : uid = Value(uid),
        title = Value(title),
        data = Value(data),
        animeVideosGroupId = Value(animeVideosGroupId),
        src = Value(src),
        type = Value(type);
  static Insertable<DriftLocalAnimeVideo> custom({
    Expression<String>? uid,
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<int>? animeVideosGroupId,
    Expression<String>? src,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (animeVideosGroupId != null)
        'anime_videos_group_id': animeVideosGroupId,
      if (src != null) 'src': src,
      if (type != null) 'type': type,
    });
  }

  LocalAnimeVideoTableCompanion copyWith(
      {Value<String>? uid,
      Value<String>? title,
      Value<String>? data,
      Value<int>? id,
      Value<DateTime>? created,
      Value<int>? animeVideosGroupId,
      Value<String>? src,
      Value<AnimeVideoType>? type}) {
    return LocalAnimeVideoTableCompanion(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      data: data ?? this.data,
      id: id ?? this.id,
      created: created ?? this.created,
      animeVideosGroupId: animeVideosGroupId ?? this.animeVideosGroupId,
      src: src ?? this.src,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (animeVideosGroupId.present) {
      map['anime_videos_group_id'] = Variable<int>(animeVideosGroupId.value);
    }
    if (src.present) {
      map['src'] = Variable<String>(src.value);
    }
    if (type.present) {
      final converter = $LocalAnimeVideoTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimeVideoTableCompanion(')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('animeVideosGroupId: $animeVideosGroupId, ')
          ..write('src: $src, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $LocalConfigsSourcesTableTable extends LocalConfigsSourcesTable
    with TableInfo<$LocalConfigsSourcesTableTable, DriftLocalConfigsSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConfigsSourcesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<ConfigsSourceType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ConfigsSourceType>(
              $LocalConfigsSourcesTableTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [id, created, baseUrl, name, type];
  @override
  String get aliasedName => _alias ?? 'local_configs_sources_table';
  @override
  String get actualTableName => 'local_configs_sources_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DriftLocalConfigsSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLocalConfigsSource map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLocalConfigsSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $LocalConfigsSourcesTableTable.$convertertype.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $LocalConfigsSourcesTableTable createAlias(String alias) {
    return $LocalConfigsSourcesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConfigsSourceType, int, int> $convertertype =
      const EnumIndexConverter<ConfigsSourceType>(ConfigsSourceType.values);
}

class DriftLocalConfigsSource extends DataClass
    implements Insertable<DriftLocalConfigsSource> {
  final int id;
  final DateTime created;
  final String baseUrl;
  final String name;
  final ConfigsSourceType type;
  const DriftLocalConfigsSource(
      {required this.id,
      required this.created,
      required this.baseUrl,
      required this.name,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['base_url'] = Variable<String>(baseUrl);
    map['name'] = Variable<String>(name);
    {
      final converter = $LocalConfigsSourcesTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    return map;
  }

  LocalConfigsSourcesTableCompanion toCompanion(bool nullToAbsent) {
    return LocalConfigsSourcesTableCompanion(
      id: Value(id),
      created: Value(created),
      baseUrl: Value(baseUrl),
      name: Value(name),
      type: Value(type),
    );
  }

  factory DriftLocalConfigsSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalConfigsSource(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      name: serializer.fromJson<String>(json['name']),
      type: $LocalConfigsSourcesTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(
          $LocalConfigsSourcesTableTable.$convertertype.toJson(type)),
    };
  }

  DriftLocalConfigsSource copyWith(
          {int? id,
          DateTime? created,
          String? baseUrl,
          String? name,
          ConfigsSourceType? type}) =>
      DriftLocalConfigsSource(
        id: id ?? this.id,
        created: created ?? this.created,
        baseUrl: baseUrl ?? this.baseUrl,
        name: name ?? this.name,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalConfigsSource(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, created, baseUrl, name, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalConfigsSource &&
          other.id == this.id &&
          other.created == this.created &&
          other.baseUrl == this.baseUrl &&
          other.name == this.name &&
          other.type == this.type);
}

class LocalConfigsSourcesTableCompanion
    extends UpdateCompanion<DriftLocalConfigsSource> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> baseUrl;
  final Value<String> name;
  final Value<ConfigsSourceType> type;
  const LocalConfigsSourcesTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
  });
  LocalConfigsSourcesTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String baseUrl,
    required String name,
    required ConfigsSourceType type,
  })  : baseUrl = Value(baseUrl),
        name = Value(name),
        type = Value(type);
  static Insertable<DriftLocalConfigsSource> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? baseUrl,
    Expression<String>? name,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (baseUrl != null) 'base_url': baseUrl,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
    });
  }

  LocalConfigsSourcesTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? baseUrl,
      Value<String>? name,
      Value<ConfigsSourceType>? type}) {
    return LocalConfigsSourcesTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      baseUrl: baseUrl ?? this.baseUrl,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      final converter = $LocalConfigsSourcesTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConfigsSourcesTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $PagesReadTableTable extends PagesReadTable
    with TableInfo<$PagesReadTableTable, DriftPagesRead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesReadTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, created, uid, readPages, totalPages, lastUpdated];
  @override
  String get aliasedName => _alias ?? 'pages_read_table';
  @override
  String get actualTableName => 'pages_read_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftPagesRead> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
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
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftPagesRead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftPagesRead(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      readPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_pages'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated']),
    );
  }

  @override
  $PagesReadTableTable createAlias(String alias) {
    return $PagesReadTableTable(attachedDatabase, alias);
  }
}

class DriftPagesRead extends DataClass implements Insertable<DriftPagesRead> {
  final int id;
  final DateTime created;
  final String uid;
  final int readPages;
  final int totalPages;
  final DateTime? lastUpdated;
  const DriftPagesRead(
      {required this.id,
      required this.created,
      required this.uid,
      required this.readPages,
      required this.totalPages,
      this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created'] = Variable<DateTime>(created);
    map['uid'] = Variable<String>(uid);
    map['read_pages'] = Variable<int>(readPages);
    map['total_pages'] = Variable<int>(totalPages);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  PagesReadTableCompanion toCompanion(bool nullToAbsent) {
    return PagesReadTableCompanion(
      id: Value(id),
      created: Value(created),
      uid: Value(uid),
      readPages: Value(readPages),
      totalPages: Value(totalPages),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory DriftPagesRead.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftPagesRead(
      id: serializer.fromJson<int>(json['id']),
      created: serializer.fromJson<DateTime>(json['created']),
      uid: serializer.fromJson<String>(json['uid']),
      readPages: serializer.fromJson<int>(json['readPages']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'created': serializer.toJson<DateTime>(created),
      'uid': serializer.toJson<String>(uid),
      'readPages': serializer.toJson<int>(readPages),
      'totalPages': serializer.toJson<int>(totalPages),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  DriftPagesRead copyWith(
          {int? id,
          DateTime? created,
          String? uid,
          int? readPages,
          int? totalPages,
          Value<DateTime?> lastUpdated = const Value.absent()}) =>
      DriftPagesRead(
        id: id ?? this.id,
        created: created ?? this.created,
        uid: uid ?? this.uid,
        readPages: readPages ?? this.readPages,
        totalPages: totalPages ?? this.totalPages,
        lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
      );
  @override
  String toString() {
    return (StringBuffer('DriftPagesRead(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('readPages: $readPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, created, uid, readPages, totalPages, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftPagesRead &&
          other.id == this.id &&
          other.created == this.created &&
          other.uid == this.uid &&
          other.readPages == this.readPages &&
          other.totalPages == this.totalPages &&
          other.lastUpdated == this.lastUpdated);
}

class PagesReadTableCompanion extends UpdateCompanion<DriftPagesRead> {
  final Value<int> id;
  final Value<DateTime> created;
  final Value<String> uid;
  final Value<int> readPages;
  final Value<int> totalPages;
  final Value<DateTime?> lastUpdated;
  const PagesReadTableCompanion({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    this.uid = const Value.absent(),
    this.readPages = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  PagesReadTableCompanion.insert({
    this.id = const Value.absent(),
    this.created = const Value.absent(),
    required String uid,
    required int readPages,
    required int totalPages,
    this.lastUpdated = const Value.absent(),
  })  : uid = Value(uid),
        readPages = Value(readPages),
        totalPages = Value(totalPages);
  static Insertable<DriftPagesRead> custom({
    Expression<int>? id,
    Expression<DateTime>? created,
    Expression<String>? uid,
    Expression<int>? readPages,
    Expression<int>? totalPages,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (created != null) 'created': created,
      if (uid != null) 'uid': uid,
      if (readPages != null) 'read_pages': readPages,
      if (totalPages != null) 'total_pages': totalPages,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  PagesReadTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? created,
      Value<String>? uid,
      Value<int>? readPages,
      Value<int>? totalPages,
      Value<DateTime?>? lastUpdated}) {
    return PagesReadTableCompanion(
      id: id ?? this.id,
      created: created ?? this.created,
      uid: uid ?? this.uid,
      readPages: readPages ?? this.readPages,
      totalPages: totalPages ?? this.totalPages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (readPages.present) {
      map['read_pages'] = Variable<int>(readPages.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesReadTableCompanion(')
          ..write('id: $id, ')
          ..write('created: $created, ')
          ..write('uid: $uid, ')
          ..write('readPages: $readPages, ')
          ..write('totalPages: $totalPages, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$WakaranaiDb extends GeneratedDatabase {
  _$WakaranaiDb(QueryExecutor e) : super(e);
  late final $LocalProtectorConfigTableTable localProtectorConfigTable =
      $LocalProtectorConfigTableTable(this);
  late final $LocalConfigInfoTableTable localConfigInfoTable =
      $LocalConfigInfoTableTable(this);
  late final $LocalApiSourceTableTable localApiSourceTable =
      $LocalApiSourceTableTable(this);
  late final $LocalMangaGalleryViewTableTable localMangaGalleryViewTable =
      $LocalMangaGalleryViewTableTable(this);
  late final $MangaLibraryItemTableTable mangaLibraryItemTable =
      $MangaLibraryItemTableTable(this);
  late final $LocalAnimeGalleryViewTableTable localAnimeGalleryViewTable =
      $LocalAnimeGalleryViewTableTable(this);
  late final $LocalMangaConcreteViewTableTable localMangaConcreteViewTable =
      $LocalMangaConcreteViewTableTable(this);
  late final $LocalChaptersGroupTableTable localChaptersGroupTable =
      $LocalChaptersGroupTableTable(this);
  late final $LocalChapterTableTable localChapterTable =
      $LocalChapterTableTable(this);
  late final $LocalPagesTableTable localPagesTable =
      $LocalPagesTableTable(this);
  late final $LocalPageTableTable localPageTable = $LocalPageTableTable(this);
  late final $AnimeLibraryItemTableTable animeLibraryItemTable =
      $AnimeLibraryItemTableTable(this);
  late final $LocalAnimeConcreteViewTableTable localAnimeConcreteViewTable =
      $LocalAnimeConcreteViewTableTable(this);
  late final $LocalAnimeVideosGroupTableTable localAnimeVideosGroupTable =
      $LocalAnimeVideosGroupTableTable(this);
  late final $LocalAnimeVideoTableTable localAnimeVideoTable =
      $LocalAnimeVideoTableTable(this);
  late final $LocalConfigsSourcesTableTable localConfigsSourcesTable =
      $LocalConfigsSourcesTableTable(this);
  late final $PagesReadTableTable pagesReadTable = $PagesReadTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localProtectorConfigTable,
        localConfigInfoTable,
        localApiSourceTable,
        localMangaGalleryViewTable,
        mangaLibraryItemTable,
        localAnimeGalleryViewTable,
        localMangaConcreteViewTable,
        localChaptersGroupTable,
        localChapterTable,
        localPagesTable,
        localPageTable,
        animeLibraryItemTable,
        localAnimeConcreteViewTable,
        localAnimeVideosGroupTable,
        localAnimeVideoTable,
        localConfigsSourcesTable,
        pagesReadTable
      ];
}
