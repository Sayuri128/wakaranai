import 'package:drift/drift.dart';
import 'package:wakaranai/model/gallery/local_gallery_view_table.dart';

@DataClassName("DriftLocalMangaGalleryView")
class LocalMangaGalleryViewTable extends LocalGalleryViewTable {
  TextColumn get uid => text()();
  TextColumn get cover => text()();
  TextColumn get title => text()();
  TextColumn get data => text()();
}