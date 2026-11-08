import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/services/epub/epub_book.dart';
import 'package:wakaranai/services/epub/epub_files.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:wakaranai/services/epub/epub_parser.dart';
import 'package:wakaranai/services/local_source/local_library.dart';

const String localBookExtension = '.epub';

bool isLocalBook(String path) =>
    p.extension(path).toLowerCase() == localBookExtension;

class LocalBookFile {
  const LocalBookFile({required this.path, required this.id});

  final String path;
  final String id;

  String get fileName => p.basenameWithoutExtension(path);
}

class OpenedLocalBook {
  const OpenedLocalBook({
    required this.file,
    required this.book,
    required this.directory,
  });

  final LocalBookFile file;
  final EpubBook book;
  final String directory;

  String get title {
    if (book.title.isNotEmpty) {
      return book.title;
    }
    return file.fileName;
  }

  String? get coverFile {
    final String? cover = book.coverPath;
    if (cover == null) {
      return null;
    }
    return extractedPath(cover);
  }

  String extractedPath(String archivePath) {
    return p.joinAll(<String>[directory, ...archivePath.split('/')]);
  }
}

class LocalBookLibrary {
  LocalBookLibrary({required this.root, required this.cache});

  static const String _bookFileName = 'book.json';
  static const String _doneFileName = '.done';

  final Directory root;
  final Directory cache;
  final Map<String, Future<OpenedLocalBook>> _opened =
      <String, Future<OpenedLocalBook>>{};

  String relativeId(String path) {
    return p.relative(path, from: root.path).replaceAll('\\', '/');
  }

  String absolutePath(String id) {
    final String resolved = p.normalize(p.join(root.path, id));
    if (!p.isWithin(root.path, resolved)) {
      throw ArgumentError('Path escapes the local books folder: $id');
    }
    return resolved;
  }

  LocalBookFile fileFor(String id) {
    return LocalBookFile(path: absolutePath(id), id: id);
  }

  Future<List<LocalBookFile>> books() async {
    if (!await root.exists()) {
      return const <LocalBookFile>[];
    }
    final List<LocalBookFile> books = <LocalBookFile>[];
    await _collect(root, books);
    books.sort(
        (LocalBookFile a, LocalBookFile b) => compareNatural(a.id, b.id));
    return books;
  }

  Future<void> _collect(Directory directory, List<LocalBookFile> books) async {
    await for (final FileSystemEntity entity
        in directory.list(followLinks: false)) {
      if (p.basename(entity.path).startsWith('.')) {
        continue;
      }
      if (entity is Directory) {
        await _collect(entity, books);
      } else if (entity is File && isLocalBook(entity.path)) {
        books.add(LocalBookFile(
          path: entity.path,
          id: relativeId(entity.path),
        ));
      }
    }
  }

  Future<OpenedLocalBook> open(LocalBookFile file) async {
    if (!await File(file.path).exists()) {
      throw StateError('The book "${file.id}" is no longer on this device');
    }
    final String key = await _cacheKey(file.path);
    final Future<OpenedLocalBook>? pending = _opened[key];
    if (pending != null) {
      return pending;
    }
    final Future<OpenedLocalBook> opening = _openUncached(file, key);
    _opened[key] = opening;
    try {
      return await opening;
    } catch (_) {
      _opened.remove(key)?.ignore();
      rethrow;
    }
  }

  Future<OpenedLocalBook> _openUncached(LocalBookFile file, String key) async {
    final Directory target = Directory(p.join(cache.path, key));
    final File done = File(p.join(target.path, _doneFileName));
    final File bookJson = File(p.join(target.path, _bookFileName));
    if (await done.exists() && await bookJson.exists()) {
      final EpubBook? cached = await _readCached(bookJson);
      if (cached != null) {
        return OpenedLocalBook(
          file: file,
          book: cached,
          directory: target.path,
        );
      }
    }
    final String sourcePath = file.path;
    final String targetPath = target.path;
    final Map<String, dynamic> json = await Isolate.run(
      () => extractLocalBook(sourcePath, targetPath),
    );
    return OpenedLocalBook(
      file: file,
      book: EpubBook.fromJson(json),
      directory: target.path,
    );
  }

