import 'package:drift/drift.dart';

abstract class WakaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}