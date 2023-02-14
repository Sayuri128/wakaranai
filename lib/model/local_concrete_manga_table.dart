import 'package:drift/drift.dart';
import 'package:wakaranai/model/local_anime_gallery_view_table.dart';
import 'package:wakaranai/model/local_concrete_view_table.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_status.dart';

@DataClassName("DriftLocalConcreteManga")
class LocalConcreteMangaTable extends LocalConcreteViewTable {

  IntColumn get galleryViewId =>
      integer().references(LocalAnimeGalleryViewTable, #id)();

  TextColumn get cover => text()();

  TextColumn get title => text()();

  TextColumn get alternativeTitle => text()();

  TextColumn get description => text()();

  IntColumn get status => intEnum<MangaStatus>()();

}
