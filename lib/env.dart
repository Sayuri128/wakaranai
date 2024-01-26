import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String localRepoUrl = dotenv.env['LOCAL_REPOSITORY_URL']!;
  static final String configsSourceOrg =
      dotenv.env['OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG']!;

  static final String configsSourceRepo =
      dotenv.env['OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY']!;

  static final String sqfliteDmBName = dotenv.env['SQFLITE_DB_NAME']!;

  static final String appRepoOrg = dotenv.env['OFFICIAL_GITHUB_REPO_ORG']!;
  static final String appRepoName = dotenv.env['OFFICIAL_GITHUB_REPO_NAME']!;

  static final String currentAppVersion = dotenv.env['CURRENT_APP_VERSION']!;
}
