import 'package:drift/drift.dart';
import 'package:wakaranai/model/waka_table.dart';

@DataClassName("DriftLocalProtectorConfig")
class LocalProtectorConfigTable extends WakaTable {

  TextColumn get pingUrl => text()();

  BoolColumn get needToLogin => boolean()();

  BoolColumn get inAppBrowserInterceptor => boolean()();

}
