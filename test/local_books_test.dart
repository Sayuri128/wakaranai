import 'dart:io';

import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/novel/novel_chapter_content.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/local_source/local_book_library.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_library.dart';
import 'package:wakaranai/services/local_source/local_novel_api_client.dart';
import 'package:wakaranai/services/local_source/local_source.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';

import 'fixtures/epub_fixtures.dart';

void _writeFile(String path, List<int> bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

void main() {
  late Directory temp;
  late LocalBookLibrary library;
  late LocalNovelApiClient client;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('local_books_test');
    library = LocalBookLibrary(
      root: Directory(p.join(temp.path, 'Local', 'Books')),
      cache: Directory(p.join(temp.path, 'cache')),
    );
    client = LocalNovelApiClient(
      library: () async => library,
      untitledChapter: (int number) => 'Part $number',
    );
    final String root = library.root.path;
    _writeFile(p.join(root, 'glass.epub'), epub3Fixture().encode());
    _writeFile(p.join(root, 'Classics', 'old.epub'), epub2Fixture().encode());
    _writeFile(p.join(root, 'broken.epub'), <int>[1, 2, 3]);
    _writeFile(p.join(root, 'notes.txt'), <int>[1]);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('lists epub files from the books folder and its subfolders', () async {
    final List<LocalBookFile> books = await library.books();
    expect(books.map((LocalBookFile book) => book.id),
        <String>['broken.epub', 'Classics/old.epub', 'glass.epub']);
  });

  test('extracts a book once and keeps the parsed result', () async {
    final LocalBookFile file = library.fileFor('glass.epub');
    final OpenedLocalBook first = await library.open(file);
    expect(File(first.coverFile!).existsSync(), isTrue);
    final File marker = File(p.join(first.directory, 'OEBPS', 'marker'));
    marker.writeAsStringSync('kept');

    final LocalBookLibrary reopened = LocalBookLibrary(
      root: library.root,
      cache: library.cache,
    );
    final OpenedLocalBook second = await reopened.open(file);
    expect(second.directory, first.directory);
    expect(second.book.title, 'The Glass Garden');
    expect(marker.existsSync(), isTrue);
  });

  test('the gallery shows titles, authors and covers and survives broken books',
      () async {
    final List<MangaGalleryView> gallery = await client.getGallery(page: 1);
    expect(gallery.map((MangaGalleryView view) => view.title),
        <String>['broken', 'Old & Bold', 'The Glass Garden']);
    final MangaGalleryView glass = gallery.last;
    expect(glass.subtitle, 'Ada Writer, Bo Coauthor');
    expect(File(glass.cover).existsSync(), isTrue);
    expect(gallery.first.cover, isEmpty);
    expect(await client.getGallery(page: 2), isEmpty);
    expect(
      (await client.getGallery(page: 1, query: 'classic author'))
          .map((MangaGalleryView view) => view.title),
      <String>['Old & Bold'],
    );
  });

  test('the concrete view lists chapters with stable uids', () async {
    final MangaGalleryView glass = (await client.getGallery(
      page: 1,
      query: 'glass',
    ))
        .single;
    final MangaConcreteView concrete =
        await client.getConcrete(uid: glass.uid, data: glass.data);
    expect(concrete.title, 'The Glass Garden');
    expect(concrete.authors, <String>['Ada Writer', 'Bo Coauthor']);
    expect(concrete.description, 'A quiet story.');
    final List<Chapter> chapters = concrete.groups.single.elements;
    expect(chapters.map((Chapter chapter) => chapter.title),
        <String>['Chapter One', 'Chapter Two']);
    expect(chapters.first.uid,
        'localbook:glass.epub#OEBPS/Text/chapter1.xhtml');
    expect(chapters.last.number, 2);
  });

  test('chapter text joins the chapter files and points images at the cache',
      () async {
    final MangaConcreteView concrete = await client.getConcrete(
      uid: 'localbook:glass.epub',
      data: const <String, dynamic>{},
    );
    final Chapter chapter = concrete.groups.single.elements.first;
    final NovelChapterContent content =
        await client.getChapterText(uid: chapter.uid, data: chapter.data);
    expect(content.title, 'Chapter One');
    expect(content.html, contains('Still chapter one.'));
    expect(content.html, contains('The rest of chapter one.'));
    final RegExpMatch image =
        RegExp(r'<img src="([^"]+)"').firstMatch(content.html)!;
    expect(File(image.group(1)!).existsSync(), isTrue);

    final NovelChapterContent fromUid = await client.getChapterText(
      uid: chapter.uid,
      data: const <String, dynamic>{},
    );
    expect(fromUid.html, content.html);
  });

  test('chapters follow the ncx and untitled ones get a numbered name',
      () async {
    final MangaConcreteView classic = await client.getConcrete(
      uid: 'localbook:Classics/old.epub',
      data: const <String, dynamic>{},
    );
    expect(
      classic.groups.single.elements.map((Chapter chapter) => chapter.title),
      <String>['Old & Bold', 'Part I', 'Part II'],
    );

    final EpubFixture fixture = EpubFixture()..container('book.opf');
    fixture.text(
      'book.opf',
      '<package><metadata/><manifest>'
          '<item id="a" href="a.xhtml"/><item id="b" href="b.xhtml"/>'
          '</manifest><spine><itemref idref="a"/><itemref idref="b"/>'
          '</spine></package>',
    );
    fixture.text('a.xhtml', '<h1>Prologue</h1><p>A</p>');
    fixture.text('b.xhtml', '<p>B</p>');
    _writeFile(p.join(library.root.path, 'plain.epub'), fixture.encode());
    final MangaConcreteView plain = await client.getConcrete(
      uid: 'localbook:plain.epub',
      data: const <String, dynamic>{},
    );
    expect(plain.title, 'plain');
    expect(
      plain.groups.single.elements.map((Chapter chapter) => chapter.title),
      <String>['Prologue', 'Part 2'],
    );
  });

  test('a broken or missing book fails with an error', () async {
    await expectLater(
      client.getConcrete(uid: 'localbook:broken.epub', data: const {}),
      throwsFormatException,
    );
    await expectLater(
      client.getConcrete(uid: 'localbook:gone.epub', data: const {}),
      throwsStateError,
    );
    expect(() => library.absolutePath('../outside.epub'), throwsArgumentError);
  });

  test('imports books without overwriting existing files', () async {
    final String source = p.join(temp.path, 'incoming', 'glass.epub');
    _writeFile(source, epub3Fixture().encode());
    final String imported = await library.importBook(File(source));
    expect(p.basename(imported), 'glass (2).epub');
    final String renamed = p.join(temp.path, 'incoming', 'download');
    _writeFile(renamed, epub2Fixture().encode());
    expect(p.basename(await library.importBook(File(renamed))),
        'download.epub');
  });

  test('the books source is a built-in novel source without downloads',
      () async {
    await S.load(const Locale('en'));
    final ExtensionDomain? books =
        LocalSources.extensionFor(LocalBooksSource.uid);
    expect(books?.config.name, 'Local books');
    expect(books?.config.type, ConfigInfoType.NOVEL);
    expect(LocalSources.isBuiltIn(LocalBooksSource.uid), isTrue);
    expect(LocalSources.isBuiltIn(LocalSource.uid), isTrue);
    expect(LocalSources.isBuiltIn('other'), isFalse);
    expect(LocalSources.supportsDownloads(LocalBooksSource.uid), isFalse);
    expect(LocalSources.supportsDownloads(LocalSource.uid), isTrue);
    expect(
      LocalSources.all().map((ExtensionDomain e) => e.config.uid),
      <String>[LocalSource.uid, LocalBooksSource.uid],
    );
    expect(
      ApiClientFactory().create(config: books!.config, code: ''),
      isA<LocalNovelApiClient>(),
    );
  });

  test('the manga library skips reserved folders', () async {
    final LocalLibrary manga = LocalLibrary(
      root: Directory(p.join(temp.path, 'Local')),
      cache: Directory(p.join(temp.path, 'manga_cache')),
      reservedFolders: const <String>{'Books'},
    );
    _writeFile(p.join(temp.path, 'Local', 'Books', 'Pics', '1.jpg'),
        fixtureImageBytes);
    _writeFile(p.join(temp.path, 'Local', 'Manga', '1.jpg'), fixtureImageBytes);
    final List<LocalTitle> titles = await manga.titles();
    expect(titles.map((LocalTitle title) => title.name), <String>['Manga']);
  });
}
