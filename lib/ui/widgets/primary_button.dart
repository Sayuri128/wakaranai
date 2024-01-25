import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      this.padding,
      required this.title,
      this.color,
      this.onPressed});

  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(color ?? AppColors.primary)),
          child: Text(title, style: medium()),
        ));
  }
}
