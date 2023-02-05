import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';

abstract class ConfigsService {
  Future<List<MangaApiClient>> getMangaConfigs();
  Future<List<AnimeApiClient>> getAnimeConfigs();
}