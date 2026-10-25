import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_variant.dart';
import 'package:wakaranai/utils/download_rate.dart';

enum GemmaModelStatus {
  unknown,
  unsupported,
  missing,
  downloading,
  installed,
  failed,
}

class GemmaModelState extends Equatable {
  const GemmaModelState({
    this.variant = GemmaVariant.e2b,
    this.status = GemmaModelStatus.unknown,
    this.progress = 0,
    this.estimate,
    this.supportByVariant = const <GemmaVariant, OnDeviceAiSupport>{},
    this.installedVariants = const <GemmaVariant>{},
  });

  final GemmaVariant variant;
  final GemmaModelStatus status;
  final int progress;
  final DownloadEstimate? estimate;
  final Map<GemmaVariant, OnDeviceAiSupport> supportByVariant;
  final Set<GemmaVariant> installedVariants;

  OnDeviceAiSupport? get support => supportByVariant[variant];

  bool get supported => supports(variant);

  bool supports(GemmaVariant variant) {
    return supportByVariant[variant]?.supported ?? false;
  }

  Iterable<GemmaVariant> get otherInstalledVariants =>
      installedVariants.where((GemmaVariant installed) => installed != variant);

  GemmaModelState copyWith({
    GemmaVariant? variant,
    GemmaModelStatus? status,
    int? progress,
    DownloadEstimate? estimate,
    bool clearEstimate = false,
    Map<GemmaVariant, OnDeviceAiSupport>? supportByVariant,
    Set<GemmaVariant>? installedVariants,
  }) {
    return GemmaModelState(
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

abstract class GemmaModelStore {
  Future<bool> isInstalled(GemmaVariant variant);

  Future<void> install(
    GemmaVariant variant, {
    required void Function(int percent) onProgress,
  });

  void cancel();

  Future<void> cancelStaleDownloads();

  Future<void> uninstall(GemmaVariant variant);
}

class GemmaModelCubit extends Cubit<GemmaModelState> {
  GemmaModelCubit({
    required GemmaModelStore store,
    required Future<OnDeviceAiSupport> Function(GemmaVariant variant) support,
    DateTime Function()? clock,
  }) : _store = store,
       _support = support,
       _clock = clock ?? DateTime.now,
       super(const GemmaModelState());

  final GemmaModelStore _store;
  final Future<OnDeviceAiSupport> Function(GemmaVariant variant) _support;
  final DateTime Function() _clock;
  Completer<bool>? _activeDownload;
  DownloadRate? _downloadRate;
  Future<void>? _initialized;
  StreamSubscription<GemmaVariant?>? _selectionSubscription;

  void followSelection(
    Stream<GemmaVariant?> selections, {
    GemmaVariant? current,
  }) {
    if (current != null) {
      unawaited(select(current));
    }
    unawaited(_selectionSubscription?.cancel());
    _selectionSubscription = selections.listen((GemmaVariant? variant) {
      if (variant != null) {
        unawaited(select(variant));
      }
    });
  }

  Future<void> init() => _initialized ??= _loadSupport();

  Future<void> _loadSupport() async {
    await _cancelStaleDownloads();
    final Map<GemmaVariant, OnDeviceAiSupport> supportByVariant =
        <GemmaVariant, OnDeviceAiSupport>{
          for (final GemmaVariant variant in GemmaVariant.values)
            variant: await _support(variant),
        };
    _emit(state.copyWith(supportByVariant: supportByVariant));
    await refresh();
  }

  Future<void> select(GemmaVariant variant) async {
    await init();
    if (variant == state.variant ||
        state.status == GemmaModelStatus.downloading) {
      return;
    }
    _emit(
      state.copyWith(
        variant: variant,
        status: GemmaModelStatus.unknown,
        progress: 0,
      ),
    );
    await refresh();
  }

  Future<void> refresh() async {
    if (state.status == GemmaModelStatus.downloading) {
      return;
    }
    final Set<GemmaVariant> installed = <GemmaVariant>{
      for (final GemmaVariant variant in GemmaVariant.values)
        if (await _checkInstalled(variant)) variant,
    };
    _emit(
      state.copyWith(
        installedVariants: installed,
        status: _statusFor(state.variant, installed),
      ),
    );
  }

  GemmaModelStatus _statusFor(
    GemmaVariant variant,
    Set<GemmaVariant> installed,
  ) {
    if (!state.supports(variant)) {
      return GemmaModelStatus.unsupported;
    }
    if (installed.contains(variant)) {
      return GemmaModelStatus.installed;
    }
    return GemmaModelStatus.missing;
  }

  Future<bool> _checkInstalled(GemmaVariant variant) async {
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
    if (state.status == GemmaModelStatus.installed) {
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
        status: GemmaModelStatus.downloading,
        progress: 0,
        clearEstimate: true,
      ),
    );
    unawaited(_install(state.variant, download));
    return download.future;
  }

  Future<void> _install(GemmaVariant variant, Completer<bool> download) async {
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
          status: GemmaModelStatus.installed,
          progress: 100,
          installedVariants: <GemmaVariant>{
            ...state.installedVariants,
            variant,
          },
        ),
      );
    } else {
      _emit(state.copyWith(status: GemmaModelStatus.failed));
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

  Future<bool> ensure(GemmaVariant variant) async {
    await select(variant);
    if (state.variant != variant) {
      return false;
    }
    if (state.status == GemmaModelStatus.installed) {
      return true;
    }
    return download();
  }

  void cancel() {
    if (_activeDownload != null) {
      _store.cancel();
    }
  }

  Future<void> delete(GemmaVariant variant) async {
    try {
      await _store.uninstall(variant);
    } catch (e) {
      logger.w('Gemma model delete failed: $e');
    }
    final Set<GemmaVariant> installed = Set<GemmaVariant>.of(
      state.installedVariants,
    )..remove(variant);
    if (variant == state.variant) {
      _emit(
        state.copyWith(
          status: GemmaModelStatus.missing,
          progress: 0,
          installedVariants: installed,
        ),
      );
    } else {
      _emit(state.copyWith(installedVariants: installed));
    }
  }

  void _emit(GemmaModelState next) {
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
