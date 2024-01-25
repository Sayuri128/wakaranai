part of 'latest_release_cubit.dart';

@immutable
abstract class LatestReleaseState {
  const LatestReleaseState();
}

class LatestReleaseInitial extends LatestReleaseState {}

class LatestReleaseLoading extends LatestReleaseState {}

class LatestReleaseLoaded extends LatestReleaseState {
  final LatestReleaseData releaseData;

  const LatestReleaseLoaded({
    required this.releaseData,
  });

  LatestReleaseLoaded copyWith({
    LatestReleaseData? releaseData,
  }) {
    return LatestReleaseLoaded(
      releaseData: releaseData ?? this.releaseData,
    );
  }
}

class LatestReleaseError extends LatestReleaseState {
  final String message;

  const LatestReleaseError({
    required this.message,
  });
}
