import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/extension_preferences/extension_host_services.dart';
import 'package:wakaranai/services/import_export/import_export_task.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/library_updates/library_update_task.dart';
import 'package:wakaranai/utils/webview_user_agent.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask(
    (String taskName, Map<String, dynamic>? inputData) async {
      await _resolveWebViewUserAgent();
      return runBackgroundTask(taskName, inputData);
    },
  );
}

Future<bool> runBackgroundTask(
  String taskName,
  Map<String, dynamic>? inputData, {
  WakaranaiDatabase Function()? openDatabase,
}) async {
  final WakaranaiDatabase database =
      (openDatabase ?? WakaranaiDatabase.new)();
  configureExtensionHost(database);
  try {
    return await _runTask(taskName, inputData, database);
  } finally {
    await database.close();
  }
}

Future<bool> _runTask(
  String taskName,
  Map<String, dynamic>? inputData,
  WakaranaiDatabase database,
) {
  switch (taskName) {
    case importTaskName:
      return runImportTask(inputData, database: database);
    case libraryUpdateTaskName:
      return runLibraryUpdateTask(inputData, database: database);
    default:
      return Future<bool>.value(true);
  }
}

Future<void> _resolveWebViewUserAgent() async {
  try {
    await WebViewUserAgent.resolve();
  } catch (e) {
    logger.w('Failed to resolve the webview user agent: $e');
  }
}
