import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';

PageTranslationResult _result(int width) {
  return PageTranslationResult(
    width: width,
    height: 1,
    bubbles: const <TranslatedBubble>[],
  );
}

void main() {
  late WakaranaiDatabase database;
  late PageTranslationRepository repository;

  final String current =
      'mlkit+gemma${PageTranslationSettings.currentVersionSuffix}';
  const String older = 'mlkit+gemma@v1';
  const String otherEngine = 'mlkit+mlkit@v1';

  Future<void> save(String engine, String page, int width) {
    return repository.put(
      pagePath: page,
      engine: engine,
      source: 'en',
      target: 'uk',
      result: _result(width),
    );
  }

  setUp(() {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    repository = PageTranslationRepository(database: database);
  });

  tearDown(() => database.close());

  test('an older version of the same engine is found for a page', () async {
    await save(older, 'p1', 7);
    await save(otherEngine, 'p2', 9);

    final PageTranslationResult? found = await repository.findOlderVersion(
      pagePath: 'p1',
      engine: current,
      source: 'en',
      target: 'uk',
    );

    expect(found?.width, 7);
    expect(
      await repository.findOlderVersion(
        pagePath: 'p2',
        engine: current,
        source: 'en',
        target: 'uk',
      ),
      isNull,
    );
  });

  test('saving a page removes its older versions', () async {
    await save(older, 'p1', 7);
    await save(current, 'p1', 8);

    expect(await repository.count(), 1);
    expect(
      await repository.findOlderVersion(
        pagePath: 'p1',
        engine: current,
        source: 'en',
        target: 'uk',
      ),
      isNull,
    );
  });

  test('outdated pages can be counted and removed', () async {
    await save(older, 'p1', 7);
    await save(otherEngine, 'p2', 9);
    await save(current, 'p3', 8);

    expect(await repository.countOutdated(), 2);
    expect(await repository.deleteOutdated(), 2);
    expect(await repository.count(), 1);
  });
}
