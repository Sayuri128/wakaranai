import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_variant.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';

const DeviceInfo _flagship = DeviceInfo(
  sdkInt: 34,
  totalRamBytes: 12 * (1 << 30) - (600 << 20),
  abis: <String>['arm64-v8a', 'armeabi-v7a'],
  model: 'samsung SM-S928B',
);

const DeviceInfo _midRange = DeviceInfo(
  sdkInt: 34,
  totalRamBytes: 8 * (1 << 30) - (500 << 20),
  abis: <String>['arm64-v8a'],
  model: 'Pixel 8',
);

class _FakeStore implements GemmaModelStore {
  final Set<GemmaVariant> installed = <GemmaVariant>{};
  final List<GemmaVariant> installs = <GemmaVariant>[];
  bool fail = false;
  Completer<void>? gate;
  void Function(int percent)? progress;

  @override
  Future<bool> isInstalled(GemmaVariant variant) async =>
      installed.contains(variant);

  @override
  Future<void> install(
    GemmaVariant variant, {
    required void Function(int percent) onProgress,
  }) async {
    installs.add(variant);
    progress = onProgress;
    await gate?.future;
    if (fail) {
      throw StateError('offline');
    }
    installed.add(variant);
  }

  @override
  void cancel() => fail = true;

  int staleCancels = 0;

  @override
  Future<void> cancelStaleDownloads() async => staleCancels++;

  @override
  Future<void> uninstall(GemmaVariant variant) async =>
      installed.remove(variant);
}

GemmaModelCubit _cubit(_FakeStore store, {DeviceInfo device = _flagship}) =>
    GemmaModelCubit(
      store: store,
      support: (GemmaVariant variant) async =>
          OnDeviceAiSupport.evaluate(device, minRamGb: variant.minRamGb),
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

  test('an 8 GB phone can run E2B but not E4B', () async {
    final _FakeStore store = _FakeStore();
    final GemmaModelCubit cubit = _cubit(store, device: _midRange);
    addTearDown(cubit.close);

    await cubit.init();
    expect(cubit.state.supports(GemmaVariant.e2b), isTrue);
    expect(cubit.state.supports(GemmaVariant.e4b), isFalse);

    expect(await cubit.ensure(GemmaVariant.e4b), isFalse);
    expect(store.installs, isEmpty);
  });

  test('download reports progress and finishes installed', () async {
    final _FakeStore store = _FakeStore()..gate = Completer<void>();
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();
    expect(cubit.state.status, GemmaModelStatus.missing);

    final Future<bool> first = cubit.download();
    final Future<bool> second = cubit.ensure(GemmaVariant.e2b);
    await Future<void>.delayed(Duration.zero);
    store.progress!(42);
    expect(cubit.state.status, GemmaModelStatus.downloading);
    expect(cubit.state.progress, 42);

    store.gate!.complete();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(store.installs, <GemmaVariant>[GemmaVariant.e2b]);
    expect(cubit.state.status, GemmaModelStatus.installed);
  });

  test(
    'leftover downloads are cancelled at start and before a download',
    () async {
      final _FakeStore store = _FakeStore();
      final GemmaModelCubit cubit = _cubit(store);
      addTearDown(cubit.close);

      await cubit.init();
      expect(store.staleCancels, 1);

      expect(await cubit.download(), isTrue);
      expect(store.staleCancels, 2);
    },
  );

  test('progress never jumps back while downloading', () async {
    final _FakeStore store = _FakeStore()..gate = Completer<void>();
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();

    final Future<bool> download = cubit.download();
    await Future<void>.delayed(Duration.zero);
    store.progress!(4);
    store.progress!(0);
    store.progress!(4);
    expect(cubit.state.progress, 4);

    store.gate!.complete();
    expect(await download, isTrue);
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

  test(
    'switching models downloads the new one and lists the old one',
    () async {
      final _FakeStore store = _FakeStore()..installed.add(GemmaVariant.e2b);
      final GemmaModelCubit cubit = _cubit(store);
      addTearDown(cubit.close);
      await cubit.init();
      expect(cubit.state.status, GemmaModelStatus.installed);

      expect(await cubit.ensure(GemmaVariant.e4b), isTrue);

      expect(cubit.state.variant, GemmaVariant.e4b);
      expect(store.installs, <GemmaVariant>[GemmaVariant.e4b]);
      expect(cubit.state.otherInstalledVariants, <GemmaVariant>[
        GemmaVariant.e2b,
      ]);

      await cubit.delete(GemmaVariant.e2b);
      expect(cubit.state.otherInstalledVariants, isEmpty);
      expect(cubit.state.status, GemmaModelStatus.installed);
    },
  );

  test('deleting the selected model marks it missing', () async {
    final _FakeStore store = _FakeStore()..installed.add(GemmaVariant.e2b);
    final GemmaModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();

    await cubit.delete(GemmaVariant.e2b);
    expect(cubit.state.status, GemmaModelStatus.missing);
    expect(store.installed, isEmpty);
  });

  test('Gemma falls back to ML Kit on unsupported phones', () {
    final PageTranslationSettings settings = PageTranslationSettings(
      translator: GemmaVariant.e4b.engineId,
    );
    final GemmaModelState flagship = GemmaModelState(
      supportByVariant: <GemmaVariant, OnDeviceAiSupport>{
        GemmaVariant.e4b: OnDeviceAiSupport.evaluate(
          _flagship,
          minRamGb: GemmaVariant.e4b.minRamGb,
        ),
      },
    );
    final GemmaModelState midRange = GemmaModelState(
      supportByVariant: <GemmaVariant, OnDeviceAiSupport>{
        GemmaVariant.e4b: OnDeviceAiSupport.evaluate(
          _midRange,
          minRamGb: GemmaVariant.e4b.minRamGb,
        ),
      },
    );

    expect(
      gemmaVariantOf(effectiveTranslationSettings(settings, flagship)),
      GemmaVariant.e4b,
    );
    expect(
      usesGemma(effectiveTranslationSettings(settings, midRange)),
      isFalse,
    );
  });
}
