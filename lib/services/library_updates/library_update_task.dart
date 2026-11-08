import 'dart:ui' show DartPluginRegistrant;

import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/repositories/shared_pref/source_attention_preferences.dart';
import 'package:wakaranai/services/app_language/background_strings.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/library_updates/library_update_notification_service.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:workmanager/workmanager.dart';

const String libraryUpdateTaskName = 'wakaranai.library_update';
const String libraryUpdateTaskUniqueName = 'wakaranai.library_update.periodic';

const String libraryUpdateTaskLocaleKey = 'locale';
const String libraryUpdateTaskConfigsOrgKey = 'configsOrg';
const String libraryUpdateTaskConfigsRepoKey = 'configsRepo';

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
      libraryUpdateTaskConfigsOrgKey: Env.configsSourceOrg,
      libraryUpdateTaskConfigsRepoKey: Env.configsSourceRepo,
    },
  );
}

Future<void> cancelLibraryUpdateTask() async {
  await Workmanager().cancelByUniqueName(libraryUpdateTaskUniqueName);
}

Future<bool> runLibraryUpdateTask(
  Map<String, dynamic>? inputData, {
  WakaranaiDatabase? database,
}) async {
  DartPluginRegistrant.ensureInitialized();

  await loadBackgroundStrings(
    fallbackLocaleName: inputData?[libraryUpdateTaskLocaleKey] as String?,
  );

  WakaranaiDatabase? ownedDatabase;

  try {
    final SettingsService settings = SettingsService();
    if (!await settings.getCheckUpdates()) return true;

    final WakaranaiDatabase taskDatabase =
        database ?? (ownedDatabase = WakaranaiDatabase());

    try {
      await ExtensionResolver(
        extensionRepository: ExtensionRepository(database: taskDatabase),
        extensionSourceRepository:
            ExtensionSourceRepository(database: taskDatabase),
        officialOrg: inputData?[libraryUpdateTaskConfigsOrgKey] as String?,
        officialRepo: inputData?[libraryUpdateTaskConfigsRepoKey] as String?,
      ).refreshOutdated();
    } catch (e) {
      logger.w('Extension update check failed: $e');
    }

    final LibraryUpdateService service = LibraryUpdateService(
      libraryEntryRepository: LibraryEntryRepository(database: taskDatabase),
      libraryUpdateRepository: LibraryUpdateRepository(database: taskDatabase),
      concreteDataRepository: ConcreteDataRepository(database: taskDatabase),
      extensionRepository: ExtensionRepository(database: taskDatabase),
    );

    final LibraryUpdateCheckResult result = await service.check();

    final bool notificationsEnabled =
        await settings.getUpdateNotifications(reload: true);
    final LibraryUpdateNotificationService notifications =
        LibraryUpdateNotificationService();

    if (result.notifiable.isNotEmpty && notificationsEnabled) {
      await notifications.showUpdates(result.notifiable);
    }

    if (result.needsAttention.isNotEmpty && notificationsEnabled) {
      await _notifySourceAttention(result.needsAttention, notifications);
    }

    logger.i(
      'Library update check: ${result.updates.length} new, '
      '${result.checked} checked, ${result.failed} failed, '
      '${result.skipped} skipped, '
      '${result.removedFromSource.length} removed from their source, '
      '${result.needsAttention.length} sources need attention',
    );

    return true;
  } catch (e, s) {
    logger.e(e);
    logger.e(s);
    return false;
  } finally {
    await ownedDatabase?.close();
  }
}

Future<void> _notifySourceAttention(
  List<SourceNeedsAttention> attentions,
  LibraryUpdateNotificationService notifications,
) async {
  final SourceAttentionPreferences preferences = SourceAttentionPreferences();
  final DateTime now = DateTime.now();
  final List<SourceNeedsAttention> due =
      await preferences.dueForNotification(attentions, now);
  if (due.isEmpty) {
    return;
  }
  await notifications.showSourceAttention(due);
  await preferences.markNotified(due, now);
}
