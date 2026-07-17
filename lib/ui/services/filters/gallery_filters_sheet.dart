import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_any/multiple_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_any/one_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<Map<String, FilterData>?> showGalleryFiltersSheet(
  BuildContext context, {
  required List<GalleryFilter> filters,
  required Map<String, FilterData> current,
}) {
  return showModalBottomSheet<Map<String, FilterData>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _GalleryFiltersSheet(
      filters: filters,
      current: current,
    ),
  );
}

class _GalleryFiltersSheet extends StatefulWidget {
  const _GalleryFiltersSheet({
    required this.filters,
    required this.current,
  });

  final List<GalleryFilter> filters;
  final Map<String, FilterData> current;

  @override
  State<_GalleryFiltersSheet> createState() => _GalleryFiltersSheetState();
}

class _GalleryFiltersSheetState extends State<_GalleryFiltersSheet> {
  final Map<String, bool> _switches = <String, bool>{};
  final Map<String, String> _singles = <String, String>{};
  final Map<String, List<String>> _multis = <String, List<String>>{};
  final Map<String, List<List<String>>> _groupMultis =
      <String, List<List<String>>>{};
  final Map<String, TextEditingController> _textControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _seedFromCurrent();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _seedFromCurrent() {
    for (final GalleryFilter filter in widget.filters) {
      final FilterData? data = widget.current[filter.param];
      if (data is FilterDataSwitcher) {
        _switches[filter.param] = data.on;
      } else if (data is FilterDataOneOfMultiple) {
        _singles[filter.param] = data.selected;
      } else if (data is FilterDataOneOfAny) {
        _singles[filter.param] = data.selected;
      } else if (data is FilterDataMultipleOfAny) {
        _multis[filter.param] = List<String>.of(data.selected);
      } else if (data is FilterDataMultipleOfMultiple) {
        _groupMultis[filter.param] =
            data.selected.map((List<String> e) => List<String>.of(e)).toList();
      }
    }
  }

  TextEditingController _controllerFor(String param) {
    return _textControllers.putIfAbsent(param, TextEditingController.new);
  }

  int get _activeCount {
    int count = 0;
    for (final GalleryFilter filter in widget.filters) {
      if (_buildData(filter) != null) count++;
    }
    return count;
  }

  FilterData? _buildData(GalleryFilter filter) {
    if (filter is GalleryFilterSwitcher) {
      return (_switches[filter.param] ?? false)
          ? FilterDataSwitcher(on: true, filter: filter)
          : null;
    }
    if (filter is GalleryFilterOneOfMultiple) {
      final String? selected = _singles[filter.param];
      if (selected == null || selected.isEmpty) return null;
      return FilterDataOneOfMultiple(selected: selected, filter: filter);
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      final List<List<String>>? selected = _groupMultis[filter.param];
      if (selected == null || selected.every((List<String> g) => g.isEmpty)) {
        return null;
      }
      return FilterDataMultipleOfMultiple(selected: selected, filter: filter);
    }
    final String param = filter.param;
    switch (filter.type) {
      case GalleryFilterType.ONE_OF_ANY:
        final String value = _controllerFor(param).text.trim();
        if (value.isEmpty) return null;
        return FilterDataOneOfAny(selected: value, filter: filter);
      case GalleryFilterType.MULTIPLE_OF_ANY:
        final List<String> values = _multis[param] ?? <String>[];
        if (values.isEmpty) return null;
        return FilterDataMultipleOfAny(selected: values, filter: filter);
      default:
        return null;
    }
  }

  void _reset() {
    setState(() {
      _switches.clear();
      _singles.clear();
      _multis.clear();
      _groupMultis.clear();
      for (final TextEditingController controller in _textControllers.values) {
        controller.clear();
      }
    });
  }

