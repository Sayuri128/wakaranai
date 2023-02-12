

import 'package:drift/drift.dart';
import 'package:wakaranai/model/library_item_table.dart';
import 'package:wakaranai/model/local_gallery_view_table.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';

@DataClassName("DriftLocalAnimeGalleryView")
class LocalAnimeGalleryViewTable extends LocalGalleryViewTable {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();
  TextColumn get cover => text()();
  TextColumn get title => text()();
  TextColumn get data => text()();
  IntColumn get status => intEnum<AnimeStatus>()();
  IntColumn get libraryItemId => integer().references(LibraryItemTable, #id)();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}