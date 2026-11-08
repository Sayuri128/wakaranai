import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

ConfigInfo _config(String uid, {int version = 1}) => ConfigInfo(
      uid: uid,
      name: 'Source $uid',
      logoUrl: '',
      nsfw: false,
      language: 'English',
      version: version,
      filters: const [],
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
    );

RemoteConfig _remote(String uid, {required bool compatible, String? revision}) =>
    RemoteConfig(
      path: 'manga/$uid',
      config: _config(uid),
      revision: revision,
      apiVersion: compatible ? capyscriptApiVersion : capyscriptApiVersion + 1,
    );

ExtensionDomain _installed(String uid, {String? revision}) => ExtensionDomain(
      id: 1,
      config: _config(uid),
      sourceCode: 'script',
      revision: revision,
      createdAt: DateTime(2026),
    );

void main() {
  test('compatible remotes are available whether installed or not', () {
    expect(
      ExtensionListingStatus.of(_remote('a', compatible: true), null),
      ExtensionListingStatus.available,
    );
    expect(
      ExtensionListingStatus.of(
        _remote('a', compatible: true, revision: 'r2'),
        _installed('a', revision: 'r1'),
      ),
      ExtensionListingStatus.available,
    );
  });

  test('an incompatible remote that is not installed is disabled', () {
    final ExtensionListingStatus status =
        ExtensionListingStatus.of(_remote('a', compatible: false), null);

    expect(status, ExtensionListingStatus.requiresNewerApp);
    expect(status.isDisabled, isTrue);
  });

  test('an installed source with an incompatible update stays usable', () {
    final ExtensionListingStatus status = ExtensionListingStatus.of(
      _remote('a', compatible: false, revision: 'r2'),
      _installed('a', revision: 'r1'),
    );

    expect(status, ExtensionListingStatus.updateNeedsNewerApp);
    expect(status.isDisabled, isFalse);
  });

  test('an installed source already on the remote revision is available', () {
    expect(
      ExtensionListingStatus.of(
        _remote('a', compatible: false, revision: 'r1'),
        _installed('a', revision: 'r1'),
      ),
      ExtensionListingStatus.available,
    );
  });

  test('the loaded state defaults unknown sources to available', () {
    final RemoteConfigsLoaded state = RemoteConfigsLoaded(
      mangaRemoteConfigs: <RemoteConfig>[
        _remote('a', compatible: false),
        _remote('b', compatible: true),
      ],
      animeRemoteConfigs: const [],
      sourceName: 'Official',
      listingStatuses: const <String, ExtensionListingStatus>{
        'a': ExtensionListingStatus.requiresNewerApp,
      },
    );

    expect(state.listingStatusOf(state.mangaRemoteConfigs[0]),
        ExtensionListingStatus.requiresNewerApp);
    expect(state.listingStatusOf(state.mangaRemoteConfigs[1]),
        ExtensionListingStatus.available);
  });
}
