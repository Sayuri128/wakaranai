import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_input_sections.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_options_section.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_range_section.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_selection.dart';
import 'package:wakaranai/ui/services/filters/gallery_filters_action_bar.dart';
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
    useSafeArea: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext sheetContext) => GalleryFiltersSheet(
      filters: filters,
      current: current,
    ),
  );
}

class GalleryFiltersSheet extends StatefulWidget {
  const GalleryFiltersSheet({
    super.key,
    required this.filters,
    required this.current,
  });

  final List<GalleryFilter> filters;
  final Map<String, FilterData> current;

  @override
  State<GalleryFiltersSheet> createState() => _GalleryFiltersSheetState();
}

class _GalleryFiltersSheetState extends State<GalleryFiltersSheet> {
  late final GalleryFilterSelection _selection = GalleryFilterSelection(
    filters: widget.filters,
    current: widget.current,
  );
  final ScrollController _scrollController = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool scrolled =
        _scrollController.hasClients && _scrollController.offset > 0;
    if (scrolled != _scrolled) {
      setState(() => _scrolled = scrolled);
    }
  }

  void _update(VoidCallback change) {
    setState(change);
  }

  void _reset() {
    _update(_selection.clearAll);
  }

  void _apply() {
    Navigator.of(context).pop(_selection.build());
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHandle(),
            _buildHeader(),
            _buildHeaderDivider(),
            Flexible(child: _buildContent()),
            if (widget.filters.isNotEmpty)
              GalleryFiltersActionBar(
                activeCount: _selection.activeCount,
                onReset: _reset,
                onApply: _apply,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final int activeCount = _selection.activeCount;
    final String subtitle = activeCount > 0
        ? S.current.filters_active_summary(activeCount)
        : S.current.filters_none_active;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.current.gallery_filters_sheet_title, style: semibold(size: 18)),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              subtitle,
              key: ValueKey<String>(subtitle),
              style: regular(
                size: 13,
                color: activeCount > 0 ? AppColors.primary : AppColors.mainGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return AnimatedOpacity(
      opacity: _scrolled ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: Container(height: 1, color: AppColors.overlay(0.08)),
    );
  }

  Widget _buildContent() {
    if (widget.filters.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: widget.filters.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) =>
          _buildFilter(widget.filters[index]),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.tune_rounded, size: 64, color: AppColors.mainGrey),
            const SizedBox(height: 16),
            Text(
              S.current.filters_empty_title,
              textAlign: TextAlign.center,
              style: semibold(size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              S.current.filters_empty_message,
              textAlign: TextAlign.center,
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
          ],
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
    if (filter is GalleryFilterOneOfMultiple ||
        filter is GalleryFilterMultipleOfMultiple) {
      return _buildOptions(filter);
    }
    switch (filter.type) {
      case GalleryFilterType.ONE_OF_ANY:
        return _buildText(filter);
      case GalleryFilterType.MULTIPLE_OF_ANY:
        return _buildTags(filter);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSwitcher(GalleryFilterSwitcher filter) {
    return GalleryFilterSwitchTile(
      key: ValueKey<String>(filter.param),
      title: filter.paramName,
      value: _selection.switchValue(filter),
      onChanged: (bool value) =>
          _update(() => _selection.setSwitch(filter, value)),
    );
  }

  Widget _buildRange(GalleryFilterRange filter) {
    return GalleryFilterRangeSection(
      key: ValueKey<String>(filter.param),
      filter: filter,
      from: _selection.rangeFrom(filter),
      to: _selection.rangeTo(filter),
      onChanged: (String from, String to) => _update(() {
        _selection.setRangeFrom(filter, from);
        _selection.setRangeTo(filter, to);
      }),
      onClear: () => _update(() => _selection.clearFilter(filter)),
    );
  }

  Widget _buildOptions(GalleryFilter filter) {
    return GalleryFilterOptionsSection(
      key: ValueKey<String>(filter.param),
      title: filter.paramName,
      options: GalleryFilterSelection.optionsOf(filter),
      singleChoice: filter is GalleryFilterOneOfMultiple,
      selectedCount: _selection.selectedCount(filter),
      isSelected: (GalleryFilterOption option) =>
          _selection.isOptionSelected(filter, option),
      onToggle: (GalleryFilterOption option) =>
          _update(() => _selection.toggleOption(filter, option)),
      onClear: () => _update(() => _selection.clearFilter(filter)),
    );
  }

  Widget _buildText(GalleryFilter filter) {
    return GalleryFilterTextSection(
      key: ValueKey<String>(filter.param),
      title: filter.paramName,
      value: _selection.textValue(filter),
      onChanged: (String value) =>
          _update(() => _selection.setText(filter, value)),
    );
  }

  Widget _buildTags(GalleryFilter filter) {
    return GalleryFilterTagsSection(
      key: ValueKey<String>(filter.param),
      title: filter.paramName,
      values: _selection.multiValues(filter),
      onAdd: (String value) =>
          _update(() => _selection.addMultiValue(filter, value)),
      onRemove: (String value) =>
          _update(() => _selection.removeMultiValue(filter, value)),
      onClear: () => _update(() => _selection.clearFilter(filter)),
    );
  }
}
