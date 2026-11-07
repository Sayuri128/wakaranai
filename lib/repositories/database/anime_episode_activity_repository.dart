import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

class AnimeEpisodeActivityRepository extends BaseRepository<
    AnimeEpisodeActivityDomain,
    AnimeEpisodeActivityTableCompanion,
    AnimeEpisodeActivityTableData> {
  AnimeEpisodeActivityRepository({required super.database}) {
    _concreteDataRepository = ConcreteDataRepository(database: database);
  }

  late final ConcreteDataRepository _concreteDataRepository;

  Future<List<AnimeEpisodeActivityDomain>?> getAllActivitiesByConcreteId(
      String uid) async {
    final concrete = await _concreteDataRepository
        .getBy<$ConcreteDataTableTable>(uid, where: (tbl) => tbl.uid);

    if (concrete == null) {
      return null;
    } else {
      return getAllBy<$AnimeEpisodeActivityTableTable>(concrete.id,
          where: (tbl) => tbl.concreteId);
    }
  }

  Future<AnimeEpisodeActivityDomain?> markCompleted(
    AnimeEpisodeActivityDomain activity,
  ) async {
    final AnimeEpisodeActivityDomain? existing =
        await getBy<$AnimeEpisodeActivityTableTable>(
      activity.uid,
      where: (tbl) => tbl.uid,
    );
    return createUpdateBy<$AnimeEpisodeActivityTableTable, String>(
      AnimeEpisodeActivityDomain(
        id: activity.id,
        uid: activity.uid,
        title: activity.title,
        timestamp: activity.timestamp,
        data: activity.data,
        concreteId: activity.concreteId,
        watchedTime: existing?.watchedTime ?? activity.watchedTime,
        totalTime: existing?.totalTime ?? activity.totalTime,
        createdAt: activity.createdAt,
      ),
      by: (AnimeEpisodeActivityDomain domain) => domain.uid,
      where: (tbl) => tbl.uid,
    );
  }

  @override
  DeleteStatement deleteStatement() {
    return database.animeEpisodeActivityTable.delete();
  }

  @override
  AnimeEpisodeActivityDomain fromDrift(AnimeEpisodeActivityTableData data) {
    return AnimeEpisodeActivityDomain(
      id: data.id,
      uid: data.uid,
      title: data.title,
      timestamp: data.timestamp,
      data: data.data,
      concreteId: data.concreteId,
      watchedTime: data.watchedTime,
      totalTime: data.totalTime,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
  
  @override
  InsertStatement insertStatement() {
    return database.animeEpisodeActivityTable.insert();
  }

  @override
  SimpleSelectStatement selectStatement({bool distinct = false}) {
    return database.animeEpisodeActivityTable.select();
  }

  @override
  AnimeEpisodeActivityTableCompanion toDrift(AnimeEpisodeActivityDomain domain,
      {bool update = false, bool create = false}) {
    return domain.toDrift(update: update, create: create);
  }

  @override
  UpdateStatement updateStatement() {
    return database.animeEpisodeActivityTable.update();
  }
}
