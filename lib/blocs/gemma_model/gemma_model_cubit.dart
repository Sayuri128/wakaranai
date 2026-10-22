import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';

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
    this.status = GemmaModelStatus.unknown,
    this.progress = 0,
    this.support,
  });

  final GemmaModelStatus status;
  final int progress;
  final OnDeviceAiSupport? support;

  bool get supported => support?.supported ?? false;

  GemmaModelState copyWith({
    GemmaModelStatus? status,
    int? progress,
    OnDeviceAiSupport? support,
  }) {
    return GemmaModelState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      support: support ?? this.support,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, progress, support?.issues];
}

abstract class GemmaModelStore {
  Future<bool> isInstalled();

  Future<void> install({required void Function(int percent) onProgress});

  void cancel();

  Future<void> uninstall();
}

class GemmaModelCubit extends Cubit<GemmaModelState> {
  GemmaModelCubit({
    required GemmaModelStore store,
    required Future<OnDeviceAiSupport> Function() support,
  }) : _store = store,
       _support = support,
       super(const GemmaModelState());

  final GemmaModelStore _store;
  final Future<OnDeviceAiSupport> Function() _support;
  Completer<bool>? _activeDownload;

  Future<void> init() async {
    final OnDeviceAiSupport support = await _support();
    if (!support.supported) {
      _emit(
        state.copyWith(status: GemmaModelStatus.unsupported, support: support),
      );
      return;
    }
    _emit(state.copyWith(support: support));
    await refresh();
  }

  Future<void> refresh() async {
    if (!state.supported || state.status == GemmaModelStatus.downloading) {
      return;
    }
    final bool installed = await _checkInstalled();
    _emit(
      state.copyWith(
        status: installed
            ? GemmaModelStatus.installed
            : GemmaModelStatus.missing,
      ),
    );
  }

  Future<bool> _checkInstalled() async {
    try {
      return await _store.isInstalled();
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
    _emit(state.copyWith(status: GemmaModelStatus.downloading, progress: 0));
    unawaited(_install(download));
    return download.future;
  }

  Future<void> _install(Completer<bool> download) async {
    bool installed = false;
    try {
      await _store.install(onProgress: _onDownloadProgress);
      installed = true;
    } catch (e) {
      logger.w('Gemma model download failed: $e');
    }
    _activeDownload = null;
    if (installed) {
      _emit(state.copyWith(status: GemmaModelStatus.installed, progress: 100));
    } else {
      _emit(state.copyWith(status: GemmaModelStatus.failed));
    }
    download.complete(installed);
  }

  void _onDownloadProgress(int percent) {
    if (percent != state.progress) {
      _emit(state.copyWith(progress: percent));
    }
  }

  Future<bool> ensure() async {
    if (state.status == GemmaModelStatus.unknown) {
      await init();
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

  Future<void> delete() async {
    try {
      await _store.uninstall();
    } catch (e) {
      logger.w('Gemma model delete failed: $e');
    }
    _emit(state.copyWith(status: GemmaModelStatus.missing, progress: 0));
  }

  void _emit(GemmaModelState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
