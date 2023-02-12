import 'package:drift/drift.dart';

@DataClassName("DriftLocalProtectorConfig")
class LocalProtectorConfigTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get pingUrl => text()();

  BoolColumn get needToLogin => boolean()();

  BoolColumn get inAppBrowserInterceptor => boolean()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();

}
