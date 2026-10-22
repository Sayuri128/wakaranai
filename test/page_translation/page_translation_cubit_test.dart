import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';

const PageTranslationResult _empty = PageTranslationResult(
  width: 1,
  height: 1,
  bubbles: <TranslatedBubble>[],
);

const TitleLanguages _jaEn = TitleLanguages(
  source: PageLanguage.japanese,
  target: PageLanguage.english,
);

const TitleLanguages _enRu = TitleLanguages(
  source: PageLanguage.english,
  target: PageLanguage('ru', 'Russian'),
);

class _FakeBackend implements PageTranslationBackend {
  _FakeBackend(this.languages, {this.ready = true});

  final TitleLanguages languages;
  bool ready;
  bool disposed = false;
  final List<String> translated = <String>[];
  final Map<String, Object> errors = <String, Object>{};
  Completer<void>? gate;

  @override
  Future<bool> isReady() async => ready;

  @override
  Future<PageTranslationResult?> cached(String path) async => null;

  @override
  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  ) async {
    await gate?.future;
    final Object? error = errors.remove(path);
    if (error != null) {
      throw error;
    }
    translated.add(path);
    return _empty;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

class _Harness {
  _Harness({
    TitleLanguages? languages = _jaEn,
    this.ready = true,
    this.packsOk = true,
    Duration retry = const Duration(seconds: 10),
  }) {
    cubit = PageTranslationCubit(
      languages: languages,
      modelRetryDelay: retry,
      backendFactory: (TitleLanguages requested) {
        final _FakeBackend backend = _FakeBackend(requested, ready: ready)
          ..gate = gate;
        backends.add(backend);
        return backend;
      },
      ensurePacks: (TitleLanguages requested) async {
        ensured.add(requested);
        if (packsOk) {
          ready = true;
        }
        return packsOk;
      },
      onLanguagesChanged: (TitleLanguages requested) async =>
          saved.add(requested),
    );
  }

  late final PageTranslationCubit cubit;
  bool ready;
  bool packsOk;
  Completer<void>? gate;
  final List<_FakeBackend> backends = <_FakeBackend>[];
  final List<TitleLanguages> ensured = <TitleLanguages>[];
  final List<TitleLanguages> saved = <TitleLanguages>[];

  _FakeBackend get backend => backends.last;
}

Future<void> _settle([int times = 3]) async {
  for (int i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('translates the requested pages in priority order', () async {
    final _Harness harness = _Harness();
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.cubit.request(<String>['p1', 'p2', 'p3'], const <String, String>{});
    await _settle();

    expect(harness.backend.translated, <String>['p1', 'p2', 'p3']);
    expect(harness.cubit.state.entry('p2')?.status, PageTranslationStatus.done);
  });

  test('queued pages that are no longer near the reader are dropped', () async {
    final _Harness harness = _Harness()..gate = Completer<void>();
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.cubit.request(<String>['p1', 'p2', 'p3'], const <String, String>{});
    harness.cubit.request(<String>['p9', 'p10'], const <String, String>{});
    harness.gate!.complete();
    await _settle(6);

    expect(harness.backend.translated, <String>['p1', 'p9', 'p10']);
    expect(harness.cubit.state.entry('p2'), isNull);
  });

  test('a title without languages asks for them first', () async {
    final _Harness harness = _Harness(languages: null);
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    expect(harness.cubit.state.phase, PageTranslationPhase.choosingLanguages);

    await harness.cubit.setLanguages(_enRu);
    expect(harness.cubit.state.phase, PageTranslationPhase.active);
    expect(harness.saved, <TitleLanguages>[_enRu]);
    expect(harness.backend.languages, _enRu);
  });

  test('dismissing the language prompt turns translation off', () async {
    final _Harness harness = _Harness(languages: null);
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.cubit.dismissPrompt();

    expect(harness.cubit.state.phase, PageTranslationPhase.off);
  });

  test('changing languages rebuilds the backend and drops old pages', () async {
    final _Harness harness = _Harness();
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.cubit.request(<String>['p1'], const <String, String>{});
    await _settle();
    final _FakeBackend first = harness.backend;

    await harness.cubit.setLanguages(_enRu);
    await _settle();

    expect(first.disposed, isTrue);
    expect(harness.backend, isNot(same(first)));
    expect(harness.cubit.state.entry('p1'), isNull);
    expect(harness.cubit.state.phase, PageTranslationPhase.active);
  });

  test('changing languages while off only saves them', () async {
    final _Harness harness = _Harness();
    addTearDown(harness.cubit.close);

    await harness.cubit.setLanguages(_enRu);

    expect(harness.cubit.state.phase, PageTranslationPhase.off);
    expect(harness.cubit.state.languages, _enRu);
    expect(harness.saved, <TitleLanguages>[_enRu]);
  });

  test('saved languages are restored without overriding a choice', () async {
    final _Harness harness = _Harness(languages: null);
    addTearDown(harness.cubit.close);

    harness.cubit.restoreLanguages(_enRu);
    harness.cubit.restoreLanguages(_jaEn);

    expect(harness.cubit.state.languages, _enRu);
    expect(harness.saved, isEmpty);
  });

  test('missing packs are downloaded through the shared queue', () async {
    final _Harness harness = _Harness(ready: false);
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    expect(harness.cubit.state.phase, PageTranslationPhase.needsModels);

    await harness.cubit.downloadModels();
    expect(harness.ensured, <TitleLanguages>[_jaEn]);
    expect(harness.cubit.state.phase, PageTranslationPhase.active);
  });

  test('a failed download turns translation back off', () async {
    final _Harness harness = _Harness(ready: false, packsOk: false);
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    await harness.cubit.downloadModels();

    expect(harness.cubit.state.phase, PageTranslationPhase.off);
    expect(harness.cubit.state.downloadFailed, isTrue);
  });

  test('pages wait and retry while the OCR model is downloading', () async {
    final _Harness harness = _Harness(retry: const Duration(milliseconds: 10));
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.backend.errors['p1'] = const OcrModelPendingException();
    harness.cubit.request(<String>['p1'], const <String, String>{});
    await _settle();
    expect(
      harness.cubit.state.entry('p1')?.status,
      PageTranslationStatus.modelPending,
    );

    final PageTranslationState done = await harness.cubit.stream
        .firstWhere(
          (PageTranslationState next) =>
              next.entry('p1')?.status == PageTranslationStatus.done,
        )
        .timeout(const Duration(seconds: 5));
    expect(done.entry('p1')?.status, PageTranslationStatus.done);
  });

  test('failed pages can be retried', () async {
    final _Harness harness = _Harness();
    addTearDown(harness.cubit.close);

    await harness.cubit.toggle();
    harness.backend.errors['p1'] = StateError('boom');
    harness.cubit.request(<String>['p1'], const <String, String>{});
    await _settle();
    expect(
      harness.cubit.state.entry('p1')?.status,
      PageTranslationStatus.failed,
    );

    harness.cubit.retry('p1');
    await _settle();
    expect(harness.cubit.state.entry('p1')?.status, PageTranslationStatus.done);
  });

  test('bubbles can be switched back to the original', () async {
    final _Harness harness = _Harness();
    addTearDown(harness.cubit.close);

    harness.cubit.toggleBubble('p1', 2);
    expect(harness.cubit.state.isHidden('p1', 2), isTrue);
    harness.cubit.toggleBubble('p1', 2);
    expect(harness.cubit.state.isHidden('p1', 2), isFalse);
  });

  test(
    'whole-chapter pages stay queued while the reader moves around',
    () async {
      final _Harness harness = _Harness()..gate = Completer<void>();
      addTearDown(harness.cubit.close);

      await harness.cubit.toggle();
      harness.cubit.requestAll(<String>[
        'p1',
        'p2',
        'p3',
        'p4',
      ], const <String, String>{});
      harness.cubit.request(<String>['p3'], const <String, String>{});
      harness.gate!.complete();
      await _settle(10);

      expect(harness.backend.translated.toSet(), <String>{
        'p1',
        'p2',
        'p3',
        'p4',
      });
      expect(harness.cubit.state.pinnedDone, 4);
      expect(harness.cubit.state.translatingChapter, isFalse);
    },
  );
}
