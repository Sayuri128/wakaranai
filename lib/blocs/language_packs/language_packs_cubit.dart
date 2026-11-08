import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

enum LanguagePackStatus {
  unknown,
  missing,
  queued,
  downloading,
  downloaded,
  failed,
}

class LanguagePacksState extends Equatable {
  const LanguagePacksState({
    this.statuses = const <String, LanguagePackStatus>{},
    this.queue = const <String>[],
    this.active,
    this.batchTotal = 0,
    this.batchDone = 0,
  });

  final Map<String, LanguagePackStatus> statuses;
  final List<String> queue;
  final String? active;
  final int batchTotal;
  final int batchDone;

  bool get busy => active != null || queue.isNotEmpty;

  LanguagePackStatus statusOf(PageLanguage language) =>
      statuses[language.code] ?? LanguagePackStatus.unknown;

  int get downloadedCount => statuses.values
      .where(
        (LanguagePackStatus status) => status == LanguagePackStatus.downloaded,
      )
      .length;

  int queuePosition(PageLanguage language) => queue.indexOf(language.code) + 1;

  LanguagePacksState copyWith({
    Map<String, LanguagePackStatus>? statuses,
    List<String>? queue,
    String? active,
    bool clearActive = false,
    int? batchTotal,
    int? batchDone,
  }) {
    return LanguagePacksState(
      statuses: statuses ?? this.statuses,
      queue: queue ?? this.queue,
      active: clearActive ? null : (active ?? this.active),
      batchTotal: batchTotal ?? this.batchTotal,
      batchDone: batchDone ?? this.batchDone,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    statuses,
    queue,
    active,
    batchTotal,
    batchDone,
  ];
}

class LanguagePacksCubit extends Cubit<LanguagePacksState> {
  LanguagePacksCubit({
    required TranslationModelStore? store,
    required bool Function() wifiOnly,
  }) : _store = store,
       _wifiOnly = wifiOnly,
       super(const LanguagePacksState());

  final TranslationModelStore? _store;
  final bool Function() _wifiOnly;
  bool _processing = false;

  bool get supported => _store != null;

  Future<void> refresh([Iterable<PageLanguage>? languages]) async {
    final TranslationModelStore? store = _store;
    if (store == null) {
      return;
    }
    for (final PageLanguage language in languages ?? PageLanguage.all) {
      final LanguagePackStatus current = state.statusOf(language);
      if (current == LanguagePackStatus.queued ||
          current == LanguagePackStatus.downloading) {
        continue;
      }
      final bool downloaded = await _checkDownloaded(store, language);
      _setStatus(
        language.code,
        downloaded ? LanguagePackStatus.downloaded : LanguagePackStatus.missing,
      );
    }
  }

  Future<bool> _checkDownloaded(
    TranslationModelStore store,
    PageLanguage language,
  ) async {
    try {
      return await store.isDownloaded(language);
    } catch (e) {
      logger.w('Language pack check failed for ${language.code}: $e');
      return false;
    }
  }

  void enqueue(PageLanguage language) {
    final LanguagePackStatus status = state.statusOf(language);
    if (status == LanguagePackStatus.queued ||
        status == LanguagePackStatus.downloading ||
        status == LanguagePackStatus.downloaded) {
      return;
    }
    _emit(
      state.copyWith(
        statuses: _withStatus(language.code, LanguagePackStatus.queued),
        queue: <String>[...state.queue, language.code],
        batchTotal: state.batchTotal + 1,
      ),
    );
    unawaited(_processQueue());
  }

  void dequeue(PageLanguage language) {
    if (!state.queue.contains(language.code)) {
      return;
    }
    _emit(
      state.copyWith(
        statuses: _withStatus(language.code, LanguagePackStatus.missing),
        queue: List<String>.of(state.queue)..remove(language.code),
        batchTotal: state.batchTotal - 1,
      ),
    );
    _resetBatchIfIdle();
  }

  Future<void> delete(PageLanguage language) async {
    final TranslationModelStore? store = _store;
    if (store == null) {
      return;
    }
    try {
      await store.delete(language);
    } catch (e) {
      logger.w('Language pack delete failed for ${language.code}: $e');
    }
    await refresh(<PageLanguage>[language]);
  }

  Future<bool> ensure(Iterable<PageLanguage> languages) async {
    final List<PageLanguage> needed = languages.toList();
    final List<PageLanguage> unchecked = needed
        .where(
          (PageLanguage language) =>
              state.statusOf(language) == LanguagePackStatus.unknown,
        )
        .toList();
    await refresh(unchecked);
    for (final PageLanguage language in needed) {
      final LanguagePackStatus status = state.statusOf(language);
      if (status == LanguagePackStatus.missing ||
          status == LanguagePackStatus.failed) {
        enqueue(language);
      }
    }

    bool allSettled(LanguagePacksState packs) {
      return needed.every((PageLanguage language) {
        final LanguagePackStatus status = packs.statusOf(language);
        return status == LanguagePackStatus.downloaded ||
            status == LanguagePackStatus.failed ||
            status == LanguagePackStatus.missing;
      });
    }

    LanguagePacksState settled = state;
    if (!allSettled(settled)) {
      settled = await stream.firstWhere(allSettled);
    }
    return needed.every(
      (PageLanguage language) =>
          settled.statusOf(language) == LanguagePackStatus.downloaded,
    );
  }

  Future<void> _processQueue() async {
    final TranslationModelStore? store = _store;
    if (_processing || store == null) {
      return;
    }
    _processing = true;
    try {
      while (!isClosed && state.queue.isNotEmpty) {
        await _downloadNext(store);
      }
    } finally {
      _processing = false;
      _resetBatchIfIdle();
    }
  }

  Future<void> _downloadNext(TranslationModelStore store) async {
    final String code = state.queue.first;
    final PageLanguage language = PageLanguage.all.firstWhere(
      (PageLanguage candidate) => candidate.code == code,
    );
    _emit(
      state.copyWith(
        statuses: _withStatus(code, LanguagePackStatus.downloading),
        queue: state.queue.sublist(1),
        active: code,
      ),
    );
    LanguagePackStatus result = LanguagePackStatus.downloaded;
    try {
      await store.download(language, wifiOnly: _wifiOnly());
    } catch (e) {
      logger.w('Language pack download failed for $code: $e');
      result = LanguagePackStatus.failed;
    }
    _emit(
      state.copyWith(
        statuses: _withStatus(code, result),
        clearActive: true,
        batchDone: state.batchDone + 1,
      ),
    );
  }

  void _resetBatchIfIdle() {
    if (!state.busy && state.batchTotal != 0) {
      _emit(state.copyWith(batchTotal: 0, batchDone: 0));
    }
  }

  Map<String, LanguagePackStatus> _withStatus(
    String code,
    LanguagePackStatus status,
  ) {
    final Map<String, LanguagePackStatus> statuses =
        Map<String, LanguagePackStatus>.of(state.statuses);
    statuses[code] = status;
    return statuses;
  }

  void _setStatus(String code, LanguagePackStatus status) {
    _emit(state.copyWith(statuses: _withStatus(code, status)));
  }

  void _emit(LanguagePacksState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
