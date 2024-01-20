import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class SwitchIconButton extends StatelessWidget {
  const SwitchIconButton(
      {Key? key,
      required this.state,
      required this.onTap,
      required this.iconOff,
      required this.iconOn})
      : super(key: key);

  final Widget iconOn;
  final Widget iconOff;

  final bool state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Container(
          decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              backgroundBlendMode: BlendMode.dstATop,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.mainBlack.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2)
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: state ? iconOn : iconOff),
          ),
        ));
  }
}
