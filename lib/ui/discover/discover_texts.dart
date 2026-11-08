import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/discover/discover_models.dart';

String discoverCategoryLabel(DiscoverCategory category) {
  switch (category) {
    case DiscoverCategory.seasonAnime:
      return S.current.discover_tab_season;
    case DiscoverCategory.trendingAnime:
      return S.current.discover_tab_trending_anime;
    case DiscoverCategory.trendingManga:
      return S.current.discover_tab_trending_manga;
    case DiscoverCategory.popularNovels:
      return S.current.discover_tab_novels;
  }
}

String discoverSeasonLabel(DiscoverSeason season) {
  switch (season.name) {
    case DiscoverSeasonName.winter:
      return S.current.discover_season_winter(season.year);
    case DiscoverSeasonName.spring:
      return S.current.discover_season_spring(season.year);
    case DiscoverSeasonName.summer:
      return S.current.discover_season_summer(season.year);
    case DiscoverSeasonName.fall:
      return S.current.discover_season_fall(season.year);
  }
}

String? discoverFormatLabel(String? format) {
  switch (format) {
    case 'TV':
      return S.current.discover_format_tv;
    case 'TV_SHORT':
      return S.current.discover_format_tv_short;
    case 'MOVIE':
      return S.current.discover_format_movie;
    case 'SPECIAL':
      return S.current.discover_format_special;
    case 'OVA':
      return S.current.discover_format_ova;
    case 'ONA':
      return S.current.discover_format_ona;
    case 'MUSIC':
      return S.current.discover_format_music;
    case 'MANGA':
      return S.current.discover_format_manga;
    case 'NOVEL':
      return S.current.discover_format_novel;
    case 'ONE_SHOT':
      return S.current.discover_format_one_shot;
  }
  return null;
}

List<String> discoverMetaParts(DiscoverMedia media) {
  final List<String> parts = <String>[];
  final String? format = discoverFormatLabel(media.format);
  if (format != null) {
    parts.add(format);
  }
  final int? year = media.year;
  if (year != null) {
    parts.add('$year');
  }
  final int? episodes = media.episodes;
  final int? chapters = media.chapters;
  if (media.isAnime && episodes != null) {
    parts.add(S.current.discover_episodes(episodes));
  }
  if (!media.isAnime && chapters != null) {
    parts.add(S.current.discover_chapters(chapters));
  }
  final int? score = media.averageScore;
  if (score != null) {
    parts.add(S.current.discover_score(score));
  }
  return parts;
}
