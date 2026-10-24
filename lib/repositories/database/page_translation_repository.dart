import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';

class PageTranslationRepository {
  PageTranslationRepository({required this.database});

  final WakaranaiDatabase database;

  static String keyFor({
    required String pagePath,
    required String engine,
    required String source,
    required String target,
  }) => '$engine|$source|$target|$pagePath';

  Future<PageTranslationResult?> get(String uid) async {
    final PageTranslationTableData? row =
        await (database.pageTranslationTable.select()..where(
              ($PageTranslationTableTable table) => table.uid.equals(uid),
            ))
            .getSingleOrNull();
    return _decode(row);
  }

  Future<PageTranslationResult?> findOlderVersion({
    required String pagePath,
    required String engine,
    required String source,
    required String target,
  }) async {
    final SimpleSelectStatement<
      $PageTranslationTableTable,
      PageTranslationTableData
    >
    query = database.pageTranslationTable.select()
      ..where(
        ($PageTranslationTableTable table) => _otherVersionsOf(
          table,
          pagePath: pagePath,
          engine: engine,
          source: source,
          target: target,
        ),
      )
      ..orderBy(<OrderClauseGenerator<$PageTranslationTableTable>>[
        ($PageTranslationTableTable table) =>
            OrderingTerm.desc(table.updatedAt),
      ])
      ..limit(1);
    return _decode(await query.getSingleOrNull());
  }

  Future<int> countOutdated() async {
    final Expression<int> rowCount = database.pageTranslationTable.id.count();
    final TypedResult row =
        await (database.pageTranslationTable.selectOnly()
              ..addColumns(<Expression<Object>>[rowCount])
              ..where(_isOutdated(database.pageTranslationTable)))
            .getSingle();
    return row.read(rowCount) ?? 0;
  }

  Future<int> deleteOutdated() {
    return (database.pageTranslationTable.delete()
          ..where(($PageTranslationTableTable table) => _isOutdated(table)))
        .go();
  }

  Expression<bool> _isOutdated($PageTranslationTableTable table) {
    return table.engine
        .like('%${PageTranslationSettings.currentVersionSuffix}')
        .not();
  }

  Expression<bool> _otherVersionsOf(
    $PageTranslationTableTable table, {
    required String pagePath,
    required String engine,
    required String source,
    required String target,
  }) {
    final String family = engine
        .split(PageTranslationSettings.versionMarker)
        .first;
    return table.pagePath.equals(pagePath) &
        table.sourceLanguage.equals(source) &
        table.targetLanguage.equals(target) &
        table.engine.like('$family${PageTranslationSettings.versionMarker}%') &
        table.engine.equals(engine).not();
  }

  PageTranslationResult? _decode(PageTranslationTableData? row) {
    if (row == null) {
      return null;
    }
    try {
      return PageTranslationResult.fromJson(
        jsonDecode(row.resultJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> put({
    required String pagePath,
    required String engine,
    required String source,
    required String target,
    required PageTranslationResult result,
  }) async {
    final String uid = keyFor(
      pagePath: pagePath,
      engine: engine,
      source: source,
      target: target,
    );
    final String json = jsonEncode(result.toJson());
    await database.pageTranslationTable.insert().insert(
      PageTranslationTableCompanion.insert(
        uid: uid,
        pagePath: pagePath,
        engine: engine,
        sourceLanguage: source,
        targetLanguage: target,
        resultJson: json,
      ),
      onConflict: DoUpdate(
        (_) => PageTranslationTableCompanion(
          resultJson: Value<String>(json),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
        target: <Column<Object>>[database.pageTranslationTable.uid],
      ),
    );
    await (database.pageTranslationTable.delete()..where(
          ($PageTranslationTableTable table) => _otherVersionsOf(
            table,
            pagePath: pagePath,
            engine: engine,
            source: source,
            target: target,
          ),
        ))
        .go();
  }

  Future<int> count() async {
    final Expression<int> rowCount = database.pageTranslationTable.id.count();
    final TypedResult row =
        await (database.pageTranslationTable.selectOnly()
              ..addColumns(<Expression<Object>>[rowCount]))
            .getSingle();
    return row.read(rowCount) ?? 0;
  }

  Future<int> clear() => database.pageTranslationTable.delete().go();
}
