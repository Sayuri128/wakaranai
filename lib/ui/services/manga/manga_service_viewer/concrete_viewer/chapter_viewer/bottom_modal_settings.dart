import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BottomModalSettings extends StatefulWidget {
  const BottomModalSettings({
    super.key,
    required this.chapterViewCubit,
    required this.state,
    this.translationLanguages,
    this.onEditTranslationLanguages,
    this.onTranslateWholeChapter,
    this.onEditGlossary,
  });

  final ChapterViewCubit chapterViewCubit;
  final ChapterViewInitialized state;
  final TitleLanguages? translationLanguages;
  final VoidCallback? onEditTranslationLanguages;
  final VoidCallback? onTranslateWholeChapter;
  final VoidCallback? onEditGlossary;

  @override
  State<BottomModalSettings> createState() => _BottomModalSettingsState();
}

class _BottomModalSettingsState extends State<BottomModalSettings> {
  late bool _enableTapControlsState;
  late ChapterViewMode _mode;

  @override
  void initState() {
    super.initState();
    _enableTapControlsState = widget.state.controlsEnabled;
    _mode = widget.state.mode;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.overlay(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              S.current
                  .chapter_viewer_bottom_modal_settings_reading_mode_title,
              style: semibold(size: 18),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final ChapterViewMode mode in ChapterViewMode.values)
                  _ModeChip(
                    label: chapterViewModelToString(mode),
                    selected: mode == _mode,
                    onTap: () {
                      widget.chapterViewCubit.onModeChanged(mode);
                      setState(() => _mode = mode);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _SwitchRow(
              label:
                  S.current.chapter_viewer_bottom_modal_settings_tap_controls,
              value: _enableTapControlsState,
              onChanged: (bool newValue) {
                widget.chapterViewCubit.onSetControls(newValue);
                setState(() => _enableTapControlsState = newValue);
              },
            ),
            ..._buildTranslationRows(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTranslationRows(BuildContext context) {
    final TitleLanguages? languages = widget.translationLanguages;
    final VoidCallback? editLanguages = widget.onEditTranslationLanguages;
    if (languages == null || editLanguages == null) {
      return const <Widget>[];
    }

    void closeThen(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    final VoidCallback? translateWholeChapter = widget.onTranslateWholeChapter;
    final VoidCallback? editGlossary = widget.onEditGlossary;
    return <Widget>[
      const SizedBox(height: 10),
      _ValueRow(
        label: S.current.page_translation_languages_title,
        value: '${languages.source.name} → ${languages.target.name}',
        onTap: () => closeThen(editLanguages),
      ),
      if (editGlossary != null) ...<Widget>[
        const SizedBox(height: 10),
        _ValueRow(
          icon: Icons.badge_outlined,
          label: S.current.page_translation_glossary_title,
          value: _glossarySummary(languages),
          onTap: () => closeThen(editGlossary),
        ),
      ],
      if (translateWholeChapter != null) ...<Widget>[
        const SizedBox(height: 10),
        _ValueRow(
          icon: Icons.auto_stories_rounded,
          label: S.current.page_translation_translate_chapter,
          value: S.current.page_translation_translate_chapter_hint,
          onTap: () => closeThen(translateWholeChapter),
        ),
      ],
    ];
  }
}

String _glossarySummary(TitleLanguages languages) {
  final int count = languages.glossary.length;
  if (count == 0) {
    return S.current.page_translation_glossary_empty;
  }
  return S.current.page_translation_glossary_count(count);
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) ...<Widget>[
                Icon(Icons.check_rounded,
                    size: 16, color: AppColors.mainBlack),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: semibold(
                  size: 14,
                  color: selected ? AppColors.mainBlack : AppColors.mainWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    this.icon = Icons.translate_rounded,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: medium(size: 15)),
                    if (value.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: regular(size: 13, color: AppColors.mainGrey),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: medium(size: 15)),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.mainBlack,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.mainWhite,
                inactiveTrackColor: AppColors.overlay(0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
