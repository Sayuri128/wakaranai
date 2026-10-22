import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

enum ChapterTranslationStatus {
  waitingForDownload,
  queued,
  preparing,
  running,
  done,
  failed,
}

class DownloadSnapshot {
  const DownloadSnapshot({
    required this.key,
    required this.done,
    required this.failed,
    required this.pages,
  });

  final String key;
  final bool done;
  final bool failed;
  final List<String> pages;
}

class ChapterTranslationJob extends Equatable {
  const ChapterTranslationJob({
    required this.key,
    required this.title,
    required this.pages,
    required this.languages,
    this.status = ChapterTranslationStatus.queued,
    this.done = 0,
    this.failedPages = 0,
  });

  final String key;
  final String title;
  final List<String> pages;
  final TitleLanguages languages;
  final ChapterTranslationStatus status;
  final int done;
  final int failedPages;

  int get total => pages.length;

  double get progress => total == 0 ? 0 : done / total;

  bool get active =>
      status == ChapterTranslationStatus.waitingForDownload ||
      status == ChapterTranslationStatus.queued ||
      status == ChapterTranslationStatus.preparing ||
      status == ChapterTranslationStatus.running;

  ChapterTranslationJob copyWith({
    ChapterTranslationStatus? status,
    int? done,
    int? failedPages,
  }) {
    return ChapterTranslationJob(
      key: key,
      title: title,
      pages: pages,
      languages: languages,
      status: status ?? this.status,
      done: done ?? this.done,
      failedPages: failedPages ?? this.failedPages,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    key,
    status,
    done,
    failedPages,
    languages,
    pages.length,
  ];
}

class ChapterTranslationState extends Equatable {
  const ChapterTranslationState({
    this.jobs = const <String, ChapterTranslationJob>{},
    this.paused = false,
  });

  final Map<String, ChapterTranslationJob> jobs;
  final bool paused;

  ChapterTranslationJob? job(String key) => jobs[key];

  List<ChapterTranslationJob> get activeJobs =>
      jobs.values.where((ChapterTranslationJob job) => job.active).toList();

  ChapterTranslationJob? get current {
    for (final ChapterTranslationJob job in jobs.values) {
      if (job.status == ChapterTranslationStatus.running ||
          job.status == ChapterTranslationStatus.preparing) {
        return job;
      }
    }
    return null;
  }

  bool get busy => activeJobs.isNotEmpty;

  ChapterTranslationState copyWith({
    Map<String, ChapterTranslationJob>? jobs,
    bool? paused,
  }) {
    return ChapterTranslationState(
      jobs: jobs ?? this.jobs,
      paused: paused ?? this.paused,
    );
  }

  @override
  List<Object?> get props => <Object?>[jobs, paused];
}

abstract class ChapterTranslationNotifier {
  Future<void> showProgress({
    required String title,
    required int done,
    required int total,
    required int remainingChapters,
    required bool paused,
  });

  Future<void> showFinished(int chapters);

  Future<void> clear();
}

class ChapterTranslationCubit extends Cubit<ChapterTranslationState> {
  ChapterTranslationCubit({
    required PageTranslationBackend Function(TitleLanguages languages)
    backendFactory,
    required Future<bool> Function(TitleLanguages languages) ensureReady,
    this.modelRetryDelay = const Duration(seconds: 10),
    this.maxModelRetries = 6,
    ChapterTranslationNotifier? notifier,
  }) : _backendFactory = backendFactory,
       _ensureReady = ensureReady,
       _notifier = notifier,
       super(const ChapterTranslationState());

  final PageTranslationBackend Function(TitleLanguages languages)
  _backendFactory;
  final Future<bool> Function(TitleLanguages languages) _ensureReady;
  final ChapterTranslationNotifier? _notifier;
  final Duration modelRetryDelay;
  final int maxModelRetries;

  final Set<String> _cancelledKeys = <String>{};
  StreamSubscription<List<DownloadSnapshot>>? _downloadsSubscription;
  Completer<void>? _resumeSignal;
  bool _processing = false;
  bool _progressShown = false;
  int _completedInBatch = 0;

