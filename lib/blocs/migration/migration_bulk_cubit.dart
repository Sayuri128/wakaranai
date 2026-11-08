import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_candidates.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_title_match.dart';

enum MigrationBulkPhase { setup, running, finished }

enum MigrationBulkItemStatus {
  waiting,
  searching,
  needsPick,
  migrating,
  done,
  skipped,
  failed,
}

class MigrationBulkItem {
  const MigrationBulkItem({
    required this.subject,
    this.status = MigrationBulkItemStatus.waiting,
    this.targetTitle,
    this.targetSource,
    this.candidateCount = 0,
    this.autoPicked = false,
  });

  final MigrationSubject subject;
  final MigrationBulkItemStatus status;
  final String? targetTitle;
  final String? targetSource;
  final int candidateCount;
  final bool autoPicked;

  bool get isSettled {
    return status == MigrationBulkItemStatus.done ||
        status == MigrationBulkItemStatus.skipped ||
        status == MigrationBulkItemStatus.failed;
  }

  MigrationBulkItem copyWith({
    MigrationSubject? subject,
    MigrationBulkItemStatus? status,
    String? targetTitle,
    String? targetSource,
    int? candidateCount,
    bool? autoPicked,
  }) {
    return MigrationBulkItem(
      subject: subject ?? this.subject,
      status: status ?? this.status,
      targetTitle: targetTitle ?? this.targetTitle,
      targetSource: targetSource ?? this.targetSource,
      candidateCount: candidateCount ?? this.candidateCount,
      autoPicked: autoPicked ?? this.autoPicked,
    );
  }
}

class MigrationBulkState {
  const MigrationBulkState({
    this.phase = MigrationBulkPhase.setup,
    this.items = const <MigrationBulkItem>[],
    this.options = const MigrationOptions(),
    this.autoPickExact = true,
    this.stopping = false,
  });

  final MigrationBulkPhase phase;
  final List<MigrationBulkItem> items;
  final MigrationOptions options;
  final bool autoPickExact;
  final bool stopping;

  int get settledCount =>
      items.where((MigrationBulkItem item) => item.isSettled).length;

  int countOf(MigrationBulkItemStatus status) {
    return items.where((MigrationBulkItem item) => item.status == status).length;
  }

  MigrationBulkState copyWith({
    MigrationBulkPhase? phase,
    List<MigrationBulkItem>? items,
    MigrationOptions? options,
    bool? autoPickExact,
    bool? stopping,
  }) {
    return MigrationBulkState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      options: options ?? this.options,
      autoPickExact: autoPickExact ?? this.autoPickExact,
      stopping: stopping ?? this.stopping,
    );
  }
}

class MigrationBulkCubit extends Cubit<MigrationBulkState> {
  MigrationBulkCubit({
    required this.search,
    required this.planner,
    required List<MigrationSubject> subjects,
    this.maxQueries = defaultMaxQueries,
  }) : super(MigrationBulkState(
          items: subjects
              .map((MigrationSubject subject) =>
                  MigrationBulkItem(subject: subject))
              .toList(growable: false),
        ));

  static const int defaultMaxQueries = 3;

  final GlobalSearchCubit search;
  final MigrationPlanner planner;
  final int maxQueries;

  final Map<int, Completer<MigrationCandidate?>> _pendingPicks =
      <int, Completer<MigrationCandidate?>>{};

  void setOptions(MigrationOptions options) {
    emit(state.copyWith(options: options));
  }

  void setAutoPickExact(bool value) {
    emit(state.copyWith(autoPickExact: value));
  }

  Future<void> start() async {
    if (state.phase != MigrationBulkPhase.setup) {
      return;
    }
    emit(state.copyWith(phase: MigrationBulkPhase.running));
    for (int index = 0; index < state.items.length; index++) {
      if (isClosed) {
        return;
      }
      if (state.stopping) {
        _update(index, status: MigrationBulkItemStatus.skipped);
        continue;
      }
      await _process(index);
    }
    if (!isClosed) {
      emit(state.copyWith(phase: MigrationBulkPhase.finished));
    }
  }

