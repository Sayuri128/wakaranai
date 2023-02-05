import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/anime_debug/anime_debug.dart';
import 'package:wakaranai/ui/home/history_page.dart';
import 'package:wakaranai/ui/home/remote_configs_page.dart';
import 'package:wakaranai/ui/home/settings_page.dart';
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
        title: S.current.navigation_bar_sources_title,
        build: (context) => const RemoteConfigPage(),
        icon: const Icon(
          Icons.home_filled,
        )),
    BottomNavigationItem(
        index: 1,
        title: S.current.navigation_bar_history_title,
        build: (context) => const HistoryPage(),
        icon: const Icon(
          Icons.history,
        )),
    BottomNavigationItem(
        index: 2,
        title: S.current.navigation_bar_settings_title,
        build: (context) => SettingsPage(),
        icon: const Icon(
          Icons.settings,
        )),
    BottomNavigationItem(
        index: 3,
        title: "Anime debug",
        build: (context) => AnimeDebug(),
        icon: const Icon(
          Icons.video_call,
        ))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          selectedItemColor: AppColors.primary,
          selectedLabelStyle: medium(size: 14, color: AppColors.primary),
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          showSelectedLabels: true,
          unselectedLabelStyle: medium(size: 14, color: AppColors.mainWhite),
          unselectedIconTheme: const IconThemeData(color: AppColors.mainWhite),
          type: BottomNavigationBarType.shifting,
          onTap: (i) {
            _currentPage = i;
            setState(() {});
          },
          items: navigationItem.map((e) => e.toBarItem()).toList()),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
          child: navigationItem[_currentPage].build(context)),
    );
  }
}
