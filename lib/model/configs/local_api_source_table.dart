import 'package:drift/drift.dart';
import 'package:wakaranai/model/configs/local_config_info_table.dart';
import 'package:wakaranai/model/waka_table.dart';
import 'package:wakascript/models/config_info/config_info.dart';

@DataClassName("DriftLocalApiSource")
class LocalApiSourceTable extends WakaTable {
  TextColumn get code => text()();

  IntColumn get type => intEnum<ConfigInfoType>()();

  IntColumn get localConfigInfoId =>
      integer().references(LocalConfigInfoTable, #id)();
}
