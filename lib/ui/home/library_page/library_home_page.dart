import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/downloads_page/downloads_page.dart';
import 'package:wakaranai/ui/home/library_page/library_page.dart';
import 'package:wakaranai/ui/widgets/keep_alive_page.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

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
            child: _SegmentedTabs(
              current: _currentPage,
              labels: <String>[
                S.current.library_tab_titles,
                S.current.downloads_title,
              ],
              badges: <int>[0, activeDownloads + activeTranslations],
              onTap: _goToPage,
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

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.current,
    required this.labels,
    required this.badges,
    required this.onTap,
  });

  final int current;
  final List<String> labels;
  final List<int> badges;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: <Widget>[
          _buildIndicator(),
          Row(
            children: <Widget>[
              for (int i = 0; i < labels.length; i++)
                Expanded(child: _buildTab(i)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: current == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 1 / labels.length,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final bool selected = index == current;
    final int badge = badges[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              labels[index],
              style: semibold(
                size: 14,
                color: selected ? AppColors.mainBlack : AppColors.mainGrey,
              ),
            ),
            if (badge > 0) ...<Widget>[
              const SizedBox(width: 6),
              _buildBadge(badge, selected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count, bool selected) {
    final Color background = selected
        ? AppColors.mainBlack.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: semibold(
          size: 11,
          color: selected ? AppColors.mainBlack : AppColors.primary,
        ),
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
