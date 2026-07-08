import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';
import 'package:wakaranai/data/entities/category_table.dart';

class LibraryEntryTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get extensionUid => text()();

  TextColumn get title => text()();

  TextColumn get cover => text().nullable()();

  TextColumn get data => text().nullable()();

  IntColumn get categoryId =>
      integer().nullable().references(CategoryTable, #id)();

  DateTimeColumn get lastReadAt => dateTime().nullable()();

  BoolColumn get trackUpdates => boolean().withDefault(const Constant(true))();

  BoolColumn get notifyUpdates => boolean().withDefault(const Constant(true))();
}
