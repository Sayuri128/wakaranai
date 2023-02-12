import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakaranai/services/local_protector_config_service/local_protector_config_service.dart';
import 'package:wakaranai/services/sqflite_service/query_item.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_exists_check_result.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class LocalConfigInfoService extends SqfliteService<LocalConfigInfo> {
  LocalConfigInfoService({required this.localProtectorConfigService})
      : super(tableName: localConfigInfoTableName);

  final LocalProtectorConfigService localProtectorConfigService;

  static const String localConfigInfoTableName = 'local_configs';
  static const String createLocalConfigInfoTable = '''
    create table $localConfigInfoTableName (
      id integer PRIMARY KEY AUTOINCREMENT,
      uid text NOT NULL,
      name text NOT NULL,
      logoUrl text NOT NULL,
      nsfw boolean NOT NULL,
      language boolean NOT NULL,
      version integer NOT NULL,
      localProtectorConfigId integer,
      searchAvailable boolean NOT NULL,
      FOREIGN KEY(localProtectorConfigId) REFERENCES ${LocalProtectorConfigService.localProtectorConfigTableName}(id)
    );
  ''';

  @override
  Future<int> update(LocalConfigInfo item) async {
    if (item.localProtectorConfig != null) {
      await localProtectorConfigService.update(item.localProtectorConfig!);
    }

    return super.update(item);
  }

  @override
  Future<void> delete(int id) async {
    final ref = await get(id);
    if (ref.localProtectorConfig != null) {
      await localProtectorConfigService.deleteQuery(query: [
        SqfliteQueryKeyValueItem(key: 'id', value: ref.localProtectorConfig!.id)
      ]);
    }
    return super.delete(id);
  }

  @override
  Future<LocalConfigInfo> mapConfig(Map<String, dynamic> map) async {
    final Map<String, dynamic> res = Map.from(map);
    if (res['localProtectorConfigId'] != null) {
      res['localProtectorConfig'] =
          (await localProtectorConfigService.get(map['localProtectorConfigId']))
              .toMap(lazy: false);
    }

    return LocalConfigInfo.fromMap(res);
  }

  @override
  Future<int> insert(LocalConfigInfo item) async {
    if (item.localProtectorConfig != null) {
      item.localProtectorConfig!.id =
          await localProtectorConfigService.insert(item.localProtectorConfig!);
    }
    return super.insert(item);
  }

  Future<SqfliteExistsCheckResult> checkExists(
      {required String uid, required int version}) async {
    final exists = await super.queryMap(query: [
      SqfliteQueryKeyValueItem(key: "uid", value: uid),
      const SqfliteQueryOperatorItem(operator: SqfliteOperator.AND),
      SqfliteQueryKeyValueItem(key: "version", value: version)
    ]);
    return SqfliteExistsCheckResult(
        value: exists.isNotEmpty,
        data: exists.isNotEmpty ? exists.first : null);
  }
}
