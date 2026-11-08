part of 'native_player_cubit.dart';

mixin _SubtitleSelection on _NativePlayerCore {
  Future<void> selectSubtitle(int? index) async {
    final bool valid =
        index != null && index >= 0 && index < _video.subtitles.length;
    final SubtitlePreference? preference = valid
        ? subtitlePreferenceFor(_video.subtitles[index])
        : const SubtitlePreference.off();
    if (preference != null) {
      _subtitlePreference = preference;
      unawaited(_persistPreference(() => _preferences.setSubtitle(preference)));
    }
    await _applySubtitle(valid ? index : null);
  }

  @override
  Future<void> _restorePreferredSubtitle() async {
    if (isClosed || state.status != NativePlayerStatus.ready) {
      return;
    }
    final int? index =
        preferredSubtitleIndex(_video.subtitles, _subtitlePreference);
    if (index == null) {
      return;
    }
    await _applySubtitle(index);
  }

  @override
  Future<void> _applySubtitle(int? index) async {
    final int generation = ++_subtitleGeneration;
    if (index == null) {
      await _clearSubtitle();
      return;
    }
    emit(state.copyWith(
      subtitleIndex: () => index,
      subtitleLoading: true,
      subtitleFailed: false,
    ));
    try {
      final ClosedCaptionFile captionFile =
          await _subtitleLoader.load(_video.subtitles[index]);
      if (generation != _subtitleGeneration || isClosed) {
        return;
      }
      _captionFile = captionFile;
      await _engine?.setClosedCaptionFile(captionFile);
      emit(state.copyWith(subtitleLoading: false));
    } catch (error, stackTrace) {
      logger.e('Failed to load subtitle ${_video.subtitles[index].url}: $error');
      logger.e(stackTrace);
      if (generation != _subtitleGeneration || isClosed) {
        return;
      }
      _captionFile = null;
      emit(state.copyWith(
        subtitleIndex: () => null,
        subtitleLoading: false,
        subtitleFailed: true,
      ));
    }
  }

  Future<void> _clearSubtitle() async {
    _captionFile = null;
    emit(state.copyWith(
      subtitleIndex: () => null,
      subtitleLoading: false,
      subtitleFailed: false,
    ));
    await _engine?.setClosedCaptionFile(null);
  }
}
