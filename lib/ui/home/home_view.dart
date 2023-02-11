import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/remote_configs_page.dart';
import 'package:wakaranai/ui/home/library/library_page.dart';
import 'package:wakaranai/ui/home/settings/settings_page.dart';
import 'package:wakaranai/utils/app_colors.dart';

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
    NavigationDestination(
      label: S.current.navigation_bar_library_title,
      icon: const Icon(
        Icons.my_library_books
      )
    ),
    NavigationDestination(
      label: S.current.navigation_bar_sources_title,
      icon: const Icon(
        Icons.home_filled,
      )
    ),
    NavigationDestination(
      label: S.current.navigation_bar_settings_title,
      icon: const Icon(
        Icons.settings,
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: NavigationBar(
        elevation: 4,
        selectedIndex: _currentPage,
        onDestinationSelected: (value) {
          _currentPage = value;
          setState(() {});
        },
        surfaceTintColor: AppColors.backgroundColor.withOpacity(0.4),
        height: 70,
        backgroundColor: AppColors.backgroundColor.withOpacity(0.4),
        animationDuration: Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        shadowColor: AppColors.mainBlack.withOpacity(0.4),
        destinations: navigationItem,
      ),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
          child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case 0:
        return LibraryPage();
      case 1:
        return RemoteConfigPage();
      case 2:
        return SettingsPage();
    }
    return const SizedBox();
  }
}
