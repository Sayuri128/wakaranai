import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/local_protector_config_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LocalConfigsInfoService {
  static final LocalConfigsInfoService _instance = LocalConfigsInfoService();

  static LocalConfigsInfoService get instance => _instance;

  WakaranaiDb get waka => wakaranaiDb;

  Future<void> delete(int id) async {
    final toDelete = await (waka.selectOnly(waka.localConfigInfoTable)
          ..addColumns([
            waka.localConfigInfoTable.id,
            waka.localConfigInfoTable.localProtectorConfigId
          ])
          ..where(waka.localConfigInfoTable.id.equals(id)))
        .get();

    if (toDelete.isNotEmpty) {
      final localProtectorConfigId =
          toDelete.first.read(waka.localConfigInfoTable.localProtectorConfigId);
      if (localProtectorConfigId != null) {
        await LocalProtectorConfigService.instance
            .delete(localProtectorConfigId);
      }
    }

    await (waka.delete(waka.localConfigInfoTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> update(LocalConfigInfo configInfo) async {
    if (configInfo.localProtectorConfig != null) {
      await LocalProtectorConfigService.instance
          .update(configInfo.localProtectorConfig!);
    }
    await (waka.into(waka.localConfigInfoTable).insert(
        LocalConfigInfoTableCompanion.insert(
            id: Value(configInfo.id!),
            uid: configInfo.uid,
            name: configInfo.name,
            logoUrl: configInfo.logoUrl,
            language: configInfo.language,
            nsfw: configInfo.nsfw,
            type: configInfo.type,
            version: configInfo.version,
            searchAvailable: configInfo.searchAvailable,
            localProtectorConfigId: Value(configInfo.localProtectorConfig?.id)),
        mode: InsertMode.insertOrReplace));
  }

  Future<int> add(ConfigInfo configInfo) async {
    if (configInfo.protectorConfig != null) {
      return await waka
          .into(waka.localConfigInfoTable)
          .insert(LocalConfigInfoTableCompanion.insert(
            uid: configInfo.uid,
            name: configInfo.name,
            logoUrl: configInfo.logoUrl,
            nsfw: configInfo.nsfw,
            type: configInfo.type,
            language: configInfo.language,
            version: configInfo.version,
            localProtectorConfigId: Value(await LocalProtectorConfigService
                .instance
                .add(configInfo.protectorConfig!)),
            searchAvailable: configInfo.searchAvailable,
          ));
    }

    return await waka
        .into(waka.localConfigInfoTable)
        .insert(LocalConfigInfoTableCompanion.insert(
          uid: configInfo.uid,
          name: configInfo.name,
          logoUrl: configInfo.logoUrl,
          nsfw: configInfo.nsfw,
          type: configInfo.type,
          version: configInfo.version,
          searchAvailable: configInfo.searchAvailable,
          language: configInfo.language,
        ));
  }

  Future<List<LocalConfigInfo>> getAll() async {
    final res = await (waka.select(waka.localConfigInfoTable)).get();

    return Future.wait(res.map((e) async {
      LocalProtectorConfig? localProtectorConfig;

      if (e.localProtectorConfigId != null) {
        localProtectorConfig = await LocalProtectorConfigService.instance
            .get(e.localProtectorConfigId!);
      }

      return LocalConfigInfo(
          id: e.id,
          name: e.name,
          uid: e.uid,
          logoUrl: e.logoUrl,
          nsfw: e.nsfw,
          type: e.type,
          language: e.language,
          version: e.version,
          searchAvailable: e.searchAvailable,
          localProtectorConfig: localProtectorConfig);
    }));
  }

  Future<LocalConfigInfo> get(int id) async {
    final res = await (waka.select(waka.localConfigInfoTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalConfigInfo with id $id does not exist");
    }

    LocalProtectorConfig? localProtectorConfig;

    if (res.first.localProtectorConfigId != null) {
      localProtectorConfig = await LocalProtectorConfigService.instance
          .get(res.first.localProtectorConfigId!);
    }

    return LocalConfigInfo(
        id: res.first.id,
        name: res.first.name,
        uid: res.first.uid,
        logoUrl: res.first.logoUrl,
        nsfw: res.first.nsfw,
        type: res.first.type,
        language: res.first.language,
        version: res.first.version,
        searchAvailable: res.first.searchAvailable,
        localProtectorConfig: localProtectorConfig);
  }
}
