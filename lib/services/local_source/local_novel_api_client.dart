import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/novel/novel_chapter_content.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/epub/epub_book.dart';
import 'package:wakaranai/services/local_source/local_book_library.dart';

typedef UntitledChapterName = String Function(int number);

class LocalNovelApiClient extends NovelApiClient {
  LocalNovelApiClient({
    required Future<LocalBookLibrary> Function() library,
    UntitledChapterName? untitledChapter,
    super.host = ExtensionHost.none,
  })  : _library = library,
        _untitledChapter = untitledChapter ?? _localizedUntitled,
        super(code: '');

  static const String uidPrefix = 'localbook:';
  static const String _idKey = 'localId';
  static const String _documentKey = 'document';
  static const String _chapterSeparator = '#';

  final Future<LocalBookLibrary> Function() _library;
  final UntitledChapterName _untitledChapter;
  Future<LocalBookLibrary>? _resolved;

  Future<LocalBookLibrary> get _libraryInstance => _resolved ??= _library();

  static String _localizedUntitled(int number) {
    return S.current.local_books_untitled_chapter(number);
  }

  @override
  Future<List<MangaGalleryView>> getGallery({
    required int page,
    String? query,
    List<FilterData>? filters,
    String? feed,
    int? pageSize,
  }) async {
    if (page > 1) {
      return const <MangaGalleryView>[];
    }
    final LocalBookLibrary library = await _libraryInstance;
    final String needle = (query ?? '').trim().toLowerCase();
    final List<MangaGalleryView> gallery = <MangaGalleryView>[];
    for (final LocalBookFile file in await library.books()) {
      final MangaGalleryView view = await _galleryView(library, file);
      if (needle.isNotEmpty && !_matches(view, file, needle)) {
        continue;
      }
      gallery.add(view);
    }
    return gallery;
  }

  bool _matches(MangaGalleryView view, LocalBookFile file, String needle) {
    return view.title.toLowerCase().contains(needle) ||
        file.fileName.toLowerCase().contains(needle) ||
        (view.subtitle ?? '').toLowerCase().contains(needle);
  }

  Future<MangaGalleryView> _galleryView(
    LocalBookLibrary library,
    LocalBookFile file,
  ) async {
    final Map<String, dynamic> data = <String, dynamic>{_idKey: file.id};
    try {
      final OpenedLocalBook opened = await library.open(file);
      return MangaGalleryView(
        uid: '$uidPrefix${file.id}',
        title: opened.title,
        cover: opened.coverFile ?? '',
        data: data,
        subtitle: _creatorsLine(opened.book),
      );
    } catch (error) {
      logger.w('Could not read the book ${file.id}: $error');
      return MangaGalleryView(
        uid: '$uidPrefix${file.id}',
        title: file.fileName,
        cover: '',
        data: data,
      );
    }
  }

  String? _creatorsLine(EpubBook book) {
    if (book.creators.isEmpty) {
      return null;
    }
    return book.creators.join(', ');
  }

  @override
  Future<MangaConcreteView> getConcrete({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final OpenedLocalBook opened = await _open(uid, data);
    final List<Chapter> chapters = <Chapter>[];
    for (int index = 0; index < opened.book.chapters.length; index++) {
      chapters.add(_chapter(opened, opened.book.chapters[index], index));
    }
    return MangaConcreteView(
      uid: uid,
      cover: opened.coverFile ?? '',
      title: opened.title,
      alternativeTitles: const <String>[],
      description: opened.book.description,
      tags: _tagsOf(opened.book),
      status: MangaStatus.UNDEFINED,
      groups: <ChaptersGroup>[
        ChaptersGroup(title: opened.title, elements: chapters),
      ],
      authors: opened.book.creators,
    );
  }

  Chapter _chapter(OpenedLocalBook opened, EpubChapter chapter, int index) {
    final String title = chapter.title.isEmpty
        ? _untitledChapter(index + 1)
        : chapter.title;
    return Chapter(
      uid: '$uidPrefix${opened.file.id}$_chapterSeparator'
          '${chapter.firstDocument}',
      title: title,
      data: <String, dynamic>{
        _idKey: opened.file.id,
        _documentKey: chapter.firstDocument,
      },
      number: (index + 1).toDouble(),
    );
  }

  List<String> _tagsOf(EpubBook book) {
    if (book.language.isEmpty) {
      return const <String>[];
    }
    return <String>[book.language];
  }

  @override
  Future<NovelChapterContent> getChapterText({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final OpenedLocalBook opened = await _open(uid, data);
    final String document = _documentOf(uid, data);
    final EpubChapter? chapter = opened.book.chapterStartingAt(document);
    if (chapter == null) {
      throw StateError('The chapter "$document" is no longer in this book');
    }
    final LocalBookLibrary library = await _libraryInstance;
    return NovelChapterContent(
      title: chapter.title,
      html: await library.chapterHtml(opened, chapter),
    );
  }

  @override
  Future<Map<String, String>> getImageHeaders({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return const <String, String>{};
  }

  @override
  Future<bool> supportsRelated() async => false;

  Future<OpenedLocalBook> _open(String uid, Map<String, dynamic>? data) async {
    final LocalBookLibrary library = await _libraryInstance;
    return library.open(library.fileFor(_idOf(uid, data)));
  }

  String _idOf(String uid, Map<String, dynamic>? data) {
    final Object? stored = data?[_idKey];
    if (stored is String && stored.isNotEmpty) {
      return stored;
    }
    String id = uid;
    if (id.startsWith(uidPrefix)) {
      id = id.substring(uidPrefix.length);
    }
    final int separator = id.indexOf(_chapterSeparator);
    if (separator >= 0) {
      id = id.substring(0, separator);
    }
    return id;
  }

  String _documentOf(String uid, Map<String, dynamic>? data) {
    final Object? stored = data?[_documentKey];
    if (stored is String && stored.isNotEmpty) {
      return stored;
    }
    final int separator = uid.indexOf(_chapterSeparator);
    if (separator < 0) {
      return '';
    }
    return uid.substring(separator + 1);
  }
}
