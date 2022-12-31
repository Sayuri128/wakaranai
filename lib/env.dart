import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String LOCAL_REPOSITORY_URL =
      dotenv.env['LOCAL_REPOSITORY_URL']!;
  static final String OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG =
      dotenv.env['OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG']!;

  static final String OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY =
      dotenv.env['OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY']!;

  static final String SQFLITE_DB_NAME = dotenv.env['SQFLITE_DB_NAME']!;
}
