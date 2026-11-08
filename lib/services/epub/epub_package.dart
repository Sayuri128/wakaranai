import 'package:wakaranai/services/epub/epub_files.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:xml/xml.dart';

class EpubManifestItem {
  const EpubManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });

  final String id;
  final String path;
  final String mediaType;
  final Set<String> properties;

  bool get isDocument {
    final String type = mediaType.toLowerCase();
    if (type == 'application/xhtml+xml' || type == 'text/html') {
      return true;
    }
    final String lower = path.toLowerCase();
    return type.isEmpty &&
        (lower.endsWith('.xhtml') ||
            lower.endsWith('.html') ||
            lower.endsWith('.htm'));
  }

  bool get isImage {
    if (mediaType.toLowerCase().startsWith('image/')) {
      return true;
    }
    return RegExp(r'\.(jpe?g|png|gif|webp|bmp|avif)$', caseSensitive: false)
        .hasMatch(path);
  }

  bool get isNcx =>
      mediaType.toLowerCase() == 'application/x-dtbncx+xml' ||
      path.toLowerCase().endsWith('.ncx');
}

class EpubSpineItem {
  const EpubSpineItem({required this.item, required this.linear});

  final EpubManifestItem item;
  final bool linear;
}

class EpubPackage {
  const EpubPackage({
    required this.opfPath,
    required this.title,
    required this.creators,
    required this.description,
    required this.language,
    required this.manifest,
    required this.spine,
    required this.coverPath,
    required this.navPath,
    required this.ncxPath,
  });

  final String opfPath;
  final String title;
  final List<String> creators;
  final String description;
  final String language;
  final List<EpubManifestItem> manifest;
  final List<EpubSpineItem> spine;
  final String? coverPath;
  final String? navPath;
  final String? ncxPath;
}

class EpubPackageReader {
  EpubPackageReader(this.files);

  final EpubFiles files;

  EpubPackage read() {
    final String opfPath = _locateOpf();
    final XmlDocument opf = parseLenientXml(files.readText(opfPath) ?? '');
    final List<EpubManifestItem> manifest = _manifest(opf, opfPath);
    if (manifest.isEmpty) {
      throw const FormatException('The EPUB package lists no files');
    }
    final Map<String, EpubManifestItem> byId = <String, EpubManifestItem>{
      for (final EpubManifestItem item in manifest) item.id: item,
    };
    final XmlElement? spineElement = _first(opf, 'spine');
    return EpubPackage(
      opfPath: opfPath,
      title: _firstText(opf, 'title'),
      creators: _texts(opf, 'creator'),
      description: EpubHtml.plainText(_firstText(opf, 'description')),
      language: _firstText(opf, 'language'),
      manifest: manifest,
      spine: _spine(spineElement, byId, manifest),
      coverPath: _coverPath(opf, manifest, byId),
      navPath: _navPath(manifest),
      ncxPath: _ncxPath(spineElement, manifest, byId),
    );
  }

  String _locateOpf() {
    final String? declared = _declaredOpf();
    if (declared != null) {
      return declared;
    }
    for (final String path in files.paths) {
      if (path.toLowerCase().endsWith('.opf')) {
        return path;
      }
    }
    throw const FormatException('Not an EPUB: no package document found');
  }

  String? _declaredOpf() {
    final String? container = files.readText('META-INF/container.xml');
    if (container == null) {
      return null;
    }
    final XmlDocument document;
    try {
      document = parseLenientXml(container);
    } on FormatException {
      return null;
    }
    for (final XmlElement rootfile
        in document.findAllElements('rootfile', namespace: '*')) {
      final String? fullPath = epubXmlAttribute(rootfile, 'full-path');
      if (fullPath == null) {
        continue;
      }
      final String? resolved = files.resolve(normalizeEpubPath(fullPath));
      if (resolved != null) {
        return resolved;
      }
    }
    return null;
  }

  List<EpubManifestItem> _manifest(XmlDocument opf, String opfPath) {
    final List<EpubManifestItem> items = <EpubManifestItem>[];
    for (final XmlElement element
        in opf.findAllElements('item', namespace: '*')) {
      final String? id = epubXmlAttribute(element, 'id');
      final String? href = epubXmlAttribute(element, 'href');
      if (id == null || href == null) {
        continue;
      }
      final String? path = resolveEpubHref(opfPath, href);
      if (path == null) {
        continue;
      }
      items.add(EpubManifestItem(
        id: id,
        path: files.resolve(path) ?? path,
        mediaType: epubXmlAttribute(element, 'media-type') ?? '',
        properties: (epubXmlAttribute(element, 'properties') ?? '')
            .split(RegExp(r'\s+'))
            .where((String value) => value.isNotEmpty)
            .toSet(),
      ));
    }
    return items;
  }

