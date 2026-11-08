import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_chip.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_section.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_selection.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFilterOptionsSection extends StatefulWidget {
  const GalleryFilterOptionsSection({
    super.key,
    required this.title,
    required this.options,
    required this.isSelected,
    required this.onToggle,
    required this.selectedCount,
    required this.onClear,
    this.singleChoice = false,
  });

  static const int collapseThreshold = 12;
  static const int previewCount = 10;
  static const int maxVisibleOptions = 60;

  final String title;
  final List<GalleryFilterOption> options;
  final bool Function(GalleryFilterOption option) isSelected;
  final ValueChanged<GalleryFilterOption> onToggle;
  final int selectedCount;
  final VoidCallback onClear;
  final bool singleChoice;

  @override
  State<GalleryFilterOptionsSection> createState() =>
      _GalleryFilterOptionsSectionState();
}

class _GalleryFilterOptionsSectionState
    extends State<GalleryFilterOptionsSection> {
  final TextEditingController _searchController = TextEditingController();
  bool _expanded = false;
  String _query = '';

  bool get _collapsible =>
      widget.options.length > GalleryFilterOptionsSection.collapseThreshold;

  bool get _showsClear => !widget.singleChoice && widget.selectedCount > 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryFilterSection(
      title: widget.title,
      count: widget.singleChoice ? 0 : widget.selectedCount,
      onClear: _showsClear ? widget.onClear : null,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (!_collapsible) {
      return <Widget>[_buildChips(widget.options, showAny: true)];
    }
    if (!_expanded) {
      return <Widget>[
        _buildChips(_previewOptions(), showAny: true, trailing: _buildToggleChip()),
      ];
    }
    return _buildExpandedBody();
  }

  List<Widget> _buildExpandedBody() {
    final List<GalleryFilterOption> matches = _matchingOptions();
    final int hiddenCount =
        matches.length - GalleryFilterOptionsSection.maxVisibleOptions;
    final List<GalleryFilterOption> visible = hiddenCount > 0
        ? matches.sublist(0, GalleryFilterOptionsSection.maxVisibleOptions)
        : matches;
    return <Widget>[
      _buildSearchField(),
      const SizedBox(height: 12),
      if (visible.isEmpty) ...<Widget>[
        _buildNoMatches(),
        Align(alignment: Alignment.centerLeft, child: _buildToggleChip()),
      ] else
        _buildChips(
          visible,
          showAny: _query.isEmpty,
          trailing: _buildToggleChip(),
        ),
      if (hiddenCount > 0) ...<Widget>[
        const SizedBox(height: 10),
        Text(
          S.current.gallery_filters_more_options(hiddenCount),
          style: regular(size: 12, color: AppColors.mainGrey),
        ),
      ],
    ];
  }

  List<GalleryFilterOption> _previewOptions() {
    final List<GalleryFilterOption> preview = <GalleryFilterOption>[];
    int unselectedShown = 0;
    for (final GalleryFilterOption option in widget.options) {
      if (widget.isSelected(option)) {
        preview.add(option);
      } else if (unselectedShown < GalleryFilterOptionsSection.previewCount) {
        preview.add(option);
        unselectedShown++;
      }
    }
    return preview;
  }

  List<GalleryFilterOption> _matchingOptions() {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.options;
    }
    return widget.options
        .where((GalleryFilterOption option) =>
            option.label.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildChips(
    List<GalleryFilterOption> options, {
    required bool showAny,
    Widget? trailing,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (widget.singleChoice && showAny)
          GalleryFilterChip(
            label: S.current.filters_any_option,
            selected: widget.selectedCount == 0,
            onTap: widget.onClear,
          ),
        for (final GalleryFilterOption option in options)
          GalleryFilterChip(
            label: option.label,
            selected: widget.isSelected(option),
            onTap: () => widget.onToggle(option),
          ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        cursorColor: AppColors.primary,
        style: medium(size: 14),
        textInputAction: TextInputAction.search,
        onChanged: (String value) => setState(() => _query = value),
        decoration: galleryFilterInputDecoration(
          hint: S.current.filters_search_hint(widget.title),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.mainGrey,
            size: 20,
          ),
          suffixIcon: _query.isEmpty ? null : _buildClearSearchButton(),
        ),
      ),
    );
  }

  Widget _buildClearSearchButton() {
    return IconButton(
      splashRadius: 18,
      tooltip: S.current.filters_clear_search,
      icon: Icon(Icons.close_rounded, color: AppColors.mainGrey, size: 18),
      onPressed: () => setState(() {
        _query = '';
        _searchController.clear();
      }),
    );
  }

  Widget _buildNoMatches() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search_off_rounded, color: AppColors.mainGrey, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              S.current.gallery_filters_no_matches,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip() {
    final String label = _expanded
        ? S.current.filters_show_less
        : S.current.filters_show_all(widget.options.length);
    return GalleryFilterLinkChip(
      label: label,
      icon: _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
      onTap: _toggleExpanded,
    );
  }
}
