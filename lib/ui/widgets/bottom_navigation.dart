import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/utils/app_colors.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key, required this.onTap}) : super(key: key);

  final Function(int) onTap;

  @override
  State<BottomNavigation> createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedFontSize: 16,
      unselectedFontSize: 14,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 20),
      backgroundColor: AppColors.accentGreen,
      selectedItemColor: AppColors.mainBlack,
      unselectedItemColor: AppColors.mainBlack,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.chrome_reader_mode_rounded),
            label: S.current.bottom_navigation_reader_menu_title,
            backgroundColor: AppColors.accentGreen),
        BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: S.current.bottom_navigation_settings_menu_title,
            backgroundColor: AppColors.accentGreen)
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          widget.onTap.call(index);
        });
      },
    );
  }
}
