part of 'native_player_cubit.dart';

mixin _PlaybackSpeedControl on _NativePlayerCore {
  Future<void> setPlaybackSpeed(double speed) async {
    final double previousSpeed = state.playbackSpeed;
    final double normalizedSpeed = normalizePlaybackSpeed(speed);
    emit(state.copyWith(playbackSpeed: normalizedSpeed));
    if (state.holdActive) {
      await _refreshHoldSpeed();
    } else {
      final bool applied = await _applyEngineSpeed(normalizedSpeed);
      if (!applied) {
        await _rejectSpeed(fallbackSpeed: previousSpeed);
        return;
      }
    }
    await _persistPreference(
      () => _preferences.setPlaybackSpeed(normalizedSpeed),
    );
  }

  Future<void> startHoldSpeed() async {
    if (state.holdActive ||
        state.status != NativePlayerStatus.ready ||
        !state.isPlaying) {
      return;
    }
    final double? holdSpeed = holdPlaybackSpeed(
      currentSpeed: state.playbackSpeed,
      configuredHoldSpeed: state.holdSpeed,
    );
    if (holdSpeed == null) {
      return;
    }
    emit(state.copyWith(holdActive: true, activeHoldSpeed: () => holdSpeed));
    final bool applied = await _applyEngineSpeed(holdSpeed);
    if (!applied && !isClosed) {
      emit(state.copyWith(
        holdActive: false,
        activeHoldSpeed: () => null,
        speedRejections: state.speedRejections + 1,
      ));
      await _applyEngineSpeed(state.playbackSpeed);
    }
  }

  Future<void> endHoldSpeed() async {
    if (!state.holdActive || isClosed) {
      return;
    }
    emit(state.copyWith(holdActive: false, activeHoldSpeed: () => null));
    await _applyEngineSpeed(state.playbackSpeed);
  }

  Future<void> _refreshHoldSpeed() async {
    final double holdSpeed = holdPlaybackSpeed(
          currentSpeed: state.playbackSpeed,
          configuredHoldSpeed: state.holdSpeed,
        ) ??
        state.playbackSpeed;
    if (holdSpeed == state.activeHoldSpeed) {
      return;
    }
    emit(state.copyWith(activeHoldSpeed: () => holdSpeed));
    final bool applied = await _applyEngineSpeed(holdSpeed);
    if (!applied) {
      await endHoldSpeed();
    }
  }

  Future<bool> _applyEngineSpeed(double speed) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return true;
    }
    return _trySetSpeed(currentEngine, speed);
  }

  @override
  Future<bool> _trySetSpeed(NativePlayerEngine engine, double speed) async {
    try {
      await engine.setPlaybackSpeed(speed);
      return true;
    } catch (error, stackTrace) {
      logger.w('Playback speed $speed was rejected: $error');
      logger.w(stackTrace);
      return false;
    }
  }

  Future<void> _rejectSpeed({required double fallbackSpeed}) async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(
      playbackSpeed: fallbackSpeed,
      speedRejections: state.speedRejections + 1,
    ));
    await _applyEngineSpeed(fallbackSpeed);
  }

  @override
  Future<void> _applyInitialSpeed(NativePlayerEngine preparedEngine) async {
    final double speed = state.effectiveSpeed;
    if (speed == 1.0) {
      return;
    }
    final bool applied = await _trySetSpeed(preparedEngine, speed);
    if (applied || isClosed) {
      return;
    }
    emit(state.copyWith(
      playbackSpeed: 1.0,
      holdActive: false,
      activeHoldSpeed: () => null,
      speedRejections: state.speedRejections + 1,
    ));
    await _trySetSpeed(preparedEngine, 1.0);
  }
}
