part of 'download_manager_cubit.dart';

enum DownloadQueueHold { none, waitingForWifi }

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

  List<DownloadDomain> get queue {
    final List<DownloadDomain> pending =
        downloads.where((DownloadDomain d) => d.isPending).toList();
    pending.sort(_compareQueueOrder);
    return pending;
  }

  bool get canPauseAny => downloads.any(_isPausable);

  bool get canResumeAny => downloads.any((DownloadDomain d) => d.isPaused);

  static bool _isPausable(DownloadDomain download) =>
      download.status == DownloadStatus.queued ||
      download.status == DownloadStatus.downloading;

  static int _compareQueueOrder(DownloadDomain a, DownloadDomain b) {
    final int pinned = _pinRank(a).compareTo(_pinRank(b));
    if (pinned != 0) {
      return pinned;
    }
    final int position = a.queuePosition.compareTo(b.queuePosition);
    if (position != 0) {
      return position;
    }
    return a.id.compareTo(b.id);
  }

  static int _pinRank(DownloadDomain download) {
    if (download.status == DownloadStatus.downloading) {
      return 0;
    }
    return 1;
  }

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
