import 'package:drift/drift.dart';
import 'package:wakaranai/model/library_item_table.dart';
import 'package:wakaranai/model/local_anime_gallery_view_table.dart';

@DataClassName("DriftAnimeLibraryItem")
class AnimeLibraryItemTable extends LibraryItemTable {
  IntColumn get localAnimeGalleryViewId =>
      integer().references(LocalAnimeGalleryViewTable, #id)();
}
