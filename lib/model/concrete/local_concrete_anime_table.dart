import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/local_concrete_view_table.dart';
import 'package:wakaranai/model/gallery/local_manga_gallery_view_table.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';

@DataClassName("DriftLocalAnimeConcreteView")
class LocalAnimeConcreteViewTable extends LocalConcreteViewTable {
  IntColumn get galleryViewId =>
      integer().references(LocalMangaGalleryViewTable, #id)();

  TextColumn get cover => text()();

  TextColumn get title => text()();

  TextColumn get alternativeTitles => text()();

  TextColumn get tags => text()();

  TextColumn get description => text()();

  IntColumn get status => intEnum<AnimeStatus>()();
}
