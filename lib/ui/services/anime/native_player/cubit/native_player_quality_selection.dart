part of 'native_player_cubit.dart';

mixin _QualitySelection on _NativePlayerCore {
  Future<void> selectQualityOption(QualityOption option) async {
    switch (option.kind) {
      case QualityOptionKind.stream:
        await selectQuality(option.streamIndex);
      case QualityOptionKind.auto:
        await selectRendition(null);
      case QualityOptionKind.rendition:
        await selectRendition(option.rendition);
    }
  }

  Future<void> selectRendition(PlayerRendition? rendition) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    _rememberQuality(
      streamIndex: state.streamIndex,
      renditionLabel: rendition?.preferenceLabel ?? kAutoQualityLabel,
    );
    if (rendition?.id == state.selectedRenditionId) {
      return;
    }
    await _selectRenditionOn(currentEngine, rendition, _openGeneration);
  }

  Future<void> selectQuality(int index) async {
    if (index < 0 || index >= _video.streams.length) {
      return;
    }
    _rememberQuality(streamIndex: index, renditionLabel: kAutoQualityLabel);
    if (index == state.streamIndex && state.status == NativePlayerStatus.ready) {
      return;
    }
    final NativePlayerEngine? currentEngine = _engine;
    final bool wasPlaying = currentEngine == null ||
        state.status != NativePlayerStatus.ready ||
        currentEngine.value.isPlaying;
    final Duration position = _currentPosition();
    await saveProgress();
    await _openStream(
      index,
      startPosition: position > Duration.zero ? position : null,
      savedProgress: _progress.saved,
      autoPlay: wasPlaying,
    );
  }

  void _rememberQuality({
    required int streamIndex,
    required String renditionLabel,
  }) {
    final QualityPreference preference = rememberedQualityPreference(
      previous: _qualityPreference,
      streams: _video.streams,
      streamIndex: streamIndex,
      renditionLabel: renditionLabel,
    );
    _qualityPreference = preference;
    unawaited(
      _persistPreference(() => _preferences.setQualityPreference(preference)),
    );
  }

  @override
  Future<void> _loadRenditions(
    NativePlayerEngine openedEngine,
    int generation,
  ) async {
    final List<PlayerRendition> renditions =
        await _readRenditions(openedEngine);
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(
      renditions: renditions,
      selectedRenditionId: () => null,
    ));
    final PlayerRendition? preferred = preferredRendition(
      renditions: renditions,
      preference: _qualityPreference,
      currentStreamLabel: _video.streams[state.streamIndex].quality,
    );
    if (preferred == null) {
      return;
    }
    await _selectRenditionOn(openedEngine, preferred, generation);
  }

  Future<List<PlayerRendition>> _readRenditions(
    NativePlayerEngine openedEngine,
  ) async {
    if (!openedEngine.supportsVideoTracks) {
      return const <PlayerRendition>[];
    }
    try {
      return distinctRenditions(await openedEngine.getVideoTracks());
    } catch (error, stackTrace) {
      logger.w('Failed to read video tracks: $error');
      logger.w(stackTrace);
      return const <PlayerRendition>[];
    }
  }

  Future<void> _selectRenditionOn(
    NativePlayerEngine targetEngine,
    PlayerRendition? rendition,
    int generation,
  ) async {
    try {
      await targetEngine.selectVideoTrack(rendition?.track);
    } catch (error, stackTrace) {
      logger.w('Failed to select video track ${rendition?.id}: $error');
      logger.w(stackTrace);
      return;
    }
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(selectedRenditionId: () => rendition?.id));
  }
}
