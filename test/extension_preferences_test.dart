import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/extension_preferences/extension_preference_values.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';
import 'package:wakaranai/services/import_export/exported_preferences.dart';

const String _mirrorA = 'https://a.example.com';
const String _mirrorB = 'https://b.example.com';

ConfigInfo _config({String uid = 'ext-a', List<String> mirrors = const <String>[]}) {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': 'Test',
    'uid': uid,
    'logoUrl': '',
    'type': 0,
    'nsfw': false,
    'language': 'en',
    'version': 1,
    'filters': <dynamic>[],
    'searchAvailable': true,
    'preferences': <dynamic>[
      <String, dynamic>{
        'key': 'adult',
        'type': 'toggle',
        'title': 'Adult',
        'default': true,
      },
      <String, dynamic>{
        'key': 'lang',
        'type': 'select',
        'title': 'Language',
        'default': 'en',
        'options': <dynamic>[
          <String, dynamic>{'value': 'en', 'label': 'English'},
          <String, dynamic>{'value': 'ja', 'label': 'Japanese'},
        ],
      },
      <String, dynamic>{
        'key': 'genres',
        'type': 'multiselect',
        'title': 'Genres',
        'default': <String>['action'],
        'options': <dynamic>[
          <String, dynamic>{'value': 'action', 'label': 'Action'},
          <String, dynamic>{'value': 'drama', 'label': 'Drama'},
        ],
      },
      <String, dynamic>{
        'key': 'token',
        'type': 'text',
        'title': 'Token',
        'default': 'none',
      },
      <String, dynamic>{
        'key': 'pageSize',
        'type': 'number',
        'title': 'Page size',
        'default': 20,
      },
    ],
    'requestPolicy': <String, dynamic>{'mirrors': mirrors},
  });
}

ExtensionHost _host(ExtensionPreferencesStore store, ConfigInfo config) {
  return ApiClientFactory(
    hostFactory: ExtensionHostFactory(preferenceStore: store),
  ).manga(config: config, code: '').host;
}

