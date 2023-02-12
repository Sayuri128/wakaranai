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
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pingUrl, needToLogin, inAppBrowserInterceptor, created];
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
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
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
      pingUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ping_url'])!,
      needToLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}need_to_login'])!,
      inAppBrowserInterceptor: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}in_app_browser_interceptor'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
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
  final String pingUrl;
  final bool needToLogin;
  final bool inAppBrowserInterceptor;
  final DateTime created;
  const DriftLocalProtectorConfig(
      {required this.id,
      required this.pingUrl,
      required this.needToLogin,
      required this.inAppBrowserInterceptor,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ping_url'] = Variable<String>(pingUrl);
    map['need_to_login'] = Variable<bool>(needToLogin);
    map['in_app_browser_interceptor'] = Variable<bool>(inAppBrowserInterceptor);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalProtectorConfigTableCompanion toCompanion(bool nullToAbsent) {
    return LocalProtectorConfigTableCompanion(
      id: Value(id),
      pingUrl: Value(pingUrl),
      needToLogin: Value(needToLogin),
      inAppBrowserInterceptor: Value(inAppBrowserInterceptor),
      created: Value(created),
    );
  }

  factory DriftLocalProtectorConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalProtectorConfig(
      id: serializer.fromJson<int>(json['id']),
      pingUrl: serializer.fromJson<String>(json['pingUrl']),
      needToLogin: serializer.fromJson<bool>(json['needToLogin']),
      inAppBrowserInterceptor:
          serializer.fromJson<bool>(json['inAppBrowserInterceptor']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pingUrl': serializer.toJson<String>(pingUrl),
      'needToLogin': serializer.toJson<bool>(needToLogin),
      'inAppBrowserInterceptor':
          serializer.toJson<bool>(inAppBrowserInterceptor),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalProtectorConfig copyWith(
          {int? id,
          String? pingUrl,
          bool? needToLogin,
          bool? inAppBrowserInterceptor,
          DateTime? created}) =>
      DriftLocalProtectorConfig(
        id: id ?? this.id,
        pingUrl: pingUrl ?? this.pingUrl,
        needToLogin: needToLogin ?? this.needToLogin,
        inAppBrowserInterceptor:
            inAppBrowserInterceptor ?? this.inAppBrowserInterceptor,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalProtectorConfig(')
          ..write('id: $id, ')
          ..write('pingUrl: $pingUrl, ')
          ..write('needToLogin: $needToLogin, ')
          ..write('inAppBrowserInterceptor: $inAppBrowserInterceptor, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pingUrl, needToLogin, inAppBrowserInterceptor, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalProtectorConfig &&
          other.id == this.id &&
          other.pingUrl == this.pingUrl &&
          other.needToLogin == this.needToLogin &&
          other.inAppBrowserInterceptor == this.inAppBrowserInterceptor &&
          other.created == this.created);
}

class LocalProtectorConfigTableCompanion
    extends UpdateCompanion<DriftLocalProtectorConfig> {
  final Value<int> id;
  final Value<String> pingUrl;
  final Value<bool> needToLogin;
  final Value<bool> inAppBrowserInterceptor;
  final Value<DateTime> created;
  const LocalProtectorConfigTableCompanion({
    this.id = const Value.absent(),
    this.pingUrl = const Value.absent(),
    this.needToLogin = const Value.absent(),
    this.inAppBrowserInterceptor = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalProtectorConfigTableCompanion.insert({
    this.id = const Value.absent(),
    required String pingUrl,
    required bool needToLogin,
    required bool inAppBrowserInterceptor,
    this.created = const Value.absent(),
  })  : pingUrl = Value(pingUrl),
        needToLogin = Value(needToLogin),
        inAppBrowserInterceptor = Value(inAppBrowserInterceptor);
  static Insertable<DriftLocalProtectorConfig> custom({
    Expression<int>? id,
    Expression<String>? pingUrl,
    Expression<bool>? needToLogin,
    Expression<bool>? inAppBrowserInterceptor,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pingUrl != null) 'ping_url': pingUrl,
      if (needToLogin != null) 'need_to_login': needToLogin,
      if (inAppBrowserInterceptor != null)
        'in_app_browser_interceptor': inAppBrowserInterceptor,
      if (created != null) 'created': created,
    });
  }

  LocalProtectorConfigTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? pingUrl,
      Value<bool>? needToLogin,
      Value<bool>? inAppBrowserInterceptor,
      Value<DateTime>? created}) {
    return LocalProtectorConfigTableCompanion(
      id: id ?? this.id,
      pingUrl: pingUrl ?? this.pingUrl,
      needToLogin: needToLogin ?? this.needToLogin,
      inAppBrowserInterceptor:
          inAppBrowserInterceptor ?? this.inAppBrowserInterceptor,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProtectorConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('pingUrl: $pingUrl, ')
          ..write('needToLogin: $needToLogin, ')
          ..write('inAppBrowserInterceptor: $inAppBrowserInterceptor, ')
          ..write('created: $created')
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
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uid,
        name,
        logoUrl,
        language,
        nsfw,
        version,
        localProtectorConfigId,
        searchAvailable,
        created
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
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
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
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      localProtectorConfigId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_protector_config_id']),
      searchAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}search_available'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
    );
  }

  @override
  $LocalConfigInfoTableTable createAlias(String alias) {
    return $LocalConfigInfoTableTable(attachedDatabase, alias);
  }
}

class DriftLocalConfigInfo extends DataClass
    implements Insertable<DriftLocalConfigInfo> {
  final int id;
  final String uid;
  final String name;
  final String logoUrl;
  final String language;
  final bool nsfw;
  final int version;
  final int? localProtectorConfigId;
  final bool searchAvailable;
  final DateTime created;
  const DriftLocalConfigInfo(
      {required this.id,
      required this.uid,
      required this.name,
      required this.logoUrl,
      required this.language,
      required this.nsfw,
      required this.version,
      this.localProtectorConfigId,
      required this.searchAvailable,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['logo_url'] = Variable<String>(logoUrl);
    map['language'] = Variable<String>(language);
    map['nsfw'] = Variable<bool>(nsfw);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || localProtectorConfigId != null) {
      map['local_protector_config_id'] = Variable<int>(localProtectorConfigId);
    }
    map['search_available'] = Variable<bool>(searchAvailable);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalConfigInfoTableCompanion toCompanion(bool nullToAbsent) {
    return LocalConfigInfoTableCompanion(
      id: Value(id),
      uid: Value(uid),
      name: Value(name),
      logoUrl: Value(logoUrl),
      language: Value(language),
      nsfw: Value(nsfw),
      version: Value(version),
      localProtectorConfigId: localProtectorConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(localProtectorConfigId),
      searchAvailable: Value(searchAvailable),
      created: Value(created),
    );
  }

  factory DriftLocalConfigInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalConfigInfo(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String>(json['logoUrl']),
      language: serializer.fromJson<String>(json['language']),
      nsfw: serializer.fromJson<bool>(json['nsfw']),
      version: serializer.fromJson<int>(json['version']),
      localProtectorConfigId:
          serializer.fromJson<int?>(json['localProtectorConfigId']),
      searchAvailable: serializer.fromJson<bool>(json['searchAvailable']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String>(logoUrl),
      'language': serializer.toJson<String>(language),
      'nsfw': serializer.toJson<bool>(nsfw),
      'version': serializer.toJson<int>(version),
      'localProtectorConfigId': serializer.toJson<int?>(localProtectorConfigId),
      'searchAvailable': serializer.toJson<bool>(searchAvailable),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalConfigInfo copyWith(
          {int? id,
          String? uid,
          String? name,
          String? logoUrl,
          String? language,
          bool? nsfw,
          int? version,
          Value<int?> localProtectorConfigId = const Value.absent(),
          bool? searchAvailable,
          DateTime? created}) =>
      DriftLocalConfigInfo(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        language: language ?? this.language,
        nsfw: nsfw ?? this.nsfw,
        version: version ?? this.version,
        localProtectorConfigId: localProtectorConfigId.present
            ? localProtectorConfigId.value
            : this.localProtectorConfigId,
        searchAvailable: searchAvailable ?? this.searchAvailable,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalConfigInfo(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('version: $version, ')
          ..write('localProtectorConfigId: $localProtectorConfigId, ')
          ..write('searchAvailable: $searchAvailable, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uid, name, logoUrl, language, nsfw,
      version, localProtectorConfigId, searchAvailable, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalConfigInfo &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.language == this.language &&
          other.nsfw == this.nsfw &&
          other.version == this.version &&
          other.localProtectorConfigId == this.localProtectorConfigId &&
          other.searchAvailable == this.searchAvailable &&
          other.created == this.created);
}

class LocalConfigInfoTableCompanion
    extends UpdateCompanion<DriftLocalConfigInfo> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> name;
  final Value<String> logoUrl;
  final Value<String> language;
  final Value<bool> nsfw;
  final Value<int> version;
  final Value<int?> localProtectorConfigId;
  final Value<bool> searchAvailable;
  final Value<DateTime> created;
  const LocalConfigInfoTableCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.language = const Value.absent(),
    this.nsfw = const Value.absent(),
    this.version = const Value.absent(),
    this.localProtectorConfigId = const Value.absent(),
    this.searchAvailable = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalConfigInfoTableCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String name,
    required String logoUrl,
    required String language,
    required bool nsfw,
    required int version,
    this.localProtectorConfigId = const Value.absent(),
    required bool searchAvailable,
    this.created = const Value.absent(),
  })  : uid = Value(uid),
        name = Value(name),
        logoUrl = Value(logoUrl),
        language = Value(language),
        nsfw = Value(nsfw),
        version = Value(version),
        searchAvailable = Value(searchAvailable);
  static Insertable<DriftLocalConfigInfo> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? language,
    Expression<bool>? nsfw,
    Expression<int>? version,
    Expression<int>? localProtectorConfigId,
    Expression<bool>? searchAvailable,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (language != null) 'language': language,
      if (nsfw != null) 'nsfw': nsfw,
      if (version != null) 'version': version,
      if (localProtectorConfigId != null)
        'local_protector_config_id': localProtectorConfigId,
      if (searchAvailable != null) 'search_available': searchAvailable,
      if (created != null) 'created': created,
    });
  }

  LocalConfigInfoTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? uid,
      Value<String>? name,
      Value<String>? logoUrl,
      Value<String>? language,
      Value<bool>? nsfw,
      Value<int>? version,
      Value<int?>? localProtectorConfigId,
      Value<bool>? searchAvailable,
      Value<DateTime>? created}) {
    return LocalConfigInfoTableCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      language: language ?? this.language,
      nsfw: nsfw ?? this.nsfw,
      version: version ?? this.version,
      localProtectorConfigId:
          localProtectorConfigId ?? this.localProtectorConfigId,
      searchAvailable: searchAvailable ?? this.searchAvailable,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConfigInfoTableCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('language: $language, ')
          ..write('nsfw: $nsfw, ')
          ..write('version: $version, ')
          ..write('localProtectorConfigId: $localProtectorConfigId, ')
          ..write('searchAvailable: $searchAvailable, ')
          ..write('created: $created')
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<LocalApiClientType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<LocalApiClientType>(
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
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, type, localConfigInfoId, created];
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
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
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
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      type: $LocalApiSourceTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      localConfigInfoId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_config_info_id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
    );
  }

  @override
  $LocalApiSourceTableTable createAlias(String alias) {
    return $LocalApiSourceTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalApiClientType, int, int> $convertertype =
      const EnumIndexConverter<LocalApiClientType>(LocalApiClientType.values);
}

