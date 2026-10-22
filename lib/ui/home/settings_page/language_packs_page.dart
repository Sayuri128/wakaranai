import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LanguagePacksPage extends StatefulWidget {
  const LanguagePacksPage({super.key});

  @override
  State<LanguagePacksPage> createState() => _LanguagePacksPageState();
}

class _LanguagePacksPageState extends State<LanguagePacksPage> {
  @override
  void initState() {
    super.initState();
    context.read<LanguagePacksCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            SettingsPageHeader(title: S.current.language_packs_title),
            Expanded(
              child: BlocBuilder<LanguagePacksCubit, LanguagePacksState>(
                builder: (BuildContext context, LanguagePacksState state) {
                  return _buildPackList(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackList(BuildContext context, LanguagePacksState state) {
    final bool wifiOnly = context.select(
      (PageTranslationSettingsCubit cubit) => cubit.state.wifiOnly,
    );
    final List<PageLanguage> downloaded = <PageLanguage>[];
    final List<PageLanguage> available = <PageLanguage>[];
    for (final PageLanguage language in PageLanguage.all) {
      if (state.statusOf(language) == LanguagePackStatus.downloaded) {
        downloaded.add(language);
      } else {
        available.add(language);
      }
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      children: <Widget>[
        if (state.batchTotal > 0) _QueueCard(state: state),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            wifiOnly
                ? S.current.language_packs_hint_wifi
                : S.current.language_packs_hint,
            style: regular(size: 13, color: AppColors.mainGrey),
          ),
        ),
        if (downloaded.isNotEmpty)
          SettingsSection(
            title: S.current.language_packs_downloaded_section,
            tiles: <Widget>[
              for (final PageLanguage language in downloaded)
                _PackTile(language: language, state: state),
            ],
          ),
        SettingsSection(
          title: S.current.language_packs_available_section,
          tiles: <Widget>[
            for (final PageLanguage language in available)
              _PackTile(language: language, state: state),
          ],
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.state});

  final LanguagePacksState state;

  @override
  Widget build(BuildContext context) {
    final int currentPack = (state.batchDone + 1).clamp(1, state.batchTotal);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.download_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    S.current.language_packs_queue_progress(
                      currentPack,
                      state.batchTotal,
                    ),
                    style: semibold(size: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: state.batchDone / state.batchTotal,
                color: AppColors.primary,
                backgroundColor: AppColors.overlay(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({required this.language, required this.state});

  final PageLanguage language;
  final LanguagePacksState state;

  @override
  Widget build(BuildContext context) {
    final LanguagePackStatus status = state.statusOf(language);
    final String? subtitle = _subtitle(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsTile(
          icon: status == LanguagePackStatus.downloaded
              ? Icons.check_circle_rounded
              : Icons.language_rounded,
          title: language.name,
          subtitle: subtitle,
          destructive: status == LanguagePackStatus.failed,
          trailing: _buildAction(context, status),
        ),
        if (status == LanguagePackStatus.downloading)
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 4,
                color: AppColors.primary,
                backgroundColor: AppColors.overlay(0.08),
              ),
            ),
          ),
      ],
    );
  }

  String? _subtitle(LanguagePackStatus status) {
    return switch (status) {
      LanguagePackStatus.unknown => null,
      LanguagePackStatus.missing =>
        S.current.page_translation_settings_pack_missing,
      LanguagePackStatus.failed => S.current.language_packs_failed,
      LanguagePackStatus.queued => S.current.language_packs_queued(
        state.queuePosition(language),
      ),
      LanguagePackStatus.downloading =>
        S.current.page_translation_models_downloading,
      LanguagePackStatus.downloaded =>
        S.current.page_translation_settings_pack_downloaded,
    };
  }

  Widget _buildAction(BuildContext context, LanguagePackStatus status) {
    final LanguagePacksCubit cubit = context.read<LanguagePacksCubit>();
    return switch (status) {
      LanguagePackStatus.unknown || LanguagePackStatus.downloading => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
      LanguagePackStatus.missing => SettingsPillButton(
        label: S.current.page_translation_settings_download_pack,
        primary: true,
        onTap: () => cubit.enqueue(language),
      ),
      LanguagePackStatus.failed => SettingsPillButton(
        label: S.current.language_packs_retry,
        primary: true,
        onTap: () => cubit.enqueue(language),
      ),
      LanguagePackStatus.queued => SettingsPillButton(
        label: S.current.language_packs_cancel,
        onTap: () => cubit.dequeue(language),
      ),
      LanguagePackStatus.downloaded => SettingsPillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => cubit.delete(language),
      ),
    };
  }
}
