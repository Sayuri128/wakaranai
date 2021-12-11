import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/utils/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0))),
        backgroundColor: AppColors.accentGreen,
        centerTitle: true,
        title: Text(S.current.app_name),
      ),
      body: const SizedBox(),
    );
  }
}
