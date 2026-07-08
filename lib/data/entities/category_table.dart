import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

class CategoryTable extends BaseTable {
  TextColumn get name => text()();

  IntColumn get sortOrder => integer().withDefault(const Constant<int>(0))();
}
