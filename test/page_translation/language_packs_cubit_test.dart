import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

const PageLanguage _ru = PageLanguage('ru', 'Russian');

class _FakeStore implements TranslationModelStore {
  final Set<String> downloaded = <String>{'en'};
  final List<String> order = <String>[];
  final Set<String> failing = <String>{};
  final Map<String, Completer<void>> gates = <String, Completer<void>>{};
  bool? lastWifiOnly;

  @override
  Future<bool> isDownloaded(PageLanguage language) async =>
      downloaded.contains(language.code);

  @override
  Future<void> download(PageLanguage language, {required bool wifiOnly}) async {
    lastWifiOnly = wifiOnly;
    order.add(language.code);
    await gates[language.code]?.future;
    if (failing.contains(language.code)) {
      throw StateError('offline');
    }
    downloaded.add(language.code);
  }

  @override
  Future<void> delete(PageLanguage language) async =>
      downloaded.remove(language.code);
}

Future<void> _settle([int times = 4]) async {
  for (int i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('packs download one at a time in the order they were queued', () async {
    final _FakeStore store = _FakeStore()..gates['ja'] = Completer<void>();
    final LanguagePacksCubit cubit = LanguagePacksCubit(
      store: store,
      wifiOnly: () => true,
    );
    addTearDown(cubit.close);

    cubit.enqueue(PageLanguage.japanese);
    cubit.enqueue(_ru);
    await _settle();

    expect(
      cubit.state.statusOf(PageLanguage.japanese),
      LanguagePackStatus.downloading,
    );
    expect(cubit.state.statusOf(_ru), LanguagePackStatus.queued);
    expect(cubit.state.queuePosition(_ru), 1);
    expect(cubit.state.batchTotal, 2);
    expect(cubit.state.batchDone, 0);

    store.gates['ja']!.complete();
    await _settle();

    expect(store.order, <String>['ja', 'ru']);
    expect(store.lastWifiOnly, isTrue);
    expect(cubit.state.statusOf(_ru), LanguagePackStatus.downloaded);
    expect(cubit.state.batchTotal, 0);
  });

  test('queued packs can be cancelled before they start', () async {
    final _FakeStore store = _FakeStore()..gates['ja'] = Completer<void>();
    final LanguagePacksCubit cubit = LanguagePacksCubit(
      store: store,
      wifiOnly: () => false,
    );
    addTearDown(cubit.close);

    cubit.enqueue(PageLanguage.japanese);
    cubit.enqueue(_ru);
    await _settle();
    cubit.dequeue(_ru);
    store.gates['ja']!.complete();
    await _settle();

    expect(store.order, <String>['ja']);
    expect(cubit.state.statusOf(_ru), LanguagePackStatus.missing);
  });

  test('ensure waits for every needed pack and reports failures', () async {
    final _FakeStore store = _FakeStore()..failing.add('ru');
    final LanguagePacksCubit cubit = LanguagePacksCubit(
      store: store,
      wifiOnly: () => false,
    );
    addTearDown(cubit.close);

    expect(await cubit.ensure(<PageLanguage>[PageLanguage.japanese]), isTrue);
    expect(
      await cubit.ensure(<PageLanguage>[PageLanguage.english, _ru]),
      isFalse,
    );
    expect(cubit.state.statusOf(_ru), LanguagePackStatus.failed);
    expect(store.order, <String>['ja', 'ru']);
  });

  test('deleting a pack marks it missing again', () async {
    final _FakeStore store = _FakeStore()..downloaded.add('ja');
    final LanguagePacksCubit cubit = LanguagePacksCubit(
      store: store,
      wifiOnly: () => false,
    );
    addTearDown(cubit.close);

    await cubit.refresh(<PageLanguage>[PageLanguage.japanese]);
    expect(
      cubit.state.statusOf(PageLanguage.japanese),
      LanguagePackStatus.downloaded,
    );

    await cubit.delete(PageLanguage.japanese);
    expect(
      cubit.state.statusOf(PageLanguage.japanese),
      LanguagePackStatus.missing,
    );
  });
}
