import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:dio/dio.dart';
import 'package:wakaranai/data/entities/download_table.dart';

sealed class DownloadJob {
  final String extensionUid;
  final String concreteTitle;
  final CancelToken cancelToken = CancelToken();
  final Completer<void> _unwound = Completer<void>();

  DownloadJob({
    required this.extensionUid,
    required this.concreteTitle,
  });

  String get uid;

  String get title;

  Future<void> get unwound => _unwound.future;

  bool get isCancelled => cancelToken.isCancelled;

  void markUnwound() {
    if (!_unwound.isCompleted) {
      _unwound.complete();
    }
  }

  void cancel([String reason = 'deleted']) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel(reason);
    }
  }

  DownloadJob restarted();
}

class ChapterDownloadJob extends DownloadJob {
  final MangaApiClient client;
  final String chapterUid;
  final String chapterTitle;
  final Map<String, dynamic>? data;

  ChapterDownloadJob({
    required this.client,
    required super.extensionUid,
    required super.concreteTitle,
    required this.chapterUid,
    required this.chapterTitle,
    required this.data,
  });

  @override
  String get uid => chapterUid;

  @override
  String get title => chapterTitle;

  @override
  ChapterDownloadJob restarted() => ChapterDownloadJob(
        client: client,
        extensionUid: extensionUid,
        concreteTitle: concreteTitle,
        chapterUid: chapterUid,
        chapterTitle: chapterTitle,
        data: data,
      );
}

class NovelChapterDownloadJob extends DownloadJob {
  final NovelApiClient client;
  final String chapterUid;
  final String chapterTitle;
  final Map<String, dynamic>? data;

  NovelChapterDownloadJob({
    required this.client,
    required super.extensionUid,
    required super.concreteTitle,
    required this.chapterUid,
    required this.chapterTitle,
    required this.data,
  });

  @override
  String get uid => chapterUid;

  @override
  String get title => chapterTitle;

  @override
  NovelChapterDownloadJob restarted() => NovelChapterDownloadJob(
        client: client,
        extensionUid: extensionUid,
        concreteTitle: concreteTitle,
        chapterUid: chapterUid,
        chapterTitle: chapterTitle,
        data: data,
      );
}

class EpisodeDownloadJob extends DownloadJob {
  final AnimeVideo episode;

  EpisodeDownloadJob({
    required super.extensionUid,
    required super.concreteTitle,
    required this.episode,
  });

  @override
  String get uid => episode.uid;

  @override
  String get title => episode.title;

  @override
  EpisodeDownloadJob restarted() => EpisodeDownloadJob(
        extensionUid: extensionUid,
        concreteTitle: concreteTitle,
        episode: episode,
      );
}

DownloadJob chapterDownloadJobFor({
  required ApiClient client,
  required String extensionUid,
  required String concreteTitle,
  required String chapterUid,
  required String title,
  required Map<String, dynamic>? data,
}) {
  if (client is NovelApiClient) {
    return NovelChapterDownloadJob(
      client: client,
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      chapterUid: chapterUid,
      chapterTitle: title,
      data: data,
    );
  }
  if (client is MangaApiClient) {
    return ChapterDownloadJob(
      client: client,
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      chapterUid: chapterUid,
      chapterTitle: title,
      data: data,
    );
  }
  throw StateError('${client.runtimeType} has no chapters to download');
}

DownloadKind chapterDownloadKindFor(ApiClient client) {
  if (client is NovelApiClient) {
    return DownloadKind.novelChapter;
  }
  return DownloadKind.chapter;
}
