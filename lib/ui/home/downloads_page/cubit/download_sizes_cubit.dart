import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/storage/download_sizes.dart';

class DownloadSizesState {
  DownloadSizesState({
    this.downloads = const <DownloadDomain>[],
    this.itemBytes = const <String, int>{},
    this.measured = false,
  });

  final List<DownloadDomain> downloads;
  final Map<String, int> itemBytes;
  final bool measured;

  late final DownloadStorageUsage usage = summarizeDownloadStorage(
    downloads,
    itemBytes,
  );
}

class DownloadSizesCubit extends Cubit<DownloadSizesState> {
  DownloadSizesCubit({
    required Stream<List<DownloadDomain>> downloads,
    required List<DownloadDomain> initial,
    DownloadSizeCache? cache,
    Duration debounce = const Duration(milliseconds: 400),
  }) : _cache = cache ?? DownloadSizeCache(),
       _debounce = debounce,
       _latest = initial,
       super(DownloadSizesState(downloads: initial)) {
    _subscription = downloads.listen(_onDownloads);
    unawaited(_refresh());
  }

  final DownloadSizeCache _cache;
  final Duration _debounce;
  late final StreamSubscription<List<DownloadDomain>> _subscription;
  List<DownloadDomain> _latest;
  Timer? _debounceTimer;
  bool _refreshing = false;
  bool _stale = false;

  void _onDownloads(List<DownloadDomain> downloads) {
    _latest = downloads;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => unawaited(_refresh()));
  }

  Future<void> refreshNow() {
    _debounceTimer?.cancel();
    return _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) {
      _stale = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _stale = false;
        await _measure(_latest);
      } while (_stale && !isClosed);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _measure(List<DownloadDomain> downloads) async {
    try {
      final Map<String, int> sizes = await _cache.refresh(downloads);
      if (isClosed) {
        return;
      }
      _emitIfChanged(downloads, sizes);
    } catch (error, stackTrace) {
      logger.w('Failed to measure downloads: $error');
      logger.w(stackTrace);
    }
  }

  void _emitIfChanged(List<DownloadDomain> downloads, Map<String, int> sizes) {
    final bool sameSizes = const MapEquality<String, int>().equals(
      sizes,
      state.itemBytes,
    );
    final bool sameDownloads = identical(downloads, state.downloads);
    if (sameSizes && sameDownloads && state.measured) {
      return;
    }
    emit(
      DownloadSizesState(
        downloads: downloads,
        itemBytes: sizes,
        measured: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
