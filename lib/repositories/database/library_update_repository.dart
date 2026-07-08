import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class LibraryUpdateRepository extends BaseRepository<LibraryUpdateDomain,
    LibraryUpdateTableCompanion, LibraryUpdateTableData> {
  LibraryUpdateRepository({required super.database});

  Stream<List<LibraryUpdateDomain>> watchAll() {
    return (database.libraryUpdateTable.select()
          ..orderBy(<OrderClauseGenerator<$LibraryUpdateTableTable>>[
            ($LibraryUpdateTableTable tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .watch()
        .map((List<LibraryUpdateTableData> rows) =>
            rows.map(LibraryUpdateDomain.fromDrift).toList());
  }

  Stream<int> watchUnseenCount() {
    return (database.libraryUpdateTable.select()
          ..where(($LibraryUpdateTableTable tbl) => tbl.seen.equals(false)))
        .watch()
        .map((List<LibraryUpdateTableData> rows) => rows.length);
  }

  Future<LibraryUpdateDomain?> getByUid(String uid) {
    return getBy<$LibraryUpdateTableTable>(uid, where: (tbl) => tbl.uid);
  }

  Future<bool> existsByUid(String uid) async {
    final LibraryUpdateTableData? row = await (database.libraryUpdateTable
            .select()
          ..where(($LibraryUpdateTableTable tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> getUidsForEntry(String libraryEntryUid) async {
    final List<LibraryUpdateTableData> rows = await (database.libraryUpdateTable
            .select()
          ..where(($LibraryUpdateTableTable tbl) =>
              tbl.libraryEntryUid.equals(libraryEntryUid)))
        .get();
    return rows.map((LibraryUpdateTableData row) => row.uid).toSet();
  }

  Future<int> markSeen(String uid) {
    return (updateStatement()
          ..where((tbl) => (tbl as $LibraryUpdateTableTable).uid.equals(uid)))
        .write(const LibraryUpdateTableCompanion(seen: Value<bool>(true)));
  }

  Future<int> markAllSeen() {
    return updateStatement()
        .write(const LibraryUpdateTableCompanion(seen: Value<bool>(true)));
  }

  Future<int> deleteByUid(String uid) {
    return deleteBy<$LibraryUpdateTableTable>(uid, where: (tbl) => tbl.uid);
  }

  Future<int> deleteByEntryUid(String libraryEntryUid) {
    return deleteBy<$LibraryUpdateTableTable>(libraryEntryUid,
        where: (tbl) => tbl.libraryEntryUid);
  }

  @override
  DeleteStatement deleteStatement() => database.libraryUpdateTable.delete();

  @override
  LibraryUpdateDomain fromDrift(LibraryUpdateTableData data) =>
      LibraryUpdateDomain.fromDrift(data);

  @override
  InsertStatement insertStatement() => database.libraryUpdateTable.insert();

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) =>
      database.libraryUpdateTable.select();

  @override
  LibraryUpdateTableCompanion toDrift(LibraryUpdateDomain domain,
          {bool update = false, bool create = false}) =>
      domain.toDrift(update: update, create: create);

  @override
  UpdateStatement updateStatement() => database.libraryUpdateTable.update();
}
