import 'package:drift/drift.dart';

abstract class LocalGalleryViewTable extends Table {
  IntColumn get id => integer().autoIncrement()();
}