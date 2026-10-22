import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

part 'page_translation_state.dart';

typedef PageTranslationBackendFactory =
    PageTranslationBackend Function(TitleLanguages languages);

class PageTranslationCubit extends Cubit<PageTranslationState> {
  PageTranslationCubit({
    required PageTranslationBackendFactory backendFactory,
    required Future<bool> Function(TitleLanguages languages) ensurePacks,
    TitleLanguages? languages,
    Future<void> Function(TitleLanguages languages)? onLanguagesChanged,
    this.modelRetryDelay = const Duration(seconds: 10),
  }) : _backendFactory = backendFactory,
       _ensurePacks = ensurePacks,
       _onLanguagesChanged = onLanguagesChanged,
       super(PageTranslationState(languages: languages));

  final PageTranslationBackendFactory _backendFactory;
  final Future<bool> Function(TitleLanguages languages) _ensurePacks;
  final Future<void> Function(TitleLanguages languages)? _onLanguagesChanged;
  final Duration modelRetryDelay;

  PageTranslationBackend? _backend;
  Map<String, String> _headers = const <String, String>{};
  List<String> _visiblePaths = const <String>[];
  bool _processing = false;
  Timer? _retryTimer;

  PageTranslationBackend get _activeBackend =>
      _backend ??= _backendFactory(state.languages!);

  Future<void> toggle() async {
    if (state.busy) {
      return;
    }
    if (state.phase != PageTranslationPhase.off) {
      _emit(state.copyWith(phase: PageTranslationPhase.off));
      return;
    }
    if (state.languages == null) {
      _emit(state.copyWith(phase: PageTranslationPhase.choosingLanguages));
      return;
    }
    await _activate();
  }

  Future<void> setLanguages(TitleLanguages languages) async {
    final bool wasOn = state.phase != PageTranslationPhase.off;
    if (languages != state.languages) {
      _retryTimer?.cancel();
      final PageTranslationBackend? previous = _backend;
      _backend = null;
      await previous?.dispose();
      _emit(
        state.copyWith(
          languages: languages,
          pages: const <String, PageTranslationEntry>{},
          hidden: const <String>{},
          pinned: const <String>{},
        ),
      );
      await _onLanguagesChanged?.call(languages);
    }
    if (wasOn) {
      await _activate();
    }
  }

  void restoreLanguages(TitleLanguages languages) {
    if (state.languages == null) {
      _emit(state.copyWith(languages: languages));
    }
  }

  void dismissPrompt() {
    if (state.phase == PageTranslationPhase.needsModels ||
        state.phase == PageTranslationPhase.choosingLanguages) {
      _emit(state.copyWith(phase: PageTranslationPhase.off));
    }
  }

  Future<void> _activate() async {
    _emit(
      state.copyWith(
        phase: PageTranslationPhase.preparing,
        downloadFailed: false,
      ),
    );
    final bool ready = await _checkReady();
    _emit(
      state.copyWith(
        phase: ready
            ? PageTranslationPhase.active
            : PageTranslationPhase.needsModels,
      ),
    );
    unawaited(_processQueue());
  }

  Future<bool> _checkReady() async {
    try {
      return await _activeBackend.isReady();
    } catch (e) {
      logger.w('Page translation readiness check failed: $e');
      return false;
    }
  }

  Future<void> downloadModels() async {
    _emit(
      state.copyWith(
        phase: PageTranslationPhase.downloading,
        downloadFailed: false,
      ),
    );
    bool downloaded = false;
    try {
      downloaded = await _ensurePacks(state.languages!);
    } catch (e) {
      logger.w('Page translation model download failed: $e');
    }
    if (downloaded) {
      _emit(state.copyWith(phase: PageTranslationPhase.active));
      unawaited(_processQueue());
    } else {
      _emit(
        state.copyWith(phase: PageTranslationPhase.off, downloadFailed: true),
      );
    }
  }

  void request(List<String> paths, Map<String, String> headers) {
    _headers = headers;
    _visiblePaths = List<String>.unmodifiable(paths);

    bool isStaleQueued(String path, PageTranslationEntry entry) {
      return entry.status == PageTranslationStatus.queued &&
          !paths.contains(path) &&
          !state.pinned.contains(path);
    }

    final Map<String, PageTranslationEntry> pages =
        Map<String, PageTranslationEntry>.of(state.pages)
          ..removeWhere(isStaleQueued);
    _queueMissing(pages, paths);
    _emit(state.copyWith(pages: pages));
    unawaited(_processQueue());
  }

  void requestAll(List<String> paths, Map<String, String> headers) {
    _headers = headers;
    final Map<String, PageTranslationEntry> pages =
        Map<String, PageTranslationEntry>.of(state.pages);
    _queueMissing(pages, paths);
    _emit(
      state.copyWith(pages: pages, pinned: <String>{...state.pinned, ...paths}),
    );
    unawaited(_processQueue());
  }

  void _queueMissing(
    Map<String, PageTranslationEntry> pages,
    List<String> paths,
  ) {
    for (final String path in paths) {
      pages.putIfAbsent(
        path,
        () => const PageTranslationEntry(PageTranslationStatus.queued),
      );
    }
  }

  void retry(String path) {
    _setEntry(path, const PageTranslationEntry(PageTranslationStatus.queued));
    unawaited(_processQueue());
  }

  void toggleBubble(String path, int index) {
    final String key = '$path#$index';
    final Set<String> hidden = Set<String>.of(state.hidden);
    if (!hidden.remove(key)) {
      hidden.add(key);
    }
    _emit(state.copyWith(hidden: hidden));
  }

  String? _nextQueuedPath() {
    for (final String path in _visiblePaths) {
      if (state.pages[path]?.status == PageTranslationStatus.queued) {
        return path;
      }
    }
    for (final MapEntry<String, PageTranslationEntry> entry
        in state.pages.entries) {
      if (entry.value.status == PageTranslationStatus.queued) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> _processQueue() async {
    if (_processing) {
      return;
    }
    _processing = true;
    try {
      while (!isClosed && state.active) {
        final String? path = _nextQueuedPath();
        if (path == null) {
          break;
        }
        _setEntry(
          path,
          const PageTranslationEntry(PageTranslationStatus.running),
        );
        final PageTranslationEntry result = await _translate(path);
        _setEntry(path, result);
      }
    } finally {
      _processing = false;
    }
  }

  Future<PageTranslationEntry> _translate(String path) async {
    try {
      final PageTranslationResult result =
          await _activeBackend.cached(path) ??
          await _activeBackend.translate(path, _headers);
      return PageTranslationEntry(PageTranslationStatus.done, result: result);
    } on OcrModelPendingException {
      _scheduleModelRetry(path);
      return const PageTranslationEntry(PageTranslationStatus.modelPending);
    } catch (e, stack) {
      logger.w(
        'Page translation failed for $path',
        error: e,
        stackTrace: stack,
      );
      return const PageTranslationEntry(PageTranslationStatus.failed);
    }
  }

  void _scheduleModelRetry(String path) {
    _retryTimer?.cancel();
    _retryTimer = Timer(modelRetryDelay, () {
      if (isClosed) {
        return;
      }
      if (state.pages[path]?.status == PageTranslationStatus.modelPending) {
        retry(path);
      }
    });
  }

  void _setEntry(String path, PageTranslationEntry entry) {
    if (isClosed) {
      return;
    }
    final Map<String, PageTranslationEntry> pages =
        Map<String, PageTranslationEntry>.of(state.pages);
    pages[path] = entry;
    _emit(state.copyWith(pages: pages));
  }

  void _emit(PageTranslationState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _backend?.dispose();
    return super.close();
  }
}
