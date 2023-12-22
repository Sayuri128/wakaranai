import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';

abstract class LocalConcreteViewTable extends WakaTable {
  TextColumn get uid => text()();
}
