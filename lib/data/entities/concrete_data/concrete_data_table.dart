import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

class ConcreteDataTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get title => text()();

  TextColumn get cover => text().nullable()();

  TextColumn get data => text().nullable()();
}
