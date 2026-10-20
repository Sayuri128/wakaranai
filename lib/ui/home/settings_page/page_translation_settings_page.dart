import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_languages_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class PageTranslationSettingsPage extends StatefulWidget {
  const PageTranslationSettingsPage({super.key});

  @override
  State<PageTranslationSettingsPage> createState() =>
      _PageTranslationSettingsPageState();
}

class _PageTranslationSettingsPageState
    extends State<PageTranslationSettingsPage> {
  int? _cachedPages;

  @override
  void initState() {
    super.initState();
    context.read<LanguagePacksCubit>().refresh();
    _refreshCacheCount();
  }

  Future<void> _refreshCacheCount() async {
    final int count = await context.read<PageTranslationRepository>().count();
    if (mounted) setState(() => _cachedPages = count);
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
    if (confirmed != true || !mounted) return;
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
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child:
            BlocBuilder<PageTranslationSettingsCubit, PageTranslationSettings>(
              builder:
                  (BuildContext context, PageTranslationSettings settings) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      children: <Widget>[
                        _buildHeader(context),
                        SettingsSection(
                          title:
                              S.current.page_translation_settings_experimental,
                          tiles: <Widget>[
                            SettingsTile(
                              icon: Icons.translate_rounded,
                              title: S.current.page_translation_settings_enable,
                              subtitle: S
                                  .current
                                  .page_translation_settings_enable_subtitle,
                              trailing: Switch(
                                value: settings.enabled,
                                activeThumbColor: AppColors.mainBlack,
                                activeTrackColor: AppColors.primary,
                                onChanged: cubit.setEnabled,
                              ),
                              onTap: () => cubit.setEnabled(!settings.enabled),
                            ),
                          ],
                        ),
                        if (settings.enabled) ...<Widget>[
                          SettingsSection(
                            title: S
                                .current
                                .page_translation_settings_languages_section,
                            tiles: <Widget>[
                              SettingsTile(
                                icon: Icons.g_translate_rounded,
                                title:
                                    S.current.page_translation_settings_target,
                                subtitle: S
                                    .current
                                    .page_translation_settings_target_subtitle,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      settings.target.name,
                                      style: medium(
                                        size: 13,
                                        color: AppColors.mainGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.mainGrey,
                                    ),
                                  ],
                                ),
                                onTap: () => _pickTarget(settings),
                              ),
                            ],
                          ),
                          SettingsSection(
                            title: S
                                .current
                                .page_translation_settings_packs_section,
                            tiles: <Widget>[
                              _buildPacksTile(context),
                              SettingsTile(
                                icon: Icons.wifi_rounded,
                                title: S
                                    .current
                                    .page_translation_settings_wifi_only,
                                trailing: Switch(
                                  value: settings.wifiOnly,
                                  activeThumbColor: AppColors.mainBlack,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: cubit.setWifiOnly,
                                ),
                                onTap: () =>
                                    cubit.setWifiOnly(!settings.wifiOnly),
                              ),
                              SettingsTile(
                                icon: Icons.document_scanner_outlined,
                                title: S
                                    .current
                                    .page_translation_settings_ocr_title,
                                subtitle: S
                                    .current
                                    .page_translation_settings_ocr_note,
                              ),
                            ],
                          ),
                          _buildStorageSection(),
                        ],
                      ],
                    );
                  },
            ),
      ),
    );
  }

  Widget _buildPacksTile(BuildContext context) {
    return BlocBuilder<LanguagePacksCubit, LanguagePacksState>(
      builder: (BuildContext context, LanguagePacksState packs) {
        final String subtitle = packs.batchTotal > 0
            ? S.current.language_packs_queue_progress(
                (packs.batchDone + 1).clamp(1, packs.batchTotal),
                packs.batchTotal,
              )
            : S.current.language_packs_downloaded_count(packs.downloadedCount);
        return SettingsTile(
          icon: Icons.download_for_offline_outlined,
          title: S.current.language_packs_title,
          subtitle: subtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mainGrey,
          ),
          onTap: () => Navigator.of(context).pushNamed(Routes.languagePacks),
        );
      },
    );
  }

  Widget _buildStorageSection() {
    final int? count = _cachedPages;
    return SettingsSection(
      title: S.current.page_translation_settings_storage_section,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.delete_sweep_outlined,
          title: S.current.page_translation_settings_clear_cache,
          subtitle: count == null
              ? null
              : S.current.page_translation_settings_clear_cache_subtitle(count),
          destructive: true,
          onTap: count == null || count == 0 ? null : _clearCache,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: <Widget>[
          Material(
            color: AppColors.overlay(0.06),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AppColors.mainWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              S.current.page_translation_settings_title,
              style: semibold(size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
