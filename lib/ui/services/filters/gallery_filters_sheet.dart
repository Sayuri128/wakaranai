import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_any/multiple_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_any/one_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const int _kSearchThreshold = 12;
const int _kMaxVisibleOptions = 60;

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

class _Opt {
  const _Opt({
    required this.group,
    required this.value,
    required this.label,
    required this.selected,
  });

  final int group;
  final String value;
  final String label;
  final bool selected;
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
  final Map<String, bool> _expanded = <String, bool>{};
  final Map<String, String> _searchQueries = <String, String>{};

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
        _controllerFor(filter.param).text = data.selected;
      } else if (data is FilterDataMultipleOfAny) {
        _multis[filter.param] = List<String>.of(data.selected);
      } else if (data is FilterDataMultipleOfMultiple) {
        _groupMultis[filter.param] =
            data.selected.map((List<String> e) => List<String>.of(e)).toList();
      } else if (data is FilterDataRange) {
        _controllerFor('${filter.param}::from').text = data.from ?? '';
        _controllerFor('${filter.param}::to').text = data.to ?? '';
      }
    }
  }

  TextEditingController _controllerFor(String key) {
    return _textControllers.putIfAbsent(key, TextEditingController.new);
  }

  int get _activeCount {
    int count = 0;
    for (final GalleryFilter filter in widget.filters) {
      if (_buildData(filter) != null) count++;
    }
    return count;
  }

  int _selectedCount(GalleryFilter filter) {
    if (filter is GalleryFilterOneOfMultiple) {
      return (_singles[filter.param]?.isNotEmpty ?? false) ? 1 : 0;
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      final List<List<String>>? sel = _groupMultis[filter.param];
      if (sel == null) return 0;
      return sel.fold<int>(0, (int a, List<String> g) => a + g.length);
    }
    return 0;
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
    if (filter is GalleryFilterRange) {
      final String from = _controllerFor('${filter.param}::from').text.trim();
      final String to = _controllerFor('${filter.param}::to').text.trim();
      if (from.isEmpty && to.isEmpty) return null;
      return FilterDataRange(
        from: from.isEmpty ? null : from,
        to: to.isEmpty ? null : to,
        filter: filter,
      );
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
      _searchQueries.clear();
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
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
                    AnimatedOpacity(
                      opacity: _activeCount > 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: IgnorePointer(
                        ignoring: _activeCount == 0,
                        child: TextButton(
                          onPressed: _reset,
                          child: Text(
                            S.current.gallery_filters_reset_button,
                            style: medium(size: 13, color: AppColors.mainGrey),
                          ),
                        ),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (BuildContext context, int index) =>
                      _buildFilter(widget.filters[index]),
                ),
              ),
              _buildApplyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilter(GalleryFilter filter) {
    if (filter is GalleryFilterSwitcher) {
      return _buildSwitcher(filter);
    }
    if (filter is GalleryFilterRange) {
      return _buildRange(filter);
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

  String _labelFor(List<String>? labels, int index, String fallback) {
    if (labels != null && index < labels.length) return labels[index];
    return fallback;
  }

  String _groupLabelFor(
      List<List<String>>? labels, int group, int index, String fallback) {
    if (labels != null &&
        group < labels.length &&
        index < labels[group].length) {
      return labels[group][index];
    }
    return fallback;
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

  Widget _buildRange(GalleryFilterRange filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(filter.paramName),
        Row(
          children: <Widget>[
            Expanded(
              child: _numberField(
                '${filter.param}::from',
                S.current.gallery_filters_range_from_hint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numberField(
                '${filter.param}::to',
                S.current.gallery_filters_range_to_hint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numberField(String key, String hint) {
    return TextField(
      controller: _controllerFor(key),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      cursorColor: AppColors.primary,
      style: medium(size: 15),
      onChanged: (_) => setState(() {}),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.overlay(0.06),
      hintText: hint,
      hintStyle: regular(size: 14, color: AppColors.mainGrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildOneOfMultiple(GalleryFilterOneOfMultiple filter) {
    final String? selected = _singles[filter.param];
    final List<_Opt> opts = List<_Opt>.generate(filter.values.length, (int i) {
      final String value = filter.values[i];
      return _Opt(
        group: 0,
        value: value,
        label: _labelFor(filter.labels, i, value),
        selected: selected == value,
      );
    });

    return _buildOptionSection(filter, opts, (_Opt o) {
      setState(() {
        if (o.selected) {
          _singles.remove(filter.param);
        } else {
          _singles[filter.param] = o.value;
        }
      });
    });
  }

  Widget _buildMultipleOfMultiple(GalleryFilterMultipleOfMultiple filter) {
    final List<List<String>> selected =
        _groupMultis[filter.param] ??= List<List<String>>.generate(
      filter.values.length,
      (_) => <String>[],
    );

    final List<_Opt> opts = <_Opt>[];
    for (int g = 0; g < filter.values.length; g++) {
      for (int i = 0; i < filter.values[g].length; i++) {
        final String value = filter.values[g][i];
        opts.add(_Opt(
          group: g,
          value: value,
          label: _groupLabelFor(filter.labels, g, i, value),
          selected: selected[g].contains(value),
        ));
      }
    }

    return _buildOptionSection(filter, opts, (_Opt o) {
      setState(() {
        if (o.selected) {
          selected[o.group].remove(o.value);
        } else {
          selected[o.group].add(o.value);
        }
      });
    });
  }

  Widget _buildOptionSection(
    GalleryFilter filter,
    List<_Opt> opts,
    void Function(_Opt) onTap,
  ) {
    final bool expanded = _expanded[filter.param] ?? false;
    final int count = _selectedCount(filter);
    final bool searchable = opts.length > _kSearchThreshold;
    final String query = (_searchQueries[filter.param] ?? '').toLowerCase();

    List<_Opt> matches = query.isEmpty
        ? opts
        : opts
            .where((_Opt o) => o.label.toLowerCase().contains(query))
            .toList();
    matches = <_Opt>[
      ...matches.where((_Opt o) => o.selected),
      ...matches.where((_Opt o) => !o.selected),
    ];
    final int hidden =
        matches.length > _kMaxVisibleOptions ? matches.length - _kMaxVisibleOptions : 0;
    final List<_Opt> visible =
        hidden > 0 ? matches.sublist(0, _kMaxVisibleOptions) : matches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () =>
              setState(() => _expanded[filter.param] = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                Text(filter.paramName, style: medium(size: 14)),
                if (count > 0) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count',
                        style: medium(size: 11, color: AppColors.mainBlack)),
                  ),
                ],
                const Spacer(),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.mainGrey,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...<Widget>[
          if (searchable) ...<Widget>[
            const SizedBox(height: 6),
            TextField(
              controller: _controllerFor('${filter.param}::search'),
              cursorColor: AppColors.primary,
              style: medium(size: 14),
              onChanged: (String v) =>
                  setState(() => _searchQueries[filter.param] = v),
              decoration: _inputDecoration(
                S.current.gallery_filters_option_search_hint,
                suffixIcon:
                    Icon(Icons.search_rounded, color: AppColors.mainGrey, size: 20),
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (visible.isEmpty)
            Text(
              S.current.gallery_filters_no_matches,
              style: regular(size: 13, color: AppColors.mainGrey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visible
                  .map((_Opt o) => _Pill(
                        label: o.label,
                        selected: o.selected,
                        onTap: () => onTap(o),
                      ))
                  .toList(),
            ),
          if (hidden > 0) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              S.current.gallery_filters_more_options(hidden),
              style: regular(size: 12, color: AppColors.mainGrey),
            ),
          ],
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
        final List<String> list =
            _multis.putIfAbsent(filter.param, () => <String>[]);
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
          decoration: _inputDecoration(
            multiple
                ? S.current.gallery_filters_multiple_of_any_hint
                : S.current.gallery_filters_one_of_any_hint,
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
