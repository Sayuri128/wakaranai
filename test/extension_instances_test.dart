import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/extension_instances.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';

ConfigInfo _config({String version = '1', String? sessionGroup}) {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': 'Komga',
    'uid': 'base-uid',
    'logoUrl': '',
    'type': 0,
    'nsfw': false,
    'language': 'Multi',
    'version': int.parse(version),
    'filters': <dynamic>[],
    'searchAvailable': true,
    'multiInstance': true,
    if (sessionGroup != null)
      'protectorConfig': <String, dynamic>{
        'pingUrl': 'https://x',
        'needToLogin': true,
        'inAppBrowserInterceptor': false,
        'sessionGroup': sessionGroup,
      },
  });
}

class _FakeConfigs implements ConfigsService {
  _FakeConfigs(this.remote, this.script);

  final RemoteConfig remote;
  final String script;

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async => <RemoteConfig>[remote];

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async => <RemoteConfig>[];

  @override
  Future<List<RemoteConfig>> getNovelConfigs() async => <RemoteConfig>[];

  @override
  Future<List<RemoteConfig>> getAudioConfigs() async => <RemoteConfig>[];

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    return RemoteScript(path: path, script: script);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late WakaranaiDatabase database;
  late ExtensionRepository repository;
  late ExtensionInstances instances;

  setUp(() {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    repository = ExtensionRepository(database: database);
    instances = ExtensionInstances(repository: repository);
  });

  tearDown(() => database.close());

  test('an instance gets its own uid, name and session group', () async {
    final ExtensionDomain? created = await instances.create(
      base: _config(sessionGroup: 'shared'),
      revision: 'r1',
      name: 'Komga Home',
      script: () async => 'script',
    );
    expect(created, isNotNull);
    expect(created!.config.uid, isNot('base-uid'));
    expect(created.config.name, 'Komga Home');
    expect(created.baseUid, 'base-uid');
    expect(created.config.protectorConfig?.sessionGroup,
        'shared#${created.config.uid}');
    expect((await instances.of('base-uid')).single.config.uid,
        created.config.uid);
  });

  test('suggests the next free numbered name', () async {
    expect(await instances.nextName(_config()), 'Komga 2');
    await instances.create(
      base: _config(),
      revision: 'r1',
      name: 'Komga 2',
      script: () async => 'script',
    );
    expect(await instances.nextName(_config()), 'Komga 3');
  });

  test('renaming keeps the uid', () async {
    final ExtensionDomain created = (await instances.create(
      base: _config(),
      revision: 'r1',
      name: 'Komga 2',
      script: () async => 'script',
    ))!;
    final ExtensionDomain? renamed = await instances.rename(created, 'Work');
    expect(renamed?.config.uid, created.config.uid);
    expect(renamed?.config.name, 'Work');
    expect(renamed?.baseUid, 'base-uid');
  });

  test('updates of the original reach its instances', () async {
    final ExtensionDomain created = (await instances.create(
      base: _config(),
      revision: 'r1',
      name: 'Komga Home',
      script: () async => 'old script',
    ))!;
    final RemoteConfig remote = RemoteConfig(
      path: 'manga/komga',
      revision: 'r2',
      config: _config(version: '2'),
    );
    final ExtensionResolver resolver = ExtensionResolver(
      extensionRepository: repository,
      extensionSourceRepository: ExtensionSourceRepository(database: database),
      candidateServices: () async => <ConfigsService>[
        _FakeConfigs(remote, 'new script'),
      ],
    );

    expect(await resolver.refreshOutdated(), 1);
    final ExtensionDomain? updated =
        await repository.getByUid(created.config.uid);
    expect(updated?.sourceCode, 'new script');
    expect(updated?.revision, 'r2');
    expect(updated?.config.version, 2);
    expect(updated?.config.name, 'Komga Home');
    expect(updated?.baseUid, 'base-uid');
  });
}
