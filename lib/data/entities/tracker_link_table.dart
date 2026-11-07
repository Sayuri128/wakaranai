import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracker_link_concrete',
  columns: <Symbol>{#concreteUid},
)
class TrackerLinkTable extends Table {
  TextColumn get concreteUid => text()();

  TextColumn get trackerId => text()();

  TextColumn get extensionUid => text()();

  TextColumn get mediaType => text()();

  IntColumn get remoteId => integer()();

  TextColumn get remoteTitle => text()();

  TextColumn get status => text()();

  IntColumn get progress => integer().withDefault(const Constant(0))();

  IntColumn get totalCount => integer().nullable()();

  IntColumn get pendingProgress => integer().nullable()();

  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{concreteUid, trackerId};
}
