part of 'download_manager_cubit.dart';

enum DownloadQueueHold { none, waitingForWifi }

enum DownloadRuntimeStatus { inactive, active, startNotAllowed, timedOut }

class DownloadManagerState {
  final List<DownloadDomain> downloads;
  final DownloadQueueHold hold;
  final DownloadRuntimeStatus runtimeStatus;

  const DownloadManagerState({
    this.downloads = const <DownloadDomain>[],
    this.hold = DownloadQueueHold.none,
    this.runtimeStatus = DownloadRuntimeStatus.inactive,
  });

  DownloadDomain? forChapter(String chapterUid) =>
      downloads.firstWhereOrNull((DownloadDomain d) => d.uid == chapterUid);

  List<DownloadDomain> get active => downloads
      .where((DownloadDomain d) =>
          d.status == DownloadStatus.queued ||
          d.status == DownloadStatus.downloading)
      .toList();

  bool get waitingForWifi => hold == DownloadQueueHold.waitingForWifi;

  bool get runsOnlyWhileAppOpen =>
      runtimeStatus == DownloadRuntimeStatus.startNotAllowed ||
      runtimeStatus == DownloadRuntimeStatus.timedOut;

  DownloadManagerState copyWith({
    List<DownloadDomain>? downloads,
    DownloadQueueHold? hold,
    DownloadRuntimeStatus? runtimeStatus,
  }) =>
      DownloadManagerState(
        downloads: downloads ?? this.downloads,
        hold: hold ?? this.hold,
        runtimeStatus: runtimeStatus ?? this.runtimeStatus,
      );
}
