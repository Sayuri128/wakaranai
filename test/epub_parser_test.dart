import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/epub/epub_book.dart';
import 'package:wakaranai/services/epub/epub_files.dart';
import 'package:wakaranai/services/epub/epub_html.dart';
import 'package:wakaranai/services/epub/epub_parser.dart';

import 'fixtures/epub_fixtures.dart';

EpubBook _parse(EpubFixture fixture) {
  return const EpubParser().parse(ArchiveEpubFiles(fixture.archive()));
}

List<String> _titles(EpubBook book) {
  return book.chapters.map((EpubChapter chapter) => chapter.title).toList();
}

void main() {
  group('EPUB 3', () {
    late EpubBook book;

    setUp(() => book = _parse(epub3Fixture()));

    test('reads the package metadata and cover image', () {
      expect(book.title, 'The Glass Garden');
      expect(book.creators, <String>['Ada Writer', 'Bo Coauthor']);
      expect(book.language, 'en');
      expect(book.description, 'A quiet story.');
      expect(book.coverPath, 'OEBPS/Images/cover.jpg');
    });

    test('builds chapters from the spine titled by the toc nav', () {
      expect(_titles(book), <String>['Chapter One', 'Chapter Two']);
      expect(book.chapters.first.documents, <String>[
        'OEBPS/Text/chapter1.xhtml',
        'OEBPS/Text/chapter1_split.xhtml',
      ]);
      expect(book.chapters.last.documents, <String>['OEBPS/Text/chapter2.xhtml']);
    });

    test('skips the cover-only page, the nav and non-linear items', () {
      final List<String> documents = book.chapters
          .expand((EpubChapter chapter) => chapter.documents)
          .toList();
      expect(documents, isNot(contains('OEBPS/Text/cover.xhtml')));
      expect(documents, isNot(contains('OEBPS/nav.xhtml')));
      expect(documents, isNot(contains('OEBPS/Text/notes.xhtml')));
    });

    test('round-trips through json', () {
      final EpubBook copy = EpubBook.fromJson(book.toJson());
      expect(copy.title, book.title);
      expect(copy.coverPath, book.coverPath);
      expect(_titles(copy), _titles(book));
      expect(copy.chapters.first.documents, book.chapters.first.documents);
      expect(copy.chapterStartingAt('OEBPS/Text/chapter2.xhtml')?.title,
          'Chapter Two');
    });
  });

  group('EPUB 2', () {
    test('uses the ncx and the meta cover', () {
      final EpubBook book = _parse(epub2Fixture());
      expect(book.title, 'Old & Bold');
      expect(book.creators, <String>['Classic Author']);
      expect(book.coverPath, 'images/front.png');
      expect(_titles(book), <String>['Old & Bold', 'Part I', 'Part II']);
    });

    test('falls back to the first package file without a container', () {
      final EpubFixture fixture = epub2Fixture();
      fixture.text('META-INF/container.xml', '<container><broken');
      final EpubBook book = _parse(fixture);
      expect(book.title, 'Old & Bold');
    });
  });

  group('malformed books', () {
    test('rejects bytes that are not a zip', () {
      expect(
        () => const EpubParser().parseBytes(<int>[1, 2, 3, 4]),
        throwsFormatException,
      );
    });

    test('rejects archives without a package document', () {
      final EpubFixture fixture = EpubFixture()..text('readme.txt', 'hello');
      expect(() => _parse(fixture), throwsFormatException);
    });

    test('repairs bare ampersands and tolerates missing toc and files', () {
      final EpubFixture fixture = EpubFixture()..container('book.opf');
      fixture.text(
        'book.opf',
        '<package><metadata><title>Salt & Pepper</title></metadata>'
            '<manifest>'
            '<item id="a" href="a.html" media-type="application/xhtml+xml"/>'
            '<item id="b" href="missing.html" '
            'media-type="application/xhtml+xml"/>'
            '<item id="c" href="c.html" media-type="application/xhtml+xml"/>'
            '</manifest>'
            '<spine><itemref idref="a"/><itemref idref="b"/>'
            '<itemref idref="unknown"/><itemref idref="c"/></spine>'
            '</package>',
      );
      fixture.text('a.html', '<html><body><h2>Opening</h2><p>Hi</p></body>');
      fixture.text('c.html', '<p>No heading here');
      final EpubBook book = _parse(fixture);
      expect(book.title, 'Salt & Pepper');
      expect(book.coverPath, isNull);
      expect(_titles(book), <String>['Opening', '']);
    });

    test('uses manifest order when the spine is empty', () {
      final EpubFixture fixture = EpubFixture()..container('book.opf');
      fixture.text(
        'book.opf',
        '<package><metadata/><manifest>'
            '<item id="b" href="b.xhtml"/>'
            '<item id="a" href="a.xhtml"/>'
            '</manifest><spine/></package>',
      );
      fixture.text('a.xhtml', '<p>A</p>');
      fixture.text('b.xhtml', '<p>B</p>');
      final EpubBook book = _parse(fixture);
      expect(book.chapters.map((EpubChapter c) => c.firstDocument),
          <String>['b.xhtml', 'a.xhtml']);
    });
  });

  group('chapter html', () {
    test('keeps the body, strips styling and scripts, rewrites images', () {
      final EpubFixture fixture = epub3Fixture();
      final String source = decodeEpubText(fixture
          .archive()
          .findFile('OEBPS/Text/chapter1.xhtml')!
          .content as List<int>);
      final EpubDocumentContent content = EpubHtml.content(
        source,
        documentPath: 'OEBPS/Text/chapter1.xhtml',
        imageSource: (String path) => '/cache/book/$path',
      );
      expect(content.html, contains('<h1>Chapter One</h1>'));
      expect(content.html, contains('It began here.'));
      expect(content.html, contains('Still chapter one.'));
      expect(content.html, isNot(contains('style')));
      expect(content.html, isNot(contains('class')));
      expect(content.html, isNot(contains('alert')));
      expect(content.html, isNot(contains('<a')));
      expect(content.html, isNot(contains('12')));
      expect(content.html,
          contains('src="/cache/book/OEBPS/Images/map one.png"'));
      expect(content.images, <String>['OEBPS/Images/map one.png']);
      expect(content.heading, 'Chapter One');
    });

    test('turns svg cover images into plain images', () {
      final EpubDocumentContent content = EpubHtml.content(
        '<body><svg><image xlink:href="../img/c.jpg"/></svg></body>',
        documentPath: 'Text/cover.xhtml',
      );
      expect(content.images, <String>['img/c.jpg']);
      expect(content.html, contains('<img src="img/c.jpg">'));
      expect(content.textLength, 0);
    });

    test('drops images that point outside the book', () {
      final EpubDocumentContent content = EpubHtml.content(
        '<p>x</p><img src="../../../etc/passwd"><img src="">',
        documentPath: 'a.xhtml',
      );
      expect(content.images, isEmpty);
      expect(content.html, '<p>x</p>');
    });

    test('expands self-closing non-void tags', () {
      expect(
        EpubHtml.expandSelfClosingTags('<div/><br/><p class="a" />'),
        '<div></div><br/><p class="a"></p>',
      );
    });

    test('turns description markup into plain lines', () {
      expect(EpubHtml.plainText('<p>One</p><p>Two<br/>Three</p>'),
          'One\nTwo\nThree');
      expect(EpubHtml.plainText('Plain'), 'Plain');
    });
  });

  group('paths', () {
    test('resolves hrefs relative to the referencing file', () {
      expect(resolveEpubHref('OEBPS/Text/a.xhtml', '../Images/b%20c.png#x'),
          'OEBPS/Images/b c.png');
      expect(resolveEpubHref('a.xhtml', 'https://example.com/x.png'), isNull);
      expect(resolveEpubHref('a.xhtml', '#note'), isNull);
      expect(resolveEpubHref('a.xhtml', '../x.png'), isNull);
      expect(resolveEpubHref('OEBPS/a.xhtml', '/root.png'), 'root.png');
    });
  });
}