  Future<EpubBook?> _readCached(File bookJson) async {
    try {
      final Object? decoded = jsonDecode(await bookJson.readAsString());
      if (decoded is Map) {
        return EpubBook.fromJson(decoded.cast<String, dynamic>());
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<String> chapterHtml(OpenedLocalBook opened, EpubChapter chapter) {
    final String directory = opened.directory;
    final List<String> documents = chapter.documents;
    return Isolate.run(() => renderLocalBookChapter(directory, documents));
  }

  Future<String> _cacheKey(String path) async {
    final FileStat stat = await File(path).stat();
    return stableHash(
        'epub|$path|${stat.size}|${stat.modified.millisecondsSinceEpoch}');
  }

  Future<String> importBook(File book) async {
    await root.create(recursive: true);
    String fileName = p.basename(book.path);
    if (!isLocalBook(fileName)) {
      fileName = '$fileName$localBookExtension';
    }
    final String destination = await _freeDestination(fileName);
    await book.copy(destination);
    return destination;
  }

  Future<String> _freeDestination(String fileName) async {
    final String base = p.basenameWithoutExtension(fileName);
    final String extension = p.extension(fileName);
    String candidate = p.join(root.path, fileName);
    int suffix = 2;
    while (await File(candidate).exists()) {
      candidate = p.join(root.path, '$base ($suffix)$extension');
      suffix++;
    }
    return candidate;
  }
}

Map<String, dynamic> extractLocalBook(String sourcePath, String targetPath) {
  final Directory target = Directory(targetPath);
  if (target.existsSync()) {
    target.deleteSync(recursive: true);
  }
  target.createSync(recursive: true);
  final InputFileStream input = InputFileStream(sourcePath);
  try {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBuffer(input);
    } catch (error) {
      throw FormatException('Not a readable EPUB archive: $error');
    }
    final EpubBook book = const EpubParser().parse(ArchiveEpubFiles(archive));
    _extractFiles(archive, targetPath);
    final Map<String, dynamic> json = book.toJson();
    File(p.join(targetPath, LocalBookLibrary._bookFileName))
        .writeAsStringSync(jsonEncode(json));
    File(p.join(targetPath, LocalBookLibrary._doneFileName))
        .writeAsStringSync('');
    return json;
  } catch (_) {
    if (target.existsSync()) {
      target.deleteSync(recursive: true);
    }
    rethrow;
  } finally {
    input.closeSync();
  }
}

void _extractFiles(Archive archive, String targetPath) {
  for (final ArchiveFile file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final String name = normalizeEpubPath(file.name);
    if (name.isEmpty || _isMetadataFile(name)) {
      continue;
    }
    final String destination =
        p.normalize(p.joinAll(<String>[targetPath, ...name.split('/')]));
    if (!p.isWithin(targetPath, destination)) {
      continue;
    }
    Directory(p.dirname(destination)).createSync(recursive: true);
    final OutputFileStream output = OutputFileStream(destination);
    try {
      file.writeContent(output);
    } finally {
      output.closeSync();
    }
  }
}

bool _isMetadataFile(String name) {
  return name == LocalBookLibrary._bookFileName ||
      name == LocalBookLibrary._doneFileName;
}

String renderLocalBookChapter(String directory, List<String> documents) {
  final StringBuffer html = StringBuffer();
  for (final String document in documents) {
    final File file =
        File(p.joinAll(<String>[directory, ...document.split('/')]));
    if (!file.existsSync()) {
      continue;
    }
    final EpubDocumentContent content = EpubHtml.content(
      decodeEpubText(file.readAsBytesSync()),
      documentPath: document,
      imageSource: (String archivePath) =>
          p.joinAll(<String>[directory, ...archivePath.split('/')]),
    );
    if (content.html.isEmpty) {
      continue;
    }
    if (html.isNotEmpty) {
      html.write('\n');
    }
    html.write('<div>${content.html}</div>');
  }
  return html.toString();
}
