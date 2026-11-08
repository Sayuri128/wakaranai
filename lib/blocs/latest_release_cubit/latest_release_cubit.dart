import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/latest_release_data.dart';
import 'package:wakaranai/services/releases_service/releases_service.dart';

part 'latest_release_state.dart';

class LatestReleaseCubit extends Cubit<LatestReleaseState> {
  LatestReleaseCubit({
    ReleasesService? releasesService,
    DateTime Function()? now,
    this.recheckInterval = const Duration(hours: 1),
    this.retryInterval = const Duration(minutes: 1),
    bool checkOnResume = true,
  })  : _releasesService = releasesService ?? ReleasesService(),
        _now = now ?? DateTime.now,
        super(LatestReleaseInitial()) {
    if (checkOnResume) {
      _lifecycleListener = AppLifecycleListener(
        onResume: () => unawaited(check()),
      );
    }
  }

  final ReleasesService _releasesService;
  final DateTime Function() _now;
  final Duration recheckInterval;
  final Duration retryInterval;
  AppLifecycleListener? _lifecycleListener;
  DateTime? _lastAttempt;
  bool _checking = false;

  Future<void> init() => check(force: true);

  Future<void> check({bool force = false}) async {
    if (_checking || isClosed) {
      return;
    }
    if (!force && !_isDue()) {
      return;
    }
    _checking = true;
    _lastAttempt = _now();
    if (state is! LatestReleaseLoaded) {
      emit(LatestReleaseLoading());
    }
    try {
      final LatestReleaseData? releaseData =
          await _releasesService.fetchLatestRelease();
      _apply(releaseData);
    } finally {
      _checking = false;
    }
  }

  void _apply(LatestReleaseData? releaseData) {
    if (isClosed) {
      return;
    }
    if (releaseData != null) {
      emit(LatestReleaseLoaded(releaseData: releaseData));
      return;
    }
    if (state is LatestReleaseLoaded) {
      return;
    }
    emit(const LatestReleaseError(
      message: 'Failed to get latest release data',
    ));
  }

  bool _isDue() {
    final DateTime? lastAttempt = _lastAttempt;
    if (lastAttempt == null) {
      return true;
    }
    final Duration interval =
        state is LatestReleaseLoaded ? recheckInterval : retryInterval;
    return _now().difference(lastAttempt) >= interval;
  }

  @override
  Future<void> close() {
    _lifecycleListener?.dispose();
    return super.close();
  }
}
