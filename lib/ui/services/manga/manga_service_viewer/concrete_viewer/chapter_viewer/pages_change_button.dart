import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class PagesChangeButton extends StatefulWidget {
  const PagesChangeButton({super.key, required this.onTap, required this.icon});

  final VoidCallback onTap;
  final Widget icon;

  @override
  State<PagesChangeButton> createState() => _PagesChangeButtonState();
}

class _PagesChangeButtonState extends State<PagesChangeButton>
    with TickerProviderStateMixin {
  late final AnimationController _shadowAnimationController;
  late final AnimationController _colorAnimationController;

  late final Animation<double> _shadowAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _colorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _colorAnimation =
        ColorTween(begin: AppColors.secondary, end: AppColors.mediumLight)
            .animate(CurveTween(curve: Curves.easeInOutCubic)
                .animate(_colorAnimationController))
          ..addListener(_animationListener);

    _shadowAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true)
          ..forward();

    _shadowAnimation = Tween<double>(begin: 1, end: 4).animate(
        CurveTween(curve: Curves.easeInOutCubic)
            .animate(_shadowAnimationController))
      ..addListener(_animationListener);
  }

  void _animationListener() {
    setState(() {});
  }

  @override
  void dispose() {
    _colorAnimationController
      ..stop()
      ..removeListener(_animationListener)
      ..dispose();
    _shadowAnimationController
      ..stop()
      ..removeListener(_animationListener)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: _colorAnimation.value,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: _colorAnimation.value ?? AppColors.primary,
                  spreadRadius: _shadowAnimation.value,
                  blurRadius: _shadowAnimation.value * 3)
            ],
            shape: BoxShape.circle),
        child: widget.icon,
      ),
    );
  }
}
