import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';

const DeviceInfo _flagship = DeviceInfo(
  sdkInt: 34,
  totalRamBytes: 12 * (1 << 30) - (600 << 20),
  abis: <String>['arm64-v8a', 'armeabi-v7a'],
  model: 'samsung SM-S928B',
);

class _FakeStore implements GemmaModelStore {
  bool installed = false;
  bool fail = false;
  int installs = 0;
  Completer<void>? gate;
  void Function(int percent)? progress;

  @override
  Future<bool> isInstalled() async => installed;

  @override
  Future<void> install({required void Function(int percent) onProgress}) async {
    installs++;
    progress = onProgress;
    await gate?.future;
    if (fail) {
      throw StateError('offline');
    }
    installed = true;
  }

  @override
  void cancel() => fail = true;

  @override
  Future<void> uninstall() async => installed = false;
}

GemmaModelCubit _cubit(_FakeStore store, {DeviceInfo device = _flagship}) =>
    GemmaModelCubit(
      store: store,
      support: () async => OnDeviceAiSupport.evaluate(device),
    );

void main() {
  test('phone requirements are evaluated from device info', () {
    expect(OnDeviceAiSupport.evaluate(_flagship).supported, isTrue);
    expect(
      OnDeviceAiSupport.evaluate(
        const DeviceInfo(
          sdkInt: 29,
          totalRamBytes: 6 * (1 << 30),
          abis: <String>['armeabi-v7a'],
          model: 'old',
        ),
      ).issues,
      <OnDeviceAiIssue>[
        OnDeviceAiIssue.androidTooOld,
        OnDeviceAiIssue.not64Bit,
        OnDeviceAiIssue.lowMemory,
      ],
    );
  });

  test('unsupported phones never offer the model', () async {
    final _FakeStore store = _FakeStore();
    final GemmaModelCubit cubit = _cubit(
      store,
      device: const DeviceInfo(
        sdkInt: 34,
        totalRamBytes: 4 * (1 << 30),
        abis: <String>['arm64-v8a'],
        model: 'budget',
      ),
    );
    addTearDown(cubit.close);

    await cubit.init();
    expect(cubit.state.status, GemmaModelStatus.unsupported);
    expect(await cubit.ensure(), isFalse);
    expect(store.installs, 0);
  });

  test('download reports progress and finishes installed', () async {
    final _FakeStore store = _FakeStore()..gate = Completer<void>();
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();
    expect(cubit.state.status, GemmaModelStatus.missing);

    final Future<bool> first = cubit.download();
    final Future<bool> second = cubit.ensure();
    await Future<void>.delayed(Duration.zero);
    store.progress!(42);
    expect(cubit.state.status, GemmaModelStatus.downloading);
    expect(cubit.state.progress, 42);

    store.gate!.complete();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(store.installs, 1);
    expect(cubit.state.status, GemmaModelStatus.installed);
  });

  test('a failed download can be retried', () async {
    final _FakeStore store = _FakeStore()..fail = true;
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();

    expect(await cubit.download(), isFalse);
    expect(cubit.state.status, GemmaModelStatus.failed);

    store.fail = false;
    expect(await cubit.download(), isTrue);
    expect(cubit.state.status, GemmaModelStatus.installed);
  });

  test('deleting the model marks it missing', () async {
    final _FakeStore store = _FakeStore()..installed = true;
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();
    expect(cubit.state.status, GemmaModelStatus.installed);

    await cubit.delete();
    expect(cubit.state.status, GemmaModelStatus.missing);
    expect(store.installed, isFalse);
  });

  test('Gemma falls back to ML Kit on unsupported phones', () {
    const PageTranslationSettings settings = PageTranslationSettings(
      translator: gemmaEngineId,
    );
    final GemmaModelState supported = GemmaModelState(
      support: OnDeviceAiSupport.evaluate(_flagship),
    );
    const GemmaModelState unsupported = GemmaModelState(
      support: OnDeviceAiSupport(
        issues: <OnDeviceAiIssue>[OnDeviceAiIssue.lowMemory],
      ),
    );

    expect(
      usesGemma(effectiveTranslationSettings(settings, supported)),
      isTrue,
    );
    expect(
      usesGemma(effectiveTranslationSettings(settings, unsupported)),
      isFalse,
    );
  });
}
