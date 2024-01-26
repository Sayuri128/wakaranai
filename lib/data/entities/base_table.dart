import 'package:drift/drift.dart';

class BaseTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}
