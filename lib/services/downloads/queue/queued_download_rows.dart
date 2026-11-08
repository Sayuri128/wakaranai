import 'dart:convert';
import 'dart:io';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';

typedef DownloadDirResolver = Future<Directory> Function(
  String extensionUid,
  String concreteUid,
  String itemUid,
);

class QueuedTitle {
  const QueuedTitle({
    required this.extensionUid,
    required this.concreteUid,
    required this.concreteId,
    required this.concreteTitle,
    required this.concreteCover,
  });

  final String extensionUid;
  final String concreteUid;
  final int concreteId;
  final String concreteTitle;
  final String? concreteCover;
}

class QueuedDownloadRows {
  QueuedDownloadRows({
    required DownloadRepository downloadRepository,
    DownloadDirResolver? resolveDir,
  })  : _downloads = downloadRepository,
        _resolveDir = resolveDir ?? DownloadFiles.chapterDir;

  final DownloadRepository _downloads;
  final DownloadDirResolver _resolveDir;

  static bool isPendingOrDone(DownloadDomain? existing) {
    if (existing == null) {
      return false;
    }
    return existing.status == DownloadStatus.done || existing.isPending;
  }

  Future<DownloadDomain?> existing(String uid) => _downloads.getByUid(uid);

  Future<DownloadDomain> chapterRow({
    required QueuedTitle title,
    required String chapterUid,
    required String chapterTitle,
    required Map<String, dynamic>? data,
    required DownloadKind kind,
  }) async {
    final Directory dir =
        await _resolveDir(title.extensionUid, title.concreteUid, chapterUid);
    return DownloadDomain(
      id: 0,
      uid: chapterUid,
      extensionUid: title.extensionUid,
      concreteUid: title.concreteUid,
      concreteId: title.concreteId,
      concreteTitle: title.concreteTitle,
      concreteCover: title.concreteCover,
      title: chapterTitle,
      status: DownloadStatus.queued,
      downloadedPages: 0,
      totalPages: 0,
      dirPath: dir.path,
      data: data != null ? jsonEncode(data) : null,
      kind: kind,
      createdAt: DateTime.now(),
    );
  }

  Future<DownloadDomain> episodeRow({
    required QueuedTitle title,
    required AnimeVideo episode,
    required DownloadDomain? existing,
  }) async {
    return DownloadDomain(
      id: 0,
      uid: episode.uid,
      extensionUid: title.extensionUid,
      concreteUid: title.concreteUid,
      concreteId: title.concreteId,
      concreteTitle: title.concreteTitle,
      concreteCover: title.concreteCover,
      title: episode.title,
      status: DownloadStatus.queued,
      downloadedPages: existing?.downloadedPages ?? 0,
      totalPages: existing?.totalPages ?? 0,
      downloadedBytes: existing?.downloadedBytes ?? 0,
      totalBytes: existing?.totalBytes ?? 0,
      dirPath: await _episodeDirPath(existing, title, episode),
      data: encodeDownloadedEpisode(episode),
      kind: DownloadKind.episode,
      createdAt: DateTime.now(),
    );
  }

  Future<void> save(DownloadDomain row) async {
    await _downloads.createUpdateBy<$DownloadTableTable, String>(
      row,
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );
    await _downloads.moveToQueueEnd(row.uid);
  }

  Future<String> _episodeDirPath(
    DownloadDomain? existing,
    QueuedTitle title,
    AnimeVideo episode,
  ) async {
    final String? previousDir = existing?.dirPath;
    if (previousDir != null && previousDir.isNotEmpty) {
      return previousDir;
    }
    final Directory dir =
        await _resolveDir(title.extensionUid, title.concreteUid, episode.uid);
    return dir.path;
  }
}
