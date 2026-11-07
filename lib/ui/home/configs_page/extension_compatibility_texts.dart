import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';

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
