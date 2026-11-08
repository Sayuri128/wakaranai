import 'dart:convert';

import 'package:archive/archive.dart';

const List<int> fixtureImageBytes = <int>[0xFF, 0xD8, 0xFF, 0xE0];

class EpubFixture {
  final Map<String, List<int>> _files = <String, List<int>>{};

  void text(String path, String content) {
    _files[path] = utf8.encode(content);
  }

  void bytes(String path, List<int> content) {
    _files[path] = content;
  }

  void container(String opfPath) {
    text(
      'META-INF/container.xml',
      '<?xml version="1.0"?>'
          '<container version="1.0" '
          'xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
          '<rootfiles><rootfile full-path="$opfPath" '
          'media-type="application/oebps-package+xml"/></rootfiles>'
          '</container>',
    );
  }

  Archive archive() {
    final Archive archive = Archive();
    final List<int> mimetype = utf8.encode('application/epub+zip');
    archive.addFile(ArchiveFile('mimetype', mimetype.length, mimetype));
    _files.forEach((String path, List<int> content) {
      archive.addFile(ArchiveFile(path, content.length, content));
    });
    return archive;
  }

  List<int> encode() => ZipEncoder().encode(archive())!;
}

String xhtml(String body, {String title = ''}) {
  return '<?xml version="1.0" encoding="utf-8"?>'
      '<!DOCTYPE html>'
      '<html xmlns="http://www.w3.org/1999/xhtml" '
      'xmlns:epub="http://www.idpf.org/2007/ops">'
      '<head><title>$title</title>'
      '<link rel="stylesheet" href="../Styles/style.css"/>'
      '<style>p { color: red; }</style></head>'
      '<body>$body</body></html>';
}

EpubFixture epub3Fixture() {
  final EpubFixture fixture = EpubFixture()..container('OEBPS/content.opf');
  fixture.text(
    'OEBPS/content.opf',
    '<?xml version="1.0" encoding="utf-8"?>'
        '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" '
        'unique-identifier="id">'
        '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<dc:title>The Glass Garden</dc:title>'
        '<dc:creator>Ada Writer</dc:creator>'
        '<dc:creator>Bo Coauthor</dc:creator>'
        '<dc:language>en</dc:language>'
        '<dc:description>&lt;p&gt;A &lt;b&gt;quiet&lt;/b&gt; story.&lt;/p&gt;'
        '</dc:description>'
        '</metadata>'
        '<manifest>'
        '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" '
        'properties="nav"/>'
        '<item id="cover-img" href="Images/cover.jpg" media-type="image/jpeg" '
        'properties="cover-image"/>'
        '<item id="pic" href="Images/map%20one.png" media-type="image/png"/>'
        '<item id="cover" href="Text/cover.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '<item id="ch1" href="Text/chapter1.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '<item id="ch1b" href="Text/chapter1_split.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '<item id="ch2" href="Text/chapter2.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '<item id="notes" href="Text/notes.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '</manifest>'
        '<spine>'
        '<itemref idref="cover"/>'
        '<itemref idref="nav"/>'
        '<itemref idref="ch1"/>'
        '<itemref idref="ch1b"/>'
        '<itemref idref="notes" linear="no"/>'
        '<itemref idref="ch2"/>'
        '</spine>'
        '</package>',
  );
  fixture.text(
    'OEBPS/nav.xhtml',
    xhtml(
      '<nav epub:type="landmarks"><ol><li>'
      '<a href="Text/chapter2.xhtml">Wrong nav</a></li></ol></nav>'
      '<nav epub:type="toc"><ol>'
      '<li><a href="Text/cover.xhtml">Cover</a></li>'
      '<li><a href="Text/chapter1.xhtml#start">  Chapter\n One </a>'
      '<ol><li><a href="Text/chapter1.xhtml#part">Inner</a></li></ol></li>'
      '<li><a href="Text/chapter2.xhtml">Chapter Two</a></li>'
      '</ol></nav>',
    ),
  );
  fixture.text(
    'OEBPS/Text/cover.xhtml',
    xhtml(
      '<div><svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink">'
      '<image xlink:href="../Images/cover.jpg"/></svg></div>',
    ),
  );
  fixture.text(
    'OEBPS/Text/chapter1.xhtml',
    xhtml(
      '<h1 class="title" style="color: blue">Chapter One</h1>'
      '<p style="font-size: 3em">It began <a href="notes.xhtml#n1">here</a>.'
      '</p><a id="anchor"/><p>Still chapter one.</p>'
      '<span epub:type="pagebreak" title="12">12</span>'
      '<script>alert(1)</script>'
      '<img src="../Images/map%20one.png" alt="Map"/>',
      title: 'Chapter One',
    ),
  );
  fixture.text(
    'OEBPS/Text/chapter1_split.xhtml',
    xhtml('<p>The rest of chapter one.</p>'),
  );
  fixture.text(
    'OEBPS/Text/chapter2.xhtml',
    xhtml('<h2>Second</h2><p>Chapter two text.</p>'),
  );
  fixture.text(
    'OEBPS/Text/notes.xhtml',
    xhtml('<p id="n1">A footnote.</p>'),
  );
  fixture.bytes('OEBPS/Images/cover.jpg', fixtureImageBytes);
  fixture.bytes('OEBPS/Images/map one.png', fixtureImageBytes);
  return fixture;
}

EpubFixture epub2Fixture() {
  final EpubFixture fixture = EpubFixture()..container('content.opf');
  fixture.text(
    'content.opf',
    '<?xml version="1.0"?>'
        '<package xmlns="http://www.idpf.org/2007/opf" version="2.0">'
        '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" '
        'xmlns:opf="http://www.idpf.org/2007/opf">'
        '<dc:title>Old &amp; Bold</dc:title>'
        '<dc:creator opf:role="aut">Classic Author</dc:creator>'
        '<meta name="cover" content="cover-image"/>'
        '</metadata>'
        '<manifest>'
        '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>'
        '<item id="cover-image" href="images/front.png" media-type="image/png"/>'
        '<item id="title" href="title.html" media-type="application/xhtml+xml"/>'
        '<item id="c1" href="c1.html" media-type="application/xhtml+xml"/>'
        '<item id="c2" href="c2.html" media-type="application/xhtml+xml"/>'
        '</manifest>'
        '<spine toc="ncx">'
        '<itemref idref="title"/>'
        '<itemref idref="c1"/>'
        '<itemref idref="c2"/>'
        '</spine>'
        '</package>',
  );
  fixture.text(
    'toc.ncx',
    '<?xml version="1.0"?>'
        '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">'
        '<navMap>'
        '<navPoint id="p1" playOrder="1"><navLabel><text>Part I</text>'
        '</navLabel><content src="c1.html"/>'
        '<navPoint id="p2" playOrder="2"><navLabel><text>Nested</text>'
        '</navLabel><content src="c1.html#x"/></navPoint>'
        '</navPoint>'
        '<navPoint id="p3" playOrder="3"><navLabel><text>Part II</text>'
        '</navLabel><content src="c2.html"/></navPoint>'
        '</navMap></ncx>',
  );
  fixture.text(
    'title.html',
    '<html><head><title>Title</title></head><body>'
        '<h1>Old &amp; Bold</h1><p>by Classic Author</p></body></html>',
  );
  fixture.text(
    'c1.html',
    '<html><body><p>First part &nbsp; text.<br>Line two.</p>'
        '<img src="images/front.png"></body></html>',
  );
  fixture.text(
    'c2.html',
    '<html><body><div/><p>Second part.</p></body></html>',
  );
  fixture.bytes('images/front.png', fixtureImageBytes);
  return fixture;
}
