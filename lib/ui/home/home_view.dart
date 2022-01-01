import 'package:flutter/material.dart';
import 'package:wakaranai/ui/widgets/appbar.dart';
import 'package:wakaranai/utils/app_colors.dart';

class BottomNavigationItem {
  final String title;
  final Widget widget;

  const BottomNavigationItem({
    required this.title,
    required this.widget,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: buildAppBar(),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SingleChildScrollView(
                  child: Row(
                children: [

                ],
              ))
            ],
          )),
    );
  }
}
