import 'package:drift/drift.dart';
import 'package:wakaranai/model/gallery/local_gallery_view_table.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';

@DataClassName("DriftLocalAnimeGalleryView")
class LocalAnimeGalleryViewTable extends LocalGalleryViewTable {
  TextColumn get uid => text()();

  TextColumn get cover => text()();

  TextColumn get title => text()();

  TextColumn get data => text()();

  IntColumn get status => intEnum<AnimeStatus>()();
}
