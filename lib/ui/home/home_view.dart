import 'package:flutter/material.dart';
import 'package:wakaranai/ui/home/local_configs_page.dart';
import 'package:wakaranai/ui/home/remote_configs_page.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BottomNavigationItem {
  final int index;
  final Icon icon;
  final String title;
  final Function(BuildContext) build;

  const BottomNavigationItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.build,
  });

  BottomNavigationBarItem toBarItem() =>
      BottomNavigationBarItem(icon: icon, label: title);
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentPage = 0;

  final navigationItem = [
    BottomNavigationItem(
        index: 0,
        title: 'Remote',
        build: (context) => const RemoteConfigPage(),
        icon: const Icon(
          Icons.home,
        )),
    BottomNavigationItem(
        index: 1,
        title: 'Local',
        build: (context) => const LocalConfigsPage(),
        icon: const Icon(
          Icons.home,
        ))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          selectedLabelStyle: medium(size: 14, color: AppColors.accentGreen),
          selectedIconTheme: const IconThemeData(color: AppColors.accentGreen),
          unselectedLabelStyle: medium(size: 14, color: AppColors.mainWhite),
          unselectedIconTheme: const IconThemeData(color: AppColors.mainWhite),
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            _currentPage = i;
            setState(() {});
          },
          items: navigationItem.map((e) => e.toBarItem()).toList()),
      body: navigationItem[_currentPage].build(context),
    );
  }
}
