import 'package:dio/dio.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/configs_repository/local/local_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakascript/api_controller.dart';

class RepoConfigsService implements ConfigsService {
  final LocalConfigsRepository _localRepository =
      LocalConfigsRepository(Dio(), baseUrl: Env.LOCAL_REPOSITORY_URL);

  @override
  Future<List<ApiClient>> getMangaConfigs() async {
    return await Future.wait((await _localRepository.getConfigs())
        .scripts
        .where((e) => e.category == 'manga')
        .first
        .scripts
        .map((e) async => ApiClient(code: e)));
  }
}
