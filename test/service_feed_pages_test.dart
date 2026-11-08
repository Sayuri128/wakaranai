import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/service_view/gallery_feed_memory.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_body.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_entry.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';

typedef _Gallery = ServiceGalleryCubit<MangaApiClient, MangaGalleryView>;

const String _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

const int _itemsPerPage = 30;

class _GalleryCall {
  const _GalleryCall(this.page, this.query, this.feed, this.filterCount);

  final int page;
  final String? query;
  final String? feed;
  final int filterCount;
}

class _FakeClient extends MangaApiClient {
  _FakeClient() : super(code: '');

  final List<_GalleryCall> calls = <_GalleryCall>[];
  final Set<String> failingFeeds = <String>{};

  List<_GalleryCall> callsFor(String? feed) {
    return calls.where((_GalleryCall call) => call.feed == feed).toList();
  }

  @override
  Future<List<MangaGalleryView>> getGallery({
    required int page,
    String? query,
    List<FilterData>? filters,
    String? feed,
    int? pageSize,
  }) async {
    calls.add(_GalleryCall(page, query, feed, filters?.length ?? 0));
    if (failingFeeds.contains(feed)) {
      throw const SourceError(SourceErrorKind.sourceDown);
    }
    final String label = _label(feed, query);
    return <MangaGalleryView>[
      for (int index = 0; index < _itemsPerPage; index++)
        MangaGalleryView(
          uid: '$page:$index',
          cover: _pixel,
          title: '$label p$page #$index',
        ),
    ];
  }

  String _label(String? feed, String? query) {
    final String base = feed ?? 'all';
    if (query == null || query.isEmpty) {
      return base;
    }
    return '$base:$query';
  }

  @override
  Future<Map<String, String>> getImageHeaders({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return <String, String>{};
  }
}

class _Kind extends ServiceGalleryKind<MangaApiClient, MangaGalleryView> {
  const _Kind();

  @override
  String get concreteRoute => '/concrete';

  @override
  String titleOf(MangaGalleryView galleryView) => galleryView.title;

  @override
  String coverOf(MangaGalleryView galleryView) => galleryView.cover;

  @override
  String? statusOf(MangaGalleryView galleryView) => null;

  @override
  Future<List<BaseActivityDomain>?> loadActivities(
    BuildContext context,
    String concreteUid,
  ) async {
    return null;
  }

