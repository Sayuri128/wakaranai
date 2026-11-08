import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/discover/discover_feed_cubit.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/discover/anilist_discover_client.dart';
import 'package:wakaranai/services/discover/discover_models.dart';
import 'package:wakaranai/ui/discover/discover_feed_view.dart';
import 'package:wakaranai/ui/discover/discover_texts.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/widgets/keep_alive_page.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.client});

  final DiscoverClient? client;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const List<DiscoverCategory> _categories = DiscoverCategory.values;

  final PageController _pageController = PageController();
  final DiscoverSeason _season = DiscoverSeason.of(DateTime.now());
  late final List<DiscoverFeedCubit> _feeds = _createFeeds();
  int _selected = 0;

  List<DiscoverFeedCubit> _createFeeds() {
    final DiscoverClient client = widget.client ?? AniListDiscoverClient();
    final SettingsState settings = context.read<SettingsCubit>().state;
    final bool showNsfw = settings is SettingsInitialized && settings.showNsfw;
    final bool hideTitles = context.read<NsfwTitlesCubit>().state.hideTitles;
    return <DiscoverFeedCubit>[
      for (final DiscoverCategory category in _categories)
        DiscoverFeedCubit(
          client: client,
          category: category,
          includeAdult: showNsfw && !hideTitles,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    unawaited(_feeds.first.start());
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final DiscoverFeedCubit feed in _feeds) {
      unawaited(feed.close());
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _selected = index);
    unawaited(_feeds[index].start());
  }

  void _onTabSelected(int index) {
    unawaited(_pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(),
            Expanded(child: _buildPages()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Text(S.current.discover_title, style: semibold(size: 24)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              S.current.discover_attribution,
              style: regular(size: 12, color: AppColors.mainGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPages() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _categories.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        final DiscoverCategory category = _categories[index];
        return KeepAlivePage(
          key: ValueKey<DiscoverCategory>(category),
          child: BlocProvider<DiscoverFeedCubit>.value(
            value: _feeds[index],
            child: DiscoverFeedView(
              season: category == DiscoverCategory.seasonAnime ? _season : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.overlay(0.06))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: <Widget>[
            Material(
              color: AppColors.overlay(0.06),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: S.current.common_go_back,
                icon:
                    Icon(Icons.arrow_back_rounded, color: AppColors.mainWhite),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SegmentedTabs(
                labels: <String>[
                  for (final DiscoverCategory category in _categories)
                    discoverCategoryLabel(category),
                ],
                selectedIndex: _selected,
                pageController: _pageController,
                semanticsLabel: S.current.discover_title,
                onSelected: _onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
