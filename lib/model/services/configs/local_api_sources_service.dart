import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/configs/local_configs_info_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LocalApiSourcesService {
  static final LocalApiSourcesService _instance = LocalApiSourcesService();

  static LocalApiSourcesService get instance => _instance;



  Future<void> delete(int id) async {
    final toDelete = await (waka.selectOnly(waka.localApiSourceTable)
          ..addColumns([
            waka.localApiSourceTable.id,
            waka.localApiSourceTable.localConfigInfoId
          ])
          ..where(waka.localApiSourceTable.id.equals(id)))
        .get();

    if (toDelete.isNotEmpty) {
      await LocalConfigsInfoService.instance.delete(
          toDelete.first.read(waka.localApiSourceTable.localConfigInfoId)!);
    }

    await (waka.delete(waka.localApiSourceTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int> add(
      {required String code,
      required ConfigInfoType type,
      required ConfigInfo configInfo}) async {
    return await (waka.into(waka.localApiSourceTable).insert(
        LocalApiSourceTableCompanion.insert(
            code: code,
            type: type,
            localConfigInfoId:
                await LocalConfigsInfoService.instance.add(configInfo))));
  }

  Future<void> update(LocalApiClient apiClient) async {
    await LocalConfigsInfoService.instance.update(apiClient.localConfigInfo);

    await (waka.into(waka.localApiSourceTable).insert(
        LocalApiSourceTableCompanion.insert(
            id: Value(apiClient.id!),
            code: apiClient.code,
            type: apiClient.type,
            localConfigInfoId: apiClient.localConfigInfo.id!),
        mode: InsertMode.insertOrReplace));
  }

  Future<List<LocalApiClient>> getAll() async {
    final res = await (waka.select(waka.localApiSourceTable)).get();

    return Future.wait(res.map((e) async {
      return LocalApiClient(
          code: e.code,
          type: e.type,
          localConfigInfo:
              await LocalConfigsInfoService.instance.get(e.localConfigInfoId),
          id: e.id);
    }));
  }

  Future<LocalApiClient> getByConfigUid(int id) async {
    final res = await (waka.select(waka.localApiSourceTable)
          ..where((tbl) => tbl.localConfigInfoId.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalApiClient with config info id $id does not exist");
    }

    return LocalApiClient(
        id: res.first.id,
        code: res.first.code,
        type: res.first.type,
        localConfigInfo: await LocalConfigsInfoService.instance
            .get(res.first.localConfigInfoId));
  }

  Future<LocalApiClient> get(int id) async {
    final res = await (waka.select(waka.localApiSourceTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (res.isEmpty) {
      Exception("LocalApiClient with id $id does not exist");
    }

    return LocalApiClient(
        id: res.first.id,
        code: res.first.code,
        type: res.first.type,
        localConfigInfo: await LocalConfigsInfoService.instance
            .get(res.first.localConfigInfoId));
  }
}
