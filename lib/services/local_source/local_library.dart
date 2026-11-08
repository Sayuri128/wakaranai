import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

const Set<String> localImageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.avif',
  '.bmp',
};

const Set<String> localArchiveExtensions = <String>{'.cbz', '.zip'};

bool isLocalImage(String path) =>
    localImageExtensions.contains(p.extension(path).toLowerCase());

bool isLocalArchive(String path) =>
    localArchiveExtensions.contains(p.extension(path).toLowerCase());

String stableHash(String value) {
  BigInt hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final BigInt prime = BigInt.parse('100000001b3', radix: 16);
  final BigInt mask = (BigInt.one << 64) - BigInt.one;
  for (final int unit in utf8.encode(value)) {
    hash = ((hash ^ BigInt.from(unit)) * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

int compareNatural(String a, String b) {
  final RegExp chunk = RegExp(r'(\d+|\D+)');
  final List<String> left =
      chunk.allMatches(a.toLowerCase()).map((Match m) => m[0]!).toList();
  final List<String> right =
      chunk.allMatches(b.toLowerCase()).map((Match m) => m[0]!).toList();
  for (int index = 0; index < left.length && index < right.length; index++) {
    final int? leftNumber = int.tryParse(left[index]);
    final int? rightNumber = int.tryParse(right[index]);
    final int result = leftNumber != null && rightNumber != null
        ? leftNumber.compareTo(rightNumber)
        : left[index].compareTo(right[index]);
    if (result != 0) {
      return result;
    }
  }
  return left.length.compareTo(right.length);
}

double? chapterNumberFromName(String name) {
  final String base = name.toLowerCase();
  final List<RegExp> patterns = <RegExp>[
    RegExp(r'(?:ch|chapter|chap|глава|розділ|гл)\.?\s*(\d+(?:[.,]\d+)?)'),
    RegExp(r'(?:#|№)\s*(\d+(?:[.,]\d+)?)'),
    RegExp(r'(\d+(?:[.,]\d+)?)\s*$'),
    RegExp(r'^(\d+(?:[.,]\d+)?)'),
  ];
  for (final RegExp pattern in patterns) {
    final RegExpMatch? match = pattern.firstMatch(base);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '.'));
    }
  }
  return null;
}

class LocalComicInfo {
  const LocalComicInfo({
    this.series,
    this.summary,
    this.writer,
    this.genres = const <String>[],
  });

  final String? series;
  final String? summary;
  final String? writer;
  final List<String> genres;

  static LocalComicInfo parse(String xml) {
    String? field(String name) {
      final RegExpMatch? match =
          RegExp('<$name>([\\s\\S]*?)</$name>').firstMatch(xml);
      final String? value = match?.group(1)?.trim();
      if (value == null || value.isEmpty) {
        return null;
      }
      return _unescape(value);
    }

    final String? genre = field('Genre');
    return LocalComicInfo(
      series: field('Series'),
      summary: field('Summary'),
      writer: field('Writer'),
      genres: genre == null
          ? const <String>[]
          : genre
              .split(',')
              .map((String g) => g.trim())
              .where((String g) => g.isNotEmpty)
              .toList(),
    );
  }

  static String _unescape(String value) {
    return value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }
}

class LocalChapter {
  const LocalChapter({required this.path, required this.name});

  final String path;
  final String name;

  bool get isArchive => isLocalArchive(path);
}

class LocalTitle {
  const LocalTitle({
    required this.path,
    required this.name,
    required this.chapters,
  });

  final String path;
  final String name;
  final List<LocalChapter> chapters;
}

class LocalLibrary {
  LocalLibrary({
    required this.root,
    required this.cache,
    this.reservedFolders = const <String>{},
  });

  final Directory root;
  final Directory cache;
  final Set<String> reservedFolders;

  String relativeId(String path) {
    return p.relative(path, from: root.path).replaceAll('\\', '/');
  }

  String absolutePath(String id) {
    final String resolved = p.normalize(p.join(root.path, id));
    if (!p.isWithin(root.path, resolved) && resolved != root.path) {
      throw ArgumentError('Path escapes the local library: $id');
    }
    return resolved;
  }

