import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_chip.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_section.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFilterSwitchTile extends StatelessWidget {
  const GalleryFilterSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GalleryFilterCard(
      child: InkWell(
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(title, style: semibold(size: 15))),
              const SizedBox(width: 8),
              Switch(
                value: value,
                activeThumbColor: AppColors.mainBlack,
                activeTrackColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryFilterTextSection extends StatefulWidget {
  const GalleryFilterTextSection({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<GalleryFilterTextSection> createState() =>
      _GalleryFilterTextSectionState();
}

class _GalleryFilterTextSectionState extends State<GalleryFilterTextSection> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant GalleryFilterTextSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.value.trim().isNotEmpty;
    return GalleryFilterSection(
      title: widget.title,
      onClear: active ? _clear : null,
      child: TextField(
        controller: _controller,
        cursorColor: AppColors.primary,
        style: medium(size: 15),
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
        decoration: galleryFilterInputDecoration(
          hint: S.current.gallery_filters_one_of_any_hint,
          prefixIcon: Icon(
            Icons.edit_rounded,
            color: AppColors.mainGrey,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class GalleryFilterTagsSection extends StatefulWidget {
  const GalleryFilterTagsSection({
    super.key,
    required this.title,
    required this.values,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  State<GalleryFilterTagsSection> createState() =>
      _GalleryFilterTagsSectionState();
}

class _GalleryFilterTagsSectionState extends State<GalleryFilterTagsSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onAdd(value);
      _controller.clear();
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GalleryFilterSection(
      title: widget.title,
      count: widget.values.length,
      onClear: widget.values.isEmpty ? null : widget.onClear,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildField(),
          if (widget.values.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _buildChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildField() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        final bool canAdd = value.text.trim().isNotEmpty;
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          cursorColor: AppColors.primary,
          style: medium(size: 15),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: galleryFilterInputDecoration(
            hint: S.current.gallery_filters_multiple_of_any_hint,
            prefixIcon: Icon(
              Icons.sell_rounded,
              color: AppColors.mainGrey,
              size: 18,
            ),
            suffixIcon: _buildAddButton(canAdd),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(bool canAdd) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: canAdd ? AppColors.primary : AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: canAdd ? _submit : null,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Tooltip(
              message: S.current.filters_add_value,
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: canAdd ? AppColors.mainBlack : AppColors.mainGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String value in widget.values)
          GalleryFilterChip(
            label: value,
            selected: true,
            trailingIcon: Icons.close_rounded,
            tooltip: S.current.filters_remove_value(value),
            onTap: () => widget.onRemove(value),
          ),
      ],
    );
  }
}
