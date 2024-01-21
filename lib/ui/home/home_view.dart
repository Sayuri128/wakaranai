import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/configs_page.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';
import 'package:wakaranai/ui/home/settings/settings_page.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final navigationItem = [
    // NavigationDestination(
    //     label: S.current.navigation_bar_library_title,
    //     icon: const Icon(Icons.my_library_books)),
    NavigationDestination(
        label: S.current.navigation_bar_sources_title,
        icon: const Icon(
          Icons.home_filled,
        )),
    NavigationDestination(
      label: S.current.navigation_bar_settings_title,
      icon: const Icon(
        Icons.settings,
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageCubit, HomePageState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBodyBehindAppBar: true,
          bottomNavigationBar: NavigationBar(
            elevation: 4,
            selectedIndex: state.currentPage,
            onDestinationSelected: (value) {
              context.read<HomePageCubit>().changePage(value);
            },
            surfaceTintColor: AppColors.backgroundColor.withOpacity(0.4),
            height: 70,
            backgroundColor: AppColors.backgroundColor.withOpacity(0.4),
            animationDuration: const Duration(milliseconds: 400),
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
            child: _buildBody(state.currentPage),
          ),
        );
      },
    );
  }

  Widget _buildBody(int page) {
    switch (page) {
      // case 0:
      //   return LibraryPage();
      case 0:
        return ConfigPage();
      case 1:
        return SettingsPage();
    }
    return const SizedBox();
  }
}

void showNotificationSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.backgroundColor,
      content: Text(
        message,
        style: medium(size: 16),
      )));
}
