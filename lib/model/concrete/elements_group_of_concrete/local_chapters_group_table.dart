import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_elements_group_of_concrete_table.dart';
import 'package:wakaranai/model/concrete/local_concrete_manga_table.dart';

@DataClassName("DriftLocalChaptersGroup")
class LocalChaptersGroupTable extends LocalElementsGroupOfConcreteTable {
  IntColumn get mangaConcreteId =>
      integer().references(LocalMangaConcreteViewTable, #id)();
}
