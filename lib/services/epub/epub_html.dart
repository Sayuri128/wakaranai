import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:wakaranai/services/epub/epub_files.dart';

typedef EpubImageSource = String Function(String archivePath);

class EpubDocumentContent {
  const EpubDocumentContent({
    required this.html,
    required this.textLength,
    required this.images,
    required this.heading,
    required this.documentTitle,
  });

  final String html;
  final int textLength;
  final List<String> images;
  final String heading;
  final String documentTitle;

  bool get isBlank => textLength == 0 && images.isEmpty;
}

class EpubHtml {
  EpubHtml._();

  static const Set<String> _removedTags = <String>{
    'script',
    'style',
    'link',
    'meta',
    'title',
    'head',
    'noscript',
    'iframe',
    'object',
    'embed',
    'audio',
    'video',
    'source',
    'track',
    'form',
    'input',
    'button',
    'select',
    'textarea',
    'canvas',
    'template',
    'math',
  };

  static const Set<String> _keptAttributes = <String>{
    'src',
    'alt',
    'colspan',
    'rowspan',
    'start',
    'value',
    'dir',
    'lang',
  };

  static const Set<String> _selfClosingTags = <String>{
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
    'image',
    'path',
    'rect',
    'circle',
    'ellipse',
    'line',
    'polyline',
    'polygon',
    'use',
    'stop',
  };

  static final RegExp _selfClosing =
      RegExp(r'<([a-zA-Z][\w:.\-]*)((?:\s[^<>]*?)?)\s*/>');
  static final RegExp _whitespace = RegExp(r'\s+');

  static Document parseDocument(String source) {
    return html_parser.parse(expandSelfClosingTags(source));
  }

  static String expandSelfClosingTags(String source) {
    return source.replaceAllMapped(_selfClosing, (Match match) {
      final String tag = match.group(1)!;
      final String attributes = match.group(2) ?? '';
      if (_selfClosingTags.contains(_localName(tag).toLowerCase())) {
        return match.group(0)!;
      }
      return '<$tag$attributes></$tag>';
    });
  }

  static EpubDocumentContent content(
    String source, {
    required String documentPath,
    EpubImageSource? imageSource,
  }) {
    final Document document = parseDocument(source);
    final String documentTitle =
        collapseWhitespace(document.querySelector('title')?.text ?? '');
    final Element root = document.body ?? Element.tag('body');
    final List<String> images = <String>[];
    _removeUnsupported(root);
    _replaceSvgImages(root, documentPath);
    _rewriteImages(root, documentPath, images, imageSource);
    _unwrapLinks(root);
    _stripAttributes(root);
    final String text = collapseWhitespace(root.text);
    return EpubDocumentContent(
      html: root.innerHtml.trim(),
      textLength: text.length,
      images: images,
      heading: _headingOf(root),
      documentTitle: documentTitle,
    );
  }

  static String collapseWhitespace(String text) {
    return text.replaceAll(_whitespace, ' ').trim();
  }

  static String plainText(String source) {
    if (!source.contains('<')) {
      return source.trim();
    }
    final Document document = html_parser.parse(source);
    final Element? body = document.body;
    if (body == null) {
      return source.trim();
    }
    for (final Element breakElement in body.querySelectorAll('br')) {
      breakElement.replaceWith(Text('\n'));
    }
    for (final Element block in body.querySelectorAll('p, div, li')) {
      block.append(Text('\n'));
    }
    return body.text
        .split('\n')
        .map((String line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
        .where((String line) => line.isNotEmpty)
        .join('\n');
  }

  static String? attribute(Element element, String localName) {
    for (final MapEntry<Object, String> entry in element.attributes.entries) {
      final Object key = entry.key;
      final String name = key is AttributeName ? key.name : key.toString();
      if (_localName(name).toLowerCase() == localName) {
        return entry.value;
      }
    }
    return null;
  }

  static String _localName(String name) {
    final int colon = name.lastIndexOf(':');
    if (colon < 0) {
      return name;
    }
    return name.substring(colon + 1);
  }

  static void _removeUnsupported(Element root) {
    for (final Element element in root.querySelectorAll('*').toList()) {
      final String tag = _localName(element.localName ?? '').toLowerCase();
      if (_removedTags.contains(tag) || _isPageBreak(element)) {
        element.remove();
      }
    }
  }

  static bool _isPageBreak(Element element) {
    final String? type = attribute(element, 'type');
    if (type != null && type.split(' ').contains('pagebreak')) {
      return true;
    }
    return element.attributes['role'] == 'doc-pagebreak';
  }

  static void _replaceSvgImages(Element root, String documentPath) {
    for (final Element svg in root.querySelectorAll('svg').toList()) {
      final List<Element> replacements = <Element>[];
      for (final Element image in svg.querySelectorAll('image')) {
        final String? href = attribute(image, 'href');
        if (href == null || href.trim().isEmpty) {
          continue;
        }
        replacements.add(Element.tag('img')..attributes['src'] = href.trim());
      }
      if (replacements.isEmpty) {
        svg.remove();
        continue;
      }
      final Node? parent = svg.parentNode;
      if (parent == null) {
        continue;
      }
      for (final Element replacement in replacements) {
        parent.insertBefore(replacement, svg);
      }
      svg.remove();
    }
  }

  static void _rewriteImages(
    Element root,
    String documentPath,
    List<String> images,
    EpubImageSource? imageSource,
  ) {
    for (final Element image in root.querySelectorAll('img').toList()) {
      final String source = (image.attributes['src'] ?? '').trim();
      if (source.startsWith('data:') ||
          source.startsWith('http://') ||
          source.startsWith('https://')) {
        continue;
      }
      final String? resolved = resolveEpubHref(documentPath, source);
      if (resolved == null) {
        image.remove();
        continue;
      }
      images.add(resolved);
      if (imageSource != null) {
        image.attributes['src'] = imageSource(resolved);
      } else {
        image.attributes['src'] = resolved;
      }
    }
  }

  static void _unwrapLinks(Element root) {
    for (final Element link in root.querySelectorAll('a').toList()) {
      final Node? parent = link.parentNode;
      if (parent == null) {
        continue;
      }
      while (link.nodes.isNotEmpty) {
        parent.insertBefore(link.nodes.first, link);
      }
      link.remove();
    }
  }

  static void _stripAttributes(Element root) {
    for (final Element element in root.querySelectorAll('*')) {
      element.attributes.removeWhere((Object key, String value) =>
          !_keptAttributes.contains(key.toString().toLowerCase()));
    }
  }

  static String _headingOf(Element root) {
    for (final Element heading in root.querySelectorAll('h1, h2, h3')) {
      final String text = collapseWhitespace(heading.text);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}
