import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';

Widget repositoryProviders(BuildContext context, {required Widget child}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<WakaranaiDatabase>(
        create: (context) {
          final db = WakaranaiDatabase();

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
      )
    ],
    child: child,
  );
}
