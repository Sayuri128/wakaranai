import 'package:drift/drift.dart';

@TableIndex(
  name: 'extension_storage_expires_at',
  columns: <Symbol>{#expiresAt},
)
class ExtensionStorageTable extends Table {
  TextColumn get extensionUid => text()();

  TextColumn get entryKey => text()();

  TextColumn get value => text()();

  IntColumn get expiresAt => integer().nullable()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{extensionUid, entryKey};
}
