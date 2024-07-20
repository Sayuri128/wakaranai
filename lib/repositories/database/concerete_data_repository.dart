import 'package:drift/drift.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

import '../../../data/domain/chapter_activity_domain/chapter_activity_domain.dart';

class ConcreteDataRepository extends BaseRepository<ChapterActivityDomain,
    ChapterActivityTableCompanion, ChapterActivityTableData> {
  ConcreteDataRepository({required super.database});

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
