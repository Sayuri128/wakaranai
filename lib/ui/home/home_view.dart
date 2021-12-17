import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/ui/home/gallery/gallery_view.dart';
import 'package:h_reader/ui/home/settings/settings_view.dart';
import 'package:h_reader/ui/widgets/appbar.dart';
import 'package:h_reader/ui/widgets/bottom_navigation.dart';
import 'package:h_reader/utils/app_colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<String> appBarTitles = [S.current.app_name, S.current.settings_title];
    List<Widget> widgets = [const GalleryView(), SettingsView()];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: buildAppBar(title: appBarTitles[_currentPage]),
      body: widgets.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigation(onTap: (index) {
        setState(() {
          _currentPage = index;
        });
      }),
    );
  }
}
