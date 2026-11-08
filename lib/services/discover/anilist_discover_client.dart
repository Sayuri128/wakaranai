import 'package:dio/dio.dart';
import 'package:wakaranai/services/discover/discover_models.dart';
import 'package:wakaranai/utils/http_client.dart';

abstract class DiscoverClient {
  Future<DiscoverMediaPage> fetch(
    DiscoverCategory category, {
    required int page,
    bool includeAdult = false,
  });
}

class AniListDiscoverClient implements DiscoverClient {
  AniListDiscoverClient({Dio? dio, DateTime Function()? clock})
      : _dio = dio ?? createDio(acceptAllStatuses: true),
        _clock = clock ?? DateTime.now;

  static const String endpoint = 'https://graphql.anilist.co';
  static const int perPage = 30;

  static const String query = r'query ($page: Int, $perPage: Int, '
      r'$type: MediaType, $sort: [MediaSort], $season: MediaSeason, '
      r'$seasonYear: Int, $format: MediaFormat, $formatNot: MediaFormat, '
      r'$isAdult: Boolean) { Page(page: $page, perPage: $perPage) { '
      'pageInfo { currentPage hasNextPage } '
      r'media(type: $type, sort: $sort, season: $season, '
      r'seasonYear: $seasonYear, format: $format, format_not: $formatNot, '
      r'isAdult: $isAdult) { '
      'id type format status title { romaji english native } synonyms '
      'coverImage { large extraLarge color } description(asHtml: false) '
      'genres averageScore episodes chapters seasonYear startDate { year } '
      '} } }';

  final Dio _dio;
  final DateTime Function() _clock;

  static Map<String, Object?> variables(
    DiscoverCategory category, {
    required int page,
    required DateTime now,
    bool includeAdult = false,
  }) {
    final Map<String, Object?> variables = <String, Object?>{
      'page': page,
      'perPage': perPage,
    };
    if (!includeAdult) {
      variables['isAdult'] = false;
    }
    switch (category) {
      case DiscoverCategory.seasonAnime:
        final DiscoverSeason season = DiscoverSeason.of(now);
        variables['type'] = 'ANIME';
        variables['season'] = season.apiName;
        variables['seasonYear'] = season.year;
        variables['sort'] = <String>['POPULARITY_DESC'];
      case DiscoverCategory.trendingAnime:
        variables['type'] = 'ANIME';
        variables['sort'] = <String>['TRENDING_DESC', 'POPULARITY_DESC'];
      case DiscoverCategory.trendingManga:
        variables['type'] = 'MANGA';
        variables['formatNot'] = 'NOVEL';
        variables['sort'] = <String>['TRENDING_DESC', 'POPULARITY_DESC'];
      case DiscoverCategory.popularNovels:
        variables['type'] = 'MANGA';
        variables['format'] = 'NOVEL';
        variables['sort'] = <String>['POPULARITY_DESC'];
    }
    return variables;
  }

  @override
  Future<DiscoverMediaPage> fetch(
    DiscoverCategory category, {
    required int page,
    bool includeAdult = false,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      endpoint,
      data: <String, Object?>{
        'query': query,
        'variables': variables(
          category,
          page: page,
          now: _clock(),
          includeAdult: includeAdult,
        ),
      },
      options: Options(
        headers: <String, String>{'Accept': 'application/json'},
      ),
    );
    final int status = response.statusCode ?? 0;
    if (status == 429) {
      throw const DiscoverException('AniList rate limit reached');
    }
    if (status >= 400 && response.data is! Map) {
      throw DiscoverException('AniList answered $status');
    }
    return DiscoverMediaPage.fromResponse(response.data, page: page);
  }
}
