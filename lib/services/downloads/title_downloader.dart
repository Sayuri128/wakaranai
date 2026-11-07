import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
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

abstract class TitleDownloadContent {
  List<ElementsGroupOfConcrete<ElementOfElementsGroupOfConcrete>> get groups;
}

const Set<DownloadStatus> _keptDownloadStatuses = <DownloadStatus>{
  DownloadStatus.queued,
  DownloadStatus.downloading,
  DownloadStatus.done,
};

Future<Set<String>> keptDownloadUidsOf(
  DownloadRepository downloadRepository,
  String concreteUid,
) async {
  final List<DownloadDomain> downloads = await downloadRepository
      .getByConcreteUid(concreteUid);
  return <String>{
    for (final DownloadDomain download in downloads)
      if (_keptDownloadStatuses.contains(download.status)) download.uid,
  };
}

class DownloadableTitle implements TitleDownloadContent {
  const DownloadableTitle({
    required this.client,
    required this.extensionUid,
    required this.concrete,
    required this.concreteId,
    required this.readUids,
    required this.downloadedUids,
  });

  final MangaApiClient client;
  final String extensionUid;
  final MangaConcreteView concrete;
  final int concreteId;
  final Set<String> readUids;
  final Set<String> downloadedUids;

  @override
  List<ChaptersGroup> get groups => concrete.groups;

  List<Chapter> select(Set<int> groupIndexes, ChapterDownloadAmount amount) {
    final List<Chapter> selected = <Chapter>[];
    final Set<String> seen = <String>{};
    for (int index = 0; index < groups.length; index++) {
      if (!groupIndexes.contains(index)) {
        continue;
      }
      final List<Chapter> picked = chaptersToDownload<Chapter>(
        groups[index].elements,
        readUids: readUids,
        downloadedUids: downloadedUids,
        amount: amount,
      );
      for (final Chapter chapter in picked) {
        if (seen.add(chapter.uid)) {
          selected.add(chapter);
        }
      }
    }
    return selected;
  }
}

class TitleDownloader {
  TitleDownloader({
    required this.downloadManager,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
    required this.downloadRepository,
  });

  final DownloadManagerCubit downloadManager;
  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final DownloadRepository downloadRepository;

  Future<DownloadableTitle> load({
    required MangaApiClient client,
    required String extensionUid,
    required String uid,
    required Map<String, dynamic> galleryData,
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
    if (saved == null) {
      throw StateError('Could not save details for $uid');
    }
    return DownloadableTitle(
      client: client,
      extensionUid: extensionUid,
      concrete: concrete,
      concreteId: saved.id,
      readUids: await _readChapterUids(concrete.uid),
      downloadedUids: await keptDownloadUidsOf(
        downloadRepository,
        concrete.uid,
      ),
    );
  }

  Future<int> queue(
    DownloadableTitle title, {
    required Set<int> groupIndexes,
    required ChapterDownloadAmount amount,
  }) async {
    final List<Chapter> selected = title.select(groupIndexes, amount);
    for (final Chapter chapter in selected) {
      await downloadManager.enqueueChapter(
        client: title.client,
        extensionUid: title.extensionUid,
        concreteUid: title.concrete.uid,
        concreteId: title.concreteId,
        concreteTitle: title.concrete.title,
        concreteCover: title.concrete.cover,
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
}
