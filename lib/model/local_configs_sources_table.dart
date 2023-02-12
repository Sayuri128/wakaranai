import 'package:drift/drift.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';

@DataClassName("DriftLocalConfigsSource")
class LocalConfigsSourcesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get baseUrl => text()();

  TextColumn get name => text()();

  IntColumn get type => intEnum<ConfigsSourceType>()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
