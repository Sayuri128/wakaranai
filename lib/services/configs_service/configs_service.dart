import 'package:wakascript/api_controller.dart';

abstract class ConfigsService {
  Future<List<ApiClient>> getMangaConfigs();
}