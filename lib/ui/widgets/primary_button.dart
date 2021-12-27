import 'package:flutter/material.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({Key? key, this.padding, required this.title, this.color, this.onPressed})
      : super(key: key);

  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(color ?? AppColors.accentGreen)),
          child: Text(title, style: medium()),
        ));
  }
}
