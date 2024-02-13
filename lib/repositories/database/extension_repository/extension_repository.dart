import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/extension/extension_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class ExtensionRepository extends BaseRepository<ExtensionDomain> {
  ExtensionRepository({
    required super.database,
  });

  @override
  Future<ExtensionDomain?> get(int id) async {
    try {
      final res = await (database.extensionTable.select()
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      return ExtensionDomain.fromDrift(res);
    } catch (e) {
      return null;
    }
  }

  Future<ExtensionDomain?> getByUid(String uid) async {
    try {
      final res = await (database.extensionTable.select()
            ..where((tbl) => tbl.uid.equals(uid)))
          .getSingle();

      return ExtensionDomain.fromDrift(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExtensionDomain?> create(ExtensionDomain domain) async {
    try {
      final res = await (database.extensionTable.insert().insert(domain.toDrift(
            create: true,
          )));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExtensionDomain?> delete(ExtensionDomain domain) async {
    try {
      final res = await (database.extensionTable.delete()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .go();
      return get(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExtensionDomain>> getAll() async {
    try {
      final res = await database.extensionTable.select().get();
      return res.map((e) => ExtensionDomain.fromDrift(e)).toList();
    } catch (e) {
      return Future.value([]);
    }
  }

  @override
  Future<ExtensionDomain?> update(ExtensionDomain domain) async {
    try {
      final res = await (database.extensionTable.update()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .write(domain.toDrift(update: true));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  Future<ExtensionDomain?> updateByUid(ExtensionDomain domain) async {
    try {
      final res = await (database.extensionTable.update()
            ..where((tbl) => tbl.uid.equals(domain.config.uid)))
          .write(domain.toDrift(update: true));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  Future<ExtensionDomain?> createUpdateByUid(ExtensionDomain domain) async {
    try {
      return await database.transaction(() async {
        final existing = await getByUid(domain.config.uid);

        if (existing != null) {
          return await updateByUid(domain.copyWith(id: existing.id));
        } else {
          return await create(domain);
        }
      });
    } catch (e) {
      return null;
    }
  }
}
