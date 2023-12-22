import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/local_anime_video_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/local_chapter_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/manga/local_page_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/element_of_elements_group_of_concrete/manga/local_pages_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_anime_videos_group_table.dart';
import 'package:wakaranai/model/concrete/elements_group_of_concrete/local_chapters_group_table.dart';
import 'package:wakaranai/model/concrete/local_concrete_anime_table.dart';
import 'package:wakaranai/model/concrete/local_concrete_manga_table.dart';
import 'package:wakaranai/model/concrete/manga/pages_read_table.dart';
import 'package:wakaranai/model/configs/local_api_source_table.dart';
import 'package:wakaranai/model/configs/local_config_info_table.dart';
import 'package:wakaranai/model/configs/local_protector_config_table.dart';
import 'package:wakaranai/model/gallery/local_anime_gallery_view_table.dart';
import 'package:wakaranai/model/gallery/local_manga_gallery_view_table.dart';
import 'package:wakaranai/model/library/library_anime_item_table.dart';
import 'package:wakaranai/model/library/library_manga_item_table.dart';
import 'package:wakaranai/model/sources/local_configs_sources_table.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_status.dart';

part 'wakaranai_db.g.dart';

@DriftDatabase(tables: [
  LocalProtectorConfigTable,
  LocalConfigInfoTable,
  LocalApiSourceTable,
  MangaLibraryItemTable,
  LocalMangaGalleryViewTable,
  LocalMangaConcreteViewTable,
  LocalChaptersGroupTable,
  LocalChapterTable,
  LocalPagesTable,
  LocalPageTable,
  AnimeLibraryItemTable,
  LocalAnimeGalleryViewTable,
  LocalAnimeConcreteViewTable,
  LocalAnimeVideosGroupTable,
  LocalAnimeVideoTable,
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
      await delete(localPageTable).go();
      await delete(localPagesTable).go();
      await delete(localChapterTable).go();
      await delete(localChaptersGroupTable).go();
      await delete(localMangaConcreteViewTable).go();
      await delete(localAnimeVideoTable).go();
      await delete(localAnimeVideosGroupTable).go();
      await delete(localAnimeConcreteViewTable).go();
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

final WakaranaiDb waka = WakaranaiDb();
