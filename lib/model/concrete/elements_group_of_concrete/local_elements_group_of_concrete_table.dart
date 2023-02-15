import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';

abstract class LocalElementsGroupOfConcreteTable extends WakaTable {
  TextColumn get title => text()();
  TextColumn get data => text()();
}