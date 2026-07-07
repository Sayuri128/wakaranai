import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/utils/app_colors.dart';

/// Wraps a scrollable [child] and overlays a "scroll to top" button that fades
/// in once the user has scrolled down past [threshold]. Scrolling is driven
/// through the [refreshController]'s attached position, so it composes with
/// [SmartRefresher] without needing a second [ScrollController].
class ScrollToTopArea extends StatefulWidget {
  const ScrollToTopArea({
    super.key,
    required this.refreshController,
    required this.child,
    this.threshold = 800,
  });

  final RefreshController refreshController;
  final Widget child;
  final double threshold;

  @override
  State<ScrollToTopArea> createState() => _ScrollToTopAreaState();
}

class _ScrollToTopAreaState extends State<ScrollToTopArea> {
  bool _visible = false;

  bool _onNotification(ScrollNotification notification) {
    final bool shouldShow = notification.metrics.pixels > widget.threshold;
    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
    return false;
  }

  void _scrollToTop() {
    widget.refreshController.position?.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: widget.child,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: _visible ? 1 : 0,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              onPressed: _scrollToTop,
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
