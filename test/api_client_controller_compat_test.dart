import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

ConfigInfo _config({int version = 1, int apiVersion = 1}) => ConfigInfo(
      uid: 'a',
      name: 'Source a',
      logoUrl: '',
      nsfw: false,
      language: 'English',
      version: version,
      filters: const [],
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
      apiVersion: apiVersion,
    );

class _FakeConfigsService implements ConfigsService {
  final List<String> downloaded = <String>[];

  @override
  Future<List<BaseExtension>> getMangaConfigs() async => const [];

  @override
  Future<List<BaseExtension>> getAnimeConfigs() async => const [];

  @override
  Future<List<BaseExtension>> getNovelConfigs() async => const [];

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    downloaded.add(path);
    return RemoteScript(path: path, script: 'new script');
  }

  @override
  void invalidate() {}
}

class _FakeRemoteConfigsCubit extends RemoteConfigsCubit {
  _FakeRemoteConfigsCubit(
    this.service, {
    required super.extensionSourceRepository,
  });

  final ConfigsService service;

  @override
  ConfigsService get configService => service;
}

void main() {
  late WakaranaiDatabase database;
  late ExtensionRepository extensions;
  late _FakeConfigsService service;
  late _FakeRemoteConfigsCubit remoteConfigsCubit;

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'CURRENT_APP_VERSION=0.4.0');
    await S.load(const Locale('en'));
  });

  setUp(() {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    extensions = ExtensionRepository(database: database);
    service = _FakeConfigsService();
    remoteConfigsCubit = _FakeRemoteConfigsCubit(
      service,
      extensionSourceRepository: ExtensionSourceRepository(database: database),
    );
  });

  tearDown(() async {
    await remoteConfigsCubit.close();
    await database.close();
  });

  Future<ApiClientControllerState> build(RemoteConfig remote) async {
    final ApiClientControllerCubit<ApiClient, dynamic> cubit =
        ApiClientControllerCubit<ApiClient, dynamic>(
      extensionRepository: extensions,
      remoteConfig: remote,
      remoteConfigsCubit: remoteConfigsCubit,
    );
    await cubit.buildApiClient();
    final ApiClientControllerState state = cubit.state;
    await cubit.close();
    return state;
  }

  RemoteConfig incompatibleRemote() => RemoteConfig(
        path: 'manga/a',
        config: _config(version: 2, apiVersion: capyscriptApiVersion + 1),
        revision: 'r2',
      );

  test('refuses to download a source that needs a newer app', () async {
    final ApiClientControllerState state = await build(incompatibleRemote());

    expect(state, isA<ApiClientControllerRequiresNewerApp>());
    final ApiClientControllerRequiresNewerApp error =
        state as ApiClientControllerRequiresNewerApp;
    expect(error.message, S.current.compat_requires_newer_app);
    expect(error.compatibility.incompatibility,
        ExtensionIncompatibility.apiVersion);
    expect(service.downloaded, isEmpty);
    expect(await extensions.getByUid('a'), isNull);
  });

  test('keeps using the cached script and config when one exists', () async {
    await extensions.createUpdateByUid(ExtensionDomain(
      id: 0,
      config: _config(),
      sourceCode: 'old script',
      revision: 'r1',
      createdAt: DateTime.now(),
    ));

    final ApiClientControllerState state = await build(incompatibleRemote());

    expect(state, isA<ApiClientControllerInitialized>());
    final ConfigInfo used =
        (state as ApiClientControllerInitialized).configInfo;
    expect(used.version, 1);
    expect(used.apiVersion, 1);
    expect(service.downloaded, isEmpty);
    final ExtensionDomain cached = (await extensions.getByUid('a'))!;
    expect(cached.sourceCode, 'old script');
    expect(cached.revision, 'r1');
  });

  test('downloads and caches a compatible source', () async {
    final ApiClientControllerState state = await build(RemoteConfig(
      path: 'manga/a',
      config: _config(apiVersion: capyscriptApiVersion),
      revision: 'r1',
    ));

    expect(state, isA<ApiClientControllerInitialized>());
    expect(service.downloaded, <String>['manga/a']);
    expect((await extensions.getByUid('a'))!.sourceCode, 'new script');
  });
}
