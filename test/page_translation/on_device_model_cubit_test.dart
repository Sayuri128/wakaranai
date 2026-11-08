import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
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

class _FakeStore implements OnDeviceModelStore {
  final Set<OnDeviceModel> installed = <OnDeviceModel>{};
  final List<OnDeviceModel> installs = <OnDeviceModel>[];
  bool fail = false;
  Completer<void>? gate;
  void Function(int percent)? progress;

  @override
  Future<bool> isInstalled(OnDeviceModel variant) async =>
      installed.contains(variant);

  @override
  Future<void> install(
    OnDeviceModel variant, {
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
  Future<void> uninstall(OnDeviceModel variant) async =>
      installed.remove(variant);
}

OnDeviceModelCubit _cubit(_FakeStore store, {DeviceInfo device = _flagship}) =>
    OnDeviceModelCubit(
      store: store,
      support: (OnDeviceModel variant) async =>
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
    final OnDeviceModelCubit cubit = _cubit(store, device: _midRange);
    addTearDown(cubit.close);

    await cubit.init();
    expect(cubit.state.supports(OnDeviceModel.e2b), isTrue);
    expect(cubit.state.supports(OnDeviceModel.e4b), isFalse);

    expect(await cubit.ensure(OnDeviceModel.e4b), isFalse);
    expect(store.installs, isEmpty);
  });

  test('download reports progress and finishes installed', () async {
    final _FakeStore store = _FakeStore()..gate = Completer<void>();
    final OnDeviceModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();
    expect(cubit.state.status, OnDeviceModelStatus.missing);

    final Future<bool> first = cubit.download();
    final Future<bool> second = cubit.ensure(OnDeviceModel.e2b);
    await Future<void>.delayed(Duration.zero);
    store.progress!(42);
    expect(cubit.state.status, OnDeviceModelStatus.downloading);
    expect(cubit.state.progress, 42);

    store.gate!.complete();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(store.installs, <OnDeviceModel>[OnDeviceModel.e2b]);
    expect(cubit.state.status, OnDeviceModelStatus.installed);
  });

  test(
    'leftover downloads are cancelled at start and before a download',
    () async {
      final _FakeStore store = _FakeStore();
      final OnDeviceModelCubit cubit = _cubit(store);
      addTearDown(cubit.close);

      await cubit.init();
      expect(store.staleCancels, 1);

      expect(await cubit.download(), isTrue);
      expect(store.staleCancels, 2);
    },
  );

  test('progress never jumps back while downloading', () async {
    final _FakeStore store = _FakeStore()..gate = Completer<void>();
    final OnDeviceModelCubit cubit = _cubit(store);
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
    final OnDeviceModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();

    expect(await cubit.download(), isFalse);
    expect(cubit.state.status, OnDeviceModelStatus.failed);

    store.fail = false;
    expect(await cubit.download(), isTrue);
    expect(cubit.state.status, OnDeviceModelStatus.installed);
  });

  test(
    'switching models downloads the new one and lists the old one',
    () async {
      final _FakeStore store = _FakeStore()..installed.add(OnDeviceModel.e2b);
      final OnDeviceModelCubit cubit = _cubit(store);
      addTearDown(cubit.close);
      await cubit.init();
      expect(cubit.state.status, OnDeviceModelStatus.installed);

      expect(await cubit.ensure(OnDeviceModel.e4b), isTrue);

      expect(cubit.state.variant, OnDeviceModel.e4b);
      expect(store.installs, <OnDeviceModel>[OnDeviceModel.e4b]);
      expect(cubit.state.otherInstalledVariants, <OnDeviceModel>[
        OnDeviceModel.e2b,
      ]);

      await cubit.delete(OnDeviceModel.e2b);
      expect(cubit.state.otherInstalledVariants, isEmpty);
      expect(cubit.state.status, OnDeviceModelStatus.installed);
    },
  );

  test('deleting the selected model marks it missing', () async {
    final _FakeStore store = _FakeStore()..installed.add(OnDeviceModel.e2b);
    final OnDeviceModelCubit cubit = _cubit(store);
    addTearDown(cubit.close);
    await cubit.init();

    await cubit.delete(OnDeviceModel.e2b);
    expect(cubit.state.status, OnDeviceModelStatus.missing);
    expect(store.installed, isEmpty);
  });

  test('Gemma falls back to ML Kit on unsupported phones', () {
    final PageTranslationSettings settings = PageTranslationSettings(
      translator: OnDeviceModel.e4b.engineId,
    );
    final OnDeviceModelState flagship = OnDeviceModelState(
      supportByVariant: <OnDeviceModel, OnDeviceAiSupport>{
        OnDeviceModel.e4b: OnDeviceAiSupport.evaluate(
          _flagship,
          minRamGb: OnDeviceModel.e4b.minRamGb,
        ),
      },
    );
    final OnDeviceModelState midRange = OnDeviceModelState(
      supportByVariant: <OnDeviceModel, OnDeviceAiSupport>{
        OnDeviceModel.e4b: OnDeviceAiSupport.evaluate(
          _midRange,
          minRamGb: OnDeviceModel.e4b.minRamGb,
        ),
      },
    );

    expect(
      onDeviceModelOf(effectiveTranslationSettings(settings, flagship)),
      OnDeviceModel.e4b,
    );
    expect(
      usesOnDeviceModel(effectiveTranslationSettings(settings, midRange)),
      isFalse,
    );
  });
}
