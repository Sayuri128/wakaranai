import 'package:drift/drift.dart';

@DataClassName("DriftPagesRead")
class PagesReadTable extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();

  IntColumn get readPages => integer()();
  IntColumn get totalPages => integer()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated => dateTime().nullable()();

}