import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

@TableIndex(name: 'page_translation_uid', columns: <Symbol>{#uid}, unique: true)
class PageTranslationTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get pagePath => text()();

  TextColumn get engine => text()();

  TextColumn get sourceLanguage => text()();

  TextColumn get targetLanguage => text()();

  TextColumn get resultJson => text()();
}
