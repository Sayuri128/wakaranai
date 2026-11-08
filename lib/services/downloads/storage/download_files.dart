import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';

class DownloadFiles {
  const DownloadFiles._();

  static const String novelChapterFileName = 'chapter.html';

  static Future<Directory> chapterDir(
      String extensionUid, String concreteUid, String chapterUid) async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(
      docs.path,
      'downloads',
      _sanitize(extensionUid),
      _sanitize(concreteUid),
      _sanitize(chapterUid),
    ));
  }

  static String _sanitize(String value) {
    final String cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final String suffix = value.hashCode.toUnsigned(32).toRadixString(16);
    if (cleaned.length <= 80) {
      return '${cleaned}_$suffix';
    }
    return '${cleaned.substring(0, 80)}_$suffix';
  }

  static String pageFileName(int index) =>
      '${index.toString().padLeft(4, '0')}.img';

  static List<String> localPagePaths(DownloadDomain download) =>
      List<String>.generate(download.totalPages,
          (int i) => p.join(download.dirPath, pageFileName(i)));

  static Future<int> keptChapterPages(
    DownloadDomain row,
    Directory dir,
    int pageCount,
  ) async {
    if (row.totalPages != pageCount) {
      return 0;
    }
    final int recorded = row.downloadedPages.clamp(0, pageCount);
    for (int i = 0; i < recorded; i++) {
      if (!await _hasPageFile(File(p.join(dir.path, pageFileName(i))))) {
        return i;
      }
    }
    return recorded;
  }

  static Future<bool> _hasPageFile(File file) async {
    try {
      return await file.exists() && await file.length() > 0;
    } on FileSystemException {
      return false;
    }
  }

  static File novelChapterFile(String dirPath) {
    return File(p.join(dirPath, novelChapterFileName));
  }

  static Future<void> writeNovelChapterFile(String dirPath, String html) async {
    final Directory dir = Directory(dirPath);
    await dir.create(recursive: true);
    final File target = novelChapterFile(dirPath);
    final File partial = File('${target.path}.part');
    await partial.writeAsString(html, flush: true);
    await partial.rename(target.path);
  }

  static Future<String?> readNovelChapterFile(DownloadDomain download) async {
    if (!download.isNovelChapter || download.status != DownloadStatus.done) {
      return null;
    }
    final File file = novelChapterFile(download.dirPath);
    try {
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } on FileSystemException catch (e) {
      logger.w('Cannot read the saved chapter ${download.uid}: $e');
      return null;
    }
  }

  static Future<void> deleteDir(String dirPath) async {
    try {
      final Directory dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      logger.w('Failed to delete download dir $dirPath: $e');
    }
  }
}
