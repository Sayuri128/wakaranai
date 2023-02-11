import 'package:wakaranai/models/serializable_object.dart';
import 'package:wakascript/models/config_info/protector_config/protector_config.dart';

class LocalProtectorConfig extends SqSerializableObject {
  int? id;
  final String pingUrl;
  final bool needToLogin;
  final bool inAppBrowserInterceptor;

  LocalProtectorConfig({
    this.id,
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

  @override
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'pingUrl': pingUrl,
      'needToLogin': needToLogin ? 1 : 0,
      'inAppBrowserInterceptor': inAppBrowserInterceptor ? 1 : 0,
    };
  }

  factory LocalProtectorConfig.fromMap(Map<String, dynamic> map) {
    return LocalProtectorConfig(
      id: map['id'] as int?,
      pingUrl: map['pingUrl'] as String,
      needToLogin: map['needToLogin'] as int == 1,
      inAppBrowserInterceptor: map['inAppBrowserInterceptor'] as int == 1,
    );
  }

  @override
  int? getId() => id;
}
