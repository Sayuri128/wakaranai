import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/utils/download_rate.dart';

enum OnDeviceModelStatus {
  unknown,
  unsupported,
  missing,
  downloading,
  installed,
  failed,
}

class OnDeviceModelState extends Equatable {
  const OnDeviceModelState({
    this.variant = OnDeviceModel.e2b,
    this.status = OnDeviceModelStatus.unknown,
    this.progress = 0,
    this.estimate,
    this.supportByVariant = const <OnDeviceModel, OnDeviceAiSupport>{},
    this.installedVariants = const <OnDeviceModel>{},
  });

  final OnDeviceModel variant;
  final OnDeviceModelStatus status;
  final int progress;
  final DownloadEstimate? estimate;
  final Map<OnDeviceModel, OnDeviceAiSupport> supportByVariant;
  final Set<OnDeviceModel> installedVariants;

  OnDeviceAiSupport? get support => supportByVariant[variant];

  bool get supported => supports(variant);

  bool supports(OnDeviceModel variant) {
    return supportByVariant[variant]?.supported ?? false;
  }

  Iterable<OnDeviceModel> get otherInstalledVariants => installedVariants.where(
    (OnDeviceModel installed) => installed != variant,
  );

  OnDeviceModelState copyWith({
    OnDeviceModel? variant,
    OnDeviceModelStatus? status,
    int? progress,
    DownloadEstimate? estimate,
    bool clearEstimate = false,
    Map<OnDeviceModel, OnDeviceAiSupport>? supportByVariant,
    Set<OnDeviceModel>? installedVariants,
  }) {
    return OnDeviceModelState(
      variant: variant ?? this.variant,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      estimate: clearEstimate ? null : estimate ?? this.estimate,
      supportByVariant: supportByVariant ?? this.supportByVariant,
      installedVariants: installedVariants ?? this.installedVariants,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    variant,
    status,
    progress,
    estimate?.bytesPerSecond,
    estimate?.remaining,
    supportByVariant.keys.toList(),
    supportByVariant.values
        .map((OnDeviceAiSupport support) => support.issues)
        .toList(),
    installedVariants,
  ];
}

abstract class OnDeviceModelStore {
  Future<bool> isInstalled(OnDeviceModel variant);

  Future<void> install(
    OnDeviceModel variant, {
    required void Function(int percent) onProgress,
  });

  void cancel();

  Future<void> cancelStaleDownloads();

  Future<void> uninstall(OnDeviceModel variant);
}

class OnDeviceModelCubit extends Cubit<OnDeviceModelState> {
  OnDeviceModelCubit({
    required OnDeviceModelStore store,
    required Future<OnDeviceAiSupport> Function(OnDeviceModel variant) support,
    DateTime Function()? clock,
  }) : _store = store,
       _support = support,
       _clock = clock ?? DateTime.now,
       super(const OnDeviceModelState());

  final OnDeviceModelStore _store;
  final Future<OnDeviceAiSupport> Function(OnDeviceModel variant) _support;
  final DateTime Function() _clock;
  Completer<bool>? _activeDownload;
  DownloadRate? _downloadRate;
  Future<void>? _initialized;
  StreamSubscription<OnDeviceModel?>? _selectionSubscription;

  void followSelection(
    Stream<OnDeviceModel?> selections, {
    OnDeviceModel? current,
  }) {
    if (current != null) {
      unawaited(select(current));
    }
    unawaited(_selectionSubscription?.cancel());
    _selectionSubscription = selections.listen((OnDeviceModel? variant) {
      if (variant != null) {
        unawaited(select(variant));
      }
    });
  }

  Future<void> init() => _initialized ??= _loadSupport();

  Future<void> _loadSupport() async {
    await _cancelStaleDownloads();
    final Map<OnDeviceModel, OnDeviceAiSupport> supportByVariant =
        <OnDeviceModel, OnDeviceAiSupport>{
          for (final OnDeviceModel variant in OnDeviceModel.values)
            variant: await _support(variant),
        };
    _emit(state.copyWith(supportByVariant: supportByVariant));
    await refresh();
  }

  Future<void> select(OnDeviceModel variant) async {
    await init();
    if (variant == state.variant ||
        state.status == OnDeviceModelStatus.downloading) {
      return;
    }
    _emit(
      state.copyWith(
        variant: variant,
        status: OnDeviceModelStatus.unknown,
        progress: 0,
      ),
    );
    await refresh();
  }

