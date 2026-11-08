import 'package:archive/archive.dart';
import 'package:wakaranai/services/epub/epub_book.dart';
import 'package:wakaranai/services/epub/epub_chapter_builder.dart';
import 'package:wakaranai/services/epub/epub_files.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:wakaranai/services/epub/epub_package.dart';
import 'package:wakaranai/services/epub/epub_toc.dart';

class EpubParser {
  const EpubParser();

  EpubBook parseBytes(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (error) {
      throw FormatException('Not a readable EPUB archive: $error');
    }
    return parse(ArchiveEpubFiles(archive));
  }

  EpubBook parse(EpubFiles files) {
    final EpubPackage package = EpubPackageReader(files).read();
    final List<EpubTocEntry> toc = EpubTocReader(files).read(package);
    final List<EpubSpineDocument> documents = _spineDocuments(files, package);
    final List<EpubChapter> chapters = const EpubChapterBuilder().build(
      documents: documents,
      toc: toc,
      coverPath: package.coverPath,
    );
    return EpubBook(
      title: package.title,
      creators: package.creators,
      description: package.description,
      language: package.language,
      coverPath: package.coverPath,
      chapters: chapters,
    );
  }

  List<EpubSpineDocument> _spineDocuments(
    EpubFiles files,
    EpubPackage package,
  ) {
    final List<EpubSpineItem> linear = package.spine
        .where((EpubSpineItem item) => item.linear)
        .toList(growable: false);
    final List<EpubSpineItem> items = linear.isEmpty ? package.spine : linear;
    final List<EpubSpineDocument> documents = <EpubSpineDocument>[];
    final Set<String> seen = <String>{};
    for (final EpubSpineItem item in items) {
      final String path = item.item.path;
      if (path == package.navPath || !seen.add(path)) {
        continue;
      }
      final String? source = files.readText(path);
      if (source == null) {
        continue;
      }
      documents.add(EpubSpineDocument(
        path: path,
        content: EpubHtml.content(source, documentPath: path),
      ));
    }
    return documents;
  }
}
