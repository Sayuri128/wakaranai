import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';

abstract class LocalElementOfElementsGroupOfConcreteTable extends WakaTable {
  TextColumn get uid => text()();
  TextColumn get title => text()();
  TextColumn get data => text()();
}