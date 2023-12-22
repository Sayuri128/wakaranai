import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakascript/models/config_info/protector_config/protector_config.dart';

class LocalProtectorConfig {
  final int? id;
  final String pingUrl;
  final bool needToLogin;
  final bool inAppBrowserInterceptor;

  LocalProtectorConfig({
    required this.id,
    required this.pingUrl,
    required this.needToLogin,
    required this.inAppBrowserInterceptor,
  });

  ProtectorConfig asProtectorConfig() => ProtectorConfig(
      pingUrl: pingUrl,
      needToLogin: needToLogin,
      inAppBrowserInterceptor: inAppBrowserInterceptor);

  factory LocalProtectorConfig.fromProtectorConfig(ProtectorConfig config) =>
      LocalProtectorConfig(
          id: null,
          pingUrl: config.pingUrl,
          needToLogin: config.needToLogin,
          inAppBrowserInterceptor: config.inAppBrowserInterceptor);

  factory LocalProtectorConfig.fromDrift(DriftLocalProtectorConfig drift) =>
      LocalProtectorConfig(
          id: drift.id,
          pingUrl: drift.pingUrl,
          needToLogin: drift.needToLogin,
          inAppBrowserInterceptor: drift.inAppBrowserInterceptor);
}
