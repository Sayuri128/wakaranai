import 'package:drift/drift.dart';
import 'package:wakaranai/model/concrete/local_concrete_view_table.dart';
import 'package:wakaranai/model/gallery/local_anime_gallery_view_table.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_status.dart';

@DataClassName("DriftLocalMangaConcreteView")
class LocalMangaConcreteViewTable extends LocalConcreteViewTable {

  IntColumn get galleryViewId =>
      integer().references(LocalAnimeGalleryViewTable, #id)();

  TextColumn get cover => text()();

  TextColumn get title => text()();

  TextColumn get alternativeTitles => text()();

  TextColumn get tags => text()();

  TextColumn get description => text()();

  IntColumn get status => intEnum<MangaStatus>()();

}
