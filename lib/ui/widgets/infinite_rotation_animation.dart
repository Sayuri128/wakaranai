import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfiniteRotationAnimation extends StatefulWidget {
  const InfiniteRotationAnimation({super.key, required this.child});

  final Widget child;

  @override
  State<InfiniteRotationAnimation> createState() =>
      _InfiniteRotationAnimationState();
}

class _InfiniteRotationAnimationState extends State<InfiniteRotationAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _rotationTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..repeat()
      ..addListener(() {
        if (!mounted) return;
        setState(() {});
      });
    _rotationTween = Tween<double>(begin: 0, end: 2 * pi)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _rotationTween.value,
      child: widget.child,
    );
  }
}
