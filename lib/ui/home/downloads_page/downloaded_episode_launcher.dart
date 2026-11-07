import 'dart:async';
import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/storage/local_playback_fallback.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/anime_episode_launcher.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

class OfflineEpisodePlayback {
  const OfflineEpisodePlayback({
    required this.anime,
    required this.groups,
    required this.groupIndex,
    required this.episode,
  });

  final AnimeConcreteView anime;
  final List<AnimeVideoGroup> groups;
  final int groupIndex;
  final AnimeVideo episode;
}

Future<void> playDownloadedEpisode(
  BuildContext context,
  DownloadDomain download,
) async {
  final DownloadedEpisodeLookup lookup =
      RepositoryDownloadedEpisodeLookup(context.read<DownloadRepository>());
  final ConcreteDataRepository concreteDataRepository =
      context.read<ConcreteDataRepository>();
  final AnimeEpisodeActivityRepository activityRepository =
      context.read<AnimeEpisodeActivityRepository>();
  final LibraryUpdatesCubit libraryUpdatesCubit =
      context.read<LibraryUpdatesCubit>();

  LocalPlaybackFailures.shared.forget(download.uid);
  final PlayableVideo? local = await lookup.playableFor(download.uid);
  if (!context.mounted) {
    return;
  }
  if (local == null) {
    logger.w('Downloaded files for episode ${download.uid} are missing');
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.of(context).downloads_episode_files_missing,
    );
    return;
  }

  final OfflineEpisodePlayback playback = buildOfflineEpisodePlayback(
    download: download,
    cachedAnime: await _cachedAnimeOf(concreteDataRepository, download),
    finishedEpisodeUids: await lookup.finishedEpisodeUidsOf(
      download.concreteUid,
    ),
  );
  final Set<String> watchedEpisodeUids =
      await _watchedEpisodeUidsOf(activityRepository, download.concreteUid);
  if (!context.mounted) {
    return;
  }

  final AnimeEpisodeLauncher launcher = AnimeEpisodeLauncher(
    client: null,
    anime: playback.anime,
    groups: playback.groups,
    groupIndex: playback.groupIndex,
    watchedEpisodeUids: watchedEpisodeUids,
    downloadedEpisodes: lookup,
    onEpisodeOpened: (AnimeVideo openedEpisode) {
      unawaited(libraryUpdatesCubit.markSeenIfNew(openedEpisode.uid));
    },
  );
  await launcher.play(context, playback.episode);
}

OfflineEpisodePlayback buildOfflineEpisodePlayback({
  required DownloadDomain download,
  required AnimeConcreteView? cachedAnime,
  required Set<String> finishedEpisodeUids,
}) {
  final AnimeConcreteView anime = cachedAnime ?? _stubAnimeOf(download);
  final OfflineEpisodePlayback? fromCache = _playbackFromCachedGroups(
    anime: anime,
    episodeUid: download.uid,
    playableUids: <String>{...finishedEpisodeUids, download.uid},
  );
  if (fromCache != null) {
    return fromCache;
  }
  final AnimeVideo episode =
      downloadedEpisodeOf(download) ?? _stubEpisodeOf(download);
  return OfflineEpisodePlayback(
    anime: anime,
    groups: <AnimeVideoGroup>[
      AnimeVideoGroup(title: '', elements: <AnimeVideo>[episode]),
    ],
    groupIndex: 0,
    episode: episode,
  );
}

OfflineEpisodePlayback? _playbackFromCachedGroups({
  required AnimeConcreteView anime,
  required String episodeUid,
  required Set<String> playableUids,
}) {
  final List<AnimeVideoGroup> playableGroups = <AnimeVideoGroup>[];
  int? groupIndex;
  AnimeVideo? episode;
  for (final AnimeVideoGroup group in anime.groups) {
    final List<AnimeVideo> playable = group.elements
        .where((AnimeVideo video) => playableUids.contains(video.uid))
        .toList(growable: false);
    if (playable.isEmpty) {
      continue;
    }
    final AnimeVideo? match = playable
        .firstWhereOrNull((AnimeVideo video) => video.uid == episodeUid);
    if (episode == null && match != null) {
      episode = match;
      groupIndex = playableGroups.length;
    }
    playableGroups.add(AnimeVideoGroup(title: group.title, elements: playable));
  }
  if (episode == null || groupIndex == null) {
    return null;
  }
  return OfflineEpisodePlayback(
    anime: anime,
    groups: playableGroups,
    groupIndex: groupIndex,
    episode: episode,
  );
}

Future<AnimeConcreteView?> _cachedAnimeOf(
  ConcreteDataRepository repository,
  DownloadDomain download,
) async {
  final ConcreteDataDomain? concrete =
      await repository.getByUid(download.concreteUid);
  final String? concreteJson = concrete?.concreteJson;
  if (concreteJson == null) {
    return null;
  }
  try {
    return AnimeConcreteView.fromJson(
      jsonDecode(concreteJson) as Map<String, dynamic>,
    );
  } catch (error, stackTrace) {
    logger.w('Failed to rebuild cached anime view: $error');
    logger.w(stackTrace);
    return null;
  }
}

Future<Set<String>> _watchedEpisodeUidsOf(
  AnimeEpisodeActivityRepository repository,
  String concreteUid,
) async {
  final List<AnimeEpisodeActivityDomain>? activities =
      await repository.getAllActivitiesByConcreteId(concreteUid);
  if (activities == null) {
    return <String>{};
  }
  return activities
      .map((AnimeEpisodeActivityDomain activity) => activity.uid)
      .toSet();
}

AnimeConcreteView _stubAnimeOf(DownloadDomain download) {
  return AnimeConcreteView(
    uid: download.concreteUid,
    cover: download.concreteCover ?? '',
    title: download.concreteTitle,
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    groups: const <AnimeVideoGroup>[],
    status: AnimeStatus.UNDEFINED,
  );
}

AnimeVideo _stubEpisodeOf(DownloadDomain download) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: download.uid,
    src: '',
    title: download.title,
    timestamp: null,
    data: const <String, dynamic>{},
  );
}