  List<EpubSpineItem> _spine(
    XmlElement? spineElement,
    Map<String, EpubManifestItem> byId,
    List<EpubManifestItem> manifest,
  ) {
    final List<EpubSpineItem> spine = <EpubSpineItem>[];
    if (spineElement != null) {
      for (final XmlElement itemref
          in spineElement.findAllElements('itemref', namespace: '*')) {
        final EpubManifestItem? item = byId[epubXmlAttribute(itemref, 'idref')];
        if (item == null || !item.isDocument) {
          continue;
        }
        spine.add(EpubSpineItem(
          item: item,
          linear: epubXmlAttribute(itemref, 'linear')?.toLowerCase() != 'no',
        ));
      }
    }
    if (spine.isNotEmpty) {
      return spine;
    }
    return manifest
        .where((EpubManifestItem item) => item.isDocument)
        .map((EpubManifestItem item) =>
            EpubSpineItem(item: item, linear: true))
        .toList(growable: false);
  }

  String? _coverPath(
    XmlDocument opf,
    List<EpubManifestItem> manifest,
    Map<String, EpubManifestItem> byId,
  ) {
    for (final EpubManifestItem item in manifest) {
      if (item.properties.contains('cover-image') && item.isImage) {
        return _existing(item.path);
      }
    }
    final String? metaCover = _metaCover(opf, manifest, byId);
    if (metaCover != null) {
      return metaCover;
    }
    for (final EpubManifestItem item in manifest) {
      if (item.isImage &&
          (item.id.toLowerCase().contains('cover') ||
              item.path.toLowerCase().contains('cover'))) {
        return _existing(item.path);
      }
    }
    return null;
  }

  String? _metaCover(
    XmlDocument opf,
    List<EpubManifestItem> manifest,
    Map<String, EpubManifestItem> byId,
  ) {
    for (final XmlElement meta in opf.findAllElements('meta', namespace: '*')) {
      if (epubXmlAttribute(meta, 'name')?.toLowerCase() != 'cover') {
        continue;
      }
      final String? content = epubXmlAttribute(meta, 'content');
      if (content == null || content.isEmpty) {
        continue;
      }
      final EpubManifestItem? byIdItem = byId[content];
      if (byIdItem != null && byIdItem.isImage) {
        return _existing(byIdItem.path);
      }
      for (final EpubManifestItem item in manifest) {
        if (item.isImage && item.path.endsWith(content)) {
          return _existing(item.path);
        }
      }
    }
    return null;
  }

  String? _existing(String path) {
    return files.resolve(path);
  }

  String? _navPath(List<EpubManifestItem> manifest) {
    for (final EpubManifestItem item in manifest) {
      if (item.properties.contains('nav')) {
        return _existing(item.path);
      }
    }
    return null;
  }

  String? _ncxPath(
    XmlElement? spineElement,
    List<EpubManifestItem> manifest,
    Map<String, EpubManifestItem> byId,
  ) {
    final String? tocId =
        spineElement == null ? null : epubXmlAttribute(spineElement, 'toc');
    final EpubManifestItem? declared = byId[tocId];
    if (declared != null) {
      return _existing(declared.path);
    }
    for (final EpubManifestItem item in manifest) {
      if (item.isNcx) {
        return _existing(item.path);
      }
    }
    return null;
  }

  static XmlElement? _first(XmlNode node, String localName) {
    return node.findAllElements(localName, namespace: '*').firstOrNull;
  }

  static String _firstText(XmlNode node, String localName) {
    for (final XmlElement element
        in node.findAllElements(localName, namespace: '*')) {
      final String text = EpubHtml.collapseWhitespace(element.innerText);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  static List<String> _texts(XmlNode node, String localName) {
    final List<String> values = <String>[];
    for (final XmlElement element
        in node.findAllElements(localName, namespace: '*')) {
      final String text = EpubHtml.collapseWhitespace(element.innerText);
      if (text.isNotEmpty && !values.contains(text)) {
        values.add(text);
      }
    }
    return values;
  }
}

String? epubXmlAttribute(XmlElement element, String localName) {
  for (final XmlAttribute attribute in element.attributes) {
    if (attribute.name.local == localName) {
      return attribute.value;
    }
  }
  return null;
}

XmlDocument parseLenientXml(String source) {
  try {
    return XmlDocument.parse(source);
  } on XmlException {
    final String repaired = source
        .replaceAll(
            RegExp(r'&(?!(?:[a-zA-Z][a-zA-Z0-9]*|#[0-9]+|#x[0-9a-fA-F]+);)'),
            '&amp;')
        .replaceAll(RegExp(r'&(nbsp|mdash|ndash|hellip|laquo|raquo|copy);'),
            ' ');
    try {
      return XmlDocument.parse(repaired);
    } on XmlException catch (error) {
      throw FormatException('Malformed EPUB XML: ${error.message}');
    }
  }
}
