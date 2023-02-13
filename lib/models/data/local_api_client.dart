import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';



class LocalApiClient {
  int? id;
  final String code;
  final ConfigInfoType type;
  final LocalConfigInfo localConfigInfo;

  LocalApiClient({
    this.id,
    required this.code,
    required this.type,
    required this.localConfigInfo,
  });

  T toApiClient<T extends ApiClient>() {
    switch (type) {
      case ConfigInfoType.MANGA:
        return MangaApiClient(code: code) as T;
      case ConfigInfoType.ANIME:
        return AnimeApiClient(code: code) as T;
    }
  }

  factory LocalApiClient.fromApiClient(
      ApiClient apiClient, ConfigInfo configInfo) {
    late ConfigInfoType type;

    if (apiClient is AnimeApiClient) {
      type = ConfigInfoType.ANIME;
    } else if (apiClient is MangaApiClient) {
      type = ConfigInfoType.MANGA;
    } else {
      throw Exception("Unknown api client");
    }

    return LocalApiClient(
        code: apiClient.parser.code,
        localConfigInfo: LocalConfigInfo.fromConfigInfo(configInfo),
        type: type);
  }

}
