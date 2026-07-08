import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';

const String _extensionUid = 'ext.test';
const String _titleUid = 'title-1';

MangaConcreteView _view(List<String> chapterUids) {
  return MangaConcreteView(
    uid: _titleUid,
    cover: 'cover.png',
    title: 'Test Title',
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: MangaStatus.UNDEFINED,
    groups: <ChaptersGroup>[
      ChaptersGroup(
        title: 'Main',
        elements: chapterUids
            .map((String uid) => Chapter(
                  uid: uid,
                  title: 'Chapter $uid',
                  data: <String, dynamic>{'n': uid},
                ))
            .toList(),
      ),
    ],
  );
}

ExtensionDomain _extension() {
  return ExtensionDomain(
    id: 0,
    config: const ConfigInfo(
      name: 'Test',
      uid: _extensionUid,
      logoUrl: '',
      nsfw: false,
      language: 'en',
      version: 1,
      filters: <GalleryFilter>[],
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
    ),
    sourceCode: 'noop',
    createdAt: DateTime.now(),
  );
}

LibraryEntryDomain _entry({
  bool trackUpdates = true,
  bool notifyUpdates = true,
}) {
  return LibraryEntryDomain(
    id: 0,
    uid: _titleUid,
    extensionUid: _extensionUid,
    title: 'Test Title',
    cover: 'cover.png',
    data: '{}',
    trackUpdates: trackUpdates,
    notifyUpdates: notifyUpdates,
    createdAt: DateTime.now(),
  );
}

class _Harness {
  _Harness(this.database)
      : libraryEntryRepository = LibraryEntryRepository(database: database),
        libraryUpdateRepository = LibraryUpdateRepository(database: database),
        concreteDataRepository = ConcreteDataRepository(database: database),
        extensionRepository = ExtensionRepository(database: database);

  final WakaranaiDatabase database;
  final LibraryEntryRepository libraryEntryRepository;
  final LibraryUpdateRepository libraryUpdateRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ExtensionRepository extensionRepository;

  LibraryUpdateService service(ConcreteViewFetcher fetcher) {
    return LibraryUpdateService(
      libraryEntryRepository: libraryEntryRepository,
      libraryUpdateRepository: libraryUpdateRepository,
      concreteDataRepository: concreteDataRepository,
      extensionRepository: extensionRepository,
      fetcher: fetcher,
    );
  }
}

ConcreteViewFetcher _returns(ConcreteView<dynamic> view) {
  return (ExtensionDomain _, LibraryEntryDomain __) async => view;
}

void main() {
  late WakaranaiDatabase database;
  late _Harness harness;

  setUp(() async {
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    harness = _Harness(database);
    await harness.extensionRepository.create(_extension());
  });

  tearDown(() async => database.close());

  test('first check records a snapshot and reports nothing as new', () async {
    await harness.libraryEntryRepository.create(_entry());

    final LibraryUpdateCheckResult result = await harness
        .service(_returns(_view(<String>['c1', 'c2'])))
        .check();

    expect(result.updates, isEmpty);
    expect(result.checked, 1);
    expect(result.failed, 0);

    final snapshot = await harness.concreteDataRepository.getByUid(_titleUid);
    expect(snapshot?.concreteJson, isNotNull);
  });

  test('a chapter added after the snapshot is reported once', () async {
    await harness.libraryEntryRepository.create(_entry());

    await harness.service(_returns(_view(<String>['c1']))).check();

    final LibraryUpdateCheckResult second = await harness
        .service(_returns(_view(<String>['c1', 'c2'])))
        .check();

    expect(second.updates.length, 1);
    expect(second.updates.single.uid, 'c2');
    expect(second.updates.single.concreteTitle, 'Test Title');

    final third = await harness
        .service(_returns(_view(<String>['c1', 'c2'])))
        .check();
    expect(third.updates, isEmpty,
        reason: 'an already recorded chapter must not be reported twice');

    final List<LibraryUpdateDomain> stored =
        await harness.libraryUpdateRepository.getAll();
    expect(stored.length, 1);
    expect(stored.single.seen, isFalse);
  });

  test('a source that throws fails soft without aborting the run', () async {
    await harness.libraryEntryRepository.create(_entry());

    final LibraryUpdateCheckResult result = await harness
        .service((ExtensionDomain _, LibraryEntryDomain __) async =>
            throw Exception('protector challenge needs a webview'))
        .check();

    expect(result.failed, 1);
    expect(result.checked, 0);
    expect(result.updates, isEmpty);
  });

  test('the snapshot is not advanced when the diff throws', () async {
    await harness.libraryEntryRepository.create(_entry());

    await harness.service(_returns(_view(<String>['c1']))).check();

    await harness
        .service((ExtensionDomain _, LibraryEntryDomain __) async =>
            throw Exception('network down'))
        .check();

    final LibraryUpdateCheckResult recovered = await harness
        .service(_returns(_view(<String>['c1', 'c2'])))
        .check();

    expect(recovered.updates.length, 1,
        reason: 'c2 must still be reported after the failed run');
  });

  test('entries with tracking disabled are skipped entirely', () async {
    await harness.libraryEntryRepository.create(_entry(trackUpdates: false));

    final LibraryUpdateCheckResult result = await harness
        .service((ExtensionDomain _, LibraryEntryDomain __) async =>
            throw StateError('fetcher must not be called'))
        .check();

    expect(result.checked, 0);
    expect(result.failed, 0);
    expect(result.updates, isEmpty);
  });

  test('a muted entry still records updates but is not notifiable', () async {
    await harness.libraryEntryRepository.create(_entry(notifyUpdates: false));

    await harness.service(_returns(_view(<String>['c1']))).check();

    final LibraryUpdateCheckResult second = await harness
        .service(_returns(_view(<String>['c1', 'c2'])))
        .check();

    expect(second.updates.length, 1);
    expect(second.notifiable, isEmpty);
  });

  test('an entry whose extension is not cached fails soft', () async {
    await harness.libraryEntryRepository.create(
      LibraryEntryDomain(
        id: 0,
        uid: 'orphan',
        extensionUid: 'ext.missing',
        title: 'Orphan',
        createdAt: DateTime.now(),
      ),
    );

    final LibraryUpdateCheckResult result =
        await harness.service(_returns(_view(<String>['c1']))).check();

    expect(result.failed, 1);
    expect(result.updates, isEmpty);
  });
}
