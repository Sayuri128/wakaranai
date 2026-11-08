import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';

class _FakeSettingsCubit extends Fake implements SettingsCubit {
  @override
  SettingsState get state => SettingsInitial();
}

class _GatedClient extends MangaApiClient {
  _GatedClient() : super(code: '');

  int pageCalls = 0;
  Completer<Pages>? gate;

  @override
  Future<Pages> getPages({
    required String uid,
    required Map<String, dynamic>? data,
  }) {
    pageCalls++;
    final Completer<Pages>? pending = gate;
    if (pending != null) {
      return pending.future;
    }
    return Future<Pages>.value(
      Pages(chapterUid: uid, value: const <String>['https://example.com/1']),
    );
  }

  @override
  Future<Map<String, String>> getImageHeaders({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return <String, String>{};
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

const Chapter _chapter =
    Chapter(uid: 'c1', title: 'Chapter 1', data: <String, dynamic>{});

const ChaptersGroup _group =
    ChaptersGroup(title: 'Main', elements: <Chapter>[_chapter]);

ChapterViewerData _data(MangaApiClient client) {
  return ChapterViewerData(
    apiClient: client,
    configInfo: _config,
    group: _group,
    chapter: _chapter,
    concreteView: const MangaConcreteView(
      uid: 'title-1',
      cover: '',
      title: 'Title',
      alternativeTitles: <String>[],
      description: '',
      tags: <String>[],
      status: MangaStatus.UNDEFINED,
      groups: <ChaptersGroup>[_group],
    ),
  );
}

void main() {
  late WakaranaiDatabase database;
  late _GatedClient client;
  late ChapterViewCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    client = _GatedClient();
    cubit = ChapterViewCubit(
      apiClient: client,
      settingsCubit: _FakeSettingsCubit(),
      pageController: PageController(),
      itemScrollController: ItemScrollController(),
      initialPage: 1,
      concreteDataRepository: ConcreteDataRepository(database: database),
      chapterActivityRepository: ChapterActivityRepository(database: database),
      downloadRepository: DownloadRepository(database: database),
    );
  });

  tearDown(() async {
    await cubit.close();
    await database.close();
  });

  test('a retry shows loading and repeated taps share one open', () async {
    final Completer<Pages> failingGate = Completer<Pages>();
    client.gate = failingGate;
    final Future<void> failedOpen = cubit.init(_data(client));
    await pumpEventQueue();
    failingGate.completeError(Exception('network down'));
    await failedOpen;
    expect(cubit.state, isA<ChapterViewError>());

    final Completer<Pages> retryGate = Completer<Pages>();
    client.gate = retryGate;
    final int callsBefore = client.pageCalls;
    final Future<void> firstRetry = cubit.init(_data(client));
    expect(cubit.state, isA<ChapterViewInit>());
    final Future<void> secondRetry = cubit.init(_data(client));
    final Future<void> thirdRetry = cubit.init(_data(client));
    await pumpEventQueue();

    expect(client.pageCalls - callsBefore, 1);

    retryGate.complete(
      const Pages(chapterUid: 'c1', value: <String>['https://example.com/1']),
    );
    await Future.wait(<Future<void>>[firstRetry, secondRetry, thirdRetry]);

    expect(cubit.state, isA<ChapterViewInitialized>());
  });

  test('an open finishing after close does not emit', () async {
    final Completer<Pages> gate = Completer<Pages>();
    client.gate = gate;
    final Future<void> opening = cubit.init(_data(client));
    await pumpEventQueue();
    await cubit.close();

    gate.completeError(Exception('late failure'));
    await opening;

    expect(cubit.isClosed, isTrue);
  });
}
