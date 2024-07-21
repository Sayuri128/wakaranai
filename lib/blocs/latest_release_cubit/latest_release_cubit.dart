import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/latest_release_data.dart';
import 'package:wakaranai/services/releases_service/releases_service.dart';

part 'latest_release_state.dart';

class LatestReleaseCubit extends Cubit<LatestReleaseState> {
  LatestReleaseCubit() : super(LatestReleaseInitial());

  final ReleasesService _releasesService = ReleasesService();

  Future<void> init() async {
    final LatestReleaseData? latestReleaseData =
        await _releasesService.getLatestReleaseDownloadUrl();

    if (latestReleaseData == null) {
      emit(const LatestReleaseError(
          message: 'Failed to get latest release data'));
    } else {
      emit(LatestReleaseLoaded(
        releaseData: latestReleaseData,
      ));
    }
  }
}
