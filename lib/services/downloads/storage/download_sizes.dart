import 'dart:io';

import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';

typedef DirectorySizeReader = Future<int> Function(String dirPath);

Future<int> measureDirectorySize(String dirPath) async {
  if (dirPath.isEmpty) {
    return 0;
  }
  final Directory directory = Directory(dirPath);
  try {
    if (!await directory.exists()) {
      return 0;
    }
    int total = 0;
    await for (final FileSystemEntity entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        total += await _fileSize(entity);
      }
    }
    return total;
  } on FileSystemException catch (error) {
    logger.w('Failed to measure download dir $dirPath: $error');
    return 0;
  }
}

Future<int> _fileSize(File file) async {
  final FileStat stat = await file.stat();
  if (stat.type != FileSystemEntityType.file || stat.size < 0) {
    return 0;
  }
  return stat.size;
}

bool isDownloadSettled(DownloadDomain download) {
  return download.status == DownloadStatus.done ||
      download.status == DownloadStatus.failed ||
      download.status == DownloadStatus.paused;
}

String downloadSizeSignature(DownloadDomain download) {
  return <Object?>[
    download.status.name,
    download.dirPath,
    download.downloadedPages,
    download.totalPages,
    download.downloadedBytes,
    download.totalBytes,
    download.playback?.length,
  ].join('|');
}

class _MeasuredSize {
  const _MeasuredSize({required this.signature, required this.bytes});

  final String signature;
  final int bytes;
}

class DownloadSizeCache {
  DownloadSizeCache({DirectorySizeReader? readDirectorySize})
    : _readDirectorySize = readDirectorySize ?? measureDirectorySize;

  final DirectorySizeReader _readDirectorySize;
  final Map<String, _MeasuredSize> _measured = <String, _MeasuredSize>{};

  Future<Map<String, int>> refresh(List<DownloadDomain> downloads) async {
    final Set<String> present = <String>{
      for (final DownloadDomain download in downloads) download.uid,
    };
    _measured.removeWhere(
      (String uid, _MeasuredSize _) => !present.contains(uid),
    );
    for (final DownloadDomain download in downloads) {
      await _measureIfStale(download);
    }
    return sizesOf(downloads);
  }

  void invalidate(String uid) {
    _measured.remove(uid);
  }

  Future<void> _measureIfStale(DownloadDomain download) async {
    if (!isDownloadSettled(download)) {
      return;
    }
    final String signature = downloadSizeSignature(download);
    if (_measured[download.uid]?.signature == signature) {
      return;
    }
    final int bytes = await _readDirectorySize(download.dirPath);
    _measured[download.uid] = _MeasuredSize(signature: signature, bytes: bytes);
  }

  Map<String, int> sizesOf(List<DownloadDomain> downloads) {
    final Map<String, int> sizes = <String, int>{};
    for (final DownloadDomain download in downloads) {
      final int? bytes = _sizeOf(download);
      if (bytes != null) {
        sizes[download.uid] = bytes;
      }
    }
    return sizes;
  }

  int? _sizeOf(DownloadDomain download) {
    if (isDownloadSettled(download)) {
      final _MeasuredSize? measured = _measured[download.uid];
      if (measured != null &&
          measured.signature == downloadSizeSignature(download)) {
        return measured.bytes;
      }
      return null;
    }
    if (download.isEpisode && download.downloadedBytes > 0) {
      return download.downloadedBytes;
    }
    return null;
  }
}

class TitleStorageUsage {
  const TitleStorageUsage({
    required this.concreteUid,
    required this.concreteTitle,
    required this.concreteCover,
    required this.isEpisode,
    required this.downloads,
    required this.bytes,
  });

  final String concreteUid;
  final String concreteTitle;
  final String? concreteCover;
  final bool isEpisode;
  final List<DownloadDomain> downloads;
  final int bytes;
}

class DownloadStorageUsage {
  const DownloadStorageUsage({
    required this.itemBytes,
    required this.titles,
    required this.totalBytes,
    required this.complete,
  });

  static const DownloadStorageUsage empty = DownloadStorageUsage(
    itemBytes: <String, int>{},
    titles: <String, TitleStorageUsage>{},
    totalBytes: 0,
    complete: true,
  );

  final Map<String, int> itemBytes;
  final Map<String, TitleStorageUsage> titles;
  final int totalBytes;
  final bool complete;

  int? bytesOfItem(String uid) => itemBytes[uid];

  int bytesOfTitle(String concreteUid) => titles[concreteUid]?.bytes ?? 0;

  List<TitleStorageUsage> get titlesBySize {
    final List<TitleStorageUsage> sorted = titles.values.toList();
    sorted.sort(
      (TitleStorageUsage first, TitleStorageUsage second) =>
          second.bytes.compareTo(first.bytes),
    );
    return sorted;
  }
}

int bytesOfDownloads(
  Iterable<DownloadDomain> downloads,
  Map<String, int> itemBytes,
) {
  int total = 0;
  for (final DownloadDomain download in downloads) {
    total += itemBytes[download.uid] ?? 0;
  }
  return total;
}

DownloadStorageUsage summarizeDownloadStorage(
  List<DownloadDomain> downloads,
  Map<String, int> itemBytes,
) {
  final Map<String, List<DownloadDomain>> grouped =
      <String, List<DownloadDomain>>{};
  for (final DownloadDomain download in downloads) {
    grouped
        .putIfAbsent(download.concreteUid, () => <DownloadDomain>[])
        .add(download);
  }
  final Map<String, TitleStorageUsage> titles = <String, TitleStorageUsage>{
    for (final MapEntry<String, List<DownloadDomain>> entry in grouped.entries)
      entry.key: _titleUsageOf(entry.value, itemBytes),
  };
  int total = 0;
  for (final TitleStorageUsage title in titles.values) {
    total += title.bytes;
  }
  return DownloadStorageUsage(
    itemBytes: Map<String, int>.unmodifiable(itemBytes),
    titles: Map<String, TitleStorageUsage>.unmodifiable(titles),
    totalBytes: total,
    complete: _allSettledMeasured(downloads, itemBytes),
  );
}

TitleStorageUsage _titleUsageOf(
  List<DownloadDomain> downloads,
  Map<String, int> itemBytes,
) {
  final DownloadDomain sample = downloads.first;
  return TitleStorageUsage(
    concreteUid: sample.concreteUid,
    concreteTitle: sample.concreteTitle,
    concreteCover: sample.concreteCover,
    isEpisode: sample.isEpisode,
    downloads: List<DownloadDomain>.unmodifiable(downloads),
    bytes: bytesOfDownloads(downloads, itemBytes),
  );
}

bool _allSettledMeasured(
  List<DownloadDomain> downloads,
  Map<String, int> itemBytes,
) {
  return downloads.every(
    (DownloadDomain download) =>
        !isDownloadSettled(download) || itemBytes.containsKey(download.uid),
  );
}
