import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:h_reader/blocs/nhentai/cache/image/image_cache_cubit.dart';
import 'package:h_reader/blocs/settings/settings_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/utils/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    context.read<ImageCacheCubit>().getAll();
    super.initState();
  }

  bool syncInProgress = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                SettingsCubit(imageCacheCubit: context.read<ImageCacheCubit>())..getSettings()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ImageCacheCubit, ImageCacheState>(listener: (context, state) {
            if (state is ImageCacheSyncCompleted) {
              showOkAlertDialog(
                  context: context,
                  message: S.current.settings_cache_sync_complete_message(state.count));
            }
          })
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is SettingsLoaded) {
              return BlocBuilder<ImageCacheCubit, ImageCacheState>(
                builder: (context, imageCacheState) => Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: SettingsList(
                    physics: const BouncingScrollPhysics(),
                    darkBackgroundColor: AppColors.backgroundColor,
                    sections: [
                      SettingsSection(
                        title: S.current.settings_caching_section_title,
                        tiles: [
                          _buildClearCacheTile(imageCacheState),
                          _buildSyncDbTile(imageCacheState)
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  SettingsTile _buildSyncDbTile(ImageCacheState imageCacheState) {
    return SettingsTile(
      title: imageCacheState is ImageCacheSyncProgress
          ? S.current.settings_cache_sync_title_progress(
              (imageCacheState.percentage * 100).toStringAsFixed(0))
          : S.current.settings_cache_sync_title,
      onPressed: (context) {
        if (imageCacheState is! ImageCacheSyncProgress) {
          context.read<ImageCacheCubit>().syncDbAndCache();
        }
      },
    );
  }

  SettingsTile _buildClearCacheTile(ImageCacheState state) {
    return SettingsTile(
      title: S.current
          .settings_cache_clear_title(state is ImageCacheReceivedAll ? state.data.length : 0),
      onPressed: (context) {
        showOkCancelAlertDialog(
                context: context, title: S.current.settings_cache_clear_dialog_title)
            .then((value) {
          switch (value) {
            case OkCancelResult.ok:
              context.read<SettingsCubit>().clearCache();
              break;
            case OkCancelResult.cancel:
              break;
          }
        });
      },
    );
  }
}
