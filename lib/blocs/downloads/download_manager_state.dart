part of 'download_manager_cubit.dart';

class DownloadManagerState {
  final List<DownloadDomain> downloads;

  const DownloadManagerState({this.downloads = const <DownloadDomain>[]});

  DownloadDomain? forChapter(String chapterUid) =>
      downloads.firstWhereOrNull((DownloadDomain d) => d.uid == chapterUid);

  List<DownloadDomain> get active => downloads
      .where((DownloadDomain d) =>
          d.status == DownloadStatus.queued ||
          d.status == DownloadStatus.downloading)
      .toList();

  DownloadManagerState copyWith({List<DownloadDomain>? downloads}) =>
      DownloadManagerState(downloads: downloads ?? this.downloads);
}
