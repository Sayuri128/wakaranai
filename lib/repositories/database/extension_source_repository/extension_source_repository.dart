import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/extension/extension_source_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';

class ExtensionSourceRepository extends BaseRepository<ExtensionSourceDomain> {
  ExtensionSourceRepository({required super.database});

  @override
  Future<ExtensionSourceDomain?> get(int id) async {
    try {
      final res = await (database.extensionSourceTable.select()
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      return ExtensionSourceDomain.fromDrift(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExtensionSourceDomain?> create(ExtensionSourceDomain domain) async {
    try {
      final res =
          await (database.extensionSourceTable.insert().insert(domain.toDrift(
                create: true,
              )));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExtensionSourceDomain>> getAll() async {
    try {
      final res = await (database.extensionSourceTable.select()).get();
      return res.map((e) => ExtensionSourceDomain.fromDrift(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ExtensionSourceDomain?> update(ExtensionSourceDomain domain) async {
    try {
      final res = await (database.extensionSourceTable.update()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .write(domain.toDrift(update: true));
      return get(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExtensionSourceDomain?> delete(ExtensionSourceDomain domain) async {
    try {
      final res = await (database.extensionSourceTable.delete()
            ..where((tbl) => tbl.id.equals(domain.id)))
          .go();
      return get(res);
    } catch (e) {
      return null;
    }
  }
}
