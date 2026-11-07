part of 'native_player_cubit.dart';

enum NativePlayerStatus { loading, ready, error }

class NativePlayerState extends Equatable {
  const NativePlayerState({
    this.status = NativePlayerStatus.loading,
    this.engine,
    this.engineGeneration = 0,
    this.streamIndex = 0,
    this.subtitleIndex,
    this.subtitleLoading = false,
    this.subtitleFailed = false,
    this.playbackSpeed = 1.0,
    this.holdSpeed = kDefaultHoldSpeed,
    this.holdActive = false,
    this.speedRejections = 0,
    this.fitMode = PlayerFitMode.fit,
    this.skipOpeningSeconds = kDefaultSkipOpeningSeconds,
    this.autoNextSecondsLeft,
    this.nextEpisodeRequested = false,
    this.isPlaying = false,
    this.errorMessage,
  });

  final NativePlayerStatus status;
  final NativePlayerEngine? engine;
  final int engineGeneration;
  final int streamIndex;
  final int? subtitleIndex;
  final bool subtitleLoading;
  final bool subtitleFailed;
  final double playbackSpeed;
  final double holdSpeed;
  final bool holdActive;
  final int speedRejections;
  final PlayerFitMode fitMode;
  final int skipOpeningSeconds;
  final int? autoNextSecondsLeft;
  final bool nextEpisodeRequested;
  final bool isPlaying;
  final String? errorMessage;

  double get effectiveSpeed => holdActive ? holdSpeed : playbackSpeed;

  NativePlayerState copyWith({
    NativePlayerStatus? status,
    ValueGetter<NativePlayerEngine?>? engine,
    int? engineGeneration,
    int? streamIndex,
    ValueGetter<int?>? subtitleIndex,
    bool? subtitleLoading,
    bool? subtitleFailed,
    double? playbackSpeed,
    double? holdSpeed,
    bool? holdActive,
    int? speedRejections,
    PlayerFitMode? fitMode,
    int? skipOpeningSeconds,
    ValueGetter<int?>? autoNextSecondsLeft,
    bool? nextEpisodeRequested,
    bool? isPlaying,
    ValueGetter<String?>? errorMessage,
  }) {
    return NativePlayerState(
      status: status ?? this.status,
      engine: engine != null ? engine() : this.engine,
      engineGeneration: engineGeneration ?? this.engineGeneration,
      streamIndex: streamIndex ?? this.streamIndex,
      subtitleIndex: subtitleIndex != null ? subtitleIndex() : this.subtitleIndex,
      subtitleLoading: subtitleLoading ?? this.subtitleLoading,
      subtitleFailed: subtitleFailed ?? this.subtitleFailed,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      holdSpeed: holdSpeed ?? this.holdSpeed,
      holdActive: holdActive ?? this.holdActive,
      speedRejections: speedRejections ?? this.speedRejections,
      fitMode: fitMode ?? this.fitMode,
      skipOpeningSeconds: skipOpeningSeconds ?? this.skipOpeningSeconds,
      autoNextSecondsLeft: autoNextSecondsLeft != null
          ? autoNextSecondsLeft()
          : this.autoNextSecondsLeft,
      nextEpisodeRequested: nextEpisodeRequested ?? this.nextEpisodeRequested,
      isPlaying: isPlaying ?? this.isPlaying,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        engine,
        engineGeneration,
        streamIndex,
        subtitleIndex,
        subtitleLoading,
        subtitleFailed,
        playbackSpeed,
        holdSpeed,
        holdActive,
        speedRejections,
        fitMode,
        skipOpeningSeconds,
        autoNextSecondsLeft,
        nextEpisodeRequested,
        isPlaying,
        errorMessage,
      ];
}
