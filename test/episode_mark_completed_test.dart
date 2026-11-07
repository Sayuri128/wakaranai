import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

void main() {
  late WakaranaiDatabase database;
  late AnimeEpisodeActivityRepository activityRepository;
  late int concreteId;

  setUp(() async {
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    activityRepository = AnimeEpisodeActivityRepository(database: database);
    final ConcreteDataDomain? concrete =
        await ConcreteDataRepository(database: database).create(
      ConcreteDataDomain(
        id: 0,
        uid: 'anime-1',
        extensionUid: 'ext',
        title: 'Anime',
        createdAt: DateTime(2024),
      ),
    );
    concreteId = concrete!.id;
  });

  tearDown(() async {
    await database.close();
  });

  AnimeEpisodeActivityDomain activity({int? watchedTime, int? totalTime}) {
    return AnimeEpisodeActivityDomain(
      id: 0,
      uid: 'episode-1',
      title: 'Episode 1',
      concreteId: concreteId,
      data: '{}',
      watchedTime: watchedTime,
      totalTime: totalTime,
      createdAt: DateTime(2024, 5),
    );
  }

  Future<AnimeEpisodeActivityDomain?> readActivity() {
    return activityRepository.getBy<$AnimeEpisodeActivityTableTable>(
      'episode-1',
      where: (tbl) => tbl.uid,
    );
  }

  test('marking a watched episode as completed keeps its progress', () async {
    await activityRepository.create(activity(watchedTime: 600, totalTime: 1440));

    await activityRepository.markCompleted(activity());

    final AnimeEpisodeActivityDomain? stored = await readActivity();
    expect(stored, isNotNull);
    expect(stored!.watchedTime, 600);
    expect(stored.totalTime, 1440);
  });

  test('marking an unseen episode as completed records it without times',
      () async {
    await activityRepository.markCompleted(activity());

    final AnimeEpisodeActivityDomain? stored = await readActivity();
    expect(stored, isNotNull);
    expect(stored!.watchedTime, isNull);
    expect(stored.totalTime, isNull);
  });
}
