import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:wakaranai/data/entities/anime_episode_activity_table.dart';
import 'package:wakaranai/data/entities/chapter_activity_table.dart';
import 'package:wakaranai/data/entities/concrete_data_table.dart';
import 'package:wakaranai/data/entities/extension_source_table.dart';
import 'package:wakaranai/data/entities/extension_table.dart';

part 'wakaranai_database.g.dart';

@DriftDatabase(tables: [
  ExtensionSourceTable,
  ExtensionTable,
  ConcreteDataTable,
  ChapterActivityTable,
  AnimeEpisodeActivityTable,
])
class WakaranaiDatabase extends _$WakaranaiDatabase {
  WakaranaiDatabase() : super(_openConnection());

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
        },
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(extensionTable);
          }
          if (from < 3) {
            await m.createTable(concreteDataTable);
            await m.createTable(chapterActivityTable);
            await m.createTable(animeEpisodeActivityTable);

          }
        },
      );

  @override
  int get schemaVersion => 3;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, "smt.sqlite"));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
