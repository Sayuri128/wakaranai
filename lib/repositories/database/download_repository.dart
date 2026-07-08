import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
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
