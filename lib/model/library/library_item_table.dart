import 'package:drift/drift.dart';
import 'package:wakaranai/model/configs/local_api_source_table.dart';
import 'package:wakaranai/model/waka_table.dart';

abstract class LibraryItemTable extends WakaTable {
  IntColumn get localApiClientId =>
      integer().references(LocalApiSourceTable, #id)();
}
