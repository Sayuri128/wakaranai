import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SegmentedTabs extends StatefulWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.badges,
    this.pageController,
    this.semanticsLabel,
  });

  static const int maxEqualWidthTabs = 3;
  static const double height = 44;

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<int>? badges;
  final PageController? pageController;
  final String? semanticsLabel;

  bool get scrollable => labels.length > maxEqualWidthTabs;

  @override
  State<SegmentedTabs> createState() => _SegmentedTabsState();
}

class _SegmentedTabsState extends State<SegmentedTabs>
    with SingleTickerProviderStateMixin {
  static const Duration _slideDuration = Duration(milliseconds: 250);
  static const Duration _labelDuration = Duration(milliseconds: 200);
  static const double _scrollableSegmentPadding = 16;

  late final AnimationController _indicator = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );
  final ScrollController _trackScroll = ScrollController();
  List<GlobalKey> _segmentKeys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    _syncSegmentKeys();
    _revealSelected(animate: false);
  }

  @override
  void didUpdateWidget(SegmentedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _syncSegmentKeys();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      unawaited(_indicator.animateTo(
        widget.selectedIndex.toDouble(),
        duration: _slideDuration,
        curve: Curves.easeOutCubic,
      ));
      _revealSelected(animate: true);
    }
  }

  @override
  void dispose() {
    _indicator.dispose();
    _trackScroll.dispose();
    super.dispose();
  }

  void _syncSegmentKeys() {
    _segmentKeys = List<GlobalKey>.generate(
      widget.labels.length,
      (int index) => GlobalKey(debugLabel: 'segment-$index'),
    );
  }

  void _revealSelected({required bool animate}) {
    if (!widget.scrollable) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || !widget.scrollable) {
        return;
      }
      final int index = widget.selectedIndex;
      if (index < 0 || index >= _segmentKeys.length) {
        return;
      }
      final BuildContext? segmentContext = _segmentKeys[index].currentContext;
      if (segmentContext == null) {
        return;
      }
      unawaited(Scrollable.ensureVisible(
        segmentContext,
        alignment: 0.5,
        duration: animate ? _slideDuration : Duration.zero,
        curve: Curves.easeOutCubic,
      ));
    });
  }

  double _indicatorPosition() {
    final PageController? controller = widget.pageController;
    if (controller != null &&
        controller.hasClients &&
        controller.positions.length == 1) {
      final double? page = controller.page;
      if (page != null) {
        return page;
      }
    }
    return _indicator.value;
  }

  int _badgeAt(int index) {
    final List<int>? badges = widget.badges;
    if (badges == null || index >= badges.length) {
      return 0;
    }
    return badges[index];
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      child: Container(
        height: SegmentedTabs.height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: widget.scrollable
            ? _buildScrollableTrack()
            : _buildTrack(equalWidths: true),
      ),
    );
  }

  Widget _buildScrollableTrack() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            controller: _trackScroll,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: _buildTrack(equalWidths: false),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrack({required bool equalWidths}) {
    final List<Widget> children = <Widget>[
      _buildIndicator(),
      for (int index = 0; index < widget.labels.length; index++)
        _buildSegment(index, equalWidths: equalWidths),
    ];
    final PageController? controller = widget.pageController;
    final Listenable animation = controller == null
        ? _indicator
        : Listenable.merge(<Listenable>[_indicator, controller]);
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) => _SegmentTrack(
        indicatorPosition: _indicatorPosition(),
        equalWidths: equalWidths,
        children: children,
      ),
    );
  }

  Widget _buildIndicator() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildSegment(int index, {required bool equalWidths}) {
    final bool selected = index == widget.selectedIndex;
    final Widget content = _buildSegmentContent(index, selected);
    return KeyedSubtree(
      key: _segmentKeys[index],
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onSelected(index),
          child: equalWidths
              ? Center(child: content)
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _scrollableSegmentPadding,
                  ),
                  child: Center(widthFactor: 1, child: content),
                ),
        ),
      ),
    );
  }

  Widget _buildSegmentContent(int index, bool selected) {
    final int badge = _badgeAt(index);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: _labelDuration,
            style: semibold(
              size: 14,
              color: selected ? AppColors.mainBlack : AppColors.mainGrey,
            ),
            child: Text(
              widget.labels[index],
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (badge > 0) ...<Widget>[
          const SizedBox(width: 6),
          _SegmentBadge(count: badge, selected: selected),
        ],
      ],
    );
  }
}

class _SegmentBadge extends StatelessWidget {
  const _SegmentBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? AppColors.mainBlack.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: semibold(
          size: 11,
          color: selected ? AppColors.mainBlack : AppColors.primary,
        ),
      ),
    );
  }
}

class _SegmentTrack extends MultiChildRenderObjectWidget {
  const _SegmentTrack({
    required this.indicatorPosition,
    required this.equalWidths,
    required super.children,
  });

