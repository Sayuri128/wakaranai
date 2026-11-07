import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/services/configs_service/remote_config_parser.dart';

Map<String, dynamic> _entry(
  String uid, {
  int type = 0,
  int? configApiVersion,
  int? entryApiVersion,
  String? minAppVersion,
  Map<String, dynamic> extraConfig = const <String, dynamic>{},
}) {
  return <String, dynamic>{
    'path': 'manga/$uid',
    if (entryApiVersion != null) 'apiVersion': entryApiVersion,
    if (minAppVersion != null) 'minAppVersion': minAppVersion,
    'config': <String, dynamic>{
      'uid': uid,
      'name': 'Source $uid',
      'logoUrl': 'https://example.com/$uid.png',
      'nsfw': false,
      'language': 'English',
      'version': 3,
      'filters': <dynamic>[],
      'type': type,
      'searchAvailable': true,
      if (configApiVersion != null) 'apiVersion': configApiVersion,
      ...extraConfig,
    },
  };
}

void main() {
  const RemoteConfigParser parser = RemoteConfigParser(appVersion: '1.0.0');

  test('an unparseable entry is skipped without failing the listing', () {
    final List<RemoteConfig> configs = parser.parseAll(<dynamic>[
      _entry('good'),
      _entry('broken', type: 7),
      'not an object',
      _entry('also_good'),
    ]);

    expect(
      configs.map((RemoteConfig e) => e.config.uid),
      <String>['good', 'also_good'],
    );
  });

  test('an unparseable entry from a newer api is listed as incompatible', () {
    final List<RemoteConfig> configs = parser.parseAll(<dynamic>[
      _entry(
        'future',
        configApiVersion: capyscriptApiVersion + 1,
        extraConfig: <String, dynamic>{'filters': 'unknown shape'},
      ),
    ]);

    expect(configs, hasLength(1));
    final RemoteConfig future = configs.single;
    expect(future.config.uid, 'future');
    expect(future.config.name, 'Source future');
    expect(future.config.logoUrl, 'https://example.com/future.png');
    expect(future.config.language, 'English');
    expect(future.config.type, ConfigInfoType.MANGA);
    expect(future.compatibility.requiresNewerApp, isTrue);
    expect(
      ExtensionListingStatus.of(future, null),
      ExtensionListingStatus.requiresNewerApp,
    );
  });

  test('an entry-level api version marks an unparseable entry incompatible',
      () {
    final List<RemoteConfig> configs = parser.parseAll(<dynamic>[
      <String, dynamic>{
        ..._entry('future', type: 9),
        'apiVersion': capyscriptApiVersion + 1,
        'category': 'anime',
      },
    ]);

    expect(configs.single.config.type, ConfigInfoType.ANIME);
    expect(configs.single.compatibility.requiresNewerApp, isTrue);
  });

  test('an unparseable entry needing a newer app version is kept', () {
    final List<RemoteConfig> configs = parser.parseAll(<dynamic>[
      _entry('future', type: 9, minAppVersion: '9.0.0'),
    ]);

    expect(configs, hasLength(1));
    expect(configs.single.config.uid, 'future');
  });
}
