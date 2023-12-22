import 'package:drift/drift.dart';
import 'package:wakaranai/model/gallery/local_manga_gallery_view_table.dart';
import 'package:wakaranai/model/library/library_item_table.dart';

@DataClassName("DriftMangaLibraryItem")
class MangaLibraryItemTable extends LibraryItemTable {
  IntColumn get localMangaGalleryViewId =>
      integer().references(LocalMangaGalleryViewTable, #id)();
}
