import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/services/widgets/gallery_title_actions_sheet.dart';

void main() {
  late WakaranaiDatabase db;
  late LibraryEntryRepository entries;
  late CategoryRepository categories;
  late LibraryCubit cubit;

  const GalleryTitle title = GalleryTitle(
    uid: 'title-1',
    extensionUid: 'ext',
    title: 'A title',
    cover: 'https://example.com/cover.png',
    data: <String, dynamic>{'id': 1},
  );

  setUp(() {
    db = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    entries = LibraryEntryRepository(database: db);
    categories = CategoryRepository(database: db);
    cubit = LibraryCubit(
      libraryEntryRepository: entries,
      categoryRepository: categories,
      libraryUpdateRepository: LibraryUpdateRepository(database: db),
      extensionResolver: ExtensionResolver(
        extensionRepository: ExtensionRepository(database: db),
        extensionSourceRepository: ExtensionSourceRepository(database: db),
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  Future<int> createCategory(String name) async {
    final CategoryDomain? created = await categories.create(
      CategoryDomain(id: 0, name: name, sortOrder: 0, createdAt: DateTime.now()),
    );
    return created!.id;
  }

  test('adding a gallery title straight into a category saves it there',
      () async {
    final int reading = await createCategory('Reading');

    await cubit.addToLibrary(title.toLibraryEntry(categoryId: reading));

    final LibraryEntryDomain? saved = await entries.getByUid(title.uid);
    expect(saved?.categoryId, reading);
    expect(saved?.extensionUid, 'ext');
    expect(saved?.dataJson, <String, dynamic>{'id': 1});
  });

  test('adding a title that is already saved keeps its category', () async {
    final int reading = await createCategory('Reading');
    final int planned = await createCategory('Planned');

    await cubit.addToLibrary(title.toLibraryEntry(categoryId: reading));
    await cubit.addToLibrary(title.toLibraryEntry(categoryId: planned));

    final LibraryEntryDomain? saved = await entries.getByUid(title.uid);
    expect(saved?.categoryId, reading);
  });

  test('moving a saved gallery title changes only its category', () async {
    final int reading = await createCategory('Reading');
    await cubit.addToLibrary(title.toLibraryEntry());
    final LibraryEntryDomain saved = (await entries.getByUid(title.uid))!;

    await cubit.moveToCategory(saved, reading);

    final LibraryEntryDomain? moved = await entries.getByUid(title.uid);
    expect(moved?.categoryId, reading);
    expect(moved?.createdAt, saved.createdAt);
  });
}
