import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/extension/extension_source_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class ExtensionSourceRepository extends BaseRepository<ExtensionSourceDomain,
    ExtensionSourceTableCompanion, ExtensionSourceTableData> {
  ExtensionSourceRepository({required super.database});

  @override
  DeleteStatement deleteStatement() {
    return database.extensionSourceTable.delete();
  }

  @override
  fromDrift(data) {
    return ExtensionSourceDomain.fromDrift(data);
  }

  @override
  InsertStatement insertStatement() {
    return database.extensionSourceTable.insert();
  }

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) {
    return database.extensionSourceTable.select();
  }

  @override
  ExtensionSourceTableCompanion toDrift(domain,
      {bool update = false, bool create = false}) {
    return domain.toDrift(update: update, create: create);
  }

  @override
  UpdateStatement updateStatement() {
    return database.extensionSourceTable.update();
  }
}
