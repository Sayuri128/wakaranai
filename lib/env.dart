import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const List<String> _requiredKeys = <String>[
    'OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG',
    'OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY',
    'OFFICIAL_GITHUB_REPO_ORG',
    'OFFICIAL_GITHUB_REPO_NAME',
    'CURRENT_APP_VERSION',
  ];

  static void validate() {
    final List<String> missing = _requiredKeys
        .where((String key) => (dotenv.env[key] ?? '').trim().isEmpty)
        .toList();

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required .env keys: ${missing.join(', ')}. '
        'Copy example.env to .env and fill them in.',
      );
    }
  }

  static String _read(String key) => dotenv.env[key] ?? '';

  static String get localRepoUrl => _read('LOCAL_REPOSITORY_URL');

  static String get configsSourceOrg =>
      _read('OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG');

  static String get configsSourceRepo =>
      _read('OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY');

  static String get appRepoOrg => _read('OFFICIAL_GITHUB_REPO_ORG');

  static String get appRepoName => _read('OFFICIAL_GITHUB_REPO_NAME');

  static String get currentAppVersion => _read('CURRENT_APP_VERSION');
}
