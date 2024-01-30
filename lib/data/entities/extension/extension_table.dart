import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

class ExtensionTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get name => text()();

  TextColumn get type => text()();

  IntColumn get version => integer()();

  TextColumn get logoUrl => text()();

  TextColumn get language => text()();

  BoolColumn get nsfw => boolean()();

  TextColumn get sourceCode => text()();

  BoolColumn get searchAvailable => boolean()();

  TextColumn get protectorConfig => text().nullable()();
}
