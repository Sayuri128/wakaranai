import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

class ChapterActivityRepository extends BaseRepository<ChapterActivityDomain,
    ChapterActivityTableCompanion, ChapterActivityTableData> {
  ChapterActivityRepository({required super.database}) {
    _concreteDataRepository = ConcreteDataRepository(database: database);
  }

  late final ConcreteDataRepository _concreteDataRepository;

  Future<List<ChapterActivityDomain>?> getAllActivitiesByConcreteId(
      String uid) async {
    final concrete = await _concreteDataRepository
        .getBy<$ConcreteDataTableTable>(uid, where: (tbl) => tbl.uid);

    if (concrete == null) {
      return null;
    } else {
      return getAllBy<$ChapterActivityTableTable>(concrete.id,
          where: (tbl) => tbl.concreteId);
    }
  }

  Future<ChapterActivityDomain?> markCompleted(
    ChapterActivityDomain activity, {
    int? completedPages,
  }) async {
    final ChapterActivityDomain? existing =
        await getBy<$ChapterActivityTableTable>(
      activity.uid,
      where: (tbl) => tbl.uid,
    );
    return createUpdateBy<$ChapterActivityTableTable, String>(
      _completedActivity(activity, existing, completedPages: completedPages),
      by: (ChapterActivityDomain domain) => domain.uid,
      where: (tbl) => tbl.uid,
    );
  }

  ChapterActivityDomain _completedActivity(
    ChapterActivityDomain activity,
    ChapterActivityDomain? existing, {
    int? completedPages,
  }) {
    if (completedPages != null) {
      return ChapterActivityDomain(
        id: existing?.id ?? activity.id,
        uid: activity.uid,
        title: activity.title,
        timestamp: activity.timestamp,
        data: activity.data,
        concreteId: activity.concreteId,
        readPages: completedPages,
        totalPages: completedPages,
        createdAt: existing?.createdAt ?? activity.createdAt,
      );
    }
    if (existing == null) {
      return activity.copyWith(readPages: 0, totalPages: 0);
    }
    final int totalPages = existing.totalPages;
    final int readPages = totalPages > 0 ? totalPages : existing.readPages;
    return ChapterActivityDomain(
      id: existing.id,
      uid: activity.uid,
      title: activity.title,
      timestamp: activity.timestamp,
      data: activity.data,
      concreteId: activity.concreteId,
      readPages: readPages,
      totalPages: totalPages,
      createdAt: existing.createdAt,
    );
  }

  @override
  DeleteStatement deleteStatement() {
    return database.chapterActivityTable.delete();
  }

  @override
  ChapterActivityDomain fromDrift(ChapterActivityTableData data) {
    return ChapterActivityDomain.fromDrift(data);
  }

  @override
  InsertStatement insertStatement() {
    return database.chapterActivityTable.insert();
  }

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) {
    return database.chapterActivityTable.select();
  }

  @override
  ChapterActivityTableCompanion toDrift(ChapterActivityDomain domain,
      {bool update = false, bool create = false}) {
    return domain.toDrift(update: update, create: create);
  }

  @override
  UpdateStatement updateStatement() {
    return database.chapterActivityTable.update();
  }
}
