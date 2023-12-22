import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/manga/local_pages_table.dart';
import 'package:wakaranai/model/waka_table.dart';

@DataClassName("DriftLocalPage")
class LocalPageTable extends WakaTable {
  TextColumn get url => text()();

  IntColumn get pagesId => integer().references(LocalPagesTable, #id)();
}
