import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/local_element_of_elements_group_of_concrete_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_chapters_group_table.dart';

@DataClassName("DriftLocalChapter")
class LocalChapterTable extends LocalElementOfElementsGroupOfConcreteTable {
  IntColumn get chaptersGroupId =>
      integer().references(LocalChaptersGroupTable, #id)();
}
