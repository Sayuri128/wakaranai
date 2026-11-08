import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/configs_repo/configs_response/repo_configs_response.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/services/configs_service/remote_config_parser.dart';

class LocalConfigsRepository {
  LocalConfigsRepository(this._dio, {this.baseUrl = ''});

  final Dio _dio;
  final String baseUrl;

  Future<RepoConfigsResponse> getConfigs(String category) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '$baseUrl/configs',
      queryParameters: <String, dynamic>{'category': category},
      options: Options(responseType: ResponseType.json),
    );
    final Map<String, dynamic> json = response.data!;
    final dynamic entries = json['configs'];
    return RepoConfigsResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      availableCategories: (json['availableCategories'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          <String>[],
      configs: entries is List
          ? const RemoteConfigParser().parseAll(entries)
          : <RemoteConfig>[],
    );
  }

  Future<RemoteScript> getScript(String path) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '$baseUrl/script',
      queryParameters: <String, dynamic>{'path': path},
      options: Options(responseType: ResponseType.json),
    );
    return RemoteScript.fromJson(response.data!);
  }
}
