import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/service_view/gallery_feed_memory.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';

typedef _Cubit = ServiceViewCubit<MangaApiClient, MangaGalleryView>;
typedef _Initialized
    = ServiceViewInitialized<MangaApiClient, MangaGalleryView>;

const String _emptyQuery = 'nothing';

class _GalleryCall {
  const _GalleryCall(this.page, this.query, this.feed);

  final int page;
  final String? query;
  final String? feed;
}

class _FakeClient extends MangaApiClient {
  _FakeClient() : super(code: '');

  final List<_GalleryCall> calls = <_GalleryCall>[];
  Object? failWith;

  _GalleryCall get lastCall => calls.last;

  @override
  Future<List<MangaGalleryView>> getGallery({
    required int page,
    String? query,
    List<FilterData>? filters,
    String? feed,
  }) async {
    calls.add(_GalleryCall(page, query, feed));
    final Object? error = failWith;
    if (error != null) {
      throw error;
    }
    if (query == _emptyQuery) {
      return <MangaGalleryView>[];
    }
    return <MangaGalleryView>[
      MangaGalleryView(
        uid: '${feed ?? 'none'}:${query ?? ''}:$page',
        cover: '',
        title: 'Title $page',
      ),
    ];
  }

  @override
  Future<Map<String, String>> getImageHeaders({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return <String, String>{};
  }
}

ConfigInfo _config({
  String uid = 'ext.feeds',
  List<GalleryFeed> feeds = const <GalleryFeed>[],
}) {
  return ConfigInfo(
    name: 'Feeds',
    uid: uid,
    logoUrl: '',
    nsfw: false,
    language: 'en',
    version: 1,
    filters: const <GalleryFilter>[],
    type: ConfigInfoType.MANGA,
    searchAvailable: true,
    feeds: feeds,
  );
}

const List<GalleryFeed> _feeds = <GalleryFeed>[
  GalleryFeed(id: 'popular', title: 'Popular'),
  GalleryFeed(id: 'latest', title: 'Latest'),
];

Future<_Initialized> _settled(_Cubit cubit) async {
  for (int attempt = 0; attempt < 200; attempt++) {
    final ServiceViewState<MangaApiClient, MangaGalleryView> state =
        cubit.state;
    if (state is _Initialized && !state.loading) {
      return state;
    }
    await Future<void>.delayed(Duration.zero);
  }
  fail('the gallery never finished loading');
}

Future<void> _drain() async {
  for (int attempt = 0; attempt < 50; attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeClient client;
  late GalleryFeedMemory memory;
  late _Cubit cubit;

  setUp(() {
    client = _FakeClient();
    memory = GalleryFeedMemory();
    cubit = _Cubit(
      ServiceViewInitial<MangaApiClient, MangaGalleryView>(client: client),
      feedMemory: memory,
    );
  });

  tearDown(() => cubit.close());

  group('extensions without feeds', () {
    test('load and page exactly as before, with no feed', () async {
      cubit.init(_config());
      final _Initialized loaded = await _settled(cubit);

      expect(loaded.selectedFeed, isNull);
      expect(cubit.selectedFeed, isNull);
      expect(client.calls.single.feed, isNull);
      expect(client.calls.single.page, 1);

      await cubit.getGallery();
      expect(client.lastCall.page, 2);
      expect(client.lastCall.feed, isNull);
      expect((await _settled(cubit)).galleryViews, hasLength(2));
    });

    test('ignore feed selection', () async {
      cubit.init(_config());
      await _settled(cubit);

      await cubit.selectFeed('popular');

      expect(client.calls, hasLength(1));
      expect(cubit.selectedFeed, isNull);
    });
  });

  group('extensions with feeds', () {
    test('start on the first feed', () async {
      cubit.init(_config(feeds: _feeds));
      final _Initialized loaded = await _settled(cubit);

      expect(loaded.selectedFeed, 'popular');
      expect(client.calls.single.feed, 'popular');
      expect(client.calls.single.page, 1);
    });

    test('switching feeds reloads from page one with the new feed', () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);
      await cubit.getGallery();
      await cubit.getGallery();
      expect((await _settled(cubit)).currentPage, 3);

      await cubit.selectFeed('latest');
      final _Initialized switched = await _settled(cubit);

      expect(client.lastCall.page, 1);
      expect(client.lastCall.feed, 'latest');
      expect(switched.selectedFeed, 'latest');
      expect(switched.currentPage, 1);
      expect(
        switched.galleryViews.map((MangaGalleryView view) => view.uid),
        <String>['latest::1'],
      );

      await cubit.getGallery();
      expect(client.lastCall.page, 2);
      expect(client.lastCall.feed, 'latest');
    });

    test('selecting the current feed does not reload', () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);

      await cubit.selectFeed('popular');

      expect(client.calls, hasLength(1));
    });

