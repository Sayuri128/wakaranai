import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/novel_reader_preferences/novel_reader_preferences_cubit.dart';
import 'package:wakaranai/blocs/reader_preferences/reader_preferences_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/novel_reader_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_theme.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showNovelReaderSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => const NovelReaderSettingsSheet(),
  );
}

class NovelReaderSettingsSheet extends StatelessWidget {
  const NovelReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _DragHandle(),
            Text(S.current.novel_reader_settings_title,
                style: semibold(size: 18)),
            const SizedBox(height: 16),
            BlocBuilder<NovelReaderPreferencesCubit, NovelReaderPreferences>(
              builder: (BuildContext context, NovelReaderPreferences value) =>
                  _buildTextRows(
                context,
                context.read<NovelReaderPreferencesCubit>(),
                value,
              ),
            ),
            BlocBuilder<ReaderPreferencesCubit, ReaderPreferences>(
              builder: (BuildContext context, ReaderPreferences value) =>
                  _buildVolumeKeyRows(
                context.read<ReaderPreferencesCubit>(),
                value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRows(
    BuildContext context,
    NovelReaderPreferencesCubit cubit,
    NovelReaderPreferences preferences,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StepperRow(
          label: S.current.novel_reader_font_size,
          value: preferences.fontSize.round().toString(),
          onDecrease: () => cubit.changeFontSize(-1),
          onIncrease: () => cubit.changeFontSize(1),
        ),
        const SizedBox(height: 10),
        _StepperRow(
          label: S.current.novel_reader_line_height,
          value: preferences.lineHeight.toStringAsFixed(1),
          onDecrease: () => cubit.changeLineHeight(-1),
          onIncrease: () => cubit.changeLineHeight(1),
        ),
        const SizedBox(height: 10),
        _StepperRow(
          label: S.current.novel_reader_margins,
          value: preferences.horizontalMargin.round().toString(),
          onDecrease: () => cubit.changeMargin(-1),
          onIncrease: () => cubit.changeMargin(1),
        ),
        const SizedBox(height: 20),
        Text(S.current.novel_reader_font_family, style: semibold(size: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final NovelReaderFont font in NovelReaderFont.values)
              _OptionChip(
                label: novelReaderFontLabel(font),
                selected: font == preferences.font,
                onTap: () => cubit.setFont(font),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(S.current.reader_background_title, style: semibold(size: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final NovelReaderBackground background
                in NovelReaderBackground.values)
              _OptionChip(
                label: novelReaderBackgroundLabel(background),
                selected: background == preferences.background,
                swatch: NovelReaderColors.of(background).background,
                onTap: () => cubit.setBackground(background),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _SwitchRow(
          label: S.current.novel_reader_justify,
          value: preferences.justify,
          onChanged: cubit.setJustify,
        ),
        const SizedBox(height: 10),
        _SwitchRow(
          label: S.current.novel_reader_keep_screen_on,
          value: preferences.keepScreenOn,
          onChanged: cubit.setKeepScreenOn,
        ),
      ],
    );
  }

  Widget _buildVolumeKeyRows(
    ReaderPreferencesCubit cubit,
    ReaderPreferences preferences,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 10),
        _SwitchRow(
          label: S.current.reader_volume_keys_title,
          value: preferences.volumeKeys,
          onChanged: cubit.setVolumeKeys,
        ),
        if (preferences.volumeKeys) ...<Widget>[
          const SizedBox(height: 10),
          _SwitchRow(
            label: S.current.reader_volume_keys_invert_title,
            value: preferences.invertVolumeKeys,
            onChanged: cubit.setInvertVolumeKeys,
          ),
        ],
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: medium(size: 15))),
            _StepButton(icon: Icons.remove_rounded, onTap: onDecrease),
            SizedBox(
              width: 48,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: semibold(size: 15),
              ),
            ),
            _StepButton(icon: Icons.add_rounded, onTap: onIncrease),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: AppColors.mainWhite),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    final Color? swatch = this.swatch;
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
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
                Icon(Icons.check_rounded, size: 16, color: AppColors.mainBlack),
                const SizedBox(width: 6),
              ],
              if (swatch != null) ...<Widget>[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.overlay(0.3)),
                  ),
                ),
                const SizedBox(width: 8),
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
              Expanded(child: Text(label, style: medium(size: 15))),
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
