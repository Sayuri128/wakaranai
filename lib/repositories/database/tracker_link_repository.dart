import 'package:drift/drift.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';

class TrackerLinkRepository {
  TrackerLinkRepository({required this.database});

  final WakaranaiDatabase database;

  Future<List<TrackerLink>> linksFor(String concreteUid) async {
    final List<TrackerLinkTableData> rows =
        await (database.select(database.trackerLinkTable)
              ..where((tbl) => tbl.concreteUid.equals(concreteUid)))
            .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Stream<List<TrackerLink>> watchLinksFor(String concreteUid) {
    return (database.select(database.trackerLinkTable)
          ..where((tbl) => tbl.concreteUid.equals(concreteUid)))
        .watch()
        .map((List<TrackerLinkTableData> rows) =>
            rows.map(_fromRow).toList(growable: false));
  }

  Future<List<TrackerLink>> pending() async {
    final List<TrackerLinkTableData> rows =
        await (database.select(database.trackerLinkTable)
              ..where((tbl) => tbl.pendingProgress.isNotNull()))
            .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> save(TrackerLink link) async {
    await database.into(database.trackerLinkTable).insertOnConflictUpdate(
          TrackerLinkTableCompanion.insert(
            concreteUid: link.concreteUid,
            trackerId: link.trackerId.name,
            extensionUid: link.extensionUid,
            mediaType: link.mediaType.name,
            remoteId: link.remoteId,
            remoteTitle: link.remoteTitle,
            status: link.status.name,
            progress: Value<int>(link.progress),
            totalCount: Value<int?>(link.totalCount),
            pendingProgress: Value<int?>(link.pendingProgress),
            syncedAt: Value<int?>(link.syncedAt?.millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> remove(String concreteUid, TrackerId trackerId) async {
    await (database.delete(database.trackerLinkTable)
          ..where((tbl) =>
              tbl.concreteUid.equals(concreteUid) &
              tbl.trackerId.equals(trackerId.name)))
        .go();
  }

  Future<void> removeAllFor(TrackerId trackerId) async {
    await (database.delete(database.trackerLinkTable)
          ..where((tbl) => tbl.trackerId.equals(trackerId.name)))
        .go();
  }

  TrackerLink _fromRow(TrackerLinkTableData row) {
    final int? syncedAt = row.syncedAt;
    return TrackerLink(
      concreteUid: row.concreteUid,
      trackerId: TrackerId.values.byName(row.trackerId),
      extensionUid: row.extensionUid,
      mediaType: TrackerMediaType.values.byName(row.mediaType),
      remoteId: row.remoteId,
      remoteTitle: row.remoteTitle,
      status: TrackerStatus.values.byName(row.status),
      progress: row.progress,
      totalCount: row.totalCount,
      pendingProgress: row.pendingProgress,
      syncedAt: syncedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(syncedAt),
    );
  }
}
