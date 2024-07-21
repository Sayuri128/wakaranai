import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/activity_history_page/acitvity_history_page.dart';
import 'package:wakaranai/ui/home/configs_page/configs_page.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_page.dart';
import 'package:wakaranai/ui/home/widgets/bottom_navigation_bar_container.dart';
import 'package:wakaranai/ui/home/widgets/bottom_navigation_bar_item_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageStorageBucket bucket = PageStorageBucket();
  final PageController _pageController = PageController();

  final List<BottomNavigationBarItemWidgetData> navigationItem =
      <BottomNavigationBarItemWidgetData>[
    BottomNavigationBarItemWidgetData(
      text: S.current.home_navigation_bar_sources_title,
      icon: Icons.explore_rounded,
    ),
    BottomNavigationBarItemWidgetData(
      text: S.current.home_navigation_bar_activity_history_title,
      icon: Icons.history_rounded,
    ),
    BottomNavigationBarItemWidgetData(
      text: S.current.home_navigation_bar_settings_title,
      icon: Icons.settings,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: bucket,
      child: BlocConsumer<HomePageCubit, HomePageState>(
        listener: (BuildContext context, HomePageState state) {
          _pageController.animateToPage(
            state.currentPage,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 200),
          );
        },
        builder: (BuildContext context, HomePageState state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            extendBodyBehindAppBar: true,
            body: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: navigationItem.length,
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildBody(
                        index,
                      );
                    },
                  ),
                ),
                BottomNavigationBarContainer(
                  data: navigationItem,
                  currentIndex: state.currentPage,
                  onTap: (int index) {
                    context.read<HomePageCubit>().changePage(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(int page) {
    switch (page) {
      // case 0:
      //   return LibraryPage();
      case 0:
        return ConfigPage(
          key: const PageStorageKey<String>('configs_page'),
        );
      case 1:
        return const ActivityHistoryPage(
          key: PageStorageKey<String>('activity_history_page'),
        );
      case 2:
        return const SettingsPage(
          key: PageStorageKey<String>('settings_page'),
        );
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
