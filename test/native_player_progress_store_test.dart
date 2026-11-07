import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

const AnimeVideo _episode = AnimeVideo(
  type: AnimeVideoType.IFRAME,
  uid: 'episode-1',
  src: 'https://cdn.test/embed/1',
  title: 'Episode 1',
  timestamp: null,
  data: <String, dynamic>{'id': 1},
);

const AnimeConcreteView _anime = AnimeConcreteView(
  uid: 'anime-1',
  cover: '',
  title: 'Anime',
  alternativeTitles: <String>[],
  description: '',
  tags: <String>[],
  groups: <AnimeVideoGroup>[],
  status: AnimeStatus.ONGOING,
);

void main() {
  late WakaranaiDatabase database;
  late ConcreteDataRepository concreteRepository;
  late AnimeEpisodeActivityRepository activityRepository;

  setUp(() {
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    concreteRepository = ConcreteDataRepository(database: database);
    activityRepository = AnimeEpisodeActivityRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  ActivityEpisodeProgressStore buildStore() {
    return ActivityEpisodeProgressStore(
      concreteDataRepository: concreteRepository,
      animeEpisodeActivityRepository: activityRepository,
      anime: _anime,
      episode: _episode,
    );
  }

  Future<int> addConcrete() async {
    final ConcreteDataDomain? created = await concreteRepository.create(
      ConcreteDataDomain(
        id: 0,
        uid: _anime.uid,
        extensionUid: 'ext',
        title: _anime.title,
        createdAt: DateTime(2024),
      ),
    );
    return created!.id;
  }

  Future<AnimeEpisodeActivityDomain?> readActivity() {
    return activityRepository.getBy<$AnimeEpisodeActivityTableTable>(
      _episode.uid,
      where: (tbl) => tbl.uid,
    );
  }

  test('records the episode and remembers the watched time', () async {
    await addConcrete();
    final ActivityEpisodeProgressStore store = buildStore();

    expect(await store.start(), isNull);
    expect((await readActivity())?.watchedTime, isNull);

    await store.save(
      const EpisodeProgress(watchedSeconds: 300, totalSeconds: 1440),
    );

    final AnimeEpisodeActivityDomain? activity = await readActivity();
    expect(activity?.watchedTime, 300);
    expect(activity?.totalTime, 1440);
  });

  test('reopening returns the saved progress without clearing it', () async {
    await addConcrete();
    await buildStore().start();
    final ActivityEpisodeProgressStore firstSession = buildStore();
    await firstSession.start();
    await firstSession.save(
      const EpisodeProgress(watchedSeconds: 610, totalSeconds: 1440),
    );

    final EpisodeProgress? resumed = await buildStore().start();

    expect(
      resumed,
      const EpisodeProgress(watchedSeconds: 610, totalSeconds: 1440),
    );
    expect((await readActivity())?.watchedTime, 610);
  });

  test('does nothing when the title was never saved', () async {
    final ActivityEpisodeProgressStore store = buildStore();

    expect(await store.start(), isNull);
    await store.save(
      const EpisodeProgress(watchedSeconds: 300, totalSeconds: 1440),
    );

    expect(await readActivity(), isNull);
  });
}
