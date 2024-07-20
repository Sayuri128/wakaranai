import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/concrete_data_domain/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

import '../../../data/domain/chapter_activity_domain/chapter_activity_domain.dart';

class ConcreteDataRepository extends BaseRepository<ConcreteDataDomain,
    ConcreteDataTableCompanion, ConcreteDataTableData> {
  ConcreteDataRepository({required super.database});

  @override
  DeleteStatement deleteStatement() {
    return database.concreteDataTable.delete();
  }

  @override
  ConcreteDataDomain fromDrift(ConcreteDataTableData data) {
    return ConcreteDataDomain.fromDrift(data);
  }

  @override
  InsertStatement insertStatement() {
    return database.concreteDataTable.insert();
  }

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) {
    return database.concreteDataTable.select();
  }

  @override
  ConcreteDataTableCompanion toDrift(ConcreteDataDomain domain,
      {bool update = false, bool create = false}) {
    return domain.toDrift(update: update, create: create);
  }

  @override
  UpdateStatement updateStatement() {
    return database.concreteDataTable.update();
  }
}
