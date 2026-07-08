import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
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
  });

  final ChapterViewCubit chapterViewCubit;
  final ChapterViewInitialized state;

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
          ],
        ),
      ),
    );
  }
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
