import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';

class GalleryTitleDownloader {
  GalleryTitleDownloader({
    required this.downloadManager,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
    required this.downloadRepository,
  });

  final DownloadManagerCubit downloadManager;
  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final DownloadRepository downloadRepository;

  static const Set<DownloadStatus> _keptStatuses = <DownloadStatus>{
    DownloadStatus.queued,
    DownloadStatus.downloading,
    DownloadStatus.done,
  };

  Future<int> download({
    required MangaApiClient client,
    required String extensionUid,
    required String uid,
    required Map<String, dynamic> galleryData,
    required ChapterDownloadAmount amount,
  }) async {
    final MangaConcreteView concrete = await client.getConcrete(
      uid: uid,
      data: galleryData,
    );
    final ConcreteDataDomain? saved = await concreteDataRepository.saveConcrete(
      concrete,
      galleryData: galleryData,
      extensionUid: extensionUid,
    );
    if (saved == null || concrete.groups.isEmpty) {
      return 0;
    }

    final List<Chapter> chapters = concrete.groups.first.elements;
    final List<Chapter> selected = chaptersToDownload<Chapter>(
      chapters,
      readUids: await _readChapterUids(concrete.uid),
      downloadedUids: await _keptDownloadUids(concrete.uid),
      amount: amount,
    );

    for (final Chapter chapter in selected) {
      await downloadManager.enqueueChapter(
        client: client,
        extensionUid: extensionUid,
        concreteUid: concrete.uid,
        concreteId: saved.id,
        concreteTitle: concrete.title,
        concreteCover: concrete.cover,
        chapterUid: chapter.uid,
        title: chapter.title,
        data: chapter.data,
        autoStart: false,
      );
    }
    if (selected.isNotEmpty) {
      downloadManager.startQueue();
    }
    return selected.length;
  }

  Future<Set<String>> _readChapterUids(String concreteUid) async {
    final List<ChapterActivityDomain> activities =
        await chapterActivityRepository.getAllActivitiesByConcreteId(
          concreteUid,
        ) ??
        <ChapterActivityDomain>[];
    return <String>{
      for (final ChapterActivityDomain activity in activities)
        if (activity.isCompleted) activity.uid,
    };
  }

  Future<Set<String>> _keptDownloadUids(String concreteUid) async {
    final List<DownloadDomain> downloads = await downloadRepository
        .getByConcreteUid(concreteUid);
    return <String>{
      for (final DownloadDomain download in downloads)
        if (_keptStatuses.contains(download.status)) download.uid,
    };
  }
}
