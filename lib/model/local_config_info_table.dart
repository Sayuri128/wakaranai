import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_protector_config_table.dart';
import 'package:wakascript/models/config_info/config_info.dart';

@DataClassName("DriftLocalConfigInfo")
class LocalConfigInfoTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uid => text()();

  TextColumn get name => text()();

  TextColumn get logoUrl => text()();

  TextColumn get language => text()();

  BoolColumn get nsfw => boolean()();

  IntColumn get type => intEnum<ConfigInfoType>()();

  IntColumn get version => integer()();

  IntColumn get localProtectorConfigId =>
      integer().nullable().references(LocalProtectorConfigTable, #id)();

  BoolColumn get searchAvailable => boolean()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
