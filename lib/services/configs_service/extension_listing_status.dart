import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';

enum ExtensionListingStatus {
  available,
  requiresNewerApp,
  updateNeedsNewerApp;

  bool get isDisabled => this == ExtensionListingStatus.requiresNewerApp;

  static ExtensionListingStatus of(
    RemoteConfig remote,
    ExtensionDomain? installed,
  ) {
    if (remote.compatibility.isCompatible) {
      return ExtensionListingStatus.available;
    }
    if (installed == null) {
      return ExtensionListingStatus.requiresNewerApp;
    }
    if (ExtensionResolver.isOutdated(installed, remote)) {
      return ExtensionListingStatus.updateNeedsNewerApp;
    }
    return ExtensionListingStatus.available;
  }
}
