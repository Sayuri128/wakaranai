import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakaranai/models/serializable_object.dart';
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

class LocalApiClient extends SqSerializableObject {
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

  ApiClient toApiClient() {
    switch (type) {
      case LocalApiClientType.MANGA:
        return MangaApiClient(code: code);
      case LocalApiClientType.ANIME:
        return AnimeApiClient(code: code);
    }
  }

  @override
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'code': code,
      'type': serializeLocalApiClientType(type),
      if (lazy)
        'localConfigInfoId': localConfigInfo.getId()
      else
        'localConfigInfo': localConfigInfo.toMap(lazy: lazy)
    };
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

  factory LocalApiClient.fromMap(Map<String, dynamic> map) {
    return LocalApiClient(
      id: map['id'] as int,
      code: map['code'] as String,
      type: deserializeLocalApiClientType(map['type']),
      localConfigInfo: LocalConfigInfo.fromMap(map['localConfigInfo']),
    );
  }

  @override
  int? getId() {
    return id;
  }
}
