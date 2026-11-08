import 'dart:async';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/global_search/global_search_backend.dart';
import 'package:wakaranai/services/global_search/global_search_catalog.dart';
import 'package:wakaranai/services/global_search/global_search_scope.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';

GlobalSearchSource _source(String uid) {
  return GlobalSearchSource(
    extension: ExtensionDomain(
      id: 0,
      config: ConfigInfo.fromJson(<String, dynamic>{
        'name': uid,
        'uid': uid,
        'logoUrl': '',
        'type': 0,
        'nsfw': false,
        'language': 'en',
        'version': 1,
        'filters': <dynamic>[],
        'searchAvailable': true,
      }),
      sourceCode: '',
      createdAt: DateTime(2026),
    ),
  );
}

MangaGalleryView _item(String uid) {
  return MangaGalleryView(
    uid: uid,
    cover: '',
    title: uid,
    data: const <String, dynamic>{},
  );
}

class _FakeCatalog implements GlobalSearchCatalog {
  _FakeCatalog(this.known, {this.repositories = const <GlobalSearchSource>[]});

  final List<GlobalSearchSource> known;
  final List<GlobalSearchSource> repositories;

  @override
  Future<GlobalSearchCatalogSnapshot> loadKnown() async {
    return GlobalSearchCatalogSnapshot(
      sources: known,
      pinned: const <String>[],
      used: known.map((GlobalSearchSource source) => source.uid).toSet(),
    );
  }

  @override
  Future<List<GlobalSearchSource>> loadAllRepositories() async {
    return repositories;
  }
}

class _Call {
  _Call(this.source, this.query);

  final GlobalSearchSource source;
  final String query;
  final Completer<GlobalSearchHit> completer = Completer<GlobalSearchHit>();
}

class _FakeBackend implements GlobalSearchBackend {
  final List<_Call> calls = <_Call>[];
  final Set<String> signInNeeded = <String>{};
  bool disposed = false;

  int get running =>
      calls.where((_Call call) => !call.completer.isCompleted).length;

  _Call callFor(String uid, String query) {
    return calls.lastWhere(
      (_Call call) => call.source.uid == uid && call.query == query,
    );
  }

  @override
  Future<bool> needsSignIn(GlobalSearchSource source) async {
    return signInNeeded.contains(source.uid);
  }

  @override
  Future<GlobalSearchHit> search(GlobalSearchSource source, String query) {
    final _Call call = _Call(source, query);
    calls.add(call);
    return call.completer.future;
  }

  @override
  Future<BaseExtension> openable(GlobalSearchSource source) async {
    return source.extension;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

Future<void> _settle() async {
  for (int index = 0; index < 5; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    backend = _FakeBackend();
  });

  GlobalSearchCubit build(
    List<GlobalSearchSource> sources, {
    Duration timeout = const Duration(seconds: 15),
    List<GlobalSearchSource> repositories = const <GlobalSearchSource>[],
  }) {
    return GlobalSearchCubit(
      backend: backend,
      catalog: _FakeCatalog(sources, repositories: repositories),
      rules: const GlobalSearchScopeRules(),
      sourceTimeout: timeout,
    );
  }

  test('runs at most three sources at a time and streams each rail', () async {
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[
      for (int index = 0; index < 5; index++) _source('s$index'),
    ]);
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('naruto');
    await _settle();

    expect(backend.calls, hasLength(3));
    expect(cubit.state.isSearching, isTrue);

    backend.callFor('s1', 'naruto').completer.complete(
          GlobalSearchHit(items: <MangaGalleryView>[_item('x')]),
        );
    await _settle();

    expect(backend.calls, hasLength(4));
    expect(backend.running, 3);
    final GlobalSearchRail rail = cubit.state.rails['s1']!;
    expect(rail.status, GlobalSearchRailStatus.loaded);
    expect(rail.items.single.uid, 'x');
    expect(cubit.state.visibleRails.first.source.uid, 's1');
  });

