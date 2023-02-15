import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_elements_group_of_concrete_table.dart';
import 'package:wakaranai/model/concrete/local_concrete_anime_table.dart';

@DataClassName("DriftLocalAnimeVideosGroup")
class LocalAnimeVideosGroupTable extends LocalElementsGroupOfConcreteTable {
  IntColumn get animeConcreteId =>
      integer().references(LocalAnimeConcreteViewTable, #id)();
}
