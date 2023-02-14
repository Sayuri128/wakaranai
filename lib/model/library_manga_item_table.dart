import 'package:drift/drift.dart';
import 'package:wakaranai/model/library_item_table.dart';
import 'package:wakaranai/model/local_manga_gallery_view_table.dart';

@DataClassName("DriftMangaLibraryItem")
class MangaLibraryItemTable extends LibraryItemTable {
  IntColumn get localMangaGalleryViewId =>
      integer().references(LocalMangaGalleryViewTable, #id)();
}
