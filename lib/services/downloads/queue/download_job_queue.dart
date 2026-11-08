import 'dart:collection';

import 'package:wakaranai/services/downloads/jobs/download_job.dart';

class DownloadJobQueue {
  final Queue<DownloadJob> waiting = Queue<DownloadJob>();
  final Set<String> deletedUids = <String>{};
  final Set<String> pauseRequested = <String>{};
  final Set<DownloadJob> stoppedByUser = Set<DownloadJob>.identity();
  final Map<String, DownloadJob> parkedJobs = <String, DownloadJob>{};
  DownloadJob? active;
  DownloadJob? heldForWifi;
  DownloadJob? previousInBatch;
  int batchIndex = 0;
  int completedInBatch = 0;

  int get batchTotal => batchIndex + waiting.length;

  bool get isIdle => waiting.isEmpty && active == null;

  bool isWaiting(String uid) {
    return waiting.any((DownloadJob job) => job.uid == uid);
  }

  bool hasJob(String uid) {
    return active?.uid == uid || isWaiting(uid);
  }

  void replace(DownloadJob job) {
    waiting.removeWhere((DownloadJob queued) => queued.uid == job.uid);
    waiting.add(job);
  }

  void startBatch() {
    completedInBatch = 0;
    batchIndex = 0;
    previousInBatch = null;
  }

  void stepBackInBatch() {
    if (batchIndex > 0) {
      batchIndex--;
    }
  }

  List<String> orderWithActiveFirst(
    List<String> pending,
    List<String> first,
  ) {
    final Set<String> pendingUids = pending.toSet();
    final String? activeUid = active?.uid;
    final List<String> order = <String>[];
    void place(String uid) {
      if (pendingUids.contains(uid) && !order.contains(uid)) {
        order.add(uid);
      }
    }

    if (activeUid != null) {
      place(activeUid);
    }
    first.forEach(place);
    pending.forEach(place);
    return order;
  }

  void sortBy(List<String> order) {
    final Map<String, int> rank = <String, int>{
      for (int index = 0; index < order.length; index++) order[index]: index,
    };
    final List<DownloadJob> jobs = waiting.toList();
    final Map<DownloadJob, int> arrival = Map<DownloadJob, int>.identity();
    for (int index = 0; index < jobs.length; index++) {
      arrival[jobs[index]] = index;
    }
    int rankOf(DownloadJob job) =>
        rank[job.uid] ?? order.length + arrival[job]!;
    jobs.sort((DownloadJob a, DownloadJob b) => rankOf(a).compareTo(rankOf(b)));
    waiting
      ..clear()
      ..addAll(jobs);
  }
}
