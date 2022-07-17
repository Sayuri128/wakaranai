import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String LOCAL_REPOSITORY_URL = dotenv.env['LOCAL_REPOSITORY_URL']!;
}
