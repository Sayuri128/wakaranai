import 'package:dio/dio.dart';
import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/data/domain/latest_release_data.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/releases_repository/github/github_releases_repository.dart';

class ReleasesService {
  final GithubReleasesRepository _githubReleasesRepository =
      GithubReleasesRepository(Dio());

  Future<LatestReleaseData?> getLatestReleaseDownloadUrl() async {
    try {
      final GithubReleaseResponseModel response =
          await _githubReleasesRepository.getLatestRelease(
        org: Env.appRepoOrg,
        repo: Env.appRepoName,
      );

      final AppVersion latestReleaseVersion =
          AppVersion.fromString(response.tagName);
      final AppVersion currentVersion =
          AppVersion.fromString(Env.currentAppVersion);

      return LatestReleaseData(
        url: response.htmlUrl,
        latestVersion: latestReleaseVersion,
        currentVersion: currentVersion,
      );
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      return null;
    }
  }
}