class DriftLocalApiSource extends DataClass
    implements Insertable<DriftLocalApiSource> {
  final int id;
  final String code;
  final LocalApiClientType type;
  final int localConfigInfoId;
  final DateTime created;
  const DriftLocalApiSource(
      {required this.id,
      required this.code,
      required this.type,
      required this.localConfigInfoId,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    {
      final converter = $LocalApiSourceTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['local_config_info_id'] = Variable<int>(localConfigInfoId);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalApiSourceTableCompanion toCompanion(bool nullToAbsent) {
    return LocalApiSourceTableCompanion(
      id: Value(id),
      code: Value(code),
      type: Value(type),
      localConfigInfoId: Value(localConfigInfoId),
      created: Value(created),
    );
  }

  factory DriftLocalApiSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalApiSource(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      type: $LocalApiSourceTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      localConfigInfoId: serializer.fromJson<int>(json['localConfigInfoId']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'type': serializer
          .toJson<int>($LocalApiSourceTableTable.$convertertype.toJson(type)),
      'localConfigInfoId': serializer.toJson<int>(localConfigInfoId),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalApiSource copyWith(
          {int? id,
          String? code,
          LocalApiClientType? type,
          int? localConfigInfoId,
          DateTime? created}) =>
      DriftLocalApiSource(
        id: id ?? this.id,
        code: code ?? this.code,
        type: type ?? this.type,
        localConfigInfoId: localConfigInfoId ?? this.localConfigInfoId,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalApiSource(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('localConfigInfoId: $localConfigInfoId, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, type, localConfigInfoId, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalApiSource &&
          other.id == this.id &&
          other.code == this.code &&
          other.type == this.type &&
          other.localConfigInfoId == this.localConfigInfoId &&
          other.created == this.created);
}

class LocalApiSourceTableCompanion
    extends UpdateCompanion<DriftLocalApiSource> {
  final Value<int> id;
  final Value<String> code;
  final Value<LocalApiClientType> type;
  final Value<int> localConfigInfoId;
  final Value<DateTime> created;
  const LocalApiSourceTableCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.type = const Value.absent(),
    this.localConfigInfoId = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalApiSourceTableCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required LocalApiClientType type,
    required int localConfigInfoId,
    this.created = const Value.absent(),
  })  : code = Value(code),
        type = Value(type),
        localConfigInfoId = Value(localConfigInfoId);
  static Insertable<DriftLocalApiSource> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<int>? type,
    Expression<int>? localConfigInfoId,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (type != null) 'type': type,
      if (localConfigInfoId != null) 'local_config_info_id': localConfigInfoId,
      if (created != null) 'created': created,
    });
  }

  LocalApiSourceTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<LocalApiClientType>? type,
      Value<int>? localConfigInfoId,
      Value<DateTime>? created}) {
    return LocalApiSourceTableCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      localConfigInfoId: localConfigInfoId ?? this.localConfigInfoId,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalApiSourceTableCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('localConfigInfoId: $localConfigInfoId, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }
}

class $LibraryItemTableTable extends LibraryItemTable
    with TableInfo<$LibraryItemTableTable, DriftLibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _localApiClientIdMeta =
      const VerificationMeta('localApiClientId');
  @override
  late final GeneratedColumn<int> localApiClientId = GeneratedColumn<int>(
      'local_api_client_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_api_source_table (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<LocalApiClientType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<LocalApiClientType>(
              $LibraryItemTableTable.$convertertype);
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, localApiClientId, type, created];
  @override
  String get aliasedName => _alias ?? 'library_item_table';
  @override
  String get actualTableName => 'library_item_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftLibraryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_api_client_id')) {
      context.handle(
          _localApiClientIdMeta,
          localApiClientId.isAcceptableOrUnknown(
              data['local_api_client_id']!, _localApiClientIdMeta));
    } else if (isInserting) {
      context.missing(_localApiClientIdMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftLibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftLibraryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      localApiClientId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_api_client_id'])!,
      type: $LibraryItemTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
    );
  }

  @override
  $LibraryItemTableTable createAlias(String alias) {
    return $LibraryItemTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalApiClientType, int, int> $convertertype =
      const EnumIndexConverter<LocalApiClientType>(LocalApiClientType.values);
}

