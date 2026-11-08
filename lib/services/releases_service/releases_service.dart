import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/data/domain/latest_release_data.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/releases_repository/github/github_releases_repository.dart';
import 'package:wakaranai/utils/http_client.dart';
import 'package:wakaranai/utils/installed_app_version.dart';

class ReleasesService {
  ReleasesService({
    GithubReleasesRepository? repository,
    String? Function()? currentVersion,
    String? org,
    String? repo,
  })  : _repository = repository ?? GithubReleasesRepository(createDio()),
        _currentVersion = currentVersion ?? _installedVersion,
        _org = org,
        _repo = repo;

  final GithubReleasesRepository _repository;
  final String? Function() _currentVersion;
  final String? _org;
  final String? _repo;

  static String? _installedVersion() => InstalledAppVersion.current;

  Future<LatestReleaseData?> fetchLatestRelease() async {
    final String org = _org ?? Env.appRepoOrg;
    final String repo = _repo ?? Env.appRepoName;
    try {
      final GithubReleaseResponseModel response =
          await _repository.getLatestRelease(org: org, repo: repo);
      return _toReleaseData(response, org, repo);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to check for a new app release',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  LatestReleaseData? _toReleaseData(
    GithubReleaseResponseModel response,
    String org,
    String repo,
  ) {
    final AppVersion? latestVersion = AppVersion.tryParse(response.tagName);
    if (latestVersion == null) {
      logger.w('Latest release tag is not a version: ${response.tagName}');
      return null;
    }
    final AppVersion? currentVersion = AppVersion.tryParse(_currentVersion());
    if (currentVersion == null) {
      logger.w('The installed app version is unknown');
      return null;
    }
    return LatestReleaseData(
      url: _releaseUrl(response, org, repo),
      latestVersion: latestVersion,
      currentVersion: currentVersion,
    );
  }

  String _releaseUrl(
    GithubReleaseResponseModel response,
    String org,
    String repo,
  ) {
    final String? htmlUrl = response.htmlUrl;
    if (htmlUrl != null && htmlUrl.trim().isNotEmpty) {
      return htmlUrl;
    }
    return 'https://github.com/$org/$repo/releases/latest';
  }
}
