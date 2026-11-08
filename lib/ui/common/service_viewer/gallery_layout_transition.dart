import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';

typedef GalleryLayoutBuilder =
    Widget Function(
      BuildContext context,
      GalleryLayout layout,
      GalleryMorph? morph,
    );

class GalleryLayoutTransition extends StatefulWidget {
  const GalleryLayoutTransition({
    super.key,
    required this.layout,
    required this.geometry,
    required this.position,
    required this.builder,
  });

  final GalleryLayout layout;
  final GalleryGeometry geometry;
  final ScrollPosition? Function() position;
  final GalleryLayoutBuilder builder;

  @override
  State<GalleryLayoutTransition> createState() =>
      _GalleryLayoutTransitionState();
}

class _GalleryLayoutTransitionState extends State<GalleryLayoutTransition>
    with TickerProviderStateMixin {
  static const Duration _fadeOut = Duration(milliseconds: 110);
  static const Duration _fadeIn = Duration(milliseconds: 220);
  static const Duration _morphDuration = Duration(milliseconds: 380);
  static const double _startScale = 0.96;

  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 1,
  );
  late final AnimationController _morphProgress = AnimationController(
    vsync: this,
    duration: _morphDuration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _fade,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: _startScale,
    end: 1,
  ).animate(_opacity);

  late GalleryLayout _shown = widget.layout;
  GalleryMorph? _morph;
  bool _switching = false;

  @override
  void didUpdateWidget(GalleryLayoutTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layout != _shown && !_switching) {
      unawaited(_switchLayout());
    }
  }

  Future<void> _switchLayout() async {
    _switching = true;
    try {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
      final GalleryLayout from = _shown;
      final GalleryLayout to = widget.layout;
      if (from != GalleryLayout.list && to != GalleryLayout.list) {
        await _morphGrids(from, to);
      } else {
        await _fadeThrough(from, to);
      }
    } on TickerCanceled {
      return;
    } finally {
      _switching = false;
    }
    if (mounted && widget.layout != _shown) {
      unawaited(_switchLayout());
    }
  }

  Future<void> _morphGrids(GalleryLayout from, GalleryLayout to) async {
    final Size? size = context.size;
    final ScrollPosition? position = widget.position();
    if (size == null || position == null || !position.hasPixels) {
      setState(() => _shown = to);
      return;
    }
    final double fromScroll = position.pixels;
    final double toScroll = carryScrollOffset(
      widget.geometry,
      from: from,
      to: to,
      width: size.width,
      offset: fromScroll,
    );
    position.correctPixels(toScroll);
    _morphProgress.value = 0;
    setState(() {
      _shown = to;
      _morph = GalleryMorph(
        geometry: widget.geometry,
        from: from,
        to: to,
        viewport: size,
        fromScroll: fromScroll,
        toScroll: toScroll,
        progress: _morphProgress,
        position: widget.position,
      );
    });
    await _morphProgress.forward().orCancel;
    if (mounted) {
      setState(() => _morph = null);
    }
  }

  Future<void> _fadeThrough(GalleryLayout from, GalleryLayout to) async {
    await _fade.animateBack(0, duration: _fadeOut).orCancel;
    if (!mounted) {
      return;
    }
    final Size? size = context.size;
    final ScrollPosition? position = widget.position();
    setState(() => _shown = to);
    if (size != null && position != null && position.hasPixels) {
      jumpAfterLayout(
        widget.position,
        carryScrollOffset(
          widget.geometry,
          from: from,
          to: to,
          width: size.width,
          offset: position.pixels,
        ),
      );
    }
    await _fade.animateTo(1, duration: _fadeIn).orCancel;
  }

  @override
  void dispose() {
    _fade.dispose();
    _morphProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: widget.builder(context, _shown, _morph),
      ),
    );
  }
}

class GalleryMorph {
  GalleryMorph({
    required this.geometry,
    required this.from,
    required this.to,
    required this.viewport,
    required this.fromScroll,
    required this.toScroll,
    required this.progress,
    required this.position,
  });

  static const double _enterOffset = 48;

  final GalleryGeometry geometry;
  final GalleryLayout from;
  final GalleryLayout to;
  final Size viewport;
  final double fromScroll;
  final double toScroll;
  final Animation<double> progress;
  final ScrollPosition? Function() position;

  double get _t => Curves.easeInOutCubic.transform(progress.value);

  double get _currentScroll {
    final ScrollPosition? current = position();
    if (current == null || !current.hasPixels) {
      return toScroll;
    }
    return current.pixels;
  }

  bool _onScreen(Rect rect) => rect.bottom > 0 && rect.top < viewport.height;