  Future<List<LocalTitle>> titles() async {
    if (!await root.exists()) {
      return const <LocalTitle>[];
    }
    final List<LocalTitle> titles = <LocalTitle>[];
    await for (final FileSystemEntity entity in root.list(followLinks: false)) {
      if (entity is Directory &&
          reservedFolders.contains(p.basename(entity.path))) {
        continue;
      }
      final LocalTitle? title = await titleAt(entity.path);
      if (title != null) {
        titles.add(title);
      }
    }
    titles.sort((LocalTitle a, LocalTitle b) => compareNatural(a.name, b.name));
    return titles;
  }

  Future<LocalTitle?> titleAt(String path) async {
    final FileSystemEntityType type = await FileSystemEntity.type(path);
    final String name = p.basenameWithoutExtension(path);
    if (name.startsWith('.')) {
      return null;
    }
    if (type == FileSystemEntityType.file && isLocalArchive(path)) {
      return LocalTitle(
        path: path,
        name: name,
        chapters: <LocalChapter>[LocalChapter(path: path, name: name)],
      );
    }
    if (type != FileSystemEntityType.directory) {
      return null;
    }
    final List<LocalChapter> chapters = await _chaptersIn(Directory(path));
    if (chapters.isEmpty) {
      return null;
    }
    return LocalTitle(path: path, name: p.basename(path), chapters: chapters);
  }

  Future<List<LocalChapter>> _chaptersIn(Directory directory) async {
    final List<LocalChapter> chapters = <LocalChapter>[];
    bool hasLooseImages = false;
    await for (final FileSystemEntity entity
        in directory.list(followLinks: false)) {
      final String name = p.basename(entity.path);
      if (name.startsWith('.')) {
        continue;
      }
      if (entity is File && isLocalArchive(entity.path)) {
        chapters.add(LocalChapter(
          path: entity.path,
          name: p.basenameWithoutExtension(entity.path),
        ));
      } else if (entity is Directory && await _containsImages(entity)) {
        chapters.add(LocalChapter(path: entity.path, name: name));
      } else if (entity is File &&
          isLocalImage(entity.path) &&
          !_isCoverFile(entity.path)) {
        hasLooseImages = true;
      }
    }
    if (chapters.isEmpty && hasLooseImages) {
      return <LocalChapter>[
        LocalChapter(path: directory.path, name: p.basename(directory.path)),
      ];
    }
    chapters.sort(
        (LocalChapter a, LocalChapter b) => compareNatural(a.name, b.name));
    return chapters;
  }

  Future<bool> _containsImages(Directory directory) async {
    await for (final FileSystemEntity entity
        in directory.list(followLinks: false)) {
      if (entity is File && isLocalImage(entity.path)) {
        return true;
      }
    }
    return false;
  }

  bool _isCoverFile(String path) {
    return p.basenameWithoutExtension(path).toLowerCase() == 'cover';
  }

  Future<String?> coverOf(LocalTitle title) async {
    if (await FileSystemEntity.isDirectory(title.path)) {
      for (final String extension in localImageExtensions) {
        final File cover = File(p.join(title.path, 'cover$extension'));
        if (await cover.exists()) {
          return cover.path;
        }
      }
    }
    if (title.chapters.isEmpty) {
      return null;
    }
    final LocalChapter first = title.chapters.first;
    if (first.isArchive) {
      return _extractCover(first.path);
    }
    final List<String> pages = await pagesOf(first);
    if (pages.isEmpty) {
      return null;
    }
    return pages.first;
  }

  Future<String?> _extractCover(String archivePath) async {
    final String key = await _cacheKey(archivePath);
    final Directory covers = Directory(p.join(cache.path, 'covers'));
    await covers.create(recursive: true);
    await for (final FileSystemEntity entity in covers.list()) {
      if (p.basenameWithoutExtension(entity.path) == key) {
        return entity.path;
      }
    }
    final InputFileStream input = InputFileStream(archivePath);
    try {
      final Archive archive = ZipDecoder().decodeBuffer(input);
      final List<ArchiveFile> images = archive.files
          .where((ArchiveFile file) => file.isFile && isLocalImage(file.name))
          .toList()
        ..sort((ArchiveFile a, ArchiveFile b) => compareNatural(a.name, b.name));
      if (images.isEmpty) {
        return null;
      }
      final String path = p.join(
        covers.path,
        '$key${p.extension(images.first.name).toLowerCase()}',
      );
      final OutputFileStream output = OutputFileStream(path);
      try {
        images.first.writeContent(output);
      } finally {
        output.closeSync();
      }
      return path;
    } catch (_) {
      return null;
    } finally {
      input.closeSync();
    }
  }