  Future<void> refresh() async {
    if (state.status == OnDeviceModelStatus.downloading) {
      return;
    }
    final Set<OnDeviceModel> installed = <OnDeviceModel>{
      for (final OnDeviceModel variant in OnDeviceModel.values)
        if (await _checkInstalled(variant)) variant,
    };
    _emit(
      state.copyWith(
        installedVariants: installed,
        status: _statusFor(state.variant, installed),
      ),
    );
  }

  OnDeviceModelStatus _statusFor(
    OnDeviceModel variant,
    Set<OnDeviceModel> installed,
  ) {
    if (!state.supports(variant)) {
      return OnDeviceModelStatus.unsupported;
    }
    if (installed.contains(variant)) {
      return OnDeviceModelStatus.installed;
    }
    return OnDeviceModelStatus.missing;
  }

  Future<bool> _checkInstalled(OnDeviceModel variant) async {
    try {
      return await _store.isInstalled(variant);
    } catch (e) {
      logger.w('Gemma model check failed: $e');
      return false;
    }
  }

  Future<bool> download() {
    final Completer<bool>? activeDownload = _activeDownload;
    if (activeDownload != null) {
      return activeDownload.future;
    }
    if (!state.supported) {
      return Future<bool>.value(false);
    }
    if (state.status == OnDeviceModelStatus.installed) {
      return Future<bool>.value(true);
    }

    final Completer<bool> download = Completer<bool>();
    _activeDownload = download;
    _downloadRate = DownloadRate(
      totalBytes: state.variant.sizeBytes,
      clock: _clock,
    );
    _emit(
      state.copyWith(
        status: OnDeviceModelStatus.downloading,
        progress: 0,
        clearEstimate: true,
      ),
    );
    unawaited(_install(state.variant, download));
    return download.future;
  }

  Future<void> _install(OnDeviceModel variant, Completer<bool> download) async {
    bool installed = false;
    await _cancelStaleDownloads();
    try {
      await _store.install(variant, onProgress: _onDownloadProgress);
      installed = true;
    } catch (e) {
      logger.w('Gemma model download failed: $e');
    }
    _activeDownload = null;
    _downloadRate = null;
    if (installed) {
      _emit(
        state.copyWith(
          status: OnDeviceModelStatus.installed,
          progress: 100,
          installedVariants: <OnDeviceModel>{
            ...state.installedVariants,
            variant,
          },
        ),
      );
    } else {
      _emit(state.copyWith(status: OnDeviceModelStatus.failed));
    }
    download.complete(installed);
  }

  Future<void> _cancelStaleDownloads() async {
    try {
      await _store.cancelStaleDownloads();
    } catch (e) {
      logger.w('Cancelling stale model downloads failed: $e');
    }
  }

  void _onDownloadProgress(int percent) {
    if (percent <= state.progress) {
      return;
    }
    final DownloadRate? rate = _downloadRate;
    rate?.record(state.variant.sizeBytes * percent ~/ 100);
    _emit(state.copyWith(progress: percent, estimate: rate?.estimate));
  }

  Future<bool> ensure(OnDeviceModel variant) async {
    await select(variant);
    if (state.variant != variant) {
      return false;
    }
    if (state.status == OnDeviceModelStatus.installed) {
      return true;
    }
    return download();
  }

  void cancel() {
    if (_activeDownload != null) {
      _store.cancel();
    }
  }

  Future<void> delete(OnDeviceModel variant) async {
    try {
      await _store.uninstall(variant);
    } catch (e) {
      logger.w('Gemma model delete failed: $e');
    }
    final Set<OnDeviceModel> installed = Set<OnDeviceModel>.of(
      state.installedVariants,
    )..remove(variant);
    if (variant == state.variant) {
      _emit(
        state.copyWith(
          status: OnDeviceModelStatus.missing,
          progress: 0,
          installedVariants: installed,
        ),
      );
    } else {
      _emit(state.copyWith(installedVariants: installed));
    }
  }

  void _emit(OnDeviceModelState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  @override
  Future<void> close() async {
    await _selectionSubscription?.cancel();
    return super.close();
  }
}
