import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/model/library_anime_item_table.dart';
import 'package:wakaranai/model/library_manga_item_table.dart';
import 'package:wakaranai/model/local_anime_gallery_view_table.dart';
import 'package:wakaranai/model/local_api_source_table.dart';
import 'package:wakaranai/model/local_config_info_table.dart';
import 'package:wakaranai/model/local_configs_sources_table.dart';
import 'package:wakaranai/model/local_manga_gallery_view_table.dart';
import 'package:wakaranai/model/local_protector_config_table.dart';
import 'package:wakaranai/model/pages_read_table.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/config_info/config_info.dart';

part 'wakaranai_db.g.dart';

@DriftDatabase(tables: [
  LocalProtectorConfigTable,
  LocalConfigInfoTable,
  LocalApiSourceTable,
  MangaLibraryItemTable,
  AnimeLibraryItemTable,
  LocalMangaGalleryViewTable,
  LocalAnimeGalleryViewTable,
  LocalConfigsSourcesTable,
  PagesReadTable,
])
class WakaranaiDb extends _$WakaranaiDb {
  WakaranaiDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<void> hardReset() async {
    return transaction(() async {
      await delete(localProtectorConfigTable).go();
      await delete(localConfigInfoTable).go();
      await delete(localApiSourceTable).go();
      await delete(localConfigInfoTable).go();
      await delete(pagesReadTable).go();
      await delete(animeLibraryItemTable).go();
      await delete(localAnimeGalleryViewTable).go();
      await delete(mangaLibraryItemTable).go();
      await delete(localMangaGalleryViewTable).go();
    });
  }

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onUpgrade: (m, from, to) async {
        for (int step = from + 1; step <= to; step++) {
          switch (step) {

          }
        }
      });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file =
        File(path.join(dbFolder.path, "databases", "wakaranai.sqlite"));
    if (!file.existsSync()) {
      file.create(recursive: true);
    }
    return NativeDatabase(file);
  });
}

final WakaranaiDb wakaranaiDb = WakaranaiDb();
