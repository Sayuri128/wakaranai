import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class NativePlayerSpeedSheet extends StatefulWidget {
  const NativePlayerSpeedSheet({
    super.key,
    required this.initialSpeed,
    required this.onSelected,
  });

  final double initialSpeed;
  final ValueChanged<double> onSelected;

  @override
  State<NativePlayerSpeedSheet> createState() => _NativePlayerSpeedSheetState();
}

class _NativePlayerSpeedSheetState extends State<NativePlayerSpeedSheet> {
  late double _speed = normalizePlaybackSpeed(widget.initialSpeed);

  int get _sliderDivisions =>
      ((kMaxPlaybackSpeed - kMinPlaybackSpeed) / kPlaybackSpeedStep).round();

  void _selectPreset(double speed) {
    setState(() {
      _speed = speed;
    });
    widget.onSelected(speed);
    Navigator.of(context).pop();
  }

  void _resetToNormal() {
    _selectPreset(1.0);
  }

  void _handleSliderChanged(double value) {
    setState(() {
      _speed = normalizePlaybackSpeed(value);
    });
  }

  void _handleSliderChangeEnd(double value) {
    final double speed = normalizePlaybackSpeed(value);
    setState(() {
      _speed = speed;
    });
    widget.onSelected(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPresets(),
          const SizedBox(height: 16),
          _buildSliderHeader(context),
          _buildSlider(context),
        ],
      ),
    );
  }

  Widget _buildPresets() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final double preset in kNativePlayerSpeeds) _buildPresetChip(preset),
      ],
    );
  }

  Widget _buildPresetChip(double preset) {
    final bool selected = preset == _speed;
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.16)
          : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => _selectPreset(preset),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            playbackSpeedLabel(preset),
            style: medium(
              size: 14,
              color: selected ? AppColors.primary : AppColors.mainWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            speedMultiplierLabel(_speed),
            style: semibold(size: 16, color: AppColors.mainWhite),
          ),
        ),
        TextButton(
          onPressed: _speed == 1.0 ? null : _resetToNormal,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(S.of(context).native_player_speed_normal),
        ),
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.overlay(0.12),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.16),
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      child: Slider(
        value: _speed,
        min: kMinPlaybackSpeed,
        max: kMaxPlaybackSpeed,
        divisions: _sliderDivisions,
        onChanged: _handleSliderChanged,
        onChangeEnd: _handleSliderChangeEnd,
      ),
    );
  }
}
