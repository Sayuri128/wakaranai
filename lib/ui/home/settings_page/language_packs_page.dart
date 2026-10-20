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
    final bool wifiOnly = context.select(
      (PageTranslationSettingsCubit c) => c.state.wifiOnly,
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<LanguagePacksCubit, LanguagePacksState>(
          builder: (BuildContext context, LanguagePacksState state) {
            final List<PageLanguage> all = PageLanguage.all;
            final List<PageLanguage> downloaded = all
                .where(
                  (PageLanguage l) =>
                      state.statusOf(l) == LanguagePackStatus.downloaded,
                )
                .toList();
            final List<PageLanguage> available = all
                .where(
                  (PageLanguage l) =>
                      state.statusOf(l) != LanguagePackStatus.downloaded,
                )
                .toList();
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
              ),
              children: <Widget>[
                _Header(title: S.current.language_packs_title),
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
                      for (final PageLanguage l in downloaded)
                        _PackTile(language: l, state: state),
                    ],
                  ),
                SettingsSection(
                  title: S.current.language_packs_available_section,
                  tiles: <Widget>[
                    for (final PageLanguage l in available)
                      _PackTile(language: l, state: state),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: Text(title, style: semibold(size: 24))),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.state});

  final LanguagePacksState state;

  @override
  Widget build(BuildContext context) {
    final int current = (state.batchDone + 1).clamp(1, state.batchTotal);
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
                      current,
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
    final LanguagePacksCubit cubit = context.read<LanguagePacksCubit>();
    final LanguagePackStatus status = state.statusOf(language);
    final Widget? action = switch (status) {
      LanguagePackStatus.unknown => null,
      LanguagePackStatus.missing => _PillButton(
        label: S.current.page_translation_settings_download_pack,
        primary: true,
        onTap: () => cubit.enqueue(language),
      ),
      LanguagePackStatus.failed => _PillButton(
        label: S.current.language_packs_retry,
        primary: true,
        onTap: () => cubit.enqueue(language),
      ),
      LanguagePackStatus.queued => _PillButton(
        label: S.current.language_packs_cancel,
        onTap: () => cubit.dequeue(language),
      ),
      LanguagePackStatus.downloading => null,
      LanguagePackStatus.downloaded => _PillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => cubit.delete(language),
      ),
    };
    final String subtitle = switch (status) {
      LanguagePackStatus.unknown => '',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsTile(
          icon: status == LanguagePackStatus.downloaded
              ? Icons.check_circle_rounded
              : Icons.language_rounded,
          title: language.name,
          subtitle: subtitle.isEmpty ? null : subtitle,
          destructive: status == LanguagePackStatus.failed,
          trailing:
              action ??
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
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
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: semibold(
              size: 13,
              color: primary ? AppColors.mainBlack : AppColors.mainWhite,
            ),
          ),
        ),
      ),
    );
  }
}
