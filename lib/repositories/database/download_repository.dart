import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class DownloadRepository extends BaseRepository<DownloadDomain,
    DownloadTableCompanion, DownloadTableData> {
  DownloadRepository({required super.database});

  Stream<List<DownloadDomain>> watchAll() {
    return (database.downloadTable.select()
          ..orderBy(<OrderClauseGenerator<$DownloadTableTable>>[
            (tbl) => OrderingTerm(expression: tbl.id),
          ]))
        .watch()
        .map((List<DownloadTableData> rows) =>
            rows.map(DownloadDomain.fromDrift).toList());
  }

  Future<DownloadDomain?> getByUid(String uid) {
    return getBy<$DownloadTableTable>(uid, where: (tbl) => tbl.uid);
  }

  Future<List<DownloadDomain>> getByConcreteUid(String concreteUid) {
    return getAllBy<$DownloadTableTable>(concreteUid,
        where: (tbl) => tbl.concreteUid);
  }

  Future<List<DownloadDomain>> getPendingInQueueOrder() async {
    final List<DownloadTableData> rows = await (database.downloadTable
            .select()
          ..where((tbl) => tbl.status.isIn(_pendingStatusIndexes))
          ..orderBy(<OrderClauseGenerator<$DownloadTableTable>>[
            (tbl) => OrderingTerm(expression: tbl.queuePosition),
            (tbl) => OrderingTerm(expression: tbl.id),
          ]))
        .get();
    return rows.map(DownloadDomain.fromDrift).toList();
  }

  Future<int> nextQueuePosition() async {
    final Expression<int> highest =
        database.downloadTable.queuePosition.max();
    final TypedResult row = await (database.selectOnly(database.downloadTable)
          ..addColumns(<Expression<Object>>[highest]))
        .getSingle();
    return (row.read(highest) ?? 0) + 1;
  }

  Future<void> moveToQueueEnd(String uid) async {
    await database.transaction(() async {
      final int position = await nextQueuePosition();
      await _writeQueuePosition(uid, position);
    });
  }

  Future<void> writeQueueOrder(List<String> orderedUids) {
    return database.transaction(() async {
      for (int index = 0; index < orderedUids.length; index++) {
        await _writeQueuePosition(orderedUids[index], index + 1);
      }
    });
  }

  Future<void> _writeQueuePosition(String uid, int position) {
    return (database.downloadTable.update()
          ..where((tbl) => tbl.uid.equals(uid)))
        .write(DownloadTableCompanion(queuePosition: Value(position)));
  }

  static final List<int> _pendingStatusIndexes = <int>[
    DownloadStatus.queued.index,
    DownloadStatus.downloading.index,
    DownloadStatus.paused.index,
  ];

  Future<int> deleteByUid(String uid) {
    return deleteBy<$DownloadTableTable>(uid, where: (tbl) => tbl.uid);
  }

  @override
  DeleteStatement deleteStatement() => database.downloadTable.delete();

  @override
  DownloadDomain fromDrift(DownloadTableData data) =>
      DownloadDomain.fromDrift(data);

  @override
  InsertStatement insertStatement() => database.downloadTable.insert();

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) =>
      database.downloadTable.select();

  @override
  DownloadTableCompanion toDrift(DownloadDomain domain,
          {bool update = false, bool create = false}) =>
      domain.toDrift(update: update, create: create);

  @override
  UpdateStatement updateStatement() => database.downloadTable.update();
}
