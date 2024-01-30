import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/data/entities/extension/extension_table.dart';
import 'package:wakaranai/data/entities/extensions_source/extension_source_table.dart';
import 'package:path/path.dart' as path;
import 'package:drift/native.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'wakaranai_database.g.dart';

@DriftDatabase(tables: [
  ExtensionSourceTable,
  ExtensionTable,
])
class WakaranaiDatabase extends _$WakaranaiDatabase {
  WakaranaiDatabase() : super(_openConnection());

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {},
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(extensionTable);
          }
        },
      );

  @override
  int get schemaVersion => 2;
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
