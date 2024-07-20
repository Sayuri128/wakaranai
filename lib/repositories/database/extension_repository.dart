import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/extension/extension_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class ExtensionRepository extends BaseRepository<ExtensionDomain,
    ExtensionTableCompanion, ExtensionTableData> {
  ExtensionRepository({
    required super.database,
  });

  Future<ExtensionDomain?> getByUid(String uid) async {
    return getBy<$ExtensionTableTable>(
      uid,
      where: (tbl) => tbl.uid,
    );
  }

  Future<ExtensionDomain?> updateByUid(ExtensionDomain domain) async {
    return updateBy<$ExtensionTableTable, String>(
      domain,
      by: (domain) => domain.config.uid,
      where: (tbl) => tbl.uid,
    );
  }

  Future<ExtensionDomain?> createUpdateByUid(ExtensionDomain domain) async {
    return createUpdateBy<$ExtensionTableTable, String>(
      domain,
      by: (domain) => domain.config.uid,
      where: (tbl) => tbl.uid,
    );
  }

  @override
  DeleteStatement deleteStatement() {
    return database.extensionTable.delete();
  }

  @override
  ExtensionDomain fromDrift(ExtensionTableData data) {
    return ExtensionDomain.fromDrift(data);
  }

  @override
  InsertStatement insertStatement() {
    return database.extensionTable.insert();
  }

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) {
    return database.extensionTable.select();
  }

  @override
  ExtensionTableCompanion toDrift(ExtensionDomain domain,
      {bool update = false, bool create = false}) {
    return domain.toDrift(update: update, create: create);
  }

  @override
  UpdateStatement updateStatement() {
    return database.extensionTable.update();
  }
}
