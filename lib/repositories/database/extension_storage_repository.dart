import 'package:drift/drift.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

typedef StorageClock = DateTime Function();

class ExtensionStorageRepository {
  ExtensionStorageRepository({required this.database, StorageClock? clock})
      : _clock = clock ?? DateTime.now;

  final WakaranaiDatabase database;
  final StorageClock _clock;

  int get _nowMillis => _clock().millisecondsSinceEpoch;

  Future<String?> read(String extensionUid, String key) async {
    final ExtensionStorageTableData? row = await (database
            .select(database.extensionStorageTable)
          ..where((tbl) =>
              tbl.extensionUid.equals(extensionUid) & tbl.entryKey.equals(key)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    if (_isExpired(row.expiresAt)) {
      await _deleteExpiredEntry(extensionUid, key);
      return null;
    }
    return row.value;
  }

  Future<void> write(
    String extensionUid,
    String key,
    String value, {
    Duration? ttl,
  }) async {
    final int now = _nowMillis;
    final int? expiresAt = ttl == null ? null : now + ttl.inMilliseconds;
    await database.into(database.extensionStorageTable).insertOnConflictUpdate(
          ExtensionStorageTableCompanion.insert(
            extensionUid: extensionUid,
            entryKey: key,
            value: value,
            expiresAt: Value<int?>(expiresAt),
            updatedAt: now,
          ),
        );
  }

  Future<void> remove(String extensionUid, String key) async {
    await (database.delete(database.extensionStorageTable)
          ..where((tbl) =>
              tbl.extensionUid.equals(extensionUid) & tbl.entryKey.equals(key)))
        .go();
  }

  Future<int> clearExtension(String extensionUid) {
    return (database.delete(database.extensionStorageTable)
          ..where((tbl) => tbl.extensionUid.equals(extensionUid)))
        .go();
  }

  Future<int> countEntries(String extensionUid) async {
    final Expression<int> count = database.extensionStorageTable.entryKey.count();
    final TypedResult result = await (database
            .selectOnly(database.extensionStorageTable)
          ..addColumns(<Expression<Object>>[count])
          ..where(database.extensionStorageTable.extensionUid
                  .equals(extensionUid) &
              _notExpired(database.extensionStorageTable.expiresAt)))
        .getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> pruneExpired() {
    final int now = _nowMillis;
    return (database.delete(database.extensionStorageTable)
          ..where((tbl) =>
              tbl.expiresAt.isNotNull() &
              tbl.expiresAt.isSmallerOrEqualValue(now)))
        .go();
  }

  Future<void> _deleteExpiredEntry(String extensionUid, String key) async {
    final int now = _nowMillis;
    await (database.delete(database.extensionStorageTable)
          ..where((tbl) =>
              tbl.extensionUid.equals(extensionUid) &
              tbl.entryKey.equals(key) &
              tbl.expiresAt.isNotNull() &
              tbl.expiresAt.isSmallerOrEqualValue(now)))
        .go();
  }

  bool _isExpired(int? expiresAt) {
    return expiresAt != null && expiresAt <= _nowMillis;
  }

  Expression<bool> _notExpired(GeneratedColumn<int> expiresAt) {
    return expiresAt.isNull() | expiresAt.isBiggerThanValue(_nowMillis);
  }
}
