import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_api_source_table.dart';

abstract class LibraryItemTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get localApiClientId =>
      integer().references(LocalApiSourceTable, #id)();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}