  void pause() {
    if (state.paused || !state.busy) {
      return;
    }
    _emit(state.copyWith(paused: true));
  }

  void resume() {
    if (!state.paused) {
      return;
    }
    _emit(state.copyWith(paused: false));
    _resumeSignal?.complete();
    _resumeSignal = null;
  }

  void togglePause() {
    if (state.paused) {
      resume();
    } else {
      pause();
    }
  }

  void cancelAll() {
    final Map<String, ChapterTranslationJob> remainingJobs =
        Map<String, ChapterTranslationJob>.of(state.jobs);
    for (final ChapterTranslationJob job in state.activeJobs) {
      _cancelledKeys.add(job.key);
      remainingJobs.remove(job.key);
    }
    _emit(state.copyWith(jobs: remainingJobs));
    resume();
  }

  void watchDownloads(Stream<List<DownloadSnapshot>> downloads) {
    unawaited(_downloadsSubscription?.cancel());
    _downloadsSubscription = downloads.listen(onDownloadsChanged);
  }

  void translateAfterDownload({
    required String key,
    required String title,
    required TitleLanguages languages,
  }) {
    if (_isActive(key)) {
      return;
    }
    _cancelledKeys.remove(key);
    _saveJob(
      ChapterTranslationJob(
        key: key,
        title: title,
        pages: const <String>[],
        languages: languages,
        status: ChapterTranslationStatus.waitingForDownload,
      ),
    );
  }

  void onDownloadsChanged(List<DownloadSnapshot> downloads) {
    for (final DownloadSnapshot download in downloads) {
      final ChapterTranslationJob? job = state.jobs[download.key];
      if (job == null ||
          job.status != ChapterTranslationStatus.waitingForDownload) {
        continue;
      }
      if (download.done) {
        _saveJob(
          ChapterTranslationJob(
            key: job.key,
            title: job.title,
            pages: List<String>.unmodifiable(download.pages),
            languages: job.languages,
          ),
        );
        unawaited(_processQueue());
      } else if (download.failed) {
        _saveJob(job.copyWith(status: ChapterTranslationStatus.failed));
      }
    }
  }

  void enqueue({
    required String key,
    required String title,
    required List<String> pages,
    required TitleLanguages languages,
  }) {
    if (_isActive(key) || _isFullyTranslated(key, languages)) {
      return;
    }
    _cancelledKeys.remove(key);
    _saveJob(
      ChapterTranslationJob(
        key: key,
        title: title,
        pages: List<String>.unmodifiable(pages),
        languages: languages,
      ),
    );
    unawaited(_processQueue());
  }

  void cancel(String key) {
    if (!state.jobs.containsKey(key)) {
      return;
    }
    _cancelledKeys.add(key);
    final Map<String, ChapterTranslationJob> remainingJobs =
        Map<String, ChapterTranslationJob>.of(state.jobs)..remove(key);
    _emit(state.copyWith(jobs: remainingJobs));
  }

  bool _isActive(String key) => state.jobs[key]?.active ?? false;

  bool _isFullyTranslated(String key, TitleLanguages languages) {
    final ChapterTranslationJob? job = state.jobs[key];
    return job != null &&
        job.status == ChapterTranslationStatus.done &&
        job.failedPages == 0 &&
        job.languages == languages;
  }

  bool _isCancelled(String key) => _cancelledKeys.contains(key);

