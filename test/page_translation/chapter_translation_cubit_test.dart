import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

const PageTranslationResult _empty = PageTranslationResult(
  width: 1,
  height: 1,
  bubbles: <TranslatedBubble>[],
);

const TitleLanguages _enUk = TitleLanguages(
  source: PageLanguage.english,
  target: PageLanguage('uk', 'Ukrainian'),
);

class _FakeBackend implements PageTranslationBackend {
  final Set<String> cachedPages = <String>{};
  final List<String> translated = <String>[];
  final Map<String, List<Object>> errors = <String, List<Object>>{};
  bool disposed = false;
  Completer<void>? gate;

  @override
  Future<bool> isReady() async => true;

  @override
  Future<PageTranslationResult?> cached(String path) async =>
      cachedPages.contains(path) ? _empty : null;

  @override
  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  ) async {
    await gate?.future;
    final List<Object>? queued = errors[path];
    if (queued != null && queued.isNotEmpty) {
      throw queued.removeAt(0);
    }
    translated.add(path);
    return _empty;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

class _FakeNotifier implements ChapterTranslationNotifier {
  final List<String> events = <String>[];

  @override
  Future<void> showProgress({
    required String title,
    required int done,
    required int total,
    required int remainingChapters,
    required bool paused,
  }) async => events.add('$title $done/$total${paused ? ' paused' : ''}');

  @override
  Future<void> showFinished(int chapters) async =>
      events.add('finished $chapters');

  @override
  Future<void> clear() async => events.add('clear');
}

void main() {
  late _FakeBackend backend;
  late bool ready;

  ChapterTranslationCubit build() => ChapterTranslationCubit(
    backendFactory: (TitleLanguages languages) => backend,
    ensureReady: (TitleLanguages languages) async => ready,
    modelRetryDelay: const Duration(milliseconds: 1),
  );

  Future<ChapterTranslationJob> finished(
    ChapterTranslationCubit cubit,
    String key,
  ) async {
    final ChapterTranslationState state = await cubit.stream
        .firstWhere(
          (ChapterTranslationState next) =>
              next.job(key) != null && !next.job(key)!.active,
        )
        .timeout(const Duration(seconds: 5));
    return state.job(key)!;
  }

  setUp(() {
    backend = _FakeBackend();
    ready = true;
  });

  test('every page is translated and cached pages are skipped', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.cachedPages.add('p2');

    cubit.enqueue(
      key: 'ch1',
      title: 'Chapter 1',
      pages: <String>['p1', 'p2', 'p3'],
      languages: _enUk,
    );
    final ChapterTranslationJob job = await finished(cubit, 'ch1');

    expect(job.status, ChapterTranslationStatus.done);
    expect(job.done, 3);
    expect(backend.translated, <String>['p1', 'p3']);
    expect(backend.disposed, isTrue);
  });

  test('chapters are processed one after another', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);

    cubit.enqueue(
      key: 'a',
      title: 'A',
      pages: <String>['a1', 'a2'],
      languages: _enUk,
    );
    cubit.enqueue(
      key: 'b',
      title: 'B',
      pages: <String>['b1'],
      languages: _enUk,
    );
    await finished(cubit, 'b');

    expect(backend.translated, <String>['a1', 'a2', 'b1']);
  });

  test('failed pages are counted without stopping the chapter', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.errors['p1'] = <Object>[StateError('broken image')];

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1', 'p2'],
      languages: _enUk,
    );
    final ChapterTranslationJob job = await finished(cubit, 'ch');

    expect(job.status, ChapterTranslationStatus.done);
    expect(job.failedPages, 1);
    expect(backend.translated, <String>['p2']);
  });

  test('pages wait for the OCR model instead of failing', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.errors['p1'] = <Object>[
      const OcrModelPendingException(),
      const OcrModelPendingException(),
    ];

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1'],
      languages: _enUk,
    );
    final ChapterTranslationJob job = await finished(cubit, 'ch');

    expect(job.failedPages, 0);
    expect(backend.translated, <String>['p1']);
  });

  test('a job fails when the engine cannot be prepared', () async {
    ready = false;
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1'],
      languages: _enUk,
    );
    final ChapterTranslationJob job = await finished(cubit, 'ch');

    expect(job.status, ChapterTranslationStatus.failed);
    expect(backend.translated, isEmpty);
  });

  test('cancelling stops a running chapter', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.gate = Completer<void>();

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1', 'p2', 'p3'],
      languages: _enUk,
    );
    await Future<void>.delayed(Duration.zero);
    cubit.cancel('ch');
    backend.gate!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.job('ch'), isNull);
    expect(backend.translated.length, lessThanOrEqualTo(1));
  });

  test('chapters wait for their download and then translate', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    final StreamController<List<DownloadSnapshot>> downloads =
        StreamController<List<DownloadSnapshot>>();
    addTearDown(downloads.close);
    cubit.watchDownloads(downloads.stream);

    cubit.translateAfterDownload(key: 'ch', title: 'Ch', languages: _enUk);
    expect(
      cubit.state.job('ch')!.status,
      ChapterTranslationStatus.waitingForDownload,
    );

    downloads.add(const <DownloadSnapshot>[
      DownloadSnapshot(
        key: 'ch',
        done: false,
        failed: false,
        pages: <String>[],
      ),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(backend.translated, isEmpty);

    downloads.add(const <DownloadSnapshot>[
      DownloadSnapshot(
        key: 'ch',
        done: true,
        failed: false,
        pages: <String>['/d/0000.img', '/d/0001.img'],
      ),
    ]);
    final ChapterTranslationJob job = await finished(cubit, 'ch');

    expect(job.status, ChapterTranslationStatus.done);
    expect(backend.translated, <String>['/d/0000.img', '/d/0001.img']);
  });

  test('a failed download fails the waiting translation', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);

    cubit.translateAfterDownload(key: 'ch', title: 'Ch', languages: _enUk);
    cubit.onDownloadsChanged(const <DownloadSnapshot>[
      DownloadSnapshot(key: 'ch', done: false, failed: true, pages: <String>[]),
    ]);

    expect(cubit.state.job('ch')!.status, ChapterTranslationStatus.failed);
  });

  test('pausing holds the queue until resumed', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.gate = Completer<void>();

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1', 'p2', 'p3'],
      languages: _enUk,
    );
    await Future<void>.delayed(Duration.zero);
    cubit.pause();
    backend.gate!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.paused, isTrue);
    expect(backend.translated, <String>['p1']);

    cubit.resume();
    final ChapterTranslationJob job = await finished(cubit, 'ch');
    expect(job.status, ChapterTranslationStatus.done);
    expect(backend.translated, <String>['p1', 'p2', 'p3']);
  });

  test('cancel all clears every active chapter', () async {
    final ChapterTranslationCubit cubit = build();
    addTearDown(cubit.close);
    backend.gate = Completer<void>();

    cubit.enqueue(
      key: 'a',
      title: 'A',
      pages: <String>['a1', 'a2'],
      languages: _enUk,
    );
    cubit.enqueue(
      key: 'b',
      title: 'B',
      pages: <String>['b1'],
      languages: _enUk,
    );
    cubit.translateAfterDownload(key: 'c', title: 'C', languages: _enUk);
    await Future<void>.delayed(Duration.zero);
    cubit.cancelAll();
    backend.gate!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.busy, isFalse);
    expect(cubit.state.jobs, isEmpty);
    expect(backend.translated.length, lessThanOrEqualTo(1));
  });

  test('the notification follows progress and reports the finish', () async {
    final _FakeNotifier notifier = _FakeNotifier();
    final ChapterTranslationCubit cubit = ChapterTranslationCubit(
      backendFactory: (TitleLanguages languages) => backend,
      ensureReady: (TitleLanguages languages) async => true,
      notifier: notifier,
    );
    addTearDown(cubit.close);

    cubit.enqueue(
      key: 'ch',
      title: 'Ch',
      pages: <String>['p1', 'p2'],
      languages: _enUk,
    );
    await finished(cubit, 'ch');

    expect(notifier.events, containsAllInOrder(<String>['Ch 1/2', 'Ch 2/2']));
    expect(notifier.events.last, 'finished 1');
  });

  test(
    'fully translated chapters finish instantly and are not requeued',
    () async {
      final _FakeNotifier notifier = _FakeNotifier();
      int prepared = 0;
      final ChapterTranslationCubit cubit = ChapterTranslationCubit(
        backendFactory: (TitleLanguages languages) => backend,
        ensureReady: (TitleLanguages languages) async {
          prepared++;
          return true;
        },
        notifier: notifier,
      );
      addTearDown(cubit.close);
      backend.cachedPages.addAll(<String>['p1', 'p2']);

      cubit.enqueue(
        key: 'ch',
        title: 'Ch',
        pages: <String>['p1', 'p2'],
        languages: _enUk,
      );
      final ChapterTranslationJob job = await finished(cubit, 'ch');

      expect(job.status, ChapterTranslationStatus.done);
      expect(job.done, 2);
      expect(prepared, 0);
      expect(backend.translated, isEmpty);
      expect(notifier.events, isNot(contains('finished 1')));

      cubit.enqueue(
        key: 'ch',
        title: 'Ch',
        pages: <String>['p1', 'p2'],
        languages: _enUk,
      );
      expect(cubit.state.job('ch')!.status, ChapterTranslationStatus.done);
    },
  );
}
