import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';

enum LocalApiClientType { MANGA, ANIME }

int serializeLocalApiClientType(LocalApiClientType type) {
  switch (type) {
    case LocalApiClientType.MANGA:
      return 0;
    case LocalApiClientType.ANIME:
      return 1;
  }
}

LocalApiClientType deserializeLocalApiClientType(int type) {
  switch (type) {
    case 0:
      return LocalApiClientType.MANGA;
    case 1:
      return LocalApiClientType.ANIME;
  }
  throw Exception("Unknown LocalApiClientType $type");
}

class LocalApiClient {
  int? id;
  final String code;
  final LocalApiClientType type;
  final LocalConfigInfo localConfigInfo;

  LocalApiClient({
    this.id,
    required this.code,
    required this.type,
    required this.localConfigInfo,
  });

  T toApiClient<T extends ApiClient>() {
    switch (type) {
      case LocalApiClientType.MANGA:
        return MangaApiClient(code: code) as T;
      case LocalApiClientType.ANIME:
        return AnimeApiClient(code: code) as T;
    }
  }

  factory LocalApiClient.fromApiClient(
      ApiClient apiClient, ConfigInfo configInfo) {
    late LocalApiClientType type;

    if (apiClient is AnimeApiClient) {
      type = LocalApiClientType.ANIME;
    } else if (apiClient is MangaApiClient) {
      type = LocalApiClientType.MANGA;
    } else {
      throw Exception("Unknown api client");
    }

    return LocalApiClient(
        code: apiClient.parser.code,
        localConfigInfo: LocalConfigInfo.fromConfigInfo(configInfo),
        type: type);
  }

}
