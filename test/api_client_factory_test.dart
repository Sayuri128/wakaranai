import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/audio_api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/configs_service/extension_client_lifecycle.dart';

ConfigInfo _config(int type) => ConfigInfo.fromJson(<String, dynamic>{
      'name': 'Test',
      'uid': 'ext-uid',
      'logoUrl': '',
      'type': type,
      'nsfw': false,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
      'preferences': <dynamic>[
        <String, dynamic>{'key': 'lang', 'type': 'text', 'title': 'Language'},
      ],
      'requestPolicy': <String, dynamic>{'userAgent': 'UA'},
      'pagination': <String, dynamic>{
        'pageSizes': <int>[24, 48],
        'defaultPageSize': 48,
      },
    });

void main() {
  test('builds the client type the config declares', () {
    final ApiClientFactory factory = ApiClientFactory();

    expect(factory.create(config: _config(0), code: ''), isA<MangaApiClient>());
    expect(factory.create(config: _config(1), code: ''), isA<AnimeApiClient>());
    expect(factory.create(config: _config(2), code: ''), isA<NovelApiClient>());
    expect(factory.create(config: _config(3), code: ''), isA<AudioApiClient>());
  });

  test('hands the extension identity, preferences and policy to the host', () {
    final MangaApiClient client =
        ApiClientFactory().manga(config: _config(0), code: '');

    expect(client.host.extensionUid, 'ext-uid');
    expect(client.host.preferenceDefinitions.single.key, 'lang');
    expect(client.host.requestPolicy?.userAgent, 'UA');
    expect(client.host.pagination?.pageSizes, <int>[24, 48]);
    expect(client.host.pagination?.defaultPageSize, 48);
    expect(client.interpreter.host, same(client.host));
  });

  test('resetting an extension reruns onInit on every live client', () async {
    const String code = '''
      import "dependencies";
      function onInit() {
        provide("generation", isProvided("generation"));
      }
      function getConcrete(uid, data) {
        return inject("generation");
      }
    ''';
    final ApiClientFactory factory = ApiClientFactory();
    final MangaApiClient first = factory.manga(config: _config(0), code: code);
    final MangaApiClient second =
        factory.create(config: _config(0), code: code) as MangaApiClient;
    await first.interpreter.runFunction('getConcrete',
        arguments: <String, dynamic>{'uid': '', 'data': <String, dynamic>{}});
    await second.interpreter.initialize();
    first.interpreter.dependencies.provide('extra', 1);
    second.interpreter.dependencies.provide('extra', 1);

    expect(ExtensionClientLifecycle.instance.reset('ext-uid'),
        greaterThanOrEqualTo(2));

    expect(first.interpreter.dependencies.isProvided('extra'), isFalse);
    expect(second.interpreter.dependencies.isProvided('extra'), isFalse);
    expect(
        await first.interpreter.runFunction('getConcrete',
            arguments: <String, dynamic>{'uid': '', 'data': <String, dynamic>{}}),
        isFalse);
  });

  test('resetting an extension without live clients does nothing', () {
    expect(ExtensionClientLifecycle.instance.reset('never-created'), 0);
  });
}
