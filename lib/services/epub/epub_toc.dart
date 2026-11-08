import 'package:html/dom.dart';
import 'package:wakaranai/services/epub/epub_files.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:wakaranai/services/epub/epub_package.dart';
import 'package:xml/xml.dart';

class EpubTocEntry {
  const EpubTocEntry({required this.label, required this.path});

  final String label;
  final String path;
}

class EpubTocReader {
  EpubTocReader(this.files);

  final EpubFiles files;

  List<EpubTocEntry> read(EpubPackage package) {
    final List<EpubTocEntry> fromNav = _safely(() => _fromNav(package.navPath));
    if (fromNav.isNotEmpty) {
      return fromNav;
    }
    return _safely(() => _fromNcx(package.ncxPath));
  }

  List<EpubTocEntry> _safely(List<EpubTocEntry> Function() read) {
    try {
      return read();
    } on FormatException {
      return const <EpubTocEntry>[];
    }
  }

  List<EpubTocEntry> _fromNav(String? navPath) {
    if (navPath == null) {
      return const <EpubTocEntry>[];
    }
    final String? source = files.readText(navPath);
    if (source == null) {
      return const <EpubTocEntry>[];
    }
    final Document document = EpubHtml.parseDocument(source);
    final Element? nav = _tocNav(document);
    if (nav == null) {
      return const <EpubTocEntry>[];
    }
    final List<EpubTocEntry> entries = <EpubTocEntry>[];
    for (final Element link in nav.querySelectorAll('a')) {
      _addEntry(
        entries,
        navPath,
        label: link.text,
        href: link.attributes['href'],
      );
    }
    return entries;
  }

  Element? _tocNav(Document document) {
    final List<Element> navs = document.querySelectorAll('nav');
    for (final Element nav in navs) {
      final String type = EpubHtml.attribute(nav, 'type') ?? '';
      final String role = nav.attributes['role'] ?? '';
      if (type.split(' ').contains('toc') || role == 'doc-toc') {
        return nav;
      }
    }
    if (navs.isEmpty) {
      return null;
    }
    return navs.first;
  }

  List<EpubTocEntry> _fromNcx(String? ncxPath) {
    if (ncxPath == null) {
      return const <EpubTocEntry>[];
    }
    final String? source = files.readText(ncxPath);
    if (source == null) {
      return const <EpubTocEntry>[];
    }
    final XmlDocument document = parseLenientXml(source);
    final List<EpubTocEntry> entries = <EpubTocEntry>[];
    for (final XmlElement point
        in document.findAllElements('navPoint', namespace: '*')) {
      final XmlElement? label =
          point.findElements('navLabel', namespace: '*').firstOrNull;
      final XmlElement? content =
          point.findElements('content', namespace: '*').firstOrNull;
      _addEntry(
        entries,
        ncxPath,
        label: label?.innerText ?? '',
        href: content == null ? null : epubXmlAttribute(content, 'src'),
      );
    }
    return entries;
  }

  void _addEntry(
    List<EpubTocEntry> entries,
    String basePath, {
    required String label,
    required String? href,
  }) {
    if (href == null) {
      return;
    }
    final String? path = resolveEpubHref(basePath, href);
    if (path == null) {
      return;
    }
    entries.add(EpubTocEntry(
      label: EpubHtml.collapseWhitespace(label),
      path: files.resolve(path) ?? path,
    ));
  }
}
