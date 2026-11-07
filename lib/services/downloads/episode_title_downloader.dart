import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

List<AnimeVideo> selectedEpisodesInWatchOrder(
  List<AnimeVideo> groupEpisodes,
  Iterable<String> selectedUids,
) {
  final Set<String> selected = selectedUids.toSet();
  return EpisodeGroupOrder(groupEpisodes)
      .ascending
      .where((AnimeVideo episode) => selected.contains(episode.uid))
      .toList();
}

class DownloadableAnimeTitle implements TitleDownloadContent {
  const DownloadableAnimeTitle({
    required this.extensionUid,
    required this.concrete,
    required this.concreteId,
    required this.watchedUids,
    required this.downloadedUids,
  });

  final String extensionUid;
  final AnimeConcreteView concrete;
  final int concreteId;
  final Set<String> watchedUids;
  final Set<String> downloadedUids;

  @override
  List<AnimeVideoGroup> get groups => concrete.groups;

  List<AnimeVideo> select(Set<int> groupIndexes, ChapterDownloadAmount amount) {
    final List<AnimeVideo> selected = <AnimeVideo>[];
    final Set<String> seen = <String>{};
    for (int index = 0; index < groups.length; index++) {
      if (!groupIndexes.contains(index)) {
        continue;
      }
      final List<AnimeVideo> picked = chaptersToDownload<AnimeVideo>(
        EpisodeGroupOrder(groups[index].elements).ascending,
        readUids: watchedUids,
        downloadedUids: downloadedUids,
        amount: amount,
      );
      for (final AnimeVideo episode in picked) {
        if (seen.add(episode.uid)) {
          selected.add(episode);
        }
      }
    }
    return selected;
  }
}

class EpisodeTitleDownloader {
  EpisodeTitleDownloader({
    required this.downloadManager,
    required this.concreteDataRepository,
    required this.episodeActivityRepository,
    required this.downloadRepository,
  });

  final DownloadManagerCubit downloadManager;
  final ConcreteDataRepository concreteDataRepository;
  final AnimeEpisodeActivityRepository episodeActivityRepository;
  final DownloadRepository downloadRepository;

  Future<DownloadableAnimeTitle> load({
    required AnimeApiClient client,
    required String extensionUid,
    required String uid,
    required Map<String, dynamic> galleryData,
  }) async {
    final AnimeConcreteView concrete = await runSerializedOn(
      client,
      () => client.getConcrete(uid: uid, data: galleryData),
    );
    final ConcreteDataDomain? saved = await concreteDataRepository.saveConcrete(
      concrete,
      galleryData: galleryData,
      extensionUid: extensionUid,
    );
    if (saved == null) {
      throw StateError('Could not save details for $uid');
    }
    return DownloadableAnimeTitle(
      extensionUid: extensionUid,
      concrete: concrete,
      concreteId: saved.id,
      watchedUids: await _watchedEpisodeUids(concrete.uid),
      downloadedUids: await keptDownloadUidsOf(
        downloadRepository,
        concrete.uid,
      ),
    );
  }

  Future<int> queue(
    DownloadableAnimeTitle title, {
    required Set<int> groupIndexes,
    required ChapterDownloadAmount amount,
  }) async {
    final List<AnimeVideo> selected = title.select(groupIndexes, amount);
    for (final AnimeVideo episode in selected) {
      await downloadManager.enqueueEpisode(
        extensionUid: title.extensionUid,
        concreteUid: title.concrete.uid,
        concreteId: title.concreteId,
        concreteTitle: title.concrete.title,
        concreteCover: title.concrete.cover,
        episode: episode,
        autoStart: false,
      );
    }
    if (selected.isNotEmpty) {
      downloadManager.startQueue();
    }
    return selected.length;
  }

  Future<Set<String>> _watchedEpisodeUids(String concreteUid) async {
    final List<AnimeEpisodeActivityDomain> activities =
        await episodeActivityRepository.getAllActivitiesByConcreteId(
          concreteUid,
        ) ??
        <AnimeEpisodeActivityDomain>[];
    return <String>{
      for (final AnimeEpisodeActivityDomain activity in activities)
        activity.uid,
    };
  }
}