  @override
  Object concreteArguments({
    required MangaApiClient client,
    required ConfigInfo configInfo,
    required MangaGalleryView galleryView,
    required Map<String, String> coverHeaders,
  }) {
    return galleryView.uid;
  }
}

final GalleryFilterSwitcher _completedFilter = GalleryFilterSwitcher(
  onValue: '1',
  offValue: '0',
  type: GalleryFilterType.SWITCHER,
  paramName: 'Completed',
  param: 'completed',
);

const List<GalleryFeed> _feeds = <GalleryFeed>[
  GalleryFeed(id: 'popular', title: 'Popular'),
  GalleryFeed(id: 'latest', title: 'Latest'),
  GalleryFeed(id: 'top', title: 'Top'),
];

ConfigInfo _config({List<GalleryFeed> feeds = _feeds}) {
  return ConfigInfo(
    name: 'Feeds',
    uid: 'ext.feeds',
    logoUrl: '',
    nsfw: false,
    language: 'en',
    version: 1,
    filters: <GalleryFilter>[_completedFilter],
    type: ConfigInfoType.MANGA,
    searchAvailable: true,
    feeds: feeds,
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (int frame = 0; frame < 30; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

int _selectedTab(WidgetTester tester) {
  return tester.widget<SegmentedTabs>(find.byType(SegmentedTabs)).selectedIndex;
}

Future<void> _swipeToNextFeed(WidgetTester tester) async {
  await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
  await _settle(tester);
}

Future<void> _swipeToPreviousFeed(WidgetTester tester) async {
  await tester.fling(find.byType(PageView), const Offset(400, 0), 1500);
  await _settle(tester);
}

void main() {
  late WakaranaiDatabase database;
  late _FakeClient client;
  late GalleryFeedMemory memory;
  late TextEditingController searchController;

  setUpAll(() => S.load(const Locale('en')));

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    client = _FakeClient();
    memory = GalleryFeedMemory();
    searchController = TextEditingController();
  });

  tearDown(() async {
    searchController.dispose();
    await database.close();
  });

  LibraryCubit buildLibrary() {
    return LibraryCubit(
      libraryEntryRepository: LibraryEntryRepository(database: database),
      categoryRepository: CategoryRepository(database: database),
      libraryUpdateRepository: LibraryUpdateRepository(database: database),
      extensionResolver: ExtensionResolver(
        extensionRepository: ExtensionRepository(database: database),
        extensionSourceRepository: ExtensionSourceRepository(
          database: database,
        ),
      ),
    );
  }

  Future<_Gallery> pumpGallery(WidgetTester tester, ConfigInfo config) async {
    final _Gallery gallery = _Gallery(
      client: client,
      configInfo: config,
      feedMemory: memory,
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: Text('opened ${settings.arguments}')),
      ),
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<GalleryLayoutCubit>(
            create: (_) => GalleryLayoutCubit(),
          ),
          BlocProvider<LibraryCubit>(create: (_) => buildLibrary()),
          BlocProvider<_Gallery>(create: (_) => gallery),
        ],
        child: ServiceViewerBody<MangaApiClient, MangaGalleryView>(
          kind: const _Kind(),
          scaffold: GlobalKey(),
          apiClient: client,
          configInfo: config,
          searchController: searchController,
        ),
      ),
    ));
    await tester.pump();
    gallery.start();
    await _settle(tester);
    return gallery;
  }

  group('extensions with feeds', () {
    testWidgets('show the feed tabs and load only the opened feed',
        (WidgetTester tester) async {
      await pumpGallery(tester, _config());

      expect(find.byType(SegmentedTabs), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('popular p1 #0'), findsOneWidget);
      expect(client.calls, hasLength(1));
      expect(client.calls.single.feed, 'popular');
      expect(_selectedTab(tester), 0);
    });

    testWidgets('load a feed on its first visit and keep the others intact',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(tester, _config());
      await tester.drag(find.text('popular p1 #0'), const Offset(0, -200));
      await _settle(tester);
      final Offset scrolled = tester.getTopLeft(find.text('popular p1 #4'));
      expect(_selectedTab(tester), 0);

      await _swipeToNextFeed(tester);

      expect(_selectedTab(tester), 1);
      expect(gallery.state.selectedFeedId, 'latest');
      expect(client.callsFor('latest'), hasLength(1));
      expect(client.callsFor('top'), isEmpty);
      expect(find.text('latest p1 #0'), findsOneWidget);

      await _swipeToPreviousFeed(tester);

      expect(_selectedTab(tester), 0);
      expect(client.callsFor('popular'), hasLength(1));
      expect(client.callsFor('latest'), hasLength(1));
      expect(tester.getTopLeft(find.text('popular p1 #4')), scrolled);
      expect(memory.feedFor('ext.feeds'), 'popular');
    });

    testWidgets('a tab tap pages to its feed without loading the ones between',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(tester, _config());

      await tester.tap(find.text('Top'));
      await _settle(tester);

      expect(_selectedTab(tester), 2);
      expect(gallery.state.selectedFeedId, 'top');
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        2,
      );
      expect(find.text('top p1 #0'), findsOneWidget);
      expect(client.callsFor('latest'), isEmpty);
      expect(memory.feedFor('ext.feeds'), 'top');

      await tester.tap(find.text('Popular'));
      await _settle(tester);

      expect(_selectedTab(tester), 0);
      expect(find.text('popular p1 #0'), findsOneWidget);
      expect(client.callsFor('popular'), hasLength(1));
    });

    testWidgets('pull to refresh inside a feed page reloads only that feed',
        (WidgetTester tester) async {
      await pumpGallery(tester, _config());
      await _swipeToNextFeed(tester);
      client.calls.clear();

      await tester.drag(find.text('latest p1 #0'), const Offset(0, 300));
      await _settle(tester);

      expect(_selectedTab(tester), 1);
      expect(client.callsFor('latest').single.page, 1);
      expect(client.callsFor('popular'), isEmpty);
    });

    testWidgets('a typed source error stays on the feed page that failed',
        (WidgetTester tester) async {
      client.failingFeeds.add('latest');
      await pumpGallery(tester, _config());

      await _swipeToNextFeed(tester);

      expect(find.byType(SourceErrorView), findsOneWidget);
      expect(find.byType(SegmentedTabs), findsOneWidget);

      await _swipeToPreviousFeed(tester);

      expect(find.byType(SourceErrorView), findsNothing);
      expect(find.text('popular p1 #0'), findsOneWidget);
    });

    testWidgets('opening a title ignores the heroes kept in other feed pages',
        (WidgetTester tester) async {
      await pumpGallery(tester, _config());
      await _swipeToNextFeed(tester);

      await tester.tap(find.text('latest p1 #0'));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('opened 1:0'), findsOneWidget);
    });

    testWidgets('open on the feed remembered for the extension',
        (WidgetTester tester) async {
      memory.remember('ext.feeds', 'latest');

      await pumpGallery(tester, _config());

      expect(_selectedTab(tester), 1);
      expect(find.text('latest p1 #0'), findsOneWidget);
      expect(client.calls.single.feed, 'latest');
    });

    testWidgets('share filters across loaded and later visited feeds',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(tester, _config());
      await _swipeToNextFeed(tester);
      client.calls.clear();

      gallery.applyFilters(<String, FilterData>{
        _completedFilter.param:
            FilterDataSwitcher(on: true, filter: _completedFilter),
      });
      await _settle(tester);

      expect(client.callsFor('popular').single.filterCount, 1);
      expect(client.callsFor('latest').single.filterCount, 1);
      expect(client.callsFor('top'), isEmpty);
      expect(find.text('1'), findsOneWidget);

      await _swipeToNextFeed(tester);

      expect(client.callsFor('top').single.filterCount, 1);
      expect(find.text('top p1 #0'), findsOneWidget);
    });

    testWidgets('a preference change reloads every loaded feed',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(tester, _config());
      await _swipeToNextFeed(tester);
      client.calls.clear();

      unawaited(reloadServiceViewAfterPreferenceChange(gallery));
      await _settle(tester);

      expect(client.callsFor('popular').single.page, 1);
      expect(client.callsFor('latest').single.page, 1);
      expect(client.callsFor('top'), isEmpty);
    });

    testWidgets('a search replaces the feed pages until it is cleared',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(tester, _config());
      await tester.drag(find.text('popular p1 #0'), const Offset(0, -200));
      await _settle(tester);
      final Offset scrolled = tester.getTopLeft(find.text('popular p1 #4'));

      await tester.enterText(find.byType(TextField), 'naruto');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await _settle(tester);

      expect(find.byType(SegmentedTabs), findsNothing);
      expect(find.text('popular p1 #4'), findsNothing);
      expect(find.text('all:naruto p1 #0'), findsOneWidget);
      expect(client.callsFor(null).single.query, 'naruto');
      expect(find.byType(InputChip), findsOneWidget);

      await tester.tap(find.descendant(
        of: find.byType(InputChip),
        matching: find.byIcon(Icons.close_rounded),
      ));
      await _settle(tester);

      expect(gallery.searchGallery, isNull);
      expect(find.byType(InputChip), findsNothing);
      expect(find.byType(SegmentedTabs), findsOneWidget);
      expect(find.text('all:naruto p1 #0'), findsNothing);
      expect(tester.getTopLeft(find.text('popular p1 #4')), scrolled);
      expect(client.callsFor('popular'), hasLength(1));
    });
  });

  group('extensions without feeds', () {
    testWidgets('show a single gallery with no tabs or pages',
        (WidgetTester tester) async {
      final _Gallery gallery = await pumpGallery(
        tester,
        _config(feeds: const <GalleryFeed>[]),
      );

      expect(find.byType(SegmentedTabs), findsNothing);
      expect(find.byType(PageView), findsNothing);
      expect(find.text('all p1 #0'), findsOneWidget);
      expect(client.calls.single.feed, isNull);

      gallery.search('naruto');
      await _settle(tester);

      expect(find.text('all:naruto p0 #0'), findsOneWidget);
      expect(client.calls.last.query, 'naruto');
      expect(find.byType(InputChip), findsOneWidget);

      await tester.tap(find.descendant(
        of: find.byType(InputChip),
        matching: find.byIcon(Icons.close_rounded),
      ));
      await _settle(tester);

      expect(find.byType(InputChip), findsNothing);
      expect(find.text('all p1 #0'), findsOneWidget);
      expect(client.calls.last.page, 1);
      expect(client.calls.last.feed, isNull);
    });
  });
}
