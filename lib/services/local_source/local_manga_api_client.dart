import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:wakaranai/services/local_source/local_library.dart';
import 'package:wakaranai/services/local_source/local_source.dart';

class LocalMangaApiClient extends MangaApiClient {
  LocalMangaApiClient({
    required Future<LocalLibrary> Function() library,
    super.host = ExtensionHost.none,
  })  : _library = library,
        super(code: '');

  static const String _uidPrefix = 'local:';
  static const String _idKey = 'localId';

  final Future<LocalLibrary> Function() _library;
  Future<LocalLibrary>? _resolved;

  Future<LocalLibrary> get _libraryInstance => _resolved ??= _library();

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
    final LocalLibrary library = await _libraryInstance;
    final String needle = (query ?? '').trim().toLowerCase();
    final List<MangaGalleryView> gallery = <MangaGalleryView>[];
    for (final LocalTitle title in await library.titles()) {
      if (needle.isNotEmpty && !title.name.toLowerCase().contains(needle)) {
        continue;
      }
      final String id = library.relativeId(title.path);
      gallery.add(MangaGalleryView(
        uid: '$_uidPrefix$id',
        title: title.name,
        cover: await library.coverOf(title) ?? '',
        data: <String, dynamic>{_idKey: id},
      ));
    }
    return gallery;
  }

  @override
  Future<MangaConcreteView> getConcrete({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final LocalLibrary library = await _libraryInstance;
    final String id = _idOf(uid, data);
    final LocalTitle? title = await library.titleAt(library.absolutePath(id));
    if (title == null) {
      throw StateError('The local title "$id" is no longer on this device');
    }
    final LocalComicInfo? info = await library.comicInfoOf(title);
    final List<Chapter> chapters = title.chapters.map((LocalChapter chapter) {
      final String chapterId = library.relativeId(chapter.path);
      return Chapter(
        uid: '$_uidPrefix$chapterId',
        title: chapter.name,
        data: <String, dynamic>{_idKey: chapterId},
        number: chapterNumberFromName(chapter.name),
      );
    }).toList(growable: false);
    return MangaConcreteView(
      uid: uid,
      cover: await library.coverOf(title) ?? '',
      title: info?.series ?? title.name,
      alternativeTitles: const <String>[],
      description: info?.summary ?? '',
      tags: info?.genres ?? const <String>[],
      status: MangaStatus.UNDEFINED,
      groups: <ChaptersGroup>[
        ChaptersGroup(title: LocalSource.folderName, elements: chapters),
      ],
      authors: _authorsOf(info),
    );
  }

  @override
  Future<Pages> getPages({
    required String uid,
    required Map<String, dynamic>? data,
  }) async {
    final LocalLibrary library = await _libraryInstance;
    final String id = _idOf(uid, data);
    final String path = library.absolutePath(id);
    final List<String> pages = await library.pagesOf(
      LocalChapter(path: path, name: id),
    );
    return Pages(chapterUid: uid, value: pages);
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

  String _idOf(String uid, Map<String, dynamic>? data) {
    final Object? stored = data?[_idKey];
    if (stored is String && stored.isNotEmpty) {
      return stored;
    }
    if (uid.startsWith(_uidPrefix)) {
      return uid.substring(_uidPrefix.length);
    }
    return uid;
  }

  List<String> _authorsOf(LocalComicInfo? info) {
    final String? writer = info?.writer;
    if (writer == null) {
      return const <String>[];
    }
    return <String>[writer];
  }
}
