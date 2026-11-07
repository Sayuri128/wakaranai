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
    expect(await _userVersion(first), first.schemaVersion);
    await first.close();

    raw.execute('PRAGMA user_version = 5;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);
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
    expect(await _userVersion(second), second.schemaVersion);

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

  test('upgrade from v7 creates the library update table and flags', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('DROP TABLE library_update_table;');
    raw.execute('ALTER TABLE library_entry_table DROP COLUMN track_updates;');
    raw.execute('ALTER TABLE library_entry_table DROP COLUMN notify_updates;');
    raw.execute('PRAGMA user_version = 7;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final List<QueryRow> tables = await second
        .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'library_update_table';")
        .get();
    expect(tables, isNotEmpty);

    final List<QueryRow> entryCols = await second
        .customSelect('PRAGMA table_info(library_entry_table);')
        .get();
    expect(
      entryCols.any((QueryRow r) => r.data['name'] == 'track_updates'),
      isTrue,
    );
    expect(
      entryCols.any((QueryRow r) => r.data['name'] == 'notify_updates'),
      isTrue,
    );

    await second.close();
  });

  test('upgrade to v8 is idempotent when the table already exists', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('PRAGMA user_version = 7;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);
    await second.close();
  });

  test('upgrade from v8 adds the extension source ref column', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE extension_source_table DROP COLUMN ref;');
    raw.execute('PRAGMA user_version = 8;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final List<QueryRow> sourceCols = await second
        .customSelect('PRAGMA table_info(extension_source_table);')
        .get();
    expect(
      sourceCols.any((QueryRow r) => r.data['name'] == 'ref'),
      isTrue,
    );

    await second.close();
  });

  test('upgrade from v9 dedupes uids and creates the unique indexes', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('DROP INDEX library_entry_uid;');
    raw.execute('DROP INDEX download_uid;');
    raw.execute('DROP INDEX concrete_data_uid;');
    raw.execute('DROP INDEX chapter_activity_uid;');
    raw.execute('DROP INDEX anime_episode_activity_uid;');
    raw.execute('DROP INDEX library_update_uid;');

    for (int i = 0; i < 3; i++) {
      raw.execute(
        'INSERT INTO library_entry_table '
        '(uid, extension_uid, title, track_updates, notify_updates, created_at) '
        "VALUES ('dupe', 'ext', 'Title $i', 1, 1, $i);",
      );
    }

    raw.execute('PRAGMA user_version = 9;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final List<QueryRow> rows = await second
        .customSelect(
            "SELECT id, title FROM library_entry_table WHERE uid = 'dupe';")
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['title'], 'Title 0');

    final List<QueryRow> indexes = await second
        .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'library_entry_uid';")
        .get();
    expect(indexes, isNotEmpty);

    await second.close();
  });

  test('the unique uid index rejects a duplicate insert', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase db = await _open(raw);

    raw.execute(
      'INSERT INTO library_entry_table '
      '(uid, extension_uid, title, track_updates, notify_updates, created_at) '
      "VALUES ('only-once', 'ext', 'First', 1, 1, 0);",
    );

    expect(
      () => raw.execute(
        'INSERT INTO library_entry_table '
        '(uid, extension_uid, title, track_updates, notify_updates, created_at) '
        "VALUES ('only-once', 'ext', 'Second', 1, 1, 1);",
      ),
      throwsA(isA<SqliteException>()),
    );

    await db.close();
  });

  test('upgrade from v10 adds the extension config and revision columns', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE extension_table DROP COLUMN config_json;');
    raw.execute('ALTER TABLE extension_table DROP COLUMN revision;');
    raw.execute('PRAGMA user_version = 10;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final Set<Object?> columns = (await second
            .customSelect('PRAGMA table_info(extension_table);')
            .get())
        .map((QueryRow r) => r.data['name'])
        .toSet();
    expect(columns, containsAll(<String>['config_json', 'revision']));

    await second.close();

    raw.execute('PRAGMA user_version = 10;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });

  test('upgrade from v11 creates the page translation cache', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('DROP TABLE page_translation_table;');
    raw.execute('PRAGMA user_version = 11;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final List<QueryRow> indexes = await second
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'page_translation_uid';",
        )
        .get();
    expect(indexes, hasLength(1));
    await second.close();

    raw.execute('PRAGMA user_version = 11;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });

  test('upgrade from v12 adds the episode download columns', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE download_table DROP COLUMN kind;');
    raw.execute('ALTER TABLE download_table DROP COLUMN downloaded_bytes;');
    raw.execute('ALTER TABLE download_table DROP COLUMN total_bytes;');
    raw.execute('ALTER TABLE download_table DROP COLUMN playback;');
    raw.execute('PRAGMA user_version = 12;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final Set<Object?> columns = (await second
            .customSelect('PRAGMA table_info(download_table);')
            .get())
        .map((QueryRow r) => r.data['name'])
        .toSet();
    expect(
      columns,
      containsAll(
          <String>['kind', 'downloaded_bytes', 'total_bytes', 'playback']),
    );
    await second.close();

    raw.execute('PRAGMA user_version = 12;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });

  test('upgrade from v13 creates the extension storage table', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('DROP TABLE extension_storage_table;');
    raw.execute('PRAGMA user_version = 13;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final List<QueryRow> tables = await second
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'extension_storage_table';",
        )
        .get();
    expect(tables, hasLength(1));

    final List<QueryRow> indexes = await second
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'extension_storage_expires_at';",
        )
        .get();
    expect(indexes, hasLength(1));
    await second.close();

    raw.execute('PRAGMA user_version = 13;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });

  test('upgrade from v14 adds the episode watched mark column', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute(
      'ALTER TABLE anime_episode_activity_table DROP COLUMN marked_watched;',
    );
    raw.execute('PRAGMA user_version = 14;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    final Set<Object?> columns = (await second
            .customSelect('PRAGMA table_info(anime_episode_activity_table);')
            .get())
        .map((QueryRow r) => r.data['name'])
        .toSet();
    expect(columns, contains('marked_watched'));
    await second.close();

    raw.execute('PRAGMA user_version = 14;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });
  test('upgrade from v15 adds the queue position and orders pending rows',
      () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE download_table DROP COLUMN queue_position;');
    final List<(String, int)> rows = <(String, int)>[
      ('done', 2),
      ('queued-a', 0),
      ('failed', 3),
      ('downloading', 1),
      ('queued-b', 0),
    ];
    for (final (String uid, int status) in rows) {
      raw.execute(
        'INSERT INTO download_table '
        '(uid, extension_uid, concrete_uid, concrete_id, concrete_title, '
        'title, status, dir_path, created_at) '
        "VALUES ('$uid', 'ext', 'concrete', 1, 'Title', '$uid', $status, "
        "'/tmp/$uid', 0);",
      );
    }
    raw.execute('PRAGMA user_version = 15;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);

    Future<Map<Object?, Object?>> positions(WakaranaiDatabase db) async {
      final List<QueryRow> stored = await db
          .customSelect('SELECT uid, queue_position FROM download_table;')
          .get();
      return <Object?, Object?>{
        for (final QueryRow row in stored)
          row.data['uid']: row.data['queue_position'],
      };
    }

    final Map<Object?, Object?> expected = <Object?, Object?>{
      'done': 0,
      'queued-a': 1,
      'failed': 0,
      'downloading': 2,
      'queued-b': 3,
    };
    expect(await positions(second), expected);
    await second.close();

    raw.execute('PRAGMA user_version = 15;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    expect(await positions(replayed), expected);
    await replayed.close();
  });

  test('upgrade from v16 creates the tracker link table', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('DROP TABLE tracker_link_table;');
    raw.execute('PRAGMA user_version = 16;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);
    final List<QueryRow> indexes = await second
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'tracker_link_concrete';",
        )
        .get();
    expect(indexes, hasLength(1));
    await second.close();

    raw.execute('PRAGMA user_version = 16;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });

  test('upgrade from v17 adds the extension base uid column', () async {
    final Database raw = sqlite3.openInMemory();
    addTearDown(raw.dispose);

    final WakaranaiDatabase first = await _open(raw);
    await first.close();

    raw.execute('ALTER TABLE extension_table DROP COLUMN base_uid;');
    raw.execute('PRAGMA user_version = 17;');

    final WakaranaiDatabase second = await _open(raw);
    expect(await _userVersion(second), second.schemaVersion);
    final List<QueryRow> columns = await second
        .customSelect("SELECT name FROM pragma_table_info('extension_table') "
            "WHERE name = 'base_uid';")
        .get();
    expect(columns, hasLength(1));
    await second.close();

    raw.execute('PRAGMA user_version = 17;');
    final WakaranaiDatabase replayed = await _open(raw);
    expect(await _userVersion(replayed), replayed.schemaVersion);
    await replayed.close();
  });
}
