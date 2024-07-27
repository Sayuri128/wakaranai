import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimePlayerButton extends StatefulWidget {
  const AnimePlayerButton(
      {super.key,
      required this.title,
      required this.onClick,
      required this.selected});

  final String title;
  final bool selected;
  final VoidCallback onClick;

  @override
  State<AnimePlayerButton> createState() => _AnimePlayerButtonState();
}

class _AnimePlayerButtonState extends State<AnimePlayerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final ColorTween _colorTween = ColorTween(
    begin: AppColors.backgroundColor,
    end: AppColors.primary,
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      reverseDuration: const Duration(milliseconds: 300),
    );

    _colorTween.animate(_controller);

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimePlayerButton oldWidget) {
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Card(
            elevation: 8.0,
            margin: EdgeInsets.zero,
            color: _colorTween.evaluate(_controller),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0)),
            child: child!,
          );
        },
        child: InkWell(
          onTap: widget.onClick,
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.title, style: medium(size: 16)),
          ),
        ));
  }
}
