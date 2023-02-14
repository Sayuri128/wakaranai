import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_concrete_view_table.dart';
import 'package:wakaranai/model/local_manga_gallery_view_table.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';

@DataClassName("DriftLocalConcreteAnime")
class LocalConcreteAnimeTable extends LocalConcreteViewTable {
  IntColumn get galleryViewId =>
      integer().references(LocalMangaGalleryViewTable, #id)();

  TextColumn get cover => text()();

  TextColumn get title => text()();

  TextColumn get alternativeTitle => text()();

  TextColumn get description => text()();

  IntColumn get status => intEnum<AnimeStatus>()();
}
