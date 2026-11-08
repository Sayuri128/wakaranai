import 'dart:async';
import 'dart:collection';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/global_search/global_search_backend.dart';
import 'package:wakaranai/services/global_search/global_search_catalog.dart';
import 'package:wakaranai/services/global_search/global_search_preferences.dart';
import 'package:wakaranai/services/global_search/global_search_scope.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';

part 'global_search_state.dart';

class _SearchJob {
  const _SearchJob({
    required this.source,
    required this.query,
    required this.generation,
  });

  final GlobalSearchSource source;
  final String query;
  final int generation;
}

class GlobalSearchCubit extends Cubit<GlobalSearchState> {
  GlobalSearchCubit({
    required this.backend,
    required this.catalog,
    required this.rules,
    this.preferences = const GlobalSearchPreferences(),
    this.maxConcurrent = defaultMaxConcurrent,
    this.sourceTimeout = defaultSourceTimeout,
  }) : super(const GlobalSearchState());

  static const int defaultMaxConcurrent = 3;
  static const Duration defaultSourceTimeout = Duration(seconds: 15);

  final GlobalSearchBackend backend;
  final GlobalSearchCatalog catalog;
  final GlobalSearchScopeRules rules;
  final GlobalSearchPreferences preferences;
  final int maxConcurrent;
  final Duration sourceTimeout;

  final Queue<_SearchJob> _pending = Queue<_SearchJob>();
  int _generation = 0;
  int _active = 0;
  List<String>? _storedScope;
  Set<String> _used = const <String>{};

  Future<void> init({String? initialQuery}) async {
    final List<String> history = await preferences.readHistory();
    _storedScope = await preferences.readScope();
    final GlobalSearchCatalogSnapshot snapshot = await catalog.loadKnown();
    if (isClosed) {
      return;
    }
    _used = snapshot.used;
    emit(state.copyWith(history: history, pinned: snapshot.pinned));
    _applyCatalog(GlobalSearchScope.merge(
      <Iterable<GlobalSearchSource>>[snapshot.sources],
    ));
    final String query = initialQuery?.trim() ?? '';
    if (query.isNotEmpty) {
      search(query);
    }
    unawaited(_loadRepositories());
  }

  Future<void> _loadRepositories() async {
    emit(state.copyWith(loadingRepositories: true));
    List<GlobalSearchSource> remote = const <GlobalSearchSource>[];
    try {
      remote = await catalog.loadAllRepositories();
    } catch (e) {
      logger.w('Failed to list every repository for global search: $e');
    }
    if (isClosed) {
      return;
    }
    emit(state.copyWith(loadingRepositories: false));
    _applyCatalog(GlobalSearchScope.merge(
      <Iterable<GlobalSearchSource>>[state.catalog, remote],
    ));
  }

  void _applyCatalog(List<GlobalSearchSource> merged) {
    final List<GlobalSearchSource> eligible =
        GlobalSearchScope.eligible(merged, rules);
    final List<GlobalSearchSource> scope = GlobalSearchScope.resolve(
      catalog: eligible,
      stored: _storedScope,
      pinned: state.pinned,
      used: _used,
      rules: rules,
    );
    final Set<String> previous = state.scopeUids;
    final Set<String> next =
        scope.map((GlobalSearchSource source) => source.uid).toSet();
    final List<GlobalSearchSource> added = scope
        .where((GlobalSearchSource source) => !previous.contains(source.uid))
        .toList(growable: false);
    emit(state.copyWith(
      catalog: eligible,
      scope: scope,
      customScope: _storedScope != null,
      scopeReady: true,
      rails: <String, GlobalSearchRail>{
        for (final MapEntry<String, GlobalSearchRail> entry
            in state.rails.entries)
          if (next.contains(entry.key)) entry.key: entry.value,
      },
    ));
    if (!state.hasQuery) {
      return;
    }
    for (final GlobalSearchSource source in added) {
      _start(source);
    }
  }

