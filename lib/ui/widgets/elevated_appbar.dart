import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ElevatedAppbar extends StatelessWidget {
  const ElevatedAppbar({super.key, this.leading, this.title, this.actions});

  final Widget? leading;
  final Widget? title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppColors.mainBlack.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2)
          ]),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: title,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: actions,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: leading,
            )
          ],
        ),
      ),
    );
  }
}
