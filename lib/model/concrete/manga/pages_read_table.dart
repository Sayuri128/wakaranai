import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';

@DataClassName("DriftPagesRead")
class PagesReadTable extends WakaTable {
  TextColumn get uid => text()();

  IntColumn get readPages => integer()();
  IntColumn get totalPages => integer()();

  DateTimeColumn get lastUpdated => dateTime().nullable()();
}