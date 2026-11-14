import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';

Map<String, dynamic> _configJson({int? apiVersion, String? minAppVersion}) =>
    <String, dynamic>{
      'name': 'Source',
      'uid': 'source-uid',
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': 'English',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
      if (apiVersion != null) 'apiVersion': apiVersion,
      if (minAppVersion != null) 'minAppVersion': minAppVersion,
    };

ConfigInfo _config({int apiVersion = 1, String? minAppVersion}) =>
    ConfigInfo.fromJson(
      _configJson(apiVersion: apiVersion, minAppVersion: minAppVersion),
    );

void main() {
  group('AppVersion.tryParse', () {
    test('accepts prefixes, build metadata and missing parts', () {
      expect(AppVersion.tryParse('1.2.3'),
          const AppVersion(major: 1, minor: 2, patch: 3));
      expect(AppVersion.tryParse('v1.2.3'),
          const AppVersion(major: 1, minor: 2, patch: 3));
      expect(AppVersion.tryParse('1.2.3+4'),
          const AppVersion(major: 1, minor: 2, patch: 3));
      expect(AppVersion.tryParse(' 1.2 '),
          const AppVersion(major: 1, minor: 2, patch: 0));
      expect(AppVersion.tryParse('2'),
          const AppVersion(major: 2, minor: 0, patch: 0));
    });

    test('rejects missing or garbage input', () {
      expect(AppVersion.tryParse(null), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('latest'), isNull);
    });
  });

  group('ExtensionCompatibility.check', () {
    ExtensionCompatibility check({
      int apiVersion = 1,
      String? minAppVersion,
      int? entryApiVersion,
      String? entryMinAppVersion,
      String? appVersion = '0.4.0',
    }) {
      return ExtensionCompatibility.check(
        _config(apiVersion: apiVersion, minAppVersion: minAppVersion),
        entryApiVersion: entryApiVersion,
        entryMinAppVersion: entryMinAppVersion,
        supportedApiVersion: 2,
        appVersion: appVersion,
      );
    }

    test('legacy and current api versions are compatible', () {
      expect(check(apiVersion: 1).isCompatible, isTrue);
      expect(check(apiVersion: 2).isCompatible, isTrue);
    });

    test('a newer api version needs a newer app', () {
      final ExtensionCompatibility result = check(apiVersion: 3);

      expect(result.requiresNewerApp, isTrue);
      expect(result.incompatibility, ExtensionIncompatibility.apiVersion);
      expect(result.requiredApiVersion, 3);
      expect(result.supportedApiVersion, 2);
    });

    test('compares the minimum app version tolerantly', () {
      expect(check(minAppVersion: '0.4.0').isCompatible, isTrue);
      expect(check(minAppVersion: '0.3.9').isCompatible, isTrue);
      expect(check(minAppVersion: 'v0.4').isCompatible, isTrue);
      expect(check(minAppVersion: '0.4.0', appVersion: '0.4.0+9').isCompatible,
          isTrue);
      expect(check(minAppVersion: '0.4.1').incompatibility,
          ExtensionIncompatibility.minAppVersion);
      expect(check(minAppVersion: '1').incompatibility,
          ExtensionIncompatibility.minAppVersion);
      expect(check(minAppVersion: '0.5', appVersion: 'v0.4.9').incompatibility,
          ExtensionIncompatibility.minAppVersion);
    });

    test('unparsable versions never block a source', () {
      expect(check(minAppVersion: 'soon').isCompatible, isTrue);
      expect(check(minAppVersion: '9.0.0', appVersion: 'dev').isCompatible,
          isTrue);
    });

    test('the api version is reported before the app version', () {
      final ExtensionCompatibility result =
          check(apiVersion: 3, minAppVersion: '9.0.0');

      expect(result.incompatibility, ExtensionIncompatibility.apiVersion);
      expect(result.requiredAppVersion, '9.0.0');
    });

    test('falls back to entry-level fields', () {
      expect(check(entryApiVersion: 3).incompatibility,
          ExtensionIncompatibility.apiVersion);
      expect(check(entryMinAppVersion: '0.5.0').incompatibility,
          ExtensionIncompatibility.minAppVersion);
      expect(
        check(minAppVersion: '0.3.0', entryMinAppVersion: '0.5.0')
            .isCompatible,
        isTrue,
      );
      expect(check(apiVersion: 3, entryApiVersion: 1).incompatibility,
          ExtensionIncompatibility.apiVersion);
    });

    test('defaults to the interpreter api version', () {
      expect(
        ExtensionCompatibility.check(
          _config(apiVersion: capyscriptApiVersion),
          appVersion: '0.0.1',
        ).isCompatible,
        isTrue,
      );
      expect(
        ExtensionCompatibility.check(
          _config(apiVersion: capyscriptApiVersion + 1),
          appVersion: '0.0.1',
        ).requiresNewerApp,
        isTrue,
      );
    });
  });

  group('RemoteConfig index entries', () {
    setUp(() => dotenv.testLoad(fileInput: 'CURRENT_APP_VERSION=0.4.0'));

    test('reads entry-level fields', () {
      final RemoteConfig remote = RemoteConfig.fromJson(<String, dynamic>{
        'category': 'manga',
        'path': 'manga/source',
        'revision': 'abc',
        'apiVersion': capyscriptApiVersion + 1,
        'minAppVersion': '0.5.0',
        'config': _configJson(),
      });

      expect(remote.apiVersion, capyscriptApiVersion + 1);
      expect(remote.minAppVersion, '0.5.0');
      expect(remote.effectiveApiVersion, capyscriptApiVersion + 1);
      expect(remote.effectiveMinAppVersion, '0.5.0');
      expect(remote.compatibility.incompatibility,
          ExtensionIncompatibility.apiVersion);
    });

    test('prefers the config fields', () {
      final RemoteConfig remote = RemoteConfig.fromJson(<String, dynamic>{
        'category': 'manga',
        'path': 'manga/source',
        'apiVersion': 1,
        'minAppVersion': '0.1.0',
        'config': _configJson(apiVersion: 2, minAppVersion: '0.6.0'),
      });

      expect(remote.effectiveApiVersion, 2);
      expect(remote.effectiveMinAppVersion, '0.6.0');
      expect(remote.compatibility.incompatibility,
          ExtensionIncompatibility.minAppVersion);
      expect(remote.compatibility.currentAppVersion, '0.4.0');
    });

    test('an old index without the fields stays compatible', () {
      final RemoteConfig remote = RemoteConfig.fromJson(<String, dynamic>{
        'category': 'manga',
        'path': 'manga/source',
        'revision': 'abc',
        'config': _configJson(),
      });

      expect(remote.apiVersion, isNull);
      expect(remote.minAppVersion, isNull);
      expect(remote.effectiveApiVersion, legacyExtensionApiVersion);
      expect(remote.effectiveMinAppVersion, isNull);
      expect(remote.compatibility.isCompatible, isTrue);
    });

    test('a directory-walk config carries its own fields', () {
      final RemoteConfig remote = RemoteConfig.fromJson(<String, dynamic>{
        'category': 'manga',
        'path': 'manga/source',
        'config': _configJson(apiVersion: capyscriptApiVersion + 1),
      });

      expect(remote.compatibility.requiresNewerApp, isTrue);
    });
  });
}
