import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

class ExtensionSourceTable extends BaseTable {
  TextColumn get type => text()();

  TextColumn get name => text()();

  TextColumn get url => text()();
}
