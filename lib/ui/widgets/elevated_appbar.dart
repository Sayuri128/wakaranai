import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ElevatedAppbar extends StatelessWidget {
  const ElevatedAppbar({super.key, this.leading, this.title, this.actions});

  final Widget? leading;
  final Widget? title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.mainWhite,
        shadowColor: AppColors.shadowColor,
        surfaceTintColor: AppColors.backgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        elevation: 16.0,
        snap: true,
        floating: true,
        pinned: true,
        title: Stack(
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
        ));
  }
}
