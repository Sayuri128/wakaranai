import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef SwitcherWidgetOnChanged = Function(bool);

class SwitcherWidget extends StatefulWidget {
  const SwitcherWidget(
      {Key? key,
      required this.on,
      required this.paramName,
      required this.onChanged,
      required this.onValue,
      required this.offValue})
      : super(key: key);

  final String paramName;
  final bool on;
  final String onValue;
  final String offValue;
  final SwitcherWidgetOnChanged onChanged;

  @override
  State<SwitcherWidget> createState() => _SwitcherWidgetState();
}

class _SwitcherWidgetState extends State<SwitcherWidget>
    with TickerProviderStateMixin {
  static const switcherWidth = 80.0;

  bool _on = false;

  late final AnimationController _switcherAnimationController;
  late final Animation<double> _switcherAnimation;

  @override
  void initState() {
    super.initState();
    _on = widget.on;

    _switcherAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _switcherAnimation =
        Tween<double>(begin: -(switcherWidth / 4), end: (switcherWidth / 4))
            .animate(CurveTween(curve: Curves.easeInOutCubic)
                .animate(_switcherAnimationController))
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    super.dispose();

    _switcherAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.paramName,
          style: medium(size: 16),
        ),
        InkWell(
          onTap: () {
            _on = !_on;
            if (_on) {
              _switcherAnimationController.forward();
            } else {
              _switcherAnimationController.reverse();
            }
            widget.onChanged(_on);
            setState(() {});
          },
          child: Row(
            children: [
              Text(
                widget.offValue,
                style: regular(),
              ),
              const SizedBox(
                width: 12,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: switcherWidth,
                height: 32,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.0),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 2)
                    ],
                    color:
                        _on ? AppColors.secondary : AppColors.backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Transform.translate(
                    offset: Offset(_switcherAnimation.value, 0),
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                          boxShadow: [
                            if (_on)
                              BoxShadow(
                                  color: AppColors.mediumLight.withOpacity(0.3),
                                  spreadRadius: 4,
                                  blurRadius: 4)
                          ],
                          color:
                              _on ? AppColors.mainWhite : AppColors.secondary,
                          shape: BoxShape.circle),
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _on
                                  ? AppColors.secondary
                                  : AppColors.backgroundColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                widget.onValue,
                style: regular(),
              )
            ],
          ),
        )
      ],
    );
  }
}
