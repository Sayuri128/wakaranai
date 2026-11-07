part of 'native_player_cubit.dart';

mixin _AutoNextCountdown on _NativePlayerCore {
  void cancelAutoNext() {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    if (isClosed || state.autoNextSecondsLeft == null) {
      return;
    }
    emit(state.copyWith(autoNextSecondsLeft: () => null));
  }

  Future<void> playNextNow() async {
    cancelAutoNext();
    if (isClosed || !hasNextEpisode) {
      return;
    }
    await playNext();
  }

  Future<void> tickAutoNext() async {
    final int? secondsLeft = state.autoNextSecondsLeft;
    if (isClosed || secondsLeft == null) {
      return;
    }
    final int remaining = secondsLeft - 1;
    if (remaining <= 0) {
      await playNextNow();
      return;
    }
    emit(state.copyWith(autoNextSecondsLeft: () => remaining));
  }

  @override
  void _trackCompletion(VideoPlayerValue value) {
    if (!value.isCompleted) {
      if (_completionHandled) {
        _resetCompletion();
      }
      return;
    }
    if (_completionHandled) {
      return;
    }
    _completionHandled = true;
    unawaited(saveProgress());
    if (hasNextEpisode && _autoPlayNext) {
      _startAutoNextCountdown();
    }
  }

  void _startAutoNextCountdown() {
    _autoNextTimer?.cancel();
    if (state.holdActive) {
      emit(state.copyWith(holdActive: false, activeHoldSpeed: () => null));
    }
    emit(state.copyWith(
      autoNextSecondsLeft: () => kAutoNextCountdownSeconds,
    ));
    _autoNextTimer = Timer.periodic(
      _autoNextTick,
      (Timer timer) => unawaited(tickAutoNext()),
    );
  }

  @override
  void _resetCompletion() {
    _completionHandled = false;
    cancelAutoNext();
  }
}
