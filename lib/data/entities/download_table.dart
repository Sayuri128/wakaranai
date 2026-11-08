import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';
import 'package:wakaranai/data/entities/concrete_data_table.dart';

enum DownloadStatus { queued, downloading, done, failed, paused }

enum DownloadKind { chapter, episode, novelChapter }

@TableIndex(name: 'download_uid', columns: <Symbol>{#uid}, unique: true)
class DownloadTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get extensionUid => text()();

  TextColumn get concreteUid => text()();

  IntColumn get concreteId => integer().references(ConcreteDataTable, #id)();

  TextColumn get concreteTitle => text()();

  TextColumn get concreteCover => text().nullable()();

  TextColumn get title => text()();

  IntColumn get status => intEnum<DownloadStatus>()();

  IntColumn get downloadedPages => integer().withDefault(const Constant(0))();

  IntColumn get totalPages => integer().withDefault(const Constant(0))();

  TextColumn get dirPath => text()();

  TextColumn get headers => text().nullable()();

  TextColumn get data => text().nullable()();

  IntColumn get kind =>
      intEnum<DownloadKind>().withDefault(const Constant(0))();

  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();

  IntColumn get totalBytes => integer().withDefault(const Constant(0))();

  TextColumn get playback => text().nullable()();

  IntColumn get queuePosition => integer().withDefault(const Constant(0))();
}
