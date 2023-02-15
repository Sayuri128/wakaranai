import 'package:drift/drift.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakascript/models/config_info/protector_config/protector_config.dart';

class LocalProtectorConfigService {
  static final LocalProtectorConfigService instance =
      LocalProtectorConfigService();



  Future<void> delete(int id) async {
    await (waka.delete(waka.localProtectorConfigTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> update(LocalProtectorConfig config) async {
    await (waka.into(waka.localProtectorConfigTable).insert(
        LocalProtectorConfigTableCompanion.insert(
            id: Value(config.id!),
            pingUrl: config.pingUrl,
            needToLogin: config.needToLogin,
            inAppBrowserInterceptor: config.inAppBrowserInterceptor),
        mode: InsertMode.insertOrReplace));
  }

  Future<int> add(ProtectorConfig protectorConfig) async {
    return (await (waka.into(waka.localProtectorConfigTable).insert(
        LocalProtectorConfigTableCompanion.insert(
            pingUrl: protectorConfig.pingUrl,
            needToLogin: protectorConfig.needToLogin,
            inAppBrowserInterceptor:
                protectorConfig.inAppBrowserInterceptor))));
  }

  Future<LocalProtectorConfig> get(int id) async {
    final res = await (waka.select(waka.localProtectorConfigTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalProtectorConfig with id $id does not exist");
    }

    return LocalProtectorConfig.fromDrift(res.first);
  }
}