  final double indicatorPosition;
  final bool equalWidths;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSegmentTrack(
      indicatorPosition: indicatorPosition,
      equalWidths: equalWidths,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSegmentTrack renderObject,
  ) {
    renderObject
      ..indicatorPosition = indicatorPosition
      ..equalWidths = equalWidths;
  }
}

class _SegmentTrackParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSegmentTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SegmentTrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SegmentTrackParentData> {
  _RenderSegmentTrack({
    required double indicatorPosition,
    required bool equalWidths,
  })  : _indicatorPosition = indicatorPosition,
        _equalWidths = equalWidths;

  double _indicatorPosition;
  bool _equalWidths;

  set indicatorPosition(double value) {
    if (value == _indicatorPosition) {
      return;
    }
    _indicatorPosition = value;
    markNeedsLayout();
  }

  set equalWidths(bool value) {
    if (value == _equalWidths) {
      return;
    }
    _equalWidths = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SegmentTrackParentData) {
      child.parentData = _SegmentTrackParentData();
    }
  }

  List<RenderBox> get _segments {
    final List<RenderBox> segments = <RenderBox>[];
    final RenderBox? indicator = firstChild;
    if (indicator == null) {
      return segments;
    }
    RenderBox? child = childAfter(indicator);
    while (child != null) {
      segments.add(child);
      child = childAfter(child);
    }
    return segments;
  }

  double _tallestSegment(List<RenderBox> segments, double width) {
    double tallest = 0;
    for (final RenderBox segment in segments) {
      tallest = math.max(tallest, segment.getMaxIntrinsicHeight(width));
    }
    return tallest;
  }

  double _trackHeight(BoxConstraints constraints, List<RenderBox> segments) {
    if (constraints.hasBoundedHeight) {
      return constraints.maxHeight;
    }
    return constraints.constrainHeight(
      _tallestSegment(segments, double.infinity),
    );
  }

  List<double> _naturalWidths(List<RenderBox> segments, double height) {
    return <double>[
      for (final RenderBox segment in segments)
        segment.getMaxIntrinsicWidth(height).ceilToDouble(),
    ];
  }

  List<double> _segmentWidths(
    BoxConstraints constraints,
    List<RenderBox> segments,
    double height,
  ) {
    if (segments.isEmpty) {
      return <double>[];
    }
    if (_equalWidths && constraints.hasBoundedWidth) {
      return List<double>.filled(
        segments.length,
        constraints.maxWidth / segments.length,
      );
    }
    final List<double> natural = _naturalWidths(segments, height);
    final double total = _sum(natural);
    if (total >= constraints.minWidth) {
      return natural;
    }
    final double extra = (constraints.minWidth - total) / segments.length;
    return <double>[for (final double width in natural) width + extra];
  }

  double _sum(List<double> values) {
    double total = 0;
    for (final double value in values) {
      total += value;
    }
    return total;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _sum(_naturalWidths(_segments, height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _sum(_naturalWidths(_segments, height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _tallestSegment(_segments, double.infinity);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _tallestSegment(_segments, double.infinity);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final List<RenderBox> segments = _segments;
    final double height = _trackHeight(constraints, segments);
    final List<double> widths = _segmentWidths(constraints, segments, height);
    return constraints.constrain(Size(_sum(widths), height));
  }

  @override
  void performLayout() {
    final List<RenderBox> segments = _segments;
    final double height = _trackHeight(constraints, segments);
    final List<double> widths = _segmentWidths(constraints, segments, height);
    final List<double> lefts = <double>[];
    double left = 0;
    for (int index = 0; index < segments.length; index++) {
      final RenderBox segment = segments[index];
      segment.layout(
        BoxConstraints.tightFor(width: widths[index], height: height),
      );
      (segment.parentData! as _SegmentTrackParentData).offset =
          Offset(left, 0);
      lefts.add(left);
      left += widths[index];
    }
    size = constraints.constrain(Size(left, height));
    _layoutIndicator(lefts, widths, height);
  }

  void _layoutIndicator(List<double> lefts, List<double> widths, double height) {
    final RenderBox? indicator = firstChild;
    if (indicator == null) {
      return;
    }
    final _SegmentTrackParentData parentData =
        indicator.parentData! as _SegmentTrackParentData;
    if (widths.isEmpty) {
      indicator.layout(BoxConstraints.tight(Size.zero));
      parentData.offset = Offset.zero;
      return;
    }
    final double position =
        _indicatorPosition.clamp(0, widths.length - 1).toDouble();
    final int from = position.floor();
    final int to = math.min(from + 1, widths.length - 1);
    final double progress = position - from;
    final double width = lerpDouble(widths[from], widths[to], progress)!;
    indicator.layout(BoxConstraints.tightFor(width: width, height: height));
    parentData.offset = Offset(
      lerpDouble(lefts[from], lefts[to], progress)!,
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
