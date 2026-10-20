import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';

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
