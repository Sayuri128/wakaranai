import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';
import 'package:wakaranai/data/entities/concrete_data/concrete_data_table.dart';

class ChapterActivityTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get title => text()();

  TextColumn get timestamp => text().nullable()();

  TextColumn get data => text().nullable()();

  IntColumn get concreteId => integer().references(ConcreteDataTable, #id)();

  IntColumn get readPages => integer()();

  IntColumn get totalPages => integer()();
}