  ChapterTranslationJob? _nextQueuedJob() {
    for (final ChapterTranslationJob job in state.jobs.values) {
      if (job.status == ChapterTranslationStatus.queued) {
        return job;
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
      while (!isClosed) {
        final ChapterTranslationJob? job = _nextQueuedJob();
        if (job == null) {
          break;
        }
        await _runJob(job);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _waitIfPaused() async {
    while (state.paused && !isClosed) {
      _resumeSignal ??= Completer<void>();
      await _resumeSignal!.future;
    }
  }

  Future<void> _runJob(ChapterTranslationJob job) async {
    if (await _alreadyTranslated(job)) {
      _saveJob(
        job.copyWith(status: ChapterTranslationStatus.done, done: job.total),
        countCompletion: false,
      );
      return;
    }

    _saveJob(job.copyWith(status: ChapterTranslationStatus.preparing));
    final bool ready = await _prepare(job);
    if (_isCancelled(job.key)) {
      return;
    }
    if (!ready) {
      _saveJob(job.copyWith(status: ChapterTranslationStatus.failed));
      return;
    }

    await _translatePages(job);
  }

  Future<bool> _alreadyTranslated(ChapterTranslationJob job) async {
    if (job.pages.isEmpty) {
      return false;
    }
    final PageTranslationBackend backend = _backendFactory(job.languages);
    try {
      for (final String path in job.pages) {
        if (await backend.cached(path) == null) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      await backend.dispose();
    }
  }

  Future<bool> _prepare(ChapterTranslationJob job) async {
    try {
      return await _ensureReady(job.languages);
    } catch (e) {
      logger.w('Chapter translation setup failed: $e');
      return false;
    }
  }

  Future<void> _translatePages(ChapterTranslationJob job) async {
    final PageTranslationBackend backend = _backendFactory(job.languages);
    int donePages = 0;
    int failedPages = 0;
    _saveJob(job.copyWith(status: ChapterTranslationStatus.running));
    try {
      for (final String path in job.pages) {
        await _waitIfPaused();
        if (_isCancelled(job.key) || isClosed) {
          return;
        }
        final bool translated = await _translatePage(backend, path);
        if (!translated) {
          failedPages++;
        }
        donePages++;
        if (_isCancelled(job.key)) {
          return;
        }
        _saveJob(
          job.copyWith(
            status: ChapterTranslationStatus.running,
            done: donePages,
            failedPages: failedPages,
          ),
        );
      }

      final bool everyPageFailed = job.total > 0 && failedPages == job.total;
      _saveJob(
        job.copyWith(
          status: everyPageFailed
              ? ChapterTranslationStatus.failed
              : ChapterTranslationStatus.done,
          done: donePages,
          failedPages: failedPages,
        ),
      );
    } finally {
      await backend.dispose();
    }
  }

  Future<bool> _translatePage(
    PageTranslationBackend backend,
    String path,
  ) async {
    for (int attempt = 0; attempt <= maxModelRetries; attempt++) {
      try {
        if (await backend.cached(path) != null) {
          return true;
        }
        await backend.translate(path, const <String, String>{});
        return true;
      } on OcrModelPendingException {
        await Future<void>.delayed(modelRetryDelay);
      } catch (e, s) {
        logger.w(
          'Chapter page translation failed for $path',
          error: e,
          stackTrace: s,
        );
        return false;
      }
    }
    return false;
  }

  void _saveJob(ChapterTranslationJob job, {bool countCompletion = true}) {
    if (_isCancelled(job.key)) {
      return;
    }
    final bool justCompleted =
        job.status == ChapterTranslationStatus.done &&
        state.jobs[job.key]?.status != ChapterTranslationStatus.done;
    if (countCompletion && justCompleted) {
      _completedInBatch++;
    }
    final Map<String, ChapterTranslationJob> jobs =
        Map<String, ChapterTranslationJob>.of(state.jobs);
    jobs[job.key] = job;
    _emit(state.copyWith(jobs: jobs));
  }

  void _emit(ChapterTranslationState next) {
    if (isClosed) {
      return;
    }
    emit(next);
    _updateNotification();
  }

  void _updateNotification() {
    final ChapterTranslationNotifier? notifier = _notifier;
    if (notifier == null) {
      return;
    }
    final ChapterTranslationJob? current = state.current;
    if (current != null) {
      _progressShown = true;
      unawaited(
        notifier.showProgress(
          title: current.title,
          done: current.done,
          total: current.total,
          remainingChapters: state.activeJobs.length,
          paused: state.paused,
        ),
      );
      return;
    }
    if (state.activeJobs.isNotEmpty || !_progressShown) {
      return;
    }
    _progressShown = false;
    final int completed = _completedInBatch;
    _completedInBatch = 0;
    if (completed > 0) {
      unawaited(notifier.showFinished(completed));
    } else {
      unawaited(notifier.clear());
    }
  }

  @override
  Future<void> close() async {
    await _downloadsSubscription?.cancel();
    return super.close();
  }
}
