import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

Future<int> _userVersion(WakaranaiDatabase db) async {
  final QueryRow row =
      await db.customSelect('PRAGMA user_version;').getSingle();
  return row.data.values.first as int;
}

Future<WakaranaiDatabase> _open(Database raw) async {
  final WakaranaiDatabase db = WakaranaiDatabase.forTesting(
    NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
  );
  await db.customSelect('SELECT 1;').get();
  return db;
}

void main() {
  test('fresh database is created at the current schema version', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase db = await _open(raw);
    expect(await _userVersion(db), db.schemaVersion);
    await db.close();
  });

  test(
      'upgrade replays safely when a column was already added but the schema '
      'version was never persisted', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    expect(await _userVersion(first), 7);
    await first.close();

    raw.execute('PRAGMA user_version = 5;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), 7);
    await second.close();
  });

  test('upgrade from v5 adds the missing columns', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE concrete_data_table DROP COLUMN concrete_json;');
    raw.execute('ALTER TABLE download_table DROP COLUMN concrete_cover;');
    raw.execute('PRAGMA user_version = 5;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), 7);

    final List<QueryRow> concreteCols = await second
        .customSelect('PRAGMA table_info(concrete_data_table);')
        .get();
    expect(
      concreteCols.any((QueryRow r) => r.data['name'] == 'concrete_json'),
      isTrue,
    );

    final List<QueryRow> downloadCols =
        await second.customSelect('PRAGMA table_info(download_table);').get();
    expect(
      downloadCols.any((QueryRow r) => r.data['name'] == 'concrete_cover'),
      isTrue,
    );

    await second.close();
  });
}
