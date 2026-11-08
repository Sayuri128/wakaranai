import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/downloads_page/downloads_page.dart';
import 'package:wakaranai/ui/home/library_page/library_page.dart';
import 'package:wakaranai/ui/widgets/keep_alive_page.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';
import 'package:wakaranai/utils/app_colors.dart';

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({super.key});

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends State<LibraryHomePage> {
  static const int _titlesPage = 0;
  static const int _downloadsPage = 1;

  final PageController _pageController = PageController();
  int _currentPage = _titlesPage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _buildTabBar(context),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) =>
                    setState(() => _currentPage = index),
                children: <Widget>[
                  KeepAlivePage(child: LibraryPage(embedded: true)),
                  KeepAlivePage(child: DownloadsPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final int activeDownloads = context.select(
      (DownloadManagerCubit cubit) => cubit.state.active.length,
    );
    final int activeTranslations = context.select(
      (ChapterTranslationCubit cubit) => cubit.state.activeJobs.length,
    );
    final bool hasDownloads = context.select(
      (DownloadManagerCubit cubit) => cubit.state.downloads.isNotEmpty,
    );
    final bool showDeleteAll = _currentPage == _downloadsPage && hasDownloads;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SegmentedTabs(
              selectedIndex: _currentPage,
              labels: <String>[
                S.current.library_tab_titles,
                S.current.downloads_title,
              ],
              badges: <int>[0, activeDownloads + activeTranslations],
              onSelected: _goToPage,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: showDeleteAll
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _CircleButton(
                      icon: Icons.delete_sweep_outlined,
                      onTap: () => confirmDeleteAllDownloads(context),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: AppColors.mainWhite),
        ),
      ),
    );
  }
}
