import 'package:wakaranai/data/domain/app_version.dart';

class LatestReleaseData {
  final String url;
  final AppVersion latestVersion;
  final AppVersion currentVersion;

  bool get needsUpdate => latestVersion > currentVersion;

  const LatestReleaseData({
    required this.url,
    required this.latestVersion,
    required this.currentVersion,
  });
}
