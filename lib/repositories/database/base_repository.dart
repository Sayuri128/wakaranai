import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

abstract class BaseRepository<TDomain extends BaseDomain, TCompanion, TData>
    extends BaseRepositoryConverters<TDomain, TCompanion, TData> {
  final WakaranaiDatabase database;

  Future<TDomain?> createUpdateBy<TTable, TValue>(
    TDomain domain, {
    required TValue Function(TDomain) by,
    required GeneratedColumn Function(TTable) where,
  }) async {
    try {
      final byValue = by(domain);

      return await database.transaction(() async {
        final existing = await getBy<TTable>(
          byValue,
          where: where,
        );

        if (existing != null) {
          domain.id = existing.id;
          return await updateBy<TTable, TValue>(
            domain,
            by: by,
            where: where,);
        } else {
          return await create(domain);
        }
      });
    } catch (e) {
      return null;
    }
  }

  Future<TDomain?> updateBy<TTable, TValue>(
    TDomain domain, {
    required TValue Function(TDomain) by,
    required dynamic Function(TTable) where,
  }) async {
    try {
      final value = by(domain);
      await (updateStatement()
            ..where((tbl) => where(tbl).equals(value)))
          .write(domain.toDrift(update: true));
      return get(domain.id);
    } catch (e) {
      return null;
    }
  }

  Future<TDomain?> getBy<TTable>(
    dynamic value, {
    required GeneratedColumn Function(TTable) where,
    bool distinct = false,
  }) async {
    try {
      final res = await (selectStatement()
            ..where((tbl) => where(tbl).equals(value)))
          .getSingle();
      return fromDrift(res);
    } catch (e) {
      return null;
    }
  }

  Future<TDomain?> get(int id) async {
    try {
      final res = await (selectStatement()..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      return fromDrift(res);
    } catch (e) {
      return null;
    }
  }

  Future<TDomain?> create(TDomain domain) async {
    try {
      final res = await insertStatement().insert(domain.toDrift(
        create: true,
      ));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  Future<List<TDomain>> getAll() async {
    try {
      final res = await selectStatement().get();
      return res.map((e) => fromDrift(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TDomain>> getAllBy<TTable>(
    dynamic value, {
    required GeneratedColumn Function(TTable) where,
    bool distinct = false,
  }) async {
    try {
      final res = await (selectStatement()
            ..where((tbl) => where(tbl).equals(value)))
          .get();
      return res.map((e) => fromDrift(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<TDomain?> update(TDomain domain) async {
    try {
      final res = await (updateStatement()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .write(domain.toDrift(update: true));
      return get(domain.id);
    } catch (e) {
      return null;
    }
  }

  Future<TDomain?> delete(TDomain domain) async {
    try {
      final res = await (deleteStatement()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .go();
      return get(domain.id);
    } catch (e) {
      return null;
    }
  }

  BaseRepository({required this.database});
}

/// TODO: needs to be replaced once macros are released in dart 3.5.0
abstract class BaseRepositoryConverters<TDomain extends BaseDomain, TCompanion,
    TData> extends BaseRepositoryStatements {
  TDomain fromDrift(TData data);

  TCompanion toDrift(TDomain domain,
      {bool update = false, bool create = false});
}

/// BaseRepositoryStatements needs to be replaced later to avoid dynamic types
abstract class BaseRepositoryStatements {
  SimpleSelectStatement<dynamic, dynamic> selectStatement(
      {bool distinct = false});

  DeleteStatement<dynamic, dynamic> deleteStatement();

  InsertStatement<dynamic, dynamic> insertStatement();

  UpdateStatement<dynamic, dynamic> updateStatement();
}
