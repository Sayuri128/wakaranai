import 'package:drift/src/runtime/query_builder/query_builder.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain/chapter_activity_domain.dart';
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