  void _apply() {
    final Map<String, FilterData> result = <String, FilterData>{};
    for (final GalleryFilter filter in widget.filters) {
      final FilterData? data = _buildData(filter);
      if (data != null) result[filter.param] = data;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.overlay(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      S.current.gallery_filters_sheet_title,
                      style: semibold(size: 18),
                    ),
                  ),
                  if (_activeCount > 0)
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        S.current.gallery_filters_reset_button,
                        style: medium(size: 13, color: AppColors.mainGrey),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: widget.filters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (BuildContext context, int index) =>
                    _buildFilter(widget.filters[index]),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(GalleryFilter filter) {
    if (filter is GalleryFilterSwitcher) {
      return _buildSwitcher(filter);
    }
    if (filter is GalleryFilterOneOfMultiple) {
      return _buildOneOfMultiple(filter);
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      return _buildMultipleOfMultiple(filter);
    }
    switch (filter.type) {
      case GalleryFilterType.ONE_OF_ANY:
        return _buildFreeText(filter, multiple: false);
      case GalleryFilterType.MULTIPLE_OF_ANY:
        return _buildFreeText(filter, multiple: true);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: medium(size: 14)),
      );

  Widget _buildSwitcher(GalleryFilterSwitcher filter) {
    final bool value = _switches[filter.param] ?? false;
    return Row(
      children: <Widget>[
        Expanded(child: Text(filter.paramName, style: medium(size: 14))),
        Switch(
          value: value,
          activeThumbColor: AppColors.mainBlack,
          activeTrackColor: AppColors.primary,
          onChanged: (bool v) => setState(() => _switches[filter.param] = v),
        ),
      ],
    );
  }

  Widget _buildOneOfMultiple(GalleryFilterOneOfMultiple filter) {
    final String? selected = _singles[filter.param];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(filter.paramName),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filter.values.map((String value) {
            final bool active = selected == value;
            return _Pill(
              label: value,
              selected: active,
              onTap: () => setState(() {
                if (active) {
                  _singles.remove(filter.param);
                } else {
                  _singles[filter.param] = value;
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleOfMultiple(GalleryFilterMultipleOfMultiple filter) {
    final List<List<String>> selected =
        _groupMultis[filter.param] ??= List<List<String>>.generate(
      filter.values.length,
      (_) => <String>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(filter.paramName),
        for (int group = 0; group < filter.values.length; group++) ...<Widget>[
          if (group > 0) const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filter.values[group].map((String value) {
              final bool active = selected[group].contains(value);
              return _Pill(
                label: value,
                selected: active,
                onTap: () => setState(() {
                  if (active) {
                    selected[group].remove(value);
                  } else {
                    selected[group].add(value);
                  }
                }),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFreeText(GalleryFilter filter, {required bool multiple}) {
    final TextEditingController controller = _controllerFor(filter.param);
    final List<String> chips = _multis[filter.param] ?? <String>[];

    void addChip() {
      final String value = controller.text.trim();
      if (value.isEmpty) return;
      setState(() {
        final List<String> list = _multis.putIfAbsent(
            filter.param, () => <String>[]);
        if (!list.contains(value)) list.add(value);
        controller.clear();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(filter.paramName),
        TextField(
          controller: controller,
          cursorColor: AppColors.primary,
          style: medium(size: 15),
          textInputAction:
              multiple ? TextInputAction.done : TextInputAction.search,
          onChanged: multiple ? null : (String v) => setState(() {}),
          onSubmitted: multiple ? (_) => addChip() : null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.overlay(0.06),
            hintText: multiple
                ? S.current.gallery_filters_multiple_of_any_hint
                : S.current.gallery_filters_one_of_any_hint,
            hintStyle: regular(size: 14, color: AppColors.mainGrey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: multiple
                ? IconButton(
                    icon: Icon(Icons.add_rounded, color: AppColors.mainGrey),
                    onPressed: addChip,
                  )
                : null,
          ),
        ),
        if (multiple && chips.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((String value) {
              return _Pill(
                label: value,
                selected: true,
                trailing: Icons.close_rounded,
                onTap: () => setState(() => chips.remove(value)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _apply,
          child: Text(
            _activeCount > 0
                ? S.current.gallery_filters_apply_button_count(_activeCount)
                : S.current.gallery_filters_apply_button,
            style: semibold(size: 15, color: AppColors.mainBlack),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: medium(
                  size: 13,
                  color: selected ? AppColors.mainBlack : AppColors.mainWhite,
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 6),
                Icon(trailing, size: 15, color: AppColors.mainBlack),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
