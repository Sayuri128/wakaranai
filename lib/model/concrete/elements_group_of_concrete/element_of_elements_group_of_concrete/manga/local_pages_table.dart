import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/local_chapter_table.dart';
import 'package:wakaranai/model/waka_table.dart';

@DataClassName("DriftLocalPages")
class LocalPagesTable extends WakaTable {
  TextColumn get chapterUid => text()();

  IntColumn get chapterId => integer().references(LocalChapterTable, #id)();
}
