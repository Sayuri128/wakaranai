import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimePlayerButton extends StatelessWidget {
  const AnimePlayerButton(
      {Key? key,
      required this.title,
      required this.onClick,
      required this.selected})
      : super(key: key);

  final String title;
  final bool selected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.zero,
        color: selected ? AppColors.primary : null,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: medium(size: 16)),
          ),
        ));
  }
}
