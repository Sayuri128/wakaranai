import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class LocalProtectorConfigService extends SqfliteService<LocalProtectorConfig> {
  LocalProtectorConfigService()
      : super(tableName: localProtectorConfigTableName);

  static const String localProtectorConfigTableName = 'protector_configs';
  static const String createLocalProtectorConfigTable = '''
    create table $localProtectorConfigTableName (
      id integer PRIMARY KEY AUTOINCREMENT,
      pingUrl text NOT NULL,
      needToLogin boolean NOT NULL,
      inAppBrowserInterceptor boolean NOT NULL,
      created DATETIME DEFAULT CURRENT_TIMESTAMP  
    );
  ''';

  @override
  Future<LocalProtectorConfig> mapConfig(Map<String, dynamic> map) async =>
      LocalProtectorConfig.fromMap(map);
}
