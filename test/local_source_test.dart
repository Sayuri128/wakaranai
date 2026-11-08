import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/services/local_source/local_library.dart';
import 'package:wakaranai/services/local_source/local_manga_api_client.dart';

void _writeImage(String path) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(<int>[0xFF, 0xD8, 0xFF]);
}

void _writeCbz(String path, List<String> entries, {String? comicInfo}) {
  final Archive archive = Archive();
  for (final String entry in entries) {
    archive.addFile(ArchiveFile(entry, 3, <int>[0xFF, 0xD8, 0xFF]));
  }
  if (comicInfo != null) {
    final List<int> bytes = utf8.encode(comicInfo);
    archive.addFile(ArchiveFile('ComicInfo.xml', bytes.length, bytes));
  }
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(ZipEncoder().encode(archive)!);
}

void main() {
  late Directory temp;
  late LocalLibrary library;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('local_source_test');
    library = LocalLibrary(
      root: Directory(p.join(temp.path, 'Local')),
      cache: Directory(p.join(temp.path, 'cache')),
    );
    final String root = library.root.path;
    _writeImage(p.join(root, 'Folder Manga', 'Chapter 10', '1.jpg'));
    _writeImage(p.join(root, 'Folder Manga', 'Chapter 2', '10.jpg'));
    _writeImage(p.join(root, 'Folder Manga', 'Chapter 2', '2.jpg'));
    _writeImage(p.join(root, 'Folder Manga', 'cover.png'));
    _writeCbz(
      p.join(root, 'Archive Manga', 'Vol 1 Ch 3.cbz'),
      <String>['p10.jpg', 'p2.jpg', 'notes.txt'],
      comicInfo: '<ComicInfo><Series>Archive &amp; Co</Series>'
          '<Summary>A summary</Summary><Genre>Drama, Comedy</Genre>'
          '<Writer>Someone</Writer></ComicInfo>',
    );
    _writeCbz(p.join(root, 'Single.cbz'), <String>['a.png']);
    _writeImage(p.join(root, 'Loose Pages', '1.png'));
    Directory(p.join(root, 'Empty')).createSync(recursive: true);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('sorts names naturally', () {
    final List<String> names = <String>['Chapter 10', 'Chapter 2', 'chapter 1']
      ..sort(compareNatural);
    expect(names, <String>['chapter 1', 'Chapter 2', 'Chapter 10']);
  });

  test('reads chapter numbers from common file names', () {
    expect(chapterNumberFromName('Vol 1 Ch 3'), 3);
    expect(chapterNumberFromName('Глава 12.5'), 12.5);
    expect(chapterNumberFromName('015'), 15);
    expect(chapterNumberFromName('Extra'), isNull);
  });

  test('lists folders, archives and loose image folders as titles', () async {
    final List<LocalTitle> titles = await library.titles();
    expect(
      titles.map((LocalTitle title) => title.name),
      <String>['Archive Manga', 'Folder Manga', 'Loose Pages', 'Single'],
    );
    final LocalTitle folder =
        titles.firstWhere((LocalTitle title) => title.name == 'Folder Manga');
    expect(
      folder.chapters.map((LocalChapter chapter) => chapter.name),
      <String>['Chapter 2', 'Chapter 10'],
    );
  });

  test('prefers cover.png and orders folder pages naturally', () async {
    final LocalTitle title =
        (await library.titleAt(p.join(library.root.path, 'Folder Manga')))!;
    expect(p.basename((await library.coverOf(title))!), 'cover.png');
    final List<String> pages = await library.pagesOf(title.chapters.first);
    expect(pages.map(p.basename), <String>['2.jpg', '10.jpg']);
  });

  test('extracts archive pages once in natural order', () async {
    final LocalTitle title =
        (await library.titleAt(p.join(library.root.path, 'Archive Manga')))!;
    final List<String> first = await library.pagesOf(title.chapters.single);
    final List<String> second = await library.pagesOf(title.chapters.single);
    expect(first, hasLength(2));
    expect(second, first);
    expect(File(first.first).existsSync(), isTrue);
    final LocalComicInfo? info = await library.comicInfoOf(title);
    expect(info?.series, 'Archive & Co');
    expect(info?.genres, <String>['Drama', 'Comedy']);
  });

  test('refuses ids that leave the library folder', () {
    expect(() => library.absolutePath('../outside'), throwsArgumentError);
  });

  test('the client exposes titles, chapters and pages', () async {
    final LocalMangaApiClient client =
        LocalMangaApiClient(library: () async => library);
    final List<MangaGalleryView> gallery =
        await client.getGallery(page: 1, query: 'archive');
    expect(gallery.single.title, 'Archive Manga');
    expect(await client.getGallery(page: 2), isEmpty);

    final MangaConcreteView concrete = await client.getConcrete(
      uid: gallery.single.uid,
      data: gallery.single.data,
    );
    expect(concrete.title, 'Archive & Co');
    expect(concrete.authors, <String>['Someone']);
    final chapter = concrete.groups.single.elements.single;
    expect(chapter.number, 3);

    final Pages pages =
        await client.getPages(uid: chapter.uid, data: chapter.data);
    expect(pages.value, hasLength(2));
  });
}
