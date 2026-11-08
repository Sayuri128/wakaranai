import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/home/settings_page/translation_appearance_section.dart';
import 'package:wakaranai/ui/home/settings_page/translation_engine_section.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_languages_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai/services/page_translation/page_language_names.dart';

class PageTranslationSettingsPage extends StatefulWidget {
  const PageTranslationSettingsPage({super.key});

  @override
  State<PageTranslationSettingsPage> createState() =>
      _PageTranslationSettingsPageState();
}

class _PageTranslationSettingsPageState
    extends State<PageTranslationSettingsPage> {
  int? _cachedPages;
  int? _outdatedPages;

  @override
  void initState() {
    super.initState();
    context.read<LanguagePacksCubit>().refresh();
    _refreshCacheCount();
  }

  Future<void> _refreshCacheCount() async {
    final PageTranslationRepository repository = context
        .read<PageTranslationRepository>();
    final int count = await repository.count();
    final int outdated = await repository.countOutdated();
    if (mounted) {
      setState(() {
        _cachedPages = count;
        _outdatedPages = outdated;
      });
    }
  }

  Future<void> _removeOutdated() async {
    await context.read<PageTranslationRepository>().deleteOutdated();
    await _refreshCacheCount();
  }

  Future<void> _clearCache() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        destructive: true,
        icon: Icons.cleaning_services_rounded,
        title: S.current.page_translation_settings_clear_cache_confirm_title,
        message:
            S.current.page_translation_settings_clear_cache_confirm_message,
        yesText: S.current.page_translation_settings_clear_cache_confirm_ok,
        noText: S.current.page_translation_models_cancel,
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await context.read<PageTranslationRepository>().clear();
    await _refreshCacheCount();
  }

  Future<void> _pickTarget(PageTranslationSettings settings) async {
    final PageLanguage? picked = await showLanguagePicker(
      context,
      title: S.current.page_translation_settings_target,
      options: PageLanguage.targets,
      current: settings.target,
    );
    if (picked != null && mounted) {
      await context.read<PageTranslationSettingsCubit>().setTarget(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            SettingsPageHeader(
              title: S.current.page_translation_settings_title,
            ),
            Expanded(
              child:
                  BlocBuilder<
                    PageTranslationSettingsCubit,
                    PageTranslationSettings
                  >(
                    builder:
                        (
                          BuildContext context,
                          PageTranslationSettings settings,
                        ) {
                          return _buildSettingsList(context, settings);
                        },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    PageTranslationSettings settings,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      children: <Widget>[
        _buildEnableSection(settings),
        if (settings.enabled) ...<Widget>[
          TranslationEngineSection(settings: settings),
          _buildLanguagesSection(settings),
          TranslationAppearanceSection(style: settings.overlay),
          _buildPacksSection(context, settings),
          _buildStorageSection(),
        ],
      ],
    );
  }

  Widget _buildEnableSection(PageTranslationSettings settings) {
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    return SettingsSection(
      title: S.current.page_translation_settings_experimental,
      tiles: <Widget>[
        _buildSwitchTile(
          icon: Icons.translate_rounded,
          title: S.current.page_translation_settings_enable,
          subtitle: S.current.page_translation_settings_enable_subtitle,
          value: settings.enabled,
          onChanged: cubit.setEnabled,
        ),
      ],
    );
  }

  Widget _buildLanguagesSection(PageTranslationSettings settings) {
    return SettingsSection(
      title: S.current.page_translation_settings_languages_section,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.g_translate_rounded,
          title: S.current.page_translation_settings_target,
          subtitle: S.current.page_translation_settings_target_subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                pageLanguageName(settings.target),
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
          onTap: () => _pickTarget(settings),
        ),
      ],
    );
  }

  Widget _buildPacksSection(
    BuildContext context,
    PageTranslationSettings settings,
  ) {
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    final OnDeviceModelState gemma = context.watch<OnDeviceModelCubit>().state;
    final bool translatesWithGemma = usesOnDeviceModel(
      effectiveTranslationSettings(settings, gemma),
    );
    return SettingsSection(
      title: S.current.page_translation_settings_packs_section,
      tiles: <Widget>[
        if (!translatesWithGemma) ...<Widget>[
          _buildPacksTile(context),
          _buildSwitchTile(
            icon: Icons.wifi_rounded,
            title: S.current.page_translation_settings_wifi_only,
            value: settings.wifiOnly,
            onChanged: cubit.setWifiOnly,
          ),
        ],
        SettingsTile(
          icon: Icons.document_scanner_outlined,
          title: S.current.page_translation_settings_ocr_title,
          subtitle: S.current.page_translation_settings_ocr_note,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.mainBlack,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildPacksTile(BuildContext context) {
    return BlocBuilder<LanguagePacksCubit, LanguagePacksState>(
      builder: (BuildContext context, LanguagePacksState packs) {
        return SettingsTile(
          icon: Icons.download_for_offline_outlined,
          title: S.current.language_packs_title,
          subtitle: _packsSubtitle(packs),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mainGrey,
          ),
          onTap: () => Navigator.of(context).pushNamed(Routes.languagePacks),
        );
      },
    );
  }

  String _packsSubtitle(LanguagePacksState packs) {
    if (packs.batchTotal == 0) {
      return S.current.language_packs_downloaded_count(packs.downloadedCount);
    }
    final int currentPack = (packs.batchDone + 1).clamp(1, packs.batchTotal);
    return S.current.language_packs_queue_progress(
      currentPack,
      packs.batchTotal,
    );
  }

  Widget _buildModelsTile() {
    final OnDeviceModelState models = context.watch<OnDeviceModelCubit>().state;
    final int installed = models.installedVariants.length;
    double gigabytes = 0;
    for (final OnDeviceModel model in models.installedVariants) {
      gigabytes += model.sizeBytes / 1e9;
    }
    return SettingsTile(
      icon: Icons.download_done_rounded,
      title: S.current.translation_models_title,
      subtitle: S.current.translation_models_summary(
        installed,
        gigabytes.toStringAsFixed(1),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
      onTap: () => Navigator.of(context).pushNamed(Routes.translationModels),
    );
  }

  Widget _buildStorageSection() {
    final int? cachedPages = _cachedPages;
    final bool hasCachedPages = cachedPages != null && cachedPages > 0;
    final int? outdatedPages = _outdatedPages;
    final bool hasOutdatedPages = outdatedPages != null && outdatedPages > 0;
    return SettingsSection(
      title: S.current.page_translation_settings_storage_section,
      tiles: <Widget>[
        _buildModelsTile(),
        if (hasOutdatedPages)
          SettingsTile(
            icon: Icons.history_toggle_off_rounded,
            title: S.current.page_translation_settings_remove_outdated,
            subtitle: S.current
                .page_translation_settings_remove_outdated_subtitle(
                  outdatedPages,
                ),
            onTap: _removeOutdated,
          ),
        SettingsTile(
          icon: Icons.delete_sweep_outlined,
          title: S.current.page_translation_settings_clear_cache,
          subtitle: cachedPages == null
              ? null
              : S.current.page_translation_settings_clear_cache_subtitle(
                  cachedPages,
                ),
          destructive: true,
          onTap: hasCachedPages ? _clearCache : null,
        ),
      ],
    );
  }
}
