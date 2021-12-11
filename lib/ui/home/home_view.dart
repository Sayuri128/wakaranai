import 'package:flutter/material.dart';
import 'package:h_reader/utils/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).padding.top * 2,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0))),
        backgroundColor: AppColors.accentGreen,
        centerTitle: true,
        title: Text('HReader'),
      ),
      body: Text('home'),
    );
  }
}
