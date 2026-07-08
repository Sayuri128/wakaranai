import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/widgets.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/library_updates/library_update_notification_service.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:workmanager/workmanager.dart';

const String libraryUpdateTaskName = 'wakaranai.library_update';
const String libraryUpdateTaskUniqueName = 'wakaranai.library_update.periodic';

const String libraryUpdateTaskLocaleKey = 'locale';

Future<void> registerLibraryUpdateTask({
  required int frequencyHours,
  required String localeName,
}) async {
  await Workmanager().registerPeriodicTask(
    libraryUpdateTaskUniqueName,
    libraryUpdateTaskName,
    frequency: Duration(hours: frequencyHours),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    constraints: Constraints(networkType: NetworkType.connected),
    inputData: <String, dynamic>{
      libraryUpdateTaskLocaleKey: localeName,
    },
  );
}

Future<void> cancelLibraryUpdateTask() async {
  await Workmanager().cancelByUniqueName(libraryUpdateTaskUniqueName);
}

Future<bool> runLibraryUpdateTask(Map<String, dynamic>? inputData) async {
  DartPluginRegistrant.ensureInitialized();

  final String localeName =
      inputData?[libraryUpdateTaskLocaleKey] as String? ?? 'en';

  await S.load(Locale(localeName));

  WakaranaiDatabase? database;

  try {
    final SettingsService settings = SettingsService();
    if (!await settings.getCheckUpdates()) return true;

    database = WakaranaiDatabase();

    final LibraryUpdateService service = LibraryUpdateService(
      libraryEntryRepository: LibraryEntryRepository(database: database),
      libraryUpdateRepository: LibraryUpdateRepository(database: database),
      concreteDataRepository: ConcreteDataRepository(database: database),
      extensionRepository: ExtensionRepository(database: database),
    );

    final LibraryUpdateCheckResult result = await service.check();

    if (result.notifiable.isNotEmpty &&
        await settings.getUpdateNotifications(reload: true)) {
      await LibraryUpdateNotificationService().showUpdates(result.notifiable);
    }

    logger.i(
      'Library update check: ${result.updates.length} new, '
      '${result.checked} checked, ${result.failed} failed',
    );

    return true;
  } catch (e, s) {
    logger.e(e);
    logger.e(s);
    return false;
  } finally {
    await database?.close();
  }
}
