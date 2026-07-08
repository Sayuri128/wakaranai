import 'package:wakaranai/services/import_export/import_export_task.dart';
import 'package:wakaranai/services/library_updates/library_update_task.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask(
    (String taskName, Map<String, dynamic>? inputData) async {
      switch (taskName) {
        case importTaskName:
          return runImportTask(inputData);
        case libraryUpdateTaskName:
          return runLibraryUpdateTask(inputData);
        default:
          return true;
      }
    },
  );
}
