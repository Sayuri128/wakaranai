import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BottomNavigationBarItemWidgetData {
  final IconData icon;
  final String text;

  const BottomNavigationBarItemWidgetData({
    required this.icon,
    required this.text,
  });
}

class BottomNavigationBarItemWidget extends StatefulWidget {
  const BottomNavigationBarItemWidget({
    super.key,
    required this.data,
    this.selected = false,
    required this.index,
    required this.borderRadius,
  });

  final BottomNavigationBarItemWidgetData data;
  final int index;
  final bool selected;
  final BorderRadius borderRadius;

  @override
  State<BottomNavigationBarItemWidget> createState() =>
      _BottomNavigationBarItemWidgetState();
}

class _BottomNavigationBarItemWidgetState
    extends State<BottomNavigationBarItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final ColorTween _colorTween = ColorTween(
    begin: AppColors.primary,
    end: AppColors.backgroundColor,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationBarItemWidget oldWidget) {
    if (widget != oldWidget) {}
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<HomePageCubit>().changePage(widget.index);
        },
        borderRadius: widget.borderRadius,
        splashColor: AppColors.primary.withOpacity(0.8),
        child: Ink(
          height: 48,
          color: AppColors.backgroundColor,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Icon(
              widget.data.icon,
              color: _colorTween.evaluate(_controller),
            ),
          ),
        ),
      ),
    );
  }
}
