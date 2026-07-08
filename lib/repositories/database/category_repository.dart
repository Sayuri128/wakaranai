import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class CategoryRepository extends BaseRepository<CategoryDomain,
    CategoryTableCompanion, CategoryTableData> {
  CategoryRepository({required super.database});

  Stream<List<CategoryDomain>> watchAll() {
    return (database.categoryTable.select()
          ..orderBy(<OrderClauseGenerator<$CategoryTableTable>>[
            (tbl) => OrderingTerm(expression: tbl.sortOrder),
            (tbl) => OrderingTerm(expression: tbl.id),
          ]))
        .watch()
        .map((List<CategoryTableData> rows) =>
            rows.map(CategoryDomain.fromDrift).toList());
  }

  @override
  DeleteStatement deleteStatement() => database.categoryTable.delete();

  @override
  CategoryDomain fromDrift(CategoryTableData data) =>
      CategoryDomain.fromDrift(data);

  @override
  InsertStatement insertStatement() => database.categoryTable.insert();

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) =>
      database.categoryTable.select();

  @override
  CategoryTableCompanion toDrift(CategoryDomain domain,
          {bool update = false, bool create = false}) =>
      domain.toDrift(update: update, create: create);

  @override
  UpdateStatement updateStatement() => database.categoryTable.update();
}
