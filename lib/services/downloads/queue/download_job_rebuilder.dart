import 'dart:convert';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/download_client_pool.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';

class DownloadJobRebuilder {
  DownloadJobRebuilder({required DownloadClientPool clients})
      : _clients = clients;

  final DownloadClientPool _clients;

  Future<DownloadJob?> rebuild(DownloadDomain row) async {
    if (row.isEpisode) {
      final AnimeVideo? episode = downloadedEpisodeOf(row);
      if (episode == null) {
        return null;
      }
      return EpisodeDownloadJob(
        extensionUid: row.extensionUid,
        concreteTitle: row.concreteTitle,
        episode: episode,
      );
    }
    return _rebuildChapterJob(row);
  }

  Future<DownloadJob?> _rebuildChapterJob(DownloadDomain row) async {
    try {
      final ExtensionDomain? extension =
          await _clients.installedExtension(row.extensionUid);
      if (extension == null) {
        return null;
      }
      final ApiClient client = await _clients.chapterClientFor(extension);
      final String? rawData = row.data;
      return chapterDownloadJobFor(
        client: client,
        extensionUid: row.extensionUid,
        concreteTitle: row.concreteTitle,
        chapterUid: row.uid,
        title: row.title,
        data: rawData == null
            ? null
            : jsonDecode(rawData) as Map<String, dynamic>?,
      );
    } catch (e) {
      logger.w('Cannot rebuild the download of ${row.uid}: $e');
      return null;
    }
  }
}
