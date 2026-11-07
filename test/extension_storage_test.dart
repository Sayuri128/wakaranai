import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_storage_repository.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/extension_preferences/extension_host_services.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';

ConfigInfo _config(String uid) => ConfigInfo.fromJson(<String, dynamic>{
      'name': 'Test',
      'uid': uid,
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
    });

void main() {
  late WakaranaiDatabase database;
  late DateTime now;
  late ExtensionStorageRepository repository;

  setUp(() {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    now = DateTime(2026, 1, 1, 12);
    repository = ExtensionStorageRepository(
      database: database,
      clock: () => now,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> rowCount() async {
    return (await database.select(database.extensionStorageTable).get())
        .length;
  }

  test('values persist without a ttl and overwrite in place', () async {
    await repository.write('ext-a', 'token', '"one"');
    await repository.write('ext-a', 'token', '"two"');
    now = now.add(const Duration(days: 365));

    expect(await repository.read('ext-a', 'token'), '"two"');
    expect(await rowCount(), 1);
  });

  test('expired entries read as null and are removed', () async {
    await repository.write(
      'ext-a',
      'token',
      '"abc"',
      ttl: const Duration(seconds: 30),
    );

    now = now.add(const Duration(seconds: 29));
    expect(await repository.read('ext-a', 'token'), '"abc"');
    expect(await repository.countEntries('ext-a'), 1);

    now = now.add(const Duration(seconds: 1));
    expect(await repository.countEntries('ext-a'), 0);
    expect(await repository.read('ext-a', 'token'), isNull);
    expect(await rowCount(), 0);
  });

  test('rewriting without a ttl clears an earlier expiry', () async {
    await repository.write('ext-a', 'k', '1', ttl: const Duration(seconds: 1));
    await repository.write('ext-a', 'k', '2');
    now = now.add(const Duration(hours: 1));

    expect(await repository.read('ext-a', 'k'), '2');
  });

  test('pruning removes only expired entries', () async {
    await repository.write('ext-a', 'short', '1',
        ttl: const Duration(minutes: 1));
    await repository.write('ext-a', 'long', '2', ttl: const Duration(days: 1));
    await repository.write('ext-b', 'forever', '3');

    now = now.add(const Duration(hours: 1));
    expect(await repository.pruneExpired(), 1);

    expect(await repository.read('ext-a', 'long'), '2');
    expect(await repository.read('ext-b', 'forever'), '3');
    expect(await rowCount(), 2);
  });

  test('entries are isolated per extension and cleared per extension',
      () async {
    await repository.write('ext-a', 'token', 'a');
    await repository.write('ext-b', 'token', 'b');

    expect(await repository.read('ext-a', 'token'), 'a');
    expect(await repository.read('ext-b', 'token'), 'b');

    await repository.remove('ext-a', 'token');
    expect(await repository.read('ext-a', 'token'), isNull);
    expect(await repository.read('ext-b', 'token'), 'b');

    await repository.write('ext-a', 'one', '1');
    await repository.write('ext-a', 'two', '2');
    expect(await repository.clearExtension('ext-a'), 2);
    expect(await repository.read('ext-b', 'token'), 'b');
  });

  test('the host storage is scoped to the extension uid', () async {
    final ApiClientFactory factory = ApiClientFactory(
      hostFactory: ExtensionHostFactory(storageRepository: repository),
    );
    final ExtensionStorage storageA =
        factory.manga(config: _config('ext-a'), code: '').host.storage;
    final ExtensionStorage storageB =
        factory.manga(config: _config('ext-b'), code: '').host.storage;

    await storageA.write('session', '"x"', ttl: const Duration(minutes: 5));

    expect(await storageA.read('session'), '"x"');
    expect(await storageB.read('session'), isNull);

    now = now.add(const Duration(minutes: 5));
    expect(await storageA.read('session'), isNull);
  });

  test('without a repository the host falls back to no-op storage', () {
    final ExtensionHost host =
        ApiClientFactory().manga(config: _config('ext-a'), code: '').host;

    expect(host.storage, isA<NoopExtensionStorage>());
    expect(host.preferences, isA<NoopExtensionPreferencesProvider>());
  });

  test('forgetting an extension clears its storage and preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ExtensionPreferencesStore preferences = ExtensionPreferencesStore();
    await preferences.write('ext-a', 'lang', 'ja');
    await preferences.write('ext-b', 'lang', 'en');
    await repository.write('ext-a', 'token', 'a');
    await repository.write('ext-b', 'token', 'b');

    final ExtensionDataCleaner cleaner = ExtensionDataCleaner(
      storageRepository: repository,
      preferenceStore: preferences,
    );

    await cleaner.clearStorage('ext-b');
    expect(await repository.read('ext-b', 'token'), isNull);
    expect(await preferences.readAll('ext-b'), <String, Object>{'lang': 'en'});

    await cleaner.forgetExtension('ext-a');
    expect(await repository.read('ext-a', 'token'), isNull);
    expect(await preferences.readAll('ext-a'), isEmpty);
    expect(await preferences.readAll('ext-b'), <String, Object>{'lang': 'en'});
  });
}
