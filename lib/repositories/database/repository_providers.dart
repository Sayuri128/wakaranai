import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/repositories/database/tracker_link_repository.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';

Widget repositoryProviders(
  BuildContext context, {
  required Widget child,
  WakaranaiDatabase? database,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<WakaranaiDatabase>(
        create: (context) {
          final db = database ?? WakaranaiDatabase();

          // Use migrator here to modify tables
          // without changing the version
          // when working in debug mode

          // final migrator = Migrator(db);
          // migrator.createTable(db.animeEpisodeActivityTable);

          return db;
        },
        lazy: false,
      ),
      RepositoryProvider(
        create: (context) => ChapterActivityRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => ExtensionRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => ExtensionSourceRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => ConcreteDataRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => AnimeEpisodeActivityRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => CategoryRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => LibraryEntryRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => DownloadRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => LibraryUpdateRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => PageTranslationRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => TrackerLinkRepository(
          database: context.read<WakaranaiDatabase>(),
        ),
      ),
      RepositoryProvider(
        create: (context) => TrackerSyncService.fromEnv(
          links: context.read<TrackerLinkRepository>(),
        ),
      ),
    ],
    child: child,
  );
}