  ({Matrix4 transform, double opacity}) frameFor(int index) {
    final double width = viewport.width;
    final double t = _t;
    final Rect target = geometry
        .cellRect(to, width, index)
        .translate(0, -_currentScroll);
    Rect origin = geometry
        .cellRect(from, width, index)
        .translate(0, -fromScroll);
    double opacity = 1;
    if (!_onScreen(origin)) {
      origin = target.translate(0, _enterOffset);
      opacity = t;
    }
    final Rect current = Rect.lerp(origin, target, t)!;
    final Matrix4 transform = Matrix4.identity()
      ..translateByDouble(
        current.left - target.left,
        current.top - target.top,
        0,
        1,
      )
      ..scaleByDouble(
        current.width / max(1, target.width),
        current.height / max(1, target.height),
        1,
        1,
      );
    return (transform: transform, opacity: opacity);
  }
}

class GalleryMorphCell extends StatelessWidget {
  const GalleryMorphCell({
    super.key,
    required this.morph,
    required this.index,
    required this.child,
  });

  final GalleryMorph? morph;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final GalleryMorph? active = morph;
    if (active == null) {
      return child;
    }
    return AnimatedBuilder(
      animation: active.progress,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final ({Matrix4 transform, double opacity}) frame = active.frameFor(
          index,
        );
        return Opacity(
          opacity: frame.opacity.clamp(0.0, 1.0),
          child: Transform(transform: frame.transform, child: child),
        );
      },
    );
  }
}

abstract class GalleryGeometry {
  const GalleryGeometry();

  double get topPadding;

  double get leftPadding;

  int columns(GalleryLayout layout, double width);

  double rowStride(GalleryLayout layout, double width);

  double crossSpacing(GalleryLayout layout);

  Size cellSize(GalleryLayout layout, double width);

  Rect cellRect(GalleryLayout layout, double width, int index) {
    final int count = columns(layout, width);
    final Size size = cellSize(layout, width);
    final int column = index % count;
    final int row = index ~/ count;
    return Rect.fromLTWH(
      leftPadding + column * (size.width + crossSpacing(layout)),
      topPadding + row * rowStride(layout, width),
      size.width,
      size.height,
    );
  }
}

class ServiceGalleryGeometry extends GalleryGeometry {
  const ServiceGalleryGeometry();

  @override
  double get topPadding => kGalleryGridPadding.top;

  @override
  double get leftPadding => kGalleryGridPadding.left;

  double _usableWidth(double width) =>
      max(1, width - kGalleryGridPadding.left - kGalleryGridPadding.right);

  SliverGridDelegateWithMaxCrossAxisExtent _delegate(GalleryLayout layout) =>
      galleryGridDelegateFor(layout)
          as SliverGridDelegateWithMaxCrossAxisExtent;

  @override
  int columns(GalleryLayout layout, double width) {
    if (layout == GalleryLayout.list) {
      return 1;
    }
    final SliverGridDelegateWithMaxCrossAxisExtent delegate = _delegate(layout);
    return max(
      1,
      (_usableWidth(width) /
              (delegate.maxCrossAxisExtent + delegate.crossAxisSpacing))
          .ceil(),
    );
  }

  @override
  double crossSpacing(GalleryLayout layout) {
    if (layout == GalleryLayout.list) {
      return 0;
    }
    return _delegate(layout).crossAxisSpacing;
  }

  @override
  Size cellSize(GalleryLayout layout, double width) {
    if (layout == GalleryLayout.list) {
      return Size(_usableWidth(width), kGalleryListRowHeight);
    }
    final SliverGridDelegateWithMaxCrossAxisExtent delegate = _delegate(layout);
    final int count = columns(layout, width);
    final double childWidth =
        (_usableWidth(width) - delegate.crossAxisSpacing * (count - 1)) / count;
    return Size(childWidth, childWidth / delegate.childAspectRatio);
  }

  @override
  double rowStride(GalleryLayout layout, double width) {
    if (layout == GalleryLayout.list) {
      return kGalleryListRowHeight + kGalleryListRowSpacing;
    }
    return cellSize(layout, width).height + _delegate(layout).mainAxisSpacing;
  }
}

double carryScrollOffset(
  GalleryGeometry geometry, {
  required GalleryLayout from,
  required GalleryLayout to,
  required double width,
  required double offset,
}) {
  if (offset <= geometry.topPadding) {
    return offset;
  }
  final double fromStride = geometry.rowStride(from, width);
  final double rows = (offset - geometry.topPadding) / fromStride;
  final int row = rows.floor();
  final double withinRow = rows - row;
  final int firstIndex = row * geometry.columns(from, width);
  final int targetRow = firstIndex ~/ geometry.columns(to, width);
  return geometry.topPadding +
      (targetRow + withinRow) * geometry.rowStride(to, width);
}

void jumpAfterLayout(ScrollPosition? Function() position, double target) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ScrollPosition? current = position();
    if (current == null || !current.hasContentDimensions) {
      return;
    }
    current.jumpTo(
      clampDouble(target, current.minScrollExtent, current.maxScrollExtent),
    );
  });
}
