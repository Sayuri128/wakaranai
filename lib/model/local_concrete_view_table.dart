import 'package:drift/drift.dart';

abstract class LocalConcreteViewTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}