class DriftLibraryItem extends DataClass
    implements Insertable<DriftLibraryItem> {
  final int id;
  final int localApiClientId;
  final LocalApiClientType type;
  final DateTime created;
  const DriftLibraryItem(
      {required this.id,
      required this.localApiClientId,
      required this.type,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_api_client_id'] = Variable<int>(localApiClientId);
    {
      final converter = $LibraryItemTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LibraryItemTableCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemTableCompanion(
      id: Value(id),
      localApiClientId: Value(localApiClientId),
      type: Value(type),
      created: Value(created),
    );
  }

  factory DriftLibraryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLibraryItem(
      id: serializer.fromJson<int>(json['id']),
      localApiClientId: serializer.fromJson<int>(json['localApiClientId']),
      type: $LibraryItemTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localApiClientId': serializer.toJson<int>(localApiClientId),
      'type': serializer
          .toJson<int>($LibraryItemTableTable.$convertertype.toJson(type)),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLibraryItem copyWith(
          {int? id,
          int? localApiClientId,
          LocalApiClientType? type,
          DateTime? created}) =>
      DriftLibraryItem(
        id: id ?? this.id,
        localApiClientId: localApiClientId ?? this.localApiClientId,
        type: type ?? this.type,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLibraryItem(')
          ..write('id: $id, ')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('type: $type, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localApiClientId, type, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLibraryItem &&
          other.id == this.id &&
          other.localApiClientId == this.localApiClientId &&
          other.type == this.type &&
          other.created == this.created);
}

class LibraryItemTableCompanion extends UpdateCompanion<DriftLibraryItem> {
  final Value<int> id;
  final Value<int> localApiClientId;
  final Value<LocalApiClientType> type;
  final Value<DateTime> created;
  const LibraryItemTableCompanion({
    this.id = const Value.absent(),
    this.localApiClientId = const Value.absent(),
    this.type = const Value.absent(),
    this.created = const Value.absent(),
  });
  LibraryItemTableCompanion.insert({
    this.id = const Value.absent(),
    required int localApiClientId,
    required LocalApiClientType type,
    this.created = const Value.absent(),
  })  : localApiClientId = Value(localApiClientId),
        type = Value(type);
  static Insertable<DriftLibraryItem> custom({
    Expression<int>? id,
    Expression<int>? localApiClientId,
    Expression<int>? type,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localApiClientId != null) 'local_api_client_id': localApiClientId,
      if (type != null) 'type': type,
      if (created != null) 'created': created,
    });
  }

  LibraryItemTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? localApiClientId,
      Value<LocalApiClientType>? type,
      Value<DateTime>? created}) {
    return LibraryItemTableCompanion(
      id: id ?? this.id,
      localApiClientId: localApiClientId ?? this.localApiClientId,
      type: type ?? this.type,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localApiClientId.present) {
      map['local_api_client_id'] = Variable<int>(localApiClientId.value);
    }
    if (type.present) {
      final converter = $LibraryItemTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemTableCompanion(')
          ..write('id: $id, ')
          ..write('localApiClientId: $localApiClientId, ')
          ..write('type: $type, ')
          ..write('created: $created')
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
  static const VerificationMeta _libraryItemIdMeta =
      const VerificationMeta('libraryItemId');
  @override
  late final GeneratedColumn<int> libraryItemId = GeneratedColumn<int>(
      'library_item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES library_item_table (id)'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, uid, cover, title, data, libraryItemId, created];
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
    if (data.containsKey('library_item_id')) {
      context.handle(
          _libraryItemIdMeta,
          libraryItemId.isAcceptableOrUnknown(
              data['library_item_id']!, _libraryItemIdMeta));
    } else if (isInserting) {
      context.missing(_libraryItemIdMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
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
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      libraryItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}library_item_id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
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
  final String uid;
  final String cover;
  final String title;
  final String data;
  final int libraryItemId;
  final DateTime created;
  const DriftLocalMangaGalleryView(
      {required this.id,
      required this.uid,
      required this.cover,
      required this.title,
      required this.data,
      required this.libraryItemId,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['library_item_id'] = Variable<int>(libraryItemId);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalMangaGalleryViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalMangaGalleryViewTableCompanion(
      id: Value(id),
      uid: Value(uid),
      cover: Value(cover),
      title: Value(title),
      data: Value(data),
      libraryItemId: Value(libraryItemId),
      created: Value(created),
    );
  }

  factory DriftLocalMangaGalleryView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalMangaGalleryView(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      libraryItemId: serializer.fromJson<int>(json['libraryItemId']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'libraryItemId': serializer.toJson<int>(libraryItemId),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalMangaGalleryView copyWith(
          {int? id,
          String? uid,
          String? cover,
          String? title,
          String? data,
          int? libraryItemId,
          DateTime? created}) =>
      DriftLocalMangaGalleryView(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        data: data ?? this.data,
        libraryItemId: libraryItemId ?? this.libraryItemId,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalMangaGalleryView(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('libraryItemId: $libraryItemId, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uid, cover, title, data, libraryItemId, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalMangaGalleryView &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.data == this.data &&
          other.libraryItemId == this.libraryItemId &&
          other.created == this.created);
}

class LocalMangaGalleryViewTableCompanion
    extends UpdateCompanion<DriftLocalMangaGalleryView> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> data;
  final Value<int> libraryItemId;
  final Value<DateTime> created;
  const LocalMangaGalleryViewTableCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.libraryItemId = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalMangaGalleryViewTableCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String cover,
    required String title,
    required String data,
    required int libraryItemId,
    this.created = const Value.absent(),
  })  : uid = Value(uid),
        cover = Value(cover),
        title = Value(title),
        data = Value(data),
        libraryItemId = Value(libraryItemId);
  static Insertable<DriftLocalMangaGalleryView> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? libraryItemId,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (libraryItemId != null) 'library_item_id': libraryItemId,
      if (created != null) 'created': created,
    });
  }

  LocalMangaGalleryViewTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? uid,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? data,
      Value<int>? libraryItemId,
      Value<DateTime>? created}) {
    return LocalMangaGalleryViewTableCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      data: data ?? this.data,
      libraryItemId: libraryItemId ?? this.libraryItemId,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (libraryItemId.present) {
      map['library_item_id'] = Variable<int>(libraryItemId.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMangaGalleryViewTableCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('libraryItemId: $libraryItemId, ')
          ..write('created: $created')
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
  static const VerificationMeta _libraryItemIdMeta =
      const VerificationMeta('libraryItemId');
  @override
  late final GeneratedColumn<int> libraryItemId = GeneratedColumn<int>(
      'library_item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES library_item_table (id)'));
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, uid, cover, title, data, status, libraryItemId, created];
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
    if (data.containsKey('library_item_id')) {
      context.handle(
          _libraryItemIdMeta,
          libraryItemId.isAcceptableOrUnknown(
              data['library_item_id']!, _libraryItemIdMeta));
    } else if (isInserting) {
      context.missing(_libraryItemIdMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
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
      libraryItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}library_item_id'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
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
  final String uid;
  final String cover;
  final String title;
  final String data;
  final AnimeStatus status;
  final int libraryItemId;
  final DateTime created;
  const DriftLocalAnimeGalleryView(
      {required this.id,
      required this.uid,
      required this.cover,
      required this.title,
      required this.data,
      required this.status,
      required this.libraryItemId,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['cover'] = Variable<String>(cover);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    {
      final converter = $LocalAnimeGalleryViewTableTable.$converterstatus;
      map['status'] = Variable<int>(converter.toSql(status));
    }
    map['library_item_id'] = Variable<int>(libraryItemId);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalAnimeGalleryViewTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimeGalleryViewTableCompanion(
      id: Value(id),
      uid: Value(uid),
      cover: Value(cover),
      title: Value(title),
      data: Value(data),
      status: Value(status),
      libraryItemId: Value(libraryItemId),
      created: Value(created),
    );
  }

  factory DriftLocalAnimeGalleryView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalAnimeGalleryView(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      cover: serializer.fromJson<String>(json['cover']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      status: $LocalAnimeGalleryViewTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      libraryItemId: serializer.fromJson<int>(json['libraryItemId']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'cover': serializer.toJson<String>(cover),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'status': serializer.toJson<int>(
          $LocalAnimeGalleryViewTableTable.$converterstatus.toJson(status)),
      'libraryItemId': serializer.toJson<int>(libraryItemId),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalAnimeGalleryView copyWith(
          {int? id,
          String? uid,
          String? cover,
          String? title,
          String? data,
          AnimeStatus? status,
          int? libraryItemId,
          DateTime? created}) =>
      DriftLocalAnimeGalleryView(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        cover: cover ?? this.cover,
        title: title ?? this.title,
        data: data ?? this.data,
        status: status ?? this.status,
        libraryItemId: libraryItemId ?? this.libraryItemId,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalAnimeGalleryView(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('status: $status, ')
          ..write('libraryItemId: $libraryItemId, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uid, cover, title, data, status, libraryItemId, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalAnimeGalleryView &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.cover == this.cover &&
          other.title == this.title &&
          other.data == this.data &&
          other.status == this.status &&
          other.libraryItemId == this.libraryItemId &&
          other.created == this.created);
}

class LocalAnimeGalleryViewTableCompanion
    extends UpdateCompanion<DriftLocalAnimeGalleryView> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> cover;
  final Value<String> title;
  final Value<String> data;
  final Value<AnimeStatus> status;
  final Value<int> libraryItemId;
  final Value<DateTime> created;
  const LocalAnimeGalleryViewTableCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.cover = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.status = const Value.absent(),
    this.libraryItemId = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalAnimeGalleryViewTableCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String cover,
    required String title,
    required String data,
    required AnimeStatus status,
    required int libraryItemId,
    this.created = const Value.absent(),
  })  : uid = Value(uid),
        cover = Value(cover),
        title = Value(title),
        data = Value(data),
        status = Value(status),
        libraryItemId = Value(libraryItemId);
  static Insertable<DriftLocalAnimeGalleryView> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? cover,
    Expression<String>? title,
    Expression<String>? data,
    Expression<int>? status,
    Expression<int>? libraryItemId,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (cover != null) 'cover': cover,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (status != null) 'status': status,
      if (libraryItemId != null) 'library_item_id': libraryItemId,
      if (created != null) 'created': created,
    });
  }

  LocalAnimeGalleryViewTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? uid,
      Value<String>? cover,
      Value<String>? title,
      Value<String>? data,
      Value<AnimeStatus>? status,
      Value<int>? libraryItemId,
      Value<DateTime>? created}) {
    return LocalAnimeGalleryViewTableCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      data: data ?? this.data,
      status: status ?? this.status,
      libraryItemId: libraryItemId ?? this.libraryItemId,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (libraryItemId.present) {
      map['library_item_id'] = Variable<int>(libraryItemId.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimeGalleryViewTableCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('cover: $cover, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('status: $status, ')
          ..write('libraryItemId: $libraryItemId, ')
          ..write('created: $created')
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
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, baseUrl, name, type, created];
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
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
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
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $LocalConfigsSourcesTableTable.$convertertype.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
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
  final String baseUrl;
  final String name;
  final ConfigsSourceType type;
  final DateTime created;
  const DriftLocalConfigsSource(
      {required this.id,
      required this.baseUrl,
      required this.name,
      required this.type,
      required this.created});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_url'] = Variable<String>(baseUrl);
    map['name'] = Variable<String>(name);
    {
      final converter = $LocalConfigsSourcesTableTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  LocalConfigsSourcesTableCompanion toCompanion(bool nullToAbsent) {
    return LocalConfigsSourcesTableCompanion(
      id: Value(id),
      baseUrl: Value(baseUrl),
      name: Value(name),
      type: Value(type),
      created: Value(created),
    );
  }

  factory DriftLocalConfigsSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftLocalConfigsSource(
      id: serializer.fromJson<int>(json['id']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      name: serializer.fromJson<String>(json['name']),
      type: $LocalConfigsSourcesTableTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(
          $LocalConfigsSourcesTableTable.$convertertype.toJson(type)),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  DriftLocalConfigsSource copyWith(
          {int? id,
          String? baseUrl,
          String? name,
          ConfigsSourceType? type,
          DateTime? created}) =>
      DriftLocalConfigsSource(
        id: id ?? this.id,
        baseUrl: baseUrl ?? this.baseUrl,
        name: name ?? this.name,
        type: type ?? this.type,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('DriftLocalConfigsSource(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, baseUrl, name, type, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftLocalConfigsSource &&
          other.id == this.id &&
          other.baseUrl == this.baseUrl &&
          other.name == this.name &&
          other.type == this.type &&
          other.created == this.created);
}

class LocalConfigsSourcesTableCompanion
    extends UpdateCompanion<DriftLocalConfigsSource> {
  final Value<int> id;
  final Value<String> baseUrl;
  final Value<String> name;
  final Value<ConfigsSourceType> type;
  final Value<DateTime> created;
  const LocalConfigsSourcesTableCompanion({
    this.id = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.created = const Value.absent(),
  });
  LocalConfigsSourcesTableCompanion.insert({
    this.id = const Value.absent(),
    required String baseUrl,
    required String name,
    required ConfigsSourceType type,
    this.created = const Value.absent(),
  })  : baseUrl = Value(baseUrl),
        name = Value(name),
        type = Value(type);
  static Insertable<DriftLocalConfigsSource> custom({
    Expression<int>? id,
    Expression<String>? baseUrl,
    Expression<String>? name,
    Expression<int>? type,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseUrl != null) 'base_url': baseUrl,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (created != null) 'created': created,
    });
  }

  LocalConfigsSourcesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? baseUrl,
      Value<String>? name,
      Value<ConfigsSourceType>? type,
      Value<DateTime>? created}) {
    return LocalConfigsSourcesTableCompanion(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConfigsSourcesTableCompanion(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('created: $created')
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
  late final $LibraryItemTableTable libraryItemTable =
      $LibraryItemTableTable(this);
  late final $LocalMangaGalleryViewTableTable localMangaGalleryViewTable =
      $LocalMangaGalleryViewTableTable(this);
  late final $LocalAnimeGalleryViewTableTable localAnimeGalleryViewTable =
      $LocalAnimeGalleryViewTableTable(this);
  late final $LocalConfigsSourcesTableTable localConfigsSourcesTable =
      $LocalConfigsSourcesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localProtectorConfigTable,
        localConfigInfoTable,
        localApiSourceTable,
        libraryItemTable,
        localMangaGalleryViewTable,
        localAnimeGalleryViewTable,
        localConfigsSourcesTable
      ];
}
