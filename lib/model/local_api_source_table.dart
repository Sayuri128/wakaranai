import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_config_info_table.dart';
import 'package:wakaranai/models/data/local_api_client.dart';

@DataClassName("DriftLocalApiSource")
class LocalApiSourceTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get code => text()();

  IntColumn get type => intEnum<LocalApiClientType>()();

  IntColumn get localConfigInfoId =>
      integer().references(LocalConfigInfoTable, #id)();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