  void search(String query) {
    final String trimmed = query.trim();
    _generation++;
    _pending.clear();
    _active = 0;
    if (trimmed.isEmpty) {
      emit(
          state.copyWith(query: '', rails: const <String, GlobalSearchRail>{}));
      return;
    }
    final List<String> history =
        GlobalSearchPreferences.withQuery(state.history, trimmed);
    emit(state.copyWith(
      query: trimmed,
      history: history,
      rails: const <String, GlobalSearchRail>{},
    ));
    unawaited(preferences.writeHistory(history));
    for (final GlobalSearchSource source in state.scope) {
      _start(source);
    }
  }

  void clear() {
    search('');
  }

  void retry(String uid) {
    if (!state.hasQuery) {
      return;
    }
    final GlobalSearchRail? rail = state.rails[uid];
    if (rail != null && rail.isLoading) {
      return;
    }
    for (final GlobalSearchSource source in state.scope) {
      if (source.uid == uid) {
        _start(source);
        return;
      }
    }
  }

  Future<void> setScopeSelection(Set<String> uids) async {
    final Set<String> eligible =
        state.catalog.map((GlobalSearchSource source) => source.uid).toSet();
    final Set<String> base = _storedScope?.toSet() ??
        GlobalSearchScope.defaultUids(pinned: state.pinned, used: _used);
    final List<String> stored = <String>[
      ...base.where((String uid) => !eligible.contains(uid)),
      ...state.catalog
          .map((GlobalSearchSource source) => source.uid)
          .where(uids.contains),
    ];
    _storedScope = List<String>.unmodifiable(stored);
    await preferences.writeScope(_storedScope);
    if (isClosed) {
      return;
    }
    _applyCatalog(state.catalog);
  }

  Future<void> resetScope() async {
    _storedScope = null;
    await preferences.writeScope(null);
    if (isClosed) {
      return;
    }
    _applyCatalog(state.catalog);
  }

  Future<void> removeFromHistory(String query) async {
    final List<String> history =
        GlobalSearchPreferences.withoutQuery(state.history, query);
    emit(state.copyWith(history: history));
    await preferences.writeHistory(history);
  }

  Future<void> clearHistory() async {
    emit(state.copyWith(history: const <String>[]));
    await preferences.writeHistory(const <String>[]);
  }

  void _start(GlobalSearchSource source) {
    emit(state.copyWith(rails: <String, GlobalSearchRail>{
      ...state.rails,
      source.uid: GlobalSearchRail.loading(source),
    }));
    _pending.add(_SearchJob(
      source: source,
      query: state.query,
      generation: _generation,
    ));
    _pump();
  }

  void _pump() {
    while (_active < maxConcurrent && _pending.isNotEmpty) {
      final _SearchJob job = _pending.removeFirst();
      _active++;
      unawaited(_run(job).whenComplete(() {
        if (job.generation != _generation) {
          return;
        }
        _active--;
        _pump();
      }));
    }
  }

  Future<void> _run(_SearchJob job) async {
    final GlobalSearchRail rail = await _railFor(job);
    if (isClosed || job.generation != _generation) {
      return;
    }
    if (!state.scopeUids.contains(job.source.uid)) {
      return;
    }
    emit(state.copyWith(rails: <String, GlobalSearchRail>{
      ...state.rails,
      job.source.uid: rail,
    }));
  }

  Future<GlobalSearchRail> _railFor(_SearchJob job) async {
    final GlobalSearchSource source = job.source;
    try {
      if (await backend.needsSignIn(source)) {
        return GlobalSearchRail(
          source: source,
          status: GlobalSearchRailStatus.needsSignIn,
        );
      }
      final GlobalSearchHit hit =
          await backend.search(source, job.query).timeout(sourceTimeout);
      return GlobalSearchRail(
        source: source,
        status: GlobalSearchRailStatus.loaded,
        items: hit.items,
        coverHeaders: hit.coverHeaders,
        client: hit.client,
        config: hit.config,
      );
    } on SourceNeedsAttention catch (attention) {
      return GlobalSearchRail(
        source: source,
        status: GlobalSearchRailStatus.needsSignIn,
        error: attention,
      );
    } catch (error) {
      logger.w('Global search failed for ${source.name}: $error');
      return GlobalSearchRail(
        source: source,
        status: GlobalSearchRailStatus.failed,
        error: error,
      );
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    _pending.clear();
    await backend.dispose();
    return super.close();
  }
}
