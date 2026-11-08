import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';

String? extensionCompatibilityReason(ExtensionCompatibility compatibility) {
  switch (compatibility.incompatibility) {
    case ExtensionIncompatibility.apiVersion:
      return S.current.compat_reason_api_version(
        compatibility.requiredApiVersion,
        compatibility.supportedApiVersion,
      );
    case ExtensionIncompatibility.minAppVersion:
      return S.current.compat_reason_min_app_version(
        compatibility.requiredAppVersion ?? '',
        compatibility.currentAppVersion ?? '',
      );
    case null:
      return null;
  }
}

String? extensionListingStatusMessage(ExtensionListingStatus status) {
  switch (status) {
    case ExtensionListingStatus.available:
      return null;
    case ExtensionListingStatus.requiresNewerApp:
      return S.current.compat_requires_newer_app;
    case ExtensionListingStatus.updateNeedsNewerApp:
      return S.current.compat_update_needs_newer_app;
  }
}
