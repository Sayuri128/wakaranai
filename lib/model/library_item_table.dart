import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_api_source_table.dart';
import 'package:wakascript/models/config_info/config_info.dart';

@DataClassName("DriftLibraryItem")
class LibraryItemTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get localApiClientId =>
      integer().references(LocalApiSourceTable, #id)();

  IntColumn get type => intEnum<ConfigInfoType>()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
