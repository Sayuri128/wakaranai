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
  final bool isPlaying;
  final String? errorMessage;

  NativePlayerState copyWith({
    NativePlayerStatus? status,
    ValueGetter<NativePlayerEngine?>? engine,
    int? engineGeneration,
    int? streamIndex,
    ValueGetter<int?>? subtitleIndex,
    bool? subtitleLoading,
    bool? subtitleFailed,
    double? playbackSpeed,
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
        isPlaying,
        errorMessage,
      ];
}
