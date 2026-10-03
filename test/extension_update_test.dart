import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';

ConfigInfo _config(String uid, {int version = 1, List<GalleryFilter>? filters}) =>
    ConfigInfo(
      uid: uid,
      name: 'Source $uid',
      logoUrl: '',
      nsfw: false,
      language: 'English',
      version: version,
      filters: filters ?? const [],
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
    );

class _FakeConfigsService implements ConfigsService {
  _FakeConfigsService(this.configs, this.scripts);

  final List<RemoteConfig> configs;
  final Map<String, String> scripts;
  final List<String> downloaded = <String>[];

  @override
  Future<List<BaseExtension>> getMangaConfigs() async => configs;

  @override
  Future<List<BaseExtension>> getAnimeConfigs() async => const [];

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    downloaded.add(path);
    return RemoteScript(path: path, script: scripts[path]!);
  }

  @override
  void invalidate() {}
}

void main() {
  late WakaranaiDatabase database;
  late ExtensionRepository extensions;

  setUp(() {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    extensions = ExtensionRepository(database: database);
  });

  tearDown(() => database.close());

  Future<void> install(String uid, String script,
      {String? revision, int version = 1}) async {
    await extensions.createUpdateByUid(ExtensionDomain(
      id: 0,
      config: _config(uid, version: version),
      sourceCode: script,
      revision: revision,
      createdAt: DateTime.now(),
    ));
  }

  ExtensionResolver resolver(ConfigsService service) => ExtensionResolver(
        extensionRepository: extensions,
        extensionSourceRepository: ExtensionSourceRepository(database: database),
        candidateServices: () async => <ConfigsService>[service],
      );

  test('refreshes installed extensions whose revision changed', () async {
    await install('a', 'old a');
    await install('b', 'old b', revision: 'r1');
    await install('c', 'old c', revision: 'same');
    final service = _FakeConfigsService(<RemoteConfig>[
      RemoteConfig(path: 'manga/a', config: _config('a'), revision: 'r2'),
      RemoteConfig(path: 'manga/b', config: _config('b'), revision: 'r2'),
      RemoteConfig(path: 'manga/c', config: _config('c'), revision: 'same'),
      RemoteConfig(path: 'manga/d', config: _config('d'), revision: 'r1'),
    ], <String, String>{'manga/a': 'new a', 'manga/b': 'new b'});

    expect(await resolver(service).refreshOutdated(), 2);

    expect((await extensions.getByUid('a'))!.sourceCode, 'new a');
    expect((await extensions.getByUid('a'))!.revision, 'r2');
    expect((await extensions.getByUid('b'))!.sourceCode, 'new b');
    expect((await extensions.getByUid('c'))!.sourceCode, 'old c');
    expect(await extensions.getByUid('d'), isNull);
    expect(service.downloaded, <String>['manga/a', 'manga/b']);

    expect(await resolver(service).refreshOutdated(), 0);
  });

  test('falls back to the version when a source has no revisions', () async {
    await install('a', 'old a', version: 1);
    await install('b', 'old b', version: 3);
    final service = _FakeConfigsService(<RemoteConfig>[
      RemoteConfig(path: 'manga/a', config: _config('a', version: 2)),
      RemoteConfig(path: 'manga/b', config: _config('b', version: 3)),
    ], <String, String>{'manga/a': 'new a'});

    expect(await resolver(service).refreshOutdated(), 1);
    expect((await extensions.getByUid('a'))!.config.version, 2);
    expect((await extensions.getByUid('b'))!.sourceCode, 'old b');
  });

  test('installed extensions keep their filters', () async {
    final filter = GalleryFilterSwitcher(
      type: GalleryFilterType.SWITCHER,
      param: 'adult',
      paramName: 'Adult',
      onValue: '1',
      offValue: '0',
    );
    await extensions.createUpdateByUid(ExtensionDomain(
      id: 0,
      config: _config('a', filters: <GalleryFilter>[filter]),
      sourceCode: 'script',
      createdAt: DateTime.now(),
    ));

    final ExtensionDomain stored = (await extensions.getByUid('a'))!;

    expect(stored.config.filters.single, isA<GalleryFilterSwitcher>());
    expect(stored.config.filters.single.param, 'adult');
  });
}
