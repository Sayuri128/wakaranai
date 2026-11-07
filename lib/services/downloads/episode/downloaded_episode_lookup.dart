import 'dart:io';

import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';

typedef MediaFileExists = Future<bool> Function(String path);

abstract class DownloadedEpisodeLookup {
  Future<PlayableVideo?> playableFor(String episodeUid);

  Future<Set<String>> finishedEpisodeUidsOf(String concreteUid);
}

EpisodeDownloadManifest? finishedEpisodeManifestOf(DownloadDomain download) {
  if (!download.isEpisode || download.status != DownloadStatus.done) {
    return null;
  }
  return EpisodeDownloadManifest.decode(download.playback);
}

class RepositoryDownloadedEpisodeLookup implements DownloadedEpisodeLookup {
  RepositoryDownloadedEpisodeLookup(
    this.repository, {
    MediaFileExists? mediaFileExists,
  }) : _mediaFileExists = mediaFileExists ?? _fileExistsOnDisk;

  final DownloadRepository repository;
  final MediaFileExists _mediaFileExists;

  @override
  Future<PlayableVideo?> playableFor(String episodeUid) async {
    final DownloadDomain? download = await repository.getByUid(episodeUid);
    if (download == null) {
      return null;
    }
    return _playableOf(download);
  }

  @override
  Future<Set<String>> finishedEpisodeUidsOf(String concreteUid) async {
    final List<DownloadDomain> downloads =
        await repository.getByConcreteUid(concreteUid);
    final Set<String> finished = <String>{};
    for (final DownloadDomain download in downloads) {
      if (await _playableOf(download) != null) {
        finished.add(download.uid);
      }
    }
    return finished;
  }

  Future<PlayableVideo?> _playableOf(DownloadDomain download) async {
    final EpisodeDownloadManifest? manifest =
        finishedEpisodeManifestOf(download);
    if (manifest == null) {
      return null;
    }
    final bool present =
        await _mediaFileExists(manifest.mediaPathIn(download.dirPath));
    if (!present) {
      return null;
    }
    return manifest.toPlayableVideo(download.dirPath);
  }
}

Future<bool> _fileExistsOnDisk(String path) {
  return File(path).exists();
}
