import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/range/range.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_section.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFilterRangeSection extends StatefulWidget {
  const GalleryFilterRangeSection({
    super.key,
    required this.filter,
    required this.from,
    required this.to,
    required this.onChanged,
    required this.onClear,
  });

  final GalleryFilterRange filter;
  final String from;
  final String to;
  final void Function(String from, String to) onChanged;
  final VoidCallback onClear;

  static String formatBound(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    String text = value.toStringAsFixed(2);
    while (text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  @override
  State<GalleryFilterRangeSection> createState() =>
      _GalleryFilterRangeSectionState();
}

class _GalleryFilterRangeSectionState extends State<GalleryFilterRangeSection> {
  late final TextEditingController _fromController =
      TextEditingController(text: widget.from);
  late final TextEditingController _toController =
      TextEditingController(text: widget.to);

  num? get _min => widget.filter.min;
  num? get _max => widget.filter.max;

  bool get _hasSlider {
    final num? min = _min;
    final num? max = _max;
    return min != null && max != null && max > min;
  }

  @override
  void didUpdateWidget(covariant GalleryFilterRangeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_fromController, widget.from);
    _syncController(_toController, widget.to);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  bool get _active =>
      widget.from.trim().isNotEmpty || widget.to.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GalleryFilterSection(
      title: widget.filter.paramName,
      onClear: _active ? widget.onClear : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildFields(),
          if (_hasSlider) _buildSlider(),
        ],
      ),
    );
  }

  Widget _buildFields() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _RangeBoundField(
            controller: _fromController,
            caption: S.current.gallery_filters_range_from_hint,
            hint: _boundHint(_min),
            onChanged: (String value) => widget.onChanged(value, widget.to),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('–', style: medium(size: 16, color: AppColors.mainGrey)),
        ),
        Expanded(
          child: _RangeBoundField(
            controller: _toController,
            caption: S.current.gallery_filters_range_to_hint,
            hint: _boundHint(_max),
            onChanged: (String value) => widget.onChanged(widget.from, value),
          ),
        ),
      ],
    );
  }

  String _boundHint(num? bound) {
    if (bound == null) {
      return S.current.filters_range_any;
    }
    return GalleryFilterRangeSection.formatBound(bound);
  }

  Widget _buildSlider() {
    final double min = _min!.toDouble();
    final double max = _max!.toDouble();
    final RangeValues values = _sliderValues(min, max);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SliderTheme(
            data: _sliderTheme(context),
            child: RangeSlider(
              min: min,
              max: max,
              divisions: _divisions(min, max),
              values: values,
              onChanged: (RangeValues next) => _onSliderChanged(next, min, max),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: <Widget>[
                Text(
                  GalleryFilterRangeSection.formatBound(min),
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
                const Spacer(),
                Text(
                  GalleryFilterRangeSection.formatBound(max),
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      trackHeight: 4,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.overlay(0.12),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.14),
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
      rangeThumbShape: const RoundRangeSliderThumbShape(
        enabledThumbRadius: 9,
        elevation: 0,
        pressedElevation: 0,
      ),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      showValueIndicator: ShowValueIndicator.never,
    );
  }

  int? _divisions(double min, double max) {
    final double span = max - min;
    if (span == span.roundToDouble() && span <= 200) {
      return span.toInt();
    }
    return 100;
  }

  RangeValues _sliderValues(double min, double max) {
    final double start = _parseOr(widget.from, min).clamp(min, max);
    final double end = _parseOr(widget.to, max).clamp(min, max);
    if (start > end) {
      return RangeValues(end, start);
    }
    return RangeValues(start, end);
  }

  double _parseOr(String text, double fallback) {
    return double.tryParse(text.trim()) ?? fallback;
  }

  void _onSliderChanged(RangeValues next, double min, double max) {
    final String from =
        next.start <= min ? '' : GalleryFilterRangeSection.formatBound(next.start);
    final String to =
        next.end >= max ? '' : GalleryFilterRangeSection.formatBound(next.end);
    widget.onChanged(from, to);
  }
}

class _RangeBoundField extends StatefulWidget {
  const _RangeBoundField({
    required this.controller,
    required this.caption,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String caption;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_RangeBoundField> createState() => _RangeBoundFieldState();
}

class _RangeBoundFieldState extends State<_RangeBoundField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = _focusNode.hasFocus;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 0),
        decoration: BoxDecoration(
          color: AppColors.overlay(focused ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.overlay(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.caption,
              style: regular(
                size: 11,
                color: focused ? AppColors.primary : AppColors.mainGrey,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              cursorColor: AppColors.primary,
              style: semibold(size: 15),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: medium(size: 15, color: AppColors.mainGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