  Future<String> _cacheKey(String path) async {
    final FileStat stat = await File(path).stat();
    return stableHash('$path|${stat.size}|${stat.modified.millisecondsSinceEpoch}');
  }

  Future<LocalComicInfo?> comicInfoOf(LocalTitle title) async {
    if (await FileSystemEntity.isDirectory(title.path)) {
      final File info = File(p.join(title.path, 'ComicInfo.xml'));
      if (await info.exists()) {
        return LocalComicInfo.parse(await info.readAsString());
      }
    }
    for (final LocalChapter chapter in title.chapters) {
      if (!chapter.isArchive) {
        continue;
      }
      final String? xml = _readArchiveEntry(chapter.path, 'ComicInfo.xml');
      if (xml != null) {
        return LocalComicInfo.parse(xml);
      }
      break;
    }
    return null;
  }

  Future<List<String>> pagesOf(LocalChapter chapter) async {
    if (chapter.isArchive) {
      return _extractArchive(chapter.path);
    }
    final List<String> pages = <String>[];
    await for (final FileSystemEntity entity
        in Directory(chapter.path).list(followLinks: false)) {
      if (entity is File &&
          isLocalImage(entity.path) &&
          !_isCoverFile(entity.path)) {
        pages.add(entity.path);
      }
    }
    pages.sort((String a, String b) =>
        compareNatural(p.basename(a), p.basename(b)));
    return pages;
  }

  String? _readArchiveEntry(String archivePath, String entryName) {
    final InputFileStream input = InputFileStream(archivePath);
    try {
      final Archive archive = ZipDecoder().decodeBuffer(input);
      for (final ArchiveFile file in archive.files) {
        if (file.isFile &&
            p.basename(file.name).toLowerCase() == entryName.toLowerCase()) {
          return utf8.decode(file.content as List<int>, allowMalformed: true);
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      input.closeSync();
    }
  }

  Future<List<String>> _extractArchive(String archivePath) async {
    final String key = await _cacheKey(archivePath);
    final Directory target = Directory(p.join(cache.path, 'pages', key));
    final File done = File(p.join(target.path, '.done'));
    if (await done.exists()) {
      return _listExtracted(target);
    }
    if (await target.exists()) {
      await target.delete(recursive: true);
    }
    await target.create(recursive: true);
    final InputFileStream input = InputFileStream(archivePath);
    try {
      final Archive archive = ZipDecoder().decodeBuffer(input);
      final List<ArchiveFile> images = archive.files
          .where((ArchiveFile file) => file.isFile && isLocalImage(file.name))
          .toList()
        ..sort((ArchiveFile a, ArchiveFile b) => compareNatural(a.name, b.name));
      for (int index = 0; index < images.length; index++) {
        final ArchiveFile image = images[index];
        final String name =
            '${index.toString().padLeft(4, '0')}${p.extension(image.name).toLowerCase()}';
        final OutputFileStream output =
            OutputFileStream(p.join(target.path, name));
        try {
          image.writeContent(output);
        } finally {
          output.closeSync();
        }
      }
    } finally {
      input.closeSync();
    }
    await done.writeAsString('');
    return _listExtracted(target);
  }

  Future<List<String>> _listExtracted(Directory target) async {
    final List<String> pages = <String>[];
    await for (final FileSystemEntity entity in target.list()) {
      if (entity is File && isLocalImage(entity.path)) {
        pages.add(entity.path);
      }
    }
    pages.sort((String a, String b) =>
        compareNatural(p.basename(a), p.basename(b)));
    return pages;
  }

  Future<String> importArchive(File archive, {String? titleName}) async {
    await root.create(recursive: true);
    final String fileName = p.basename(archive.path);
    final String destination = titleName == null || titleName.trim().isEmpty
        ? p.join(root.path, fileName)
        : p.join(root.path, _safeName(titleName), fileName);
    await Directory(p.dirname(destination)).create(recursive: true);
    await archive.copy(destination);
    return destination;
  }

  String _safeName(String name) {
    return name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
