import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:h_reader/blocs/image_cache/image_cache_cubit.dart';
import 'package:h_reader/blocs/settings/settings_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/repositories/settings/settings_repository.dart';
import 'package:h_reader/utils/app_colors.dart';

class SettingsView extends StatefulWidget {
  SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final keys = <KeepCachedImageDay, GlobalKey>{
    KeepCachedImageDay.ONE: GlobalKey(),
    KeepCachedImageDay.WEEK: GlobalKey(),
    KeepCachedImageDay.MONTH: GlobalKey(),
    KeepCachedImageDay.FOREVER: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    context.read<ImageCacheCubit>().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => SettingsCubit()..getSettings())],
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
                        _buildCachingPeriodSettingsTile(settingsState),
                        _buildClearCacheTile(imageCacheState)
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

  SettingsTile _buildCachingPeriodSettingsTile(SettingsLoaded state) {
    return SettingsTile(
      trailing: const Icon(Icons.chevron_left),
      title: S.current.settings_caching_images_title,
      onPressed: (context) {
        showConfirmationDialog(
            context: context,
            title: S.current.settings_caching_period_dialog_title,
            initialSelectedActionKey: keys[state.keepCachedImageDay],
            actions: [
              AlertDialogAction(
                  key: keys[KeepCachedImageDay.ONE],
                  label: S.current.settings_caching_period_one_day),
              AlertDialogAction(
                  key: keys[KeepCachedImageDay.WEEK],
                  label: S.current.settings_caching_period_one_week),
              AlertDialogAction(
                  key: keys[KeepCachedImageDay.MONTH],
                  label: S.current.settings_caching_period_one_month),
              AlertDialogAction(
                  key: keys[KeepCachedImageDay.FOREVER],
                  label: S.current.settings_caching_period_forever),
            ]).then((value) {
          if (value != null) {
            context.read<SettingsCubit>().setStoreCachedImagePeriod(
                keys.entries.singleWhere((element) => element.value == value).key);
          }
        });
      },
    );
  }
}
