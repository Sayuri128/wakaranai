import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class SwitchIconButton extends StatelessWidget {
  const SwitchIconButton(
      {super.key,
      required this.state,
      required this.onTap,
      required this.iconOn});

  final Widget iconOn;

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
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: AppColors.mainBlack.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2)
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: state ? 0.5 : 0,
              curve: Curves.easeOutCubic,
              child: iconOn,
            ),
          ),
        ));
  }
}
