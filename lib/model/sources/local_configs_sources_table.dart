import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';

@DataClassName("DriftLocalConfigsSource")
class LocalConfigsSourcesTable extends WakaTable {

  TextColumn get baseUrl => text()();

  TextColumn get name => text()();

  IntColumn get type => intEnum<ConfigsSourceType>()();

}
