import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/local_element_of_elements_group_of_concrete_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_anime_videos_group_table.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';

@DataClassName("DriftLocalAnimeVideo")
class LocalAnimeVideoTable extends LocalElementOfElementsGroupOfConcreteTable {
  IntColumn get animeVideosGroupId =>
      integer().references(LocalAnimeVideosGroupTable, #id)();
  TextColumn get src => text()();
  IntColumn get type => intEnum<AnimeVideoType>()();
}
