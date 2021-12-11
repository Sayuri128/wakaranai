import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/ui/home/gallery/gallery_view.dart';
import 'package:h_reader/ui/widgets/bottom_navigation.dart';
import 'package:h_reader/utils/app_colors.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      const GalleryView(),
      Center(
        child: Text('settings'),
      )
    ];

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
      body: widgets.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigation(onTap: (index) {
        setState(() {
          _currentPage = index;
        });
      }),
    );
  }
}
