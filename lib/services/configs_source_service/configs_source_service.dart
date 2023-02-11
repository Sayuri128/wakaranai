import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class ConfigsSourceService extends SqfliteService<ConfigsSourceItem> {
  ConfigsSourceService()
      : super(
            tableName: configsSourcesTableName);

  static const String configsSourcesTableName = 'configs_sources';
  static const String createConfigsSourcesTable =
      '''create table $configsSourcesTableName (
                            id integer PRIMARY KEY AUTOINCREMENT,
                            baseUrl text NOT NULL,
                            name text NOT NULL,
                            type text NOT NULL,
                            created DATETIME DEFAULT CURRENT_TIMESTAMP
                            );''';

  @override
  Future<ConfigsSourceItem> mapConfig(Map<String, dynamic> map) async =>
      ConfigsSourceItem.fromJson(map);
}
