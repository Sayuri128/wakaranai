import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_service.dart';
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
  List<String> _priority = const <String>[];
  bool _running = false;
  Timer? _retryTimer;

  PageTranslationBackend get _activeBackend =>
      _backend ??= _backendFactory(state.languages!);

  Future<void> toggle() async {
    if (state.busy) return;
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
    final bool activate = state.phase != PageTranslationPhase.off;
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
        ),
      );
      await _onLanguagesChanged?.call(languages);
    }
    if (activate) await _activate();
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
    bool ready = false;
    try {
      ready = await _activeBackend.isReady();
    } catch (e) {
      logger.w('Page translation readiness check failed: $e');
    }
    _emit(
      state.copyWith(
        phase: ready
            ? PageTranslationPhase.active
            : PageTranslationPhase.needsModels,
      ),
    );
    unawaited(_pump());
  }

  Future<void> downloadModels() async {
    _emit(
      state.copyWith(
        phase: PageTranslationPhase.downloading,
        downloadFailed: false,
      ),
    );
    bool ok = false;
    try {
      ok = await _ensurePacks(state.languages!);
    } catch (e) {
      logger.w('Page translation model download failed: $e');
    }
    if (ok) {
      _emit(state.copyWith(phase: PageTranslationPhase.active));
      unawaited(_pump());
    } else {
      _emit(
        state.copyWith(phase: PageTranslationPhase.off, downloadFailed: true),
      );
    }
  }

  void request(List<String> paths, Map<String, String> headers) {
    _headers = headers;
    _priority = List<String>.unmodifiable(paths);
    final Map<String, PageTranslationEntry> pages =
        Map<String, PageTranslationEntry>.of(state.pages)..removeWhere(
          (String path, PageTranslationEntry entry) =>
              entry.status == PageTranslationStatus.queued &&
              !paths.contains(path),
        );
    for (final String path in paths) {
      pages.putIfAbsent(
        path,
        () => const PageTranslationEntry(PageTranslationStatus.queued),
      );
    }
    _emit(state.copyWith(pages: pages));
    unawaited(_pump());
  }

  void retry(String path) {
    _setStatus(path, const PageTranslationEntry(PageTranslationStatus.queued));
    unawaited(_pump());
  }

  void toggleBubble(String path, int index) {
    final String key = '$path#$index';
    final Set<String> hidden = Set<String>.of(state.hidden);
    if (!hidden.remove(key)) hidden.add(key);
    _emit(state.copyWith(hidden: hidden));
  }

  String? _next() {
    for (final String path in _priority) {
      if (state.pages[path]?.status == PageTranslationStatus.queued) {
        return path;
      }
    }
    for (final MapEntry<String, PageTranslationEntry> entry
        in state.pages.entries) {
      if (entry.value.status == PageTranslationStatus.queued) return entry.key;
    }
    return null;
  }

  Future<void> _pump() async {
    if (_running) return;
    _running = true;
    try {
      while (!isClosed && state.active) {
        final String? path = _next();
        if (path == null) break;
        _setStatus(
          path,
          const PageTranslationEntry(PageTranslationStatus.running),
        );
        _setStatus(path, await _translate(path));
      }
    } finally {
      _running = false;
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
      if (isClosed) return;
      if (state.pages[path]?.status == PageTranslationStatus.modelPending) {
        retry(path);
      }
    });
  }

  void _setStatus(String path, PageTranslationEntry entry) {
    if (isClosed) return;
    _emit(
      state.copyWith(
        pages: Map<String, PageTranslationEntry>.of(state.pages)
          ..[path] = entry,
      ),
    );
  }

  void _emit(PageTranslationState next) {
    if (!isClosed) emit(next);
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _backend?.dispose();
    return super.close();
  }
}
