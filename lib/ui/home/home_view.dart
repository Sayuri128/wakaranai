import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/ui/home/gallery/gallery_view.dart';
import 'package:h_reader/ui/home/settings/settings_view.dart';
import 'package:h_reader/ui/widgets/appbar.dart';
import 'package:h_reader/ui/widgets/bottom_navigation.dart';
import 'package:h_reader/utils/app_colors.dart';

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
  List<BottomNavigationItem> navigationBarItems = [
    BottomNavigationItem(widget: const GalleryView(), title: S.current.app_name),
    BottomNavigationItem(widget: const SettingsView(), title: S.current.settings_title),
  ];

  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    ;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: buildAppBar(title: navigationBarItems[_currentPage].title),
      body: navigationBarItems[_currentPage].widget,
      bottomNavigationBar: BottomNavigation(onTap: (index) {
        setState(() {
          _currentPage = index;
        });
      }),
    );
  }
}
