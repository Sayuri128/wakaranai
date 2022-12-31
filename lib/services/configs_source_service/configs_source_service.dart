import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class ConfigsSourceService extends SqfliteService<ConfigsSourceItem> {
  ConfigsSourceService() : super(tableName: SqfliteService.configsSourcesTableName);
}
