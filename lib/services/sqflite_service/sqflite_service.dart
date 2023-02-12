import 'package:sqflite/sqflite.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/models/serializable_object.dart';
import 'package:wakaranai/services/configs_source_service/configs_source_service.dart';
import 'package:wakaranai/services/library_service/library_service.dart';
import 'package:wakaranai/services/local_anime_gallery_view_service/local_anime_gallery_view_service.dart';
import 'package:wakaranai/services/local_api_clients_service/local_api_clients_service.dart';
import 'package:wakaranai/services/local_config_info_service/local_config_info_service.dart';
import 'package:wakaranai/services/local_manga_gallery_view_service/local_manga_gallery_view_service.dart';
import 'package:wakaranai/services/local_protector_config_service/local_protector_config_service.dart';
import 'package:wakaranai/services/sqflite_service/query_item.dart';

abstract class SqfliteService<T extends SqSerializableObject> {
  Database? _db;
  final String tableName;

  SqfliteService({required this.tableName});

  Future<Database> _open() async {
    // await deleteDatabase('${await getDatabasesPath()}/${Env.SQFLITE_DB_NAME}');
    return openDatabase('${await getDatabasesPath()}/${Env.SQFLITE_DB_NAME}',
        // singleInstance: true,
        version: 1,
        onOpen: (db) {},
        onUpgrade: (db, oldVersion, newVersion) async {},
        onCreate: (db, version) async {
      await db.transaction((Transaction txn) async {
        await txn.execute(ConfigsSourceService.createConfigsSourcesTable);
        await txn.execute(
            LocalMangaGalleryViewService.createLocalMangaGalleryViewTableName);
        await txn.execute(
            LocalAnimeGalleryViewService.createAnimeMangaGalleryViewTableName);

        // CONFIGS
        await txn.execute(
            LocalProtectorConfigService.createLocalProtectorConfigTable);
        await txn.execute(LocalConfigInfoService.createLocalConfigInfoTable);
        await txn.execute(LocalApiClientsService.createApiConfigsTable);

        await txn.execute(LibraryService.createLibraryTable);
      });
    });
  }

  Future<T> mapConfig(Map<String, dynamic> map);

  Future<Database> db() async {
    _db ??= await _open();
    return _db!;
  }

  Future<int> insert(T item) async {
    _db ??= await _open();

    return await _db!.insert(tableName, item.toMap());
  }

  Future<int> count({List<SqfliteQueryItem> query = const []}) async {
    final db = await _open();

    return Sqflite.firstIntValue(await db
        .rawQuery("SELECT COUNT(*) FROM $tableName WHERE ${query.map((e) {
      if (e is SqfliteQueryKeyValueItem) {
        return "${e.key} ${serializeSqfliteComparisonOperator(e.operator)} ${e.value}";
      } else if (e is SqfliteQueryOperatorItem) {
        return serializeSqfliteOperator(e.operator);
      }
      return "";
    })}"))!;
  }

  Future<List<Map<String, dynamic>>> queryMap(
      {List<SqfliteQueryItem> query = const [],
      int limit = 1,
      int? offset}) async {
    final db = await _open();

    return db.query(tableName,
        limit: limit,
        distinct: true,
        offset: offset,
        where: query.map((e) {
          if (e is SqfliteQueryKeyValueItem) {
            return "${e.key} ${serializeSqfliteComparisonOperator(e.operator)} ?";
          } else if (e is SqfliteQueryOperatorItem) {
            return serializeSqfliteOperator(e.operator);
          }
          return "";
        }).join(" "),
        whereArgs: query
            .whereType<SqfliteQueryKeyValueItem>()
            .cast<SqfliteQueryKeyValueItem>()
            .map((e) => e.value)
            .toList());
  }

  Future<List<T>> query(
      {List<SqfliteQueryItem> query = const [],
      int limit = 1,
      int? offset}) async {
    return (await Future.wait(
            (await queryMap(query: query, limit: limit, offset: offset))
                .map(mapConfig)))
        .toList();
  }

  Future<T> get(int id) async {
    _db ??= await _open();

    List<Map<String, dynamic>> maps =
        await _db!.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return await mapConfig(maps.first);
    }
    throw Exception();
  }

  Future<Map<String, dynamic>> getMap(int id) async {
    final db = await _open();
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw Exception("Api config with id $id does not exist");
    }

    return maps.first;
  }

  Future<void> delete(int id) async {
    _db ??= await _open();

    await _db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<T>> getAll() async {
    _db ??= await _open();

    return (await Future.wait(
            (await _db!.query(tableName)).map((e) => mapConfig(e))))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllMaps() async {
    final db = await _open();
    return (await db.query(tableName)).toList();
  }

  Future<void> clear() async {
    _db ??= await _open();

    await _db!.delete(tableName);
  }

  Future<void> deleteQuery({List<SqfliteQueryItem> query = const []}) async {
    final db = await _open();
    db.delete(tableName,
        where: query.map((e) {
          if (e is SqfliteQueryKeyValueItem) {
            return "${e.key} ${serializeSqfliteComparisonOperator(e.operator)} ?";
          } else if (e is SqfliteQueryOperatorItem) {
            return serializeSqfliteOperator(e.operator);
          }
          return "";
        }).join(" "),
        whereArgs: query
            .whereType<SqfliteQueryKeyValueItem>()
            .cast<SqfliteQueryKeyValueItem>()
            .map((e) => e.value)
            .toList());
  }
}
