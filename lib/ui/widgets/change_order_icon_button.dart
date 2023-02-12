import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ChangeOrderIconButton extends StatelessWidget {
  const ChangeOrderIconButton(
      {Key? key, required this.state, required this.onTap})
      : super(key: key);

  final bool state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.mainBlack.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 2)
            ]),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(64),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: state
                    ? Icon(Icons.filter_list_rounded)
                    : Transform.rotate(
                        angle: pi / 1,
                        child: Icon(Icons.filter_list_rounded),
                      )),
          ),
        ));
  }
}