  void stop() {
    emit(state.copyWith(stopping: true));
    for (final MapEntry<int, Completer<MigrationCandidate?>> entry
        in _pendingPicks.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(null);
      }
    }
  }

  void resolvePick(int index, MigrationCandidate? candidate) {
    final Completer<MigrationCandidate?>? pending = _pendingPicks[index];
    if (pending == null || pending.isCompleted) {
      return;
    }
    pending.complete(candidate);
  }

  Future<void> _process(int index) async {
    _update(index, status: MigrationBulkItemStatus.searching);
    final MigrationSubject subject =
        await planner.complete(state.items[index].subject);
    if (isClosed) {
      return;
    }
    _update(index, subject: subject);
    final List<RankedMigrationCandidate> ranked = await _searchFor(subject);
    if (isClosed) {
      return;
    }
    MigrationCandidate? pick;
    bool autoPicked = false;
    if (state.autoPickExact) {
      pick = autoPickExactCandidate(
        ranked,
        groupOrder: migrationSourceOrder(search.state),
      )?.candidate;
      autoPicked = pick != null;
    }
    pick ??= await _askForPick(index, ranked.length);
    if (isClosed) {
      return;
    }
    if (pick == null) {
      _update(index, status: MigrationBulkItemStatus.skipped);
      return;
    }
    await _migrate(index, subject, pick, autoPicked: autoPicked);
  }

  Future<List<RankedMigrationCandidate>> _searchFor(
    MigrationSubject subject,
  ) async {
    List<RankedMigrationCandidate> ranked = const <RankedMigrationCandidate>[];
    final List<String> queries = subject.searchTitles.take(maxQueries).toList();
    for (final String query in queries) {
      search.search(query);
      await _searchSettled();
      if (isClosed) {
        return ranked;
      }
      ranked = rankMigrationSearch(subject, search.state);
      if (ranked.isNotEmpty) {
        return ranked;
      }
    }
    return ranked;
  }

  Future<void> _searchSettled() async {
    if (!search.state.isSearching) {
      return;
    }
    await search.stream
        .firstWhere((GlobalSearchState searchState) => !searchState.isSearching);
  }

  Future<MigrationCandidate?> _askForPick(int index, int candidateCount) {
    final Completer<MigrationCandidate?> completer =
        Completer<MigrationCandidate?>();
    _pendingPicks[index] = completer;
    _update(
      index,
      status: MigrationBulkItemStatus.needsPick,
      candidateCount: candidateCount,
    );
    return completer.future.whenComplete(() => _pendingPicks.remove(index));
  }

  Future<void> _migrate(
    int index,
    MigrationSubject subject,
    MigrationCandidate pick, {
    required bool autoPicked,
  }) async {
    _update(
      index,
      status: MigrationBulkItemStatus.migrating,
      targetTitle: migrationCandidateTitleOf(pick.item),
      targetSource: pick.config.name.trim(),
      autoPicked: autoPicked,
    );
    try {
      final MigrationPreparation preparation =
          await planner.prepare(subject, pick);
      await planner.apply(preparation, state.options);
      _update(index, status: MigrationBulkItemStatus.done);
    } catch (error) {
      logger.e('Bulk migration of ${subject.title} failed: $error');
      _update(index, status: MigrationBulkItemStatus.failed);
    }
  }

  void _update(
    int index, {
    MigrationSubject? subject,
    MigrationBulkItemStatus? status,
    String? targetTitle,
    String? targetSource,
    int? candidateCount,
    bool? autoPicked,
  }) {
    if (isClosed) {
      return;
    }
    final List<MigrationBulkItem> items = List<MigrationBulkItem>.of(state.items);
    items[index] = items[index].copyWith(
      subject: subject,
      status: status,
      targetTitle: targetTitle,
      targetSource: targetSource,
      candidateCount: candidateCount,
      autoPicked: autoPicked,
    );
    emit(state.copyWith(items: List<MigrationBulkItem>.unmodifiable(items)));
  }

  @override
  Future<void> close() {
    for (final Completer<MigrationCandidate?> pending in _pendingPicks.values) {
      if (!pending.isCompleted) {
        pending.complete(null);
      }
    }
    return super.close();
  }
}
