import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class LibraryEntryRepository extends BaseRepository<LibraryEntryDomain,
    LibraryEntryTableCompanion, LibraryEntryTableData> {
  LibraryEntryRepository({required super.database});

  Stream<List<LibraryEntryDomain>> watchAll() {
    return database.libraryEntryTable
        .select()
        .watch()
        .map((List<LibraryEntryTableData> rows) =>
            rows.map(LibraryEntryDomain.fromDrift).toList());
  }

  Future<LibraryEntryDomain?> getByUid(String uid) {
    return getBy<$LibraryEntryTableTable>(uid, where: (tbl) => tbl.uid);
  }

  Future<int> deleteByUid(String uid) {
    return deleteBy<$LibraryEntryTableTable>(uid, where: (tbl) => tbl.uid);
  }

  Future<int> clearCategory(int categoryId) {
    return (updateStatement()
          ..where((tbl) =>
              (tbl as $LibraryEntryTableTable).categoryId.equals(categoryId)))
        .write(const LibraryEntryTableCompanion(
            categoryId: Value<int?>(null)));
  }

  @override
  DeleteStatement deleteStatement() => database.libraryEntryTable.delete();

  @override
  LibraryEntryDomain fromDrift(LibraryEntryTableData data) =>
      LibraryEntryDomain.fromDrift(data);

  @override
  InsertStatement insertStatement() => database.libraryEntryTable.insert();

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) =>
      database.libraryEntryTable.select();

  @override
  LibraryEntryTableCompanion toDrift(LibraryEntryDomain domain,
          {bool update = false, bool create = false}) =>
      domain.toDrift(update: update, create: create);

  @override
  UpdateStatement updateStatement() => database.libraryEntryTable.update();
}