  test('a new query ignores results of the previous one', () async {
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[_source('a')]);
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('old');
    await _settle();
    cubit.search('new');
    await _settle();

    backend.callFor('a', 'old').completer.complete(
          GlobalSearchHit(items: <MangaGalleryView>[_item('stale')]),
        );
    await _settle();
    expect(cubit.state.rails['a']!.isLoading, isTrue);

    backend.callFor('a', 'new').completer.complete(
          GlobalSearchHit(items: <MangaGalleryView>[_item('fresh')]),
        );
    await _settle();
    expect(cubit.state.query, 'new');
    expect(cubit.state.rails['a']!.items.single.uid, 'fresh');
  });

  test('stale in-flight calls do not hold slots of a new query', () async {
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[
      for (int index = 0; index < 3; index++) _source('s$index'),
    ]);
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('first');
    await _settle();
    cubit.search('second');
    await _settle();

    expect(
      backend.calls.where((_Call call) => call.query == 'second'),
      hasLength(3),
    );
  });

  test('a slow source times out into a failed rail and can be retried',
      () async {
    final GlobalSearchCubit cubit = build(
      <GlobalSearchSource>[_source('slow')],
      timeout: const Duration(milliseconds: 20),
    );
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('q');
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final GlobalSearchRail failed = cubit.state.rails['slow']!;
    expect(failed.status, GlobalSearchRailStatus.failed);
    expect(failed.timedOut, isTrue);

    cubit.retry('slow');
    await _settle();
    expect(cubit.state.rails['slow']!.isLoading, isTrue);
    backend.calls.last.completer.complete(
      const GlobalSearchHit(items: <MangaGalleryView>[]),
    );
    await _settle();
    expect(cubit.state.rails['slow']!.isEmptyResult, isTrue);
    expect(cubit.state.emptyRails.single.source.uid, 'slow');
    expect(cubit.state.visibleRails, isEmpty);
  });

  test('protector sources without a session are not called', () async {
    backend.signInNeeded.add('locked');
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[
      _source('locked'),
      _source('open'),
    ]);
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('q');
    await _settle();

    expect(cubit.state.rails['locked']!.status,
        GlobalSearchRailStatus.needsSignIn);
    expect(
      backend.calls.map((_Call call) => call.source.uid),
      <String>['open'],
    );
  });

  test('a session failure from the source asks for sign-in', () async {
    final GlobalSearchSource source = _source('expired');
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[source]);
    addTearDown(cubit.close);
    await cubit.init();
    cubit.search('q');
    await _settle();
    backend.calls.single.completer.completeError(SourceNeedsAttention(
      config: source.config,
      reason: SourceAttentionReason.sessionExpired,
    ));
    await _settle();

    expect(cubit.state.rails['expired']!.status,
        GlobalSearchRailStatus.needsSignIn);
  });

  test('editing the scope searches newly added sources only', () async {
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[
      _source('a'),
      _source('b'),
    ]);
    addTearDown(cubit.close);
    await cubit.init();
    await cubit.setScopeSelection(<String>{'a'});
    cubit.search('q');
    await _settle();
    expect(backend.calls, hasLength(1));

    await cubit.setScopeSelection(<String>{'a', 'b'});
    await _settle();
    expect(
        backend.calls.map((_Call call) => call.source.uid), <String>['a', 'b']);
    expect(cubit.state.customScope, isTrue);

    await cubit.setScopeSelection(<String>{'b'});
    expect(cubit.state.rails.containsKey('a'), isFalse);
  });

  test('sources from other repositories join a stored scope', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'GLOBAL_SEARCH_SCOPE': '["a","remote"]',
    });
    final GlobalSearchCubit cubit = build(
      <GlobalSearchSource>[_source('a')],
      repositories: <GlobalSearchSource>[_source('remote')],
    );
    addTearDown(cubit.close);
    await cubit.init();
    await _settle();

    expect(cubit.state.scopeUids, <String>{'a', 'remote'});
  });

  test('remembers submitted queries and disposes the backend', () async {
    final GlobalSearchCubit cubit = build(<GlobalSearchSource>[_source('a')]);
    await cubit.init(initialQuery: '  one piece ');
    expect(cubit.state.query, 'one piece');
    expect(cubit.state.history, <String>['one piece']);
    await cubit.close();
    expect(backend.disposed, isTrue);
  });
}
