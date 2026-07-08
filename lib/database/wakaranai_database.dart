import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:wakaranai/data/entities/anime_episode_activity_table.dart';
import 'package:wakaranai/data/entities/category_table.dart';
import 'package:wakaranai/data/entities/chapter_activity_table.dart';
import 'package:wakaranai/data/entities/concrete_data_table.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/data/entities/extension_source_table.dart';
import 'package:wakaranai/data/entities/extension_table.dart';
import 'package:wakaranai/data/entities/library_entry_table.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';

part 'wakaranai_database.g.dart';

@DriftDatabase(tables: [
  ExtensionSourceTable,
  ExtensionTable,
  ConcreteDataTable,
  ChapterActivityTable,
  AnimeEpisodeActivityTable,
  CategoryTable,
  LibraryEntryTable,
  DownloadTable,
  LibraryUpdateTable,
])
class WakaranaiDatabase extends _$WakaranaiDatabase {
  WakaranaiDatabase() : super(_openConnection());

  WakaranaiDatabase.forTesting(super.executor);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode = WAL;');
          await customStatement('PRAGMA busy_timeout = 8000;');
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
          if (from < 4) {
            await m.createTable(categoryTable);
            await m.createTable(libraryEntryTable);
          }
          if (from < 5) {
            await m.createTable(downloadTable);
          }
          if (from < 6) {
            await _addColumnIfMissing(
                m, concreteDataTable, concreteDataTable.concreteJson);
          }
          if (from < 7) {
            await _addColumnIfMissing(
                m, downloadTable, downloadTable.concreteCover);
          }
          if (from < 8) {
            await _createTableIfMissing(m, libraryUpdateTable);
            await _addColumnIfMissing(
                m, libraryEntryTable, libraryEntryTable.trackUpdates);
            await _addColumnIfMissing(
                m, libraryEntryTable, libraryEntryTable.notifyUpdates);
          }
        },
      );

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn column,
  ) async {
    if (await _hasColumn(table.actualTableName, column.name)) return;
    await m.addColumn(table, column);
  }

  Future<void> _createTableIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
  ) async {
    if (await _hasTable(table.actualTableName)) return;
    await m.createTable(table);
  }

  Future<bool> _hasTable(String table) async {
    final List<QueryRow> rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?;",
      variables: <Variable<Object>>[Variable<String>(table)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _hasColumn(String table, String column) async {
    final List<QueryRow> rows =
        await customSelect('PRAGMA table_info($table);').get();
    return rows.any((QueryRow row) => row.data['name'] == column);
  }

  @override
  int get schemaVersion => 8;
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
