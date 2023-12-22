import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';

class LocalConfigsSourcesService {
  static final LocalConfigsSourcesService _instance =
  LocalConfigsSourcesService();

  static LocalConfigsSourcesService get instance => _instance;



  Future<List<ConfigsSourceItem>> getAll() async {
    final res = await waka.select(waka.localConfigsSourcesTable).get();
    return res.map(ConfigsSourceItem.fromDrift).toList();
  }

  Future<void> add(ConfigsSourceItem item) async {
    await waka.into(waka.localConfigsSourcesTable).insert(
        LocalConfigsSourcesTableCompanion.insert(
            baseUrl: item.baseUrl, name: item.name, type: item.type));
  }

  Future<void> delete(ConfigsSourceItem item) async {
    await (waka.delete(waka.localConfigsSourcesTable)
          ..where((tbl) => tbl.id.equals(item.id!)))
        .go();
  }
}
