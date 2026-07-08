import 'package:drift/drift.dart';
import 'package:wakaranai/data/entities/base_table.dart';

enum UpdateMediaType { manga, anime }

class LibraryUpdateTable extends BaseTable {
  TextColumn get uid => text()();

  TextColumn get libraryEntryUid => text()();

  TextColumn get extensionUid => text()();

  TextColumn get title => text()();

  TextColumn get concreteTitle => text()();

  TextColumn get concreteCover => text().nullable()();

  IntColumn get mediaType => intEnum<UpdateMediaType>()();

  TextColumn get data => text().nullable()();

  BoolColumn get seen => boolean().withDefault(const Constant(false))();
}
