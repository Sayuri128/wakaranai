import 'package:wakaranai/services/epub/epub_book.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:wakaranai/services/epub/epub_toc.dart';

class EpubSpineDocument {
  const EpubSpineDocument({required this.path, required this.content});

  final String path;
  final EpubDocumentContent content;
}

class _ChapterDraft {
  _ChapterDraft(this.tocTitle);

  final String? tocTitle;
  final List<EpubSpineDocument> documents = <EpubSpineDocument>[];

  String get title {
    final String? fromToc = tocTitle;
    if (fromToc != null && fromToc.isNotEmpty) {
      return fromToc;
    }
    for (final EpubSpineDocument document in documents) {
      if (document.content.heading.isNotEmpty) {
        return document.content.heading;
      }
    }
    return '';
  }

  bool hasContent(String? coverPath) {
    for (final EpubSpineDocument document in documents) {
      if (document.content.textLength > 0) {
        return true;
      }
      for (final String image in document.content.images) {
        if (image != coverPath) {
          return true;
        }
      }
    }
    return false;
  }

  EpubChapter build() {
    return EpubChapter(
      title: title,
      documents: documents
          .map((EpubSpineDocument document) => document.path)
          .toList(growable: false),
    );
  }
}

class EpubChapterBuilder {
  const EpubChapterBuilder();

  List<EpubChapter> build({
    required List<EpubSpineDocument> documents,
    required List<EpubTocEntry> toc,
    String? coverPath,
  }) {
    final Map<String, String> tocTitles = _tocTitles(toc, documents);
    final List<_ChapterDraft> drafts = <_ChapterDraft>[];
    for (final EpubSpineDocument document in documents) {
      final String? tocTitle = tocTitles[document.path];
      final bool startsChapter =
          tocTitle != null || tocTitles.isEmpty || drafts.isEmpty;
      if (startsChapter) {
        drafts.add(_ChapterDraft(tocTitle));
      }
      drafts.last.documents.add(document);
    }
    return drafts
        .where((_ChapterDraft draft) => draft.hasContent(coverPath))
        .map((_ChapterDraft draft) => draft.build())
        .toList(growable: false);
  }

  Map<String, String> _tocTitles(
    List<EpubTocEntry> toc,
    List<EpubSpineDocument> documents,
  ) {
    final Set<String> spinePaths = documents
        .map((EpubSpineDocument document) => document.path)
        .toSet();
    final Map<String, String> titles = <String, String>{};
    for (final EpubTocEntry entry in toc) {
      if (!spinePaths.contains(entry.path)) {
        continue;
      }
      titles.putIfAbsent(entry.path, () => entry.label);
    }
    return titles;
  }
}
