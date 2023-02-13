import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_config_info_table.dart';
import 'package:wakascript/models/config_info/config_info.dart';

@DataClassName("DriftLocalApiSource")
class LocalApiSourceTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get code => text()();

  IntColumn get type => intEnum<ConfigInfoType>()();

  IntColumn get localConfigInfoId =>
      integer().references(LocalConfigInfoTable, #id)();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
