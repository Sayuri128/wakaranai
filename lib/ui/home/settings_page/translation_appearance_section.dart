import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_typesetter.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const double _previewWidth = 320;
const double _previewHeight = 140;
const Rect _bubbleArea = Rect.fromLTWH(14, 14, 168, 112);
const Rect _artworkArea = Rect.fromLTWH(196, 14, 110, 112);

class TranslationAppearanceSection extends StatelessWidget {
  const TranslationAppearanceSection({super.key, required this.style});

  final TranslationOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    return SettingsSection(
      title: S.current.page_translation_appearance_section,
      tiles: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: _AppearancePreview(style: style),
        ),
        _ChoiceRow<TranslationTextSize>(
          label: S.current.page_translation_text_size,
          options: TranslationTextSize.values,
          selected: style.textSize,
          labelOf: _textSizeLabel,
          onSelected: (TranslationTextSize size) =>
              cubit.setOverlay(style.copyWith(textSize: size)),
        ),
        _ChoiceRow<TranslationFont>(
          label: S.current.page_translation_font,
          options: TranslationFont.values,
          selected: style.font,
          labelOf: _fontLabel,
          onSelected: (TranslationFont font) =>
              cubit.setOverlay(style.copyWith(font: font)),
        ),
        _LabelOpacityRow(
          opacity: style.labelOpacity,
          onChanged: (double opacity) =>
              cubit.setOverlay(style.copyWith(labelOpacity: opacity)),
        ),
      ],
    );
  }

  static String _textSizeLabel(TranslationTextSize size) {
    return switch (size) {
      TranslationTextSize.small => S.current.page_translation_text_size_small,
      TranslationTextSize.normal => S.current.page_translation_text_size_normal,
      TranslationTextSize.large => S.current.page_translation_text_size_large,
    };
  }

  static String _fontLabel(TranslationFont font) {
    return switch (font) {
      TranslationFont.system => S.current.page_translation_font_system,
      TranslationFont.comic => S.current.page_translation_font_comic,
    };
  }
}

class _AppearancePreview extends StatelessWidget {
  const _AppearancePreview({required this.style});

  final TranslationOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    final PageTranslationResult sample = PageTranslationResult(
      width: _previewWidth.toInt(),
      height: _previewHeight.toInt(),
      bubbles: <TranslatedBubble>[
        TranslatedBubble(
          textBox: _bubbleArea.deflate(30),
          layoutBox: _bubbleArea.deflate(16),
          fillColor: 0xFFFFFFFF,
          erase: true,
          source: '',
          translation: S.current.page_translation_preview_bubble,
        ),
        TranslatedBubble(
          textBox: _artworkArea.deflate(20),
          layoutBox: _artworkArea.deflate(12),
          fillColor: 0xFF000000,
          erase: false,
          source: '',
          translation: S.current.page_translation_preview_label,
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _previewWidth / _previewHeight,
        child: CustomPaint(
          painter: _SamplePagePainter(),
          foregroundPainter: TranslationOverlayPainter(
            result: sample,
            hidden: const <int>{},
            style: style,
          ),
        ),
      ),
    );
  }
}

class _SamplePagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _previewWidth;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8E8E8),
    );
    final Rect bubble = scaleRect(_bubbleArea, scale, scale);
    canvas.drawOval(bubble, Paint()..color = Colors.white);
    canvas.drawOval(
      bubble,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );
    final Rect artwork = scaleRect(_artworkArea, scale, scale);
    canvas.drawRect(artwork, Paint()..color = const Color(0xFF4A4A4A));
    final Paint hatch = Paint()
      ..color = const Color(0xFF6A6A6A)
      ..strokeWidth = 3 * scale;
    for (double x = artwork.left; x < artwork.right; x += 12 * scale) {
      canvas.drawLine(
        Offset(x, artwork.top),
        Offset(x + 30 * scale, artwork.bottom),
        hatch,
      );
    }
  }

  @override
  bool shouldRepaint(_SamplePagePainter oldDelegate) => false;
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: medium(size: 14)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (final T option in options) ...<Widget>[
                Expanded(child: _buildChip(option)),
                if (option != options.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(T option) {
    final bool isSelected = option == selected;
    return Material(
      color: isSelected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelected(option),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              labelOf(option),
              style: medium(
                size: 13,
                color: isSelected ? AppColors.mainBlack : AppColors.mainWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelOpacityRow extends StatelessWidget {
  const _LabelOpacityRow({required this.opacity, required this.onChanged});

  final double opacity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final int percent = (opacity * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  S.current.page_translation_label_background,
                  style: medium(size: 14),
                ),
              ),
              Text(
                '$percent%',
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            S.current.page_translation_label_background_subtitle,
            style: regular(size: 12, color: AppColors.mainGrey),
          ),
          Slider(
            value: opacity,
            min: TranslationOverlayStyle.minLabelOpacity,
            max: TranslationOverlayStyle.maxLabelOpacity,
            divisions: 10,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.overlay(0.12),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