    test('an unknown feed is ignored', () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);

      await cubit.selectFeed('missing');

      expect(client.calls, hasLength(1));
      expect(cubit.selectedFeed, 'popular');
    });

    test('a search drops the feed and clearing it restores the feed',
        () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);
      await cubit.selectFeed('latest');
      await _settled(cubit);

      cubit.search('naruto');
      final _Initialized searching = await _settled(cubit);
      expect(client.lastCall.query, 'naruto');
      expect(client.lastCall.feed, isNull);
      expect(searching.searchQuery, 'naruto');

      await cubit.getGallery();
      expect(client.lastCall.query, 'naruto');
      expect(client.lastCall.feed, isNull);

      cubit.search('');
      final _Initialized cleared = await _settled(cubit);
      expect(cleared.searchQuery, isEmpty);
      expect(client.lastCall.feed, 'latest');
      expect(client.lastCall.page, 1);
      expect(cleared.selectedFeed, 'latest');
    });

    test('clearing a search that found nothing still restores the feed',
        () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);

      cubit.search(_emptyQuery);
      expect((await _settled(cubit)).galleryViews, isEmpty);

      cubit.search('');
      final _Initialized cleared = await _settled(cubit);

      expect(cleared.searchQuery, isEmpty);
      expect(client.lastCall.feed, 'popular');
    });

    test('a refresh keeps the selected feed', () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);
      await cubit.selectFeed('latest');
      await _settled(cubit);

      await cubit.refresh();

      expect(client.lastCall.feed, 'latest');
      expect(client.lastCall.page, 1);
    });

    test('the last feed is remembered per extension for the session',
        () async {
      cubit.init(_config(feeds: _feeds));
      await _settled(cubit);
      await cubit.selectFeed('latest');
      await _settled(cubit);

      final _FakeClient otherClient = _FakeClient();
      final _Cubit reopened = _Cubit(
        ServiceViewInitial<MangaApiClient, MangaGalleryView>(
          client: otherClient,
        ),
        feedMemory: memory,
      );
      addTearDown(reopened.close);
      reopened.init(_config(feeds: _feeds));
      await _settled(reopened);
      expect(otherClient.calls.single.feed, 'latest');

      final _FakeClient anotherExtensionClient = _FakeClient();
      final _Cubit anotherExtension = _Cubit(
        ServiceViewInitial<MangaApiClient, MangaGalleryView>(
          client: anotherExtensionClient,
        ),
        feedMemory: memory,
      );
      addTearDown(anotherExtension.close);
      anotherExtension.init(_config(uid: 'ext.other', feeds: _feeds));
      await _settled(anotherExtension);
      expect(anotherExtensionClient.calls.single.feed, 'popular');
    });

    test('a feed picked after a failed first load retries with that feed',
        () async {
      client.failWith = Exception('network down');
      cubit.init(_config(feeds: _feeds));
      await _drain();
      expect(cubit.state,
          isA<ServiceViewError<MangaApiClient, MangaGalleryView>>());

      client.failWith = null;
      await cubit.selectFeed('latest');
      final _Initialized loaded = await _settled(cubit);

      expect(client.lastCall.feed, 'latest');
      expect(loaded.selectedFeed, 'latest');
    });
  });

  group('source errors', () {
    test('a typed error on the first load becomes an error state', () async {
      client.failWith = const SourceError(SourceErrorKind.sourceDown);
      cubit.init(_config());
      await _drain();

      final ServiceViewState<MangaApiClient, MangaGalleryView> state =
          cubit.state;
      expect(state, isA<ServiceViewError<MangaApiClient, MangaGalleryView>>());
      final Object? error =
          (state as ServiceViewError<MangaApiClient, MangaGalleryView>).error;
      expect(error, isA<SourceError>());
    });

    test('a typed error while paging keeps the grid and reports a failure',
        () async {
      cubit.init(_config());
      await _settled(cubit);
      final List<ServiceViewFailure> failures = <ServiceViewFailure>[];
      final StreamSubscription<
              ServiceViewState<MangaApiClient, MangaGalleryView>>
          subscription = cubit.stream.listen(
        (ServiceViewState<MangaApiClient, MangaGalleryView> state) {
          if (state is _Initialized && state.failure != null) {
            failures.add(state.failure!);
          }
        },
      );
      addTearDown(subscription.cancel);

      client.failWith = const SourceError(SourceErrorKind.rateLimited);
      await cubit.getGallery();
      final _Initialized after = await _settled(cubit);

      expect(failures, hasLength(1));
      expect(failures.single.error, isA<SourceError>());
      expect(after.failure, isNull);
      expect(after.galleryViews, hasLength(1));
      expect(after.currentPage, 1);
    });
  });
}
