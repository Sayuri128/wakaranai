import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/widgets/activity_history_long_tap_dialog.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final _pageBucket = PageStorageBucket();

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dayTimeFormat = DateFormat('HH:mm');

  int _currentPage = 0;

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
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Expanded(
              child: PageStorage(
                bucket: _pageBucket,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int index) =>
                      setState(() => _currentPage = index),
                  children: <Widget>[
                    _buildMangaActivities(),
                    _buildAnimeActivities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            S.current.home_navigation_bar_activity_history_title,
            style: semibold(size: 24),
          ),
          const SizedBox(height: 14),
          _buildSegmentedTabs(),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment:
                _currentPage == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _buildSegment(
                  S.current.activity_history_manga_appbar_title, 0),
              _buildSegment(
                  S.current.activity_history_anime_appbar_title, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, int index) {
    final bool selected = _currentPage == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _goToPage(index),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: semibold(
              size: 14,
              color: selected ? AppColors.mainBlack : AppColors.mainGrey,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildMangaActivities() {
    return BlocBuilder<MangaActivityHistoryCubit, ActivityHistoryState>(
      builder: (BuildContext context, ActivityHistoryState state) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundColor,
          onRefresh: () async {
            return context.read<MangaActivityHistoryCubit>().init();
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('manga'),
            slivers: _buildContentSlivers(
              context: context,
              isLoading: state is ActivityHistoryInitial ||
                  state is ActivityHistoryLoading,
              errorMessage:
                  state is ActivityHistoryError ? state.message : null,
              activities: state is ActivityHistoryLoaded
                  ? state.mangaActivities
                  : null,
              emptyMessage:
                  S.current.activity_history_empty_manga_list_message,
              emptyIcon: Icons.auto_stories_rounded,
              onTap: (DayActivityListItem<BaseActivityDomain> day) {
                context.read<MangaActivityHistoryCubit>().onActivityTap(
                      context,
                      concrete: day.data,
                      activity: day.activity,
                    );
              },
              onDelete: (DayActivityListItem<BaseActivityDomain> day) {
                context.read<MangaActivityHistoryCubit>().onDelete(
                      context: context,
                      activity: day.activity,
                    );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimeActivities() {
    return BlocBuilder<AnimeActivityHistoryCubit, AnimeActivityHistoryState>(
      builder: (BuildContext context, AnimeActivityHistoryState state) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundColor,
          onRefresh: () async {
            return context.read<AnimeActivityHistoryCubit>().init();
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('anime'),
            slivers: _buildContentSlivers(
              context: context,
              isLoading: state is AnimeActivityHistoryInitial ||
                  state is AnimeActivityHistoryLoading,
              errorMessage:
                  state is AnimeActivityHistoryError ? state.message : null,
              activities: state is AnimeActivityHistoryLoaded
                  ? state.animeActivities
                  : null,
              emptyMessage:
                  S.current.activity_history_empty_anime_list_message,
              emptyIcon: Icons.movie_rounded,
              onTap: (DayActivityListItem<BaseActivityDomain> day) {
                context.read<AnimeActivityHistoryCubit>().onActivityTap(
                      context,
                      concrete: day.data,
                      activity: day.activity,
                    );
              },
              onDelete: (DayActivityListItem<BaseActivityDomain> day) {
                context.read<AnimeActivityHistoryCubit>().onDelete(
                      context: context,
                      activity: day.activity,
                    );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildContentSlivers({
    required BuildContext context,
    required bool isLoading,
    required String? errorMessage,
    required List<ActivityListItem<BaseActivityDomain>>? activities,
    required String emptyMessage,
    required IconData emptyIcon,
    required void Function(DayActivityListItem<BaseActivityDomain>) onTap,
    required void Function(DayActivityListItem<BaseActivityDomain>) onDelete,
  }) {
    if (isLoading) {
      return <Widget>[
        const SliverToBoxAdapter(child: _ActivityHistorySkeleton()),
      ];
    }

    if (errorMessage != null) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: ServiceViewerMessage(
            icon: Icons.error_outline_rounded,
            title: S.current.activity_history_error_loading_history,
            message: errorMessage,
          ),
        ),
      ];
    }

    if (activities == null || activities.isEmpty) {
      final List<String> parts = emptyMessage.split('\n');
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: ServiceViewerMessage(
            icon: emptyIcon,
            title: parts.first,
            message: parts.length > 1 ? parts.sublist(1).join('\n') : null,
          ),
        ),
      ];
    }

    return <Widget>[
      SliverList.builder(
        itemCount: activities.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildDay(
            context: context,
            item: activities[index],
            onTap: onTap,
            onDelete: onDelete,
          );
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }

  Widget _buildDay({
    required BuildContext context,
    required ActivityListItem<BaseActivityDomain> item,
    required void Function(DayActivityListItem<BaseActivityDomain>) onTap,
    required void Function(DayActivityListItem<BaseActivityDomain>) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: <Widget>[
              Text(
                _dateFormat.format(item.day),
                style: semibold(size: 14, color: AppColors.mainWhite),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
        for (final DayActivityListItem<BaseActivityDomain> listItem
            in item.listItems)
          _buildListItem(
            context: context,
            listItem: listItem,
            onTap: onTap,
            onDelete: onDelete,
          ),
      ],
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required DayActivityListItem<BaseActivityDomain> listItem,
    required void Function(DayActivityListItem<BaseActivityDomain>) onTap,
    required void Function(DayActivityListItem<BaseActivityDomain>) onDelete,
  }) {
    final BaseActivityDomain activity = listItem.activity;
    final bool hasProgress = activity is ChapterActivityDomain &&
        activity.totalPages != 0;
    final double progress = hasProgress
        ? (activity.readPages / activity.totalPages).clamp(0.0, 1.0)
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: () => onTap(listItem),
          onLongPress: () =>
              _showActivityDialog(context, listItem: listItem, onDelete: onDelete),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildCover(listItem.data.cover),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              listItem.data.title.trim(),
                              style: semibold(size: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dayTimeFormat.format(
                                activity.updatedAt ?? activity.createdAt),
                            style: medium(size: 12, color: AppColors.mainGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activity.title.trim(),
                        style: regular(size: 13, color: AppColors.mainGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasProgress) ...<Widget>[
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${activity.readPages}/${activity.totalPages}",
                              style: regular(
                                  size: 11, color: AppColors.mainGrey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(String? cover) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 52,
        height: 74,
        child: (cover == null || cover.isEmpty)
            ? _buildCoverPlaceholder()
            : CachedNetworkImage(
                imageUrl: cover,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    _buildCoverPlaceholder(),
                errorWidget:
                    (BuildContext context, String url, Object error) =>
                        _buildCoverPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return const ColoredBox(
      color: Color(0xFF3A3A3A),
      child: Center(
        child: Icon(Icons.image_rounded, color: Colors.white24, size: 20),
      ),
    );
  }

  void _showActivityDialog(
    BuildContext context, {
    required DayActivityListItem<BaseActivityDomain> listItem,
    required void Function(DayActivityListItem<BaseActivityDomain>) onDelete,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) =>
          ActivityHistoryLongTapDialog<BaseActivityDomain>(
              domain: listItem.activity, onDelete: () => onDelete(listItem)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ActivityHistorySkeleton extends StatelessWidget {
  const _ActivityHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int group = 0; group < 2; group++) ...<Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: ShimmerBox(width: 120, height: 14, borderRadius: 6),
            ),
            for (int i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    ShimmerBox(width: 52, height: 74, borderRadius: 10),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShimmerBox(width: 180, height: 14, borderRadius: 6),
                          SizedBox(height: 10),
                          ShimmerBox(width: 100, height: 12, borderRadius: 6),
                          SizedBox(height: 12),
                          ShimmerBox(
                              width: double.infinity,
                              height: 4,
                              borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
