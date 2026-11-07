import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';

typedef _Cubit
    = ConcreteViewCubit<MangaApiClient, MangaConcreteView, MangaGalleryView>;
typedef _Error
    = ConcreteViewError<MangaApiClient, MangaConcreteView, MangaGalleryView>;
typedef _Initialized = ConcreteViewInitialized<MangaApiClient,
    MangaConcreteView, MangaGalleryView>;

const String _titleUid = 'title-1';

class _FailingClient extends MangaApiClient {
  _FailingClient(this.error) : super(code: '');

  final Object error;

  @override
  Future<MangaConcreteView> getConcrete({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    throw error;
  }
}

const ConfigInfo _config = ConfigInfo(
  name: 'Test',
  uid: 'ext.test',
  logoUrl: '',
  nsfw: false,
  language: 'en',
  version: 1,
  filters: <GalleryFilter>[],
  type: ConfigInfoType.MANGA,
  searchAvailable: true,
);

MangaConcreteView _view() {
  return MangaConcreteView(
    uid: _titleUid,
    cover: '',
    title: 'Saved Title',
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: MangaStatus.UNDEFINED,
    groups: <ChaptersGroup>[
      ChaptersGroup(
        title: 'Main',
        elements: <Chapter>[
          Chapter(uid: 'c1', title: 'Chapter 1', data: const <String, dynamic>{}),
        ],
      ),
    ],
  );
}

void main() {
  late WakaranaiDatabase database;
  late ConcreteDataRepository concreteDataRepository;

  setUp(() {
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    concreteDataRepository = ConcreteDataRepository(database: database);
  });

  tearDown(() => database.close());

  _Cubit cubitFor(Object error) {
    return _Cubit(
      ConcreteViewState<MangaApiClient, MangaConcreteView, MangaGalleryView>(
        apiClient: _FailingClient(error),
        configInfo: _config,
      ),
      concreteDataRepository: concreteDataRepository,
      chapterActivityRepository: ChapterActivityRepository(database: database),
      animeEpisodeActivityRepository:
          AnimeEpisodeActivityRepository(database: database),
    );
  }

  Future<void> saveOfflineCopy() async {
    await concreteDataRepository.saveConcrete(
      _view(),
      galleryData: const <String, dynamic>{},
      extensionUid: _config.uid,
    );
  }

  test('a removed title shows the error and offers the saved details',
      () async {
    await saveOfflineCopy();
    final _Cubit cubit =
        cubitFor(const SourceError(SourceErrorKind.notFound, 'gone'));
    addTearDown(cubit.close);

    await cubit.getConcrete(_titleUid, const <String, dynamic>{});

    final _Error error = cubit.state as _Error;
    expect(error.error, isA<SourceError>());
    expect(error.hasOfflineData, isTrue);

    expect(await cubit.openOffline(_titleUid, const <String, dynamic>{}),
        isTrue);
    final _Initialized offline = cubit.state as _Initialized;
    expect(offline.offline, isTrue);
    expect(offline.concreteView.title, 'Saved Title');
  });

  test('a removed title without saved details has nothing to open', () async {
    final _Cubit cubit = cubitFor(const SourceError(SourceErrorKind.notFound));
    addTearDown(cubit.close);

    await cubit.getConcrete(_titleUid, const <String, dynamic>{});

    expect((cubit.state as _Error).hasOfflineData, isFalse);
  });

  test('a source that is down still falls back to the saved details',
      () async {
    await saveOfflineCopy();
    final _Cubit cubit =
        cubitFor(const SourceError(SourceErrorKind.sourceDown));
    addTearDown(cubit.close);

    await cubit.getConcrete(_titleUid, const <String, dynamic>{});

    expect((cubit.state as _Initialized).offline, isTrue);
  });

  test('a typed error without saved details keeps the error for display',
      () async {
    final _Cubit cubit =
        cubitFor(const SourceError(SourceErrorKind.regionBlocked));
    addTearDown(cubit.close);

    await cubit.getConcrete(_titleUid, const <String, dynamic>{});

    final _Error error = cubit.state as _Error;
    expect((error.error as SourceError).kind, SourceErrorKind.regionBlocked);
    expect(error.hasOfflineData, isFalse);
  });
}