void main() {
  late ExtensionPreferencesStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    store = ExtensionPreferencesStore();
  });

  test('unset preferences resolve to the declared defaults', () async {
    final ExtensionHost host = _host(store, _config());

    expect(await host.resolvePreference('adult'), true);
    expect(await host.resolvePreference('lang'), 'en');
    expect(await host.resolvePreference('genres'), <String>['action']);
    expect(await host.resolvePreference('token'), 'none');
    expect(await host.resolvePreference('pageSize'), 20);
    expect(await host.resolvePreference(ExtensionPreference.mirrorKey), isNull);
  });

  test('stored values of every type override the defaults', () async {
    final ConfigInfo config = _config(mirrors: <String>[_mirrorA, _mirrorB]);
    await store.write(config.uid, 'adult', false);
    await store.write(config.uid, 'lang', 'ja');
    await store.write(config.uid, 'genres', <String>['drama', 'action']);
    await store.write(config.uid, 'token', 'abc');
    await store.write(config.uid, 'pageSize', 2.5);
    await store.write(config.uid, ExtensionPreference.mirrorKey, _mirrorB);

    final ExtensionHost host = _host(store, config);

    expect(await host.resolvePreference('adult'), false);
    expect(await host.resolvePreference('lang'), 'ja');
    expect(await host.resolvePreference('genres'), <String>['drama', 'action']);
    expect(await host.resolvePreference('token'), 'abc');
    expect(await host.resolvePreference('pageSize'), 2.5);
    expect(
      await host.resolvePreference(ExtensionPreference.mirrorKey),
      _mirrorB,
    );
  });

  test('values that no longer fit the definition fall back to defaults',
      () async {
    final ConfigInfo config = _config(mirrors: <String>[_mirrorA]);
    await store.write(config.uid, 'adult', 'yes');
    await store.write(config.uid, 'lang', 'fr');
    await store.write(config.uid, 'genres', <String>['drama', 'horror']);
    await store.write(config.uid, 'pageSize', 'ten');
    await store.write(
      config.uid,
      ExtensionPreference.mirrorKey,
      'https://gone.example.com',
    );

    final ExtensionHost host = _host(store, config);

    expect(await host.resolvePreference('adult'), true);
    expect(await host.resolvePreference('lang'), 'en');
    expect(await host.resolvePreference('genres'), <String>['drama']);
    expect(await host.resolvePreference('pageSize'), 20);
    expect(await host.resolvePreference(ExtensionPreference.mirrorKey), isNull);
  });

  test('an empty stored text value falls back to the default', () async {
    final ConfigInfo config = _config();
    await store.write(config.uid, 'token', '');

    final ExtensionHost host = _host(store, config);

    expect(await host.resolvePreference('token'), 'none');
  });

  test('the provider reads live values without rebuilding the client',
      () async {
    final ConfigInfo config = _config();
    final ExtensionHost host = _host(store, config);

    expect(await host.resolvePreference('lang'), 'en');
    await store.write(config.uid, 'lang', 'ja');
    expect(await host.resolvePreference('lang'), 'ja');
    await store.remove(config.uid, 'lang');
    expect(await host.resolvePreference('lang'), 'en');
  });

  test('preferences are isolated per extension uid', () async {
    await store.write('ext-a', 'lang', 'ja');
    await store.write('ext-a-b', 'lang', 'en');

    expect(await _host(store, _config(uid: 'ext-a')).resolvePreference('lang'),
        'ja');
    expect(await store.readAll('ext-a'), <String, Object>{'lang': 'ja'});

    await store.clearExtension('ext-a');

    expect(await store.readAll('ext-a'), isEmpty);
    expect(await store.readAll('ext-a-b'), <String, Object>{'lang': 'en'});
  });

  test('writes notify listeners of the changed uid', () async {
    final List<String> changed = <String>[];
    final StreamSubscription<String> subscription =
        store.changesFor('ext-a').listen(changed.add);
    addTearDown(subscription.cancel);

    await store.write('ext-a', 'lang', 'ja');
    await store.write('ext-b', 'lang', 'ja');
    await store.remove('ext-a', 'lang');
    await store.clearExtension('ext-a');
    await Future<void>.delayed(Duration.zero);

    expect(changed, <String>['ext-a', 'ext-a', 'ext-a']);
  });

  test('extension preferences round trip through a settings export',
      () async {
    await store.write('ext-a', 'adult', false);
    await store.write('ext-a', 'pageSize', 30);
    await store.write('ext-a', 'ratio', 1.5);
    await store.write('ext-a', 'token', 'abc');
    await store.write('ext-a', 'genres', <String>['drama', 'action']);

    final List<ExportPreference> exported = ExportedPreferences.collect(
      await SharedPreferences.getInstance(),
    );
    final List<dynamic> json = jsonDecode(
      jsonEncode(exported.map((ExportPreference e) => e.toJson()).toList()),
    ) as List<dynamic>;

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences fresh = await SharedPreferences.getInstance();
    final int applied = await ExportedPreferences.apply(
      fresh,
      json
          .map((dynamic e) =>
              ExportPreference.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

    expect(applied, 5);
    final ExtensionPreferencesStore restored = ExtensionPreferencesStore();
    expect(await restored.readAll('ext-a'), <String, Object>{
      'adult': false,
      'pageSize': 30,
      'ratio': 1.5,
      'token': 'abc',
      'genres': <String>['drama', 'action'],
    });
  });

  test('number parsing keeps integers and rejects garbage', () {
    expect(ExtensionPreferenceValues.parseNumber('12'), 12);
    expect(ExtensionPreferenceValues.parseNumber(' -3.5 '), -3.5);
    expect(ExtensionPreferenceValues.parseNumber(''), isNull);
    expect(ExtensionPreferenceValues.parseNumber('1e999'), isNull);
    expect(ExtensionPreferenceValues.parseNumber('abc'), isNull);
    expect(ExtensionPreferenceValues.formatNumber(4.0), '4');
  });

  test('settings are offered only for preferences or mirrors', () {
    final ConfigInfo bare = ConfigInfo.fromJson(<String, dynamic>{
      'name': 'Bare',
      'uid': 'bare',
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
    });

    expect(hasExtensionSettings(bare), isFalse);
    expect(hasExtensionSettings(_config()), isTrue);
    expect(extensionMirrors(_config(mirrors: <String>[_mirrorA, _mirrorA])),
        <String>[_mirrorA]);
  });
}
