import 'package:drift/drift.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/pages_read.dart';

class PagesReadService {
  static final PagesReadService _instance = PagesReadService();

  static PagesReadService get instance => _instance;

  WakaranaiDb get waka => wakaranaiDb;

  Future<PagesRead?> getByUid(String uid) async {
    final res = await (waka.select(waka.pagesReadTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .get();

    if (res.isEmpty) {
      return null;
    }

    return PagesRead.fromDrift(res.first);
  }

  Future<void> deleteByUid(String uid) async {
    await (waka.delete(waka.pagesReadTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .go();
  }

  Future<void> deleteBulkByUid(List<String> uid) async {
    await (waka.delete(waka.pagesReadTable)..where((tbl) => tbl.uid.isIn(uid)))
        .go();
  }

  Future<int> update(PagesRead pagesRead) async {
    return await (waka.into(waka.pagesReadTable).insert(
        PagesReadTableCompanion.insert(
            id: pagesRead.id != null
                ? Value(pagesRead.id!)
                : const Value.absent(),
            uid: pagesRead.uid,
            readPages: pagesRead.readPages,
            totalPages: pagesRead.totalPages,
            lastUpdated: Value(pagesRead.lastUpdated),
            created: pagesRead.created != null
                ? Value(pagesRead.created!)
                : const Value.absent()),
        mode: InsertMode.insertOrReplace));
  }

  Future<int> add(PagesRead pagesRead) async {
    final res = await (waka.selectOnly(waka.pagesReadTable)
          ..addColumns([waka.pagesReadTable.uid, waka.pagesReadTable.id])
          ..where(waka.pagesReadTable.uid.equals(pagesRead.uid)))
        .get();

    if (res.isNotEmpty) {
      return res.first.read(waka.pagesReadTable.id)!;
    }

    return waka.into(waka.pagesReadTable).insert(PagesReadTableCompanion.insert(
        uid: pagesRead.uid,
        readPages: pagesRead.readPages,
        totalPages: pagesRead.totalPages));
  }
}
