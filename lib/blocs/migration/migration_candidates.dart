import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_title_match.dart';

typedef RankedMigrationCandidate = MigrationCandidateScore<MigrationCandidate>;

String migrationCandidateTitleOf(GalleryView item) {
  if (item is MangaGalleryView) {
    return item.title;
  }
  if (item is AnimeGalleryView) {
    return item.title;
  }
  return '';
}

String migrationCandidateCoverOf(GalleryView item) {
  if (item is MangaGalleryView) {
    return item.cover;
  }
  if (item is AnimeGalleryView) {
    return item.cover;
  }
  return '';
}

bool _isSubject(
  MigrationSubject subject,
  GlobalSearchRail rail,
  GalleryView item,
) {
  return rail.source.uid == subject.extensionUid && item.uid == subject.uid;
}

List<MigrationCandidate> migrationCandidatesOf(
  MigrationSubject subject,
  GlobalSearchState state,
) {
  final List<MigrationCandidate> candidates = <MigrationCandidate>[];
  for (final GlobalSearchSource source in state.scope) {
    final GlobalSearchRail? rail = state.rails[source.uid];
    final ApiClient? client = rail?.client;
    final ConfigInfo? config = rail?.config;
    if (rail == null || !rail.hasResults || client == null || config == null) {
      continue;
    }
    final ConfigInfoType? type = subject.type;
    if (type != null && config.type != type) {
      continue;
    }
    for (final GalleryView item in rail.items) {
      if (_isSubject(subject, rail, item)) {
        continue;
      }
      candidates.add(MigrationCandidate(
        client: client,
        config: config,
        item: item,
        coverHeaders: rail.coverHeaders[item.uid] ?? const <String, String>{},
      ));
    }
  }
  return candidates;
}

List<RankedMigrationCandidate> rankMigrationSearch(
  MigrationSubject subject,
  GlobalSearchState state,
) {
  return rankMigrationCandidates<MigrationCandidate>(
    subjectTitles: subject.searchTitles,
    candidates: migrationCandidatesOf(subject, state),
    titleOf: (MigrationCandidate candidate) =>
        migrationCandidateTitleOf(candidate.item),
    groupKeyOf: (MigrationCandidate candidate) => candidate.config.uid,
  );
}

List<String> migrationSourceOrder(GlobalSearchState state) {
  return state.scope
      .map((GlobalSearchSource source) => source.uid)
      .toList(growable: false);
}
