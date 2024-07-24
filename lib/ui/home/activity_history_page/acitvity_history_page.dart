import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/widgets/activity_history_long_tap_dialog.dart';
import 'package:wakaranai/ui/widgets/elevated_appbar.dart';
import 'package:wakaranai/ui/widgets/infinite_rotation_animation.dart';
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
  final ScrollController _scrollListController = ScrollController();
  final _pageBucket = PageStorageBucket();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dayTimeFormat = DateFormat('HH:mm');

  @override
  void dispose() {
    _scrollListController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => MangaActivityHistoryCubit(
            chapterActivityRepository: RepositoryProvider.of(context),
            concreteDataRepository: RepositoryProvider.of(context),
            extensionRepository: RepositoryProvider.of(context),
          )..init(),
        ),
        BlocProvider(
          create: (context) => AnimeActivityHistoryCubit(
              extensionRepository: RepositoryProvider.of(context),
              concreteDataRepository: RepositoryProvider.of(context),
              animeEpisodeActivityRepository: RepositoryProvider.of(context))
            ..init(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: PageStorage(
          bucket: _pageBucket,
          child: PageView(
            controller: _pageController,
            children: [
              _buildMangaActivities(),
              _buildAnimeActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapFullScreen(BuildContext context, Widget child) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200,
      child: child,
    );
  }

  Widget _buildAnimeActivities() {
    return BlocBuilder<AnimeActivityHistoryCubit, AnimeActivityHistoryState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            return context.read<AnimeActivityHistoryCubit>().init();
          },
          child: CustomScrollView(
            controller: _scrollListController,
            key: const PageStorageKey('anime'),
            slivers: [
              ElevatedAppbar(
                title: Text(
                  S.current.activity_history_anime_appbar_title,
                  style: medium(size: 24),
                ),
              ),
              if (state is AnimeActivityHistoryInitial ||
                  state is AnimeActivityHistoryLoading)
                SliverToBoxAdapter(
                  child: _wrapFullScreen(
                      context,
                      const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      )),
                )
              else if (state is AnimeActivityHistoryError)
                SliverToBoxAdapter(
                  child: _wrapFullScreen(
                    context,
                    Center(
                      child: Text(state.message),
                    ),
                  ),
                )
              else if (state is AnimeActivityHistoryLoaded)
                if (state.animeActivities.isEmpty)
                  _buildEmptyState(context,
                      S.current.activity_history_empty_anime_list_message)
                else
                  SliverList.builder(
                    itemCount: state.animeActivities.length,
                    itemBuilder: (context, index) {
                      final item = state.animeActivities[index];
                      return _buildDay(
                        context: context,
                        item: item,
                        onTap: (day) {
                          context
                              .read<AnimeActivityHistoryCubit>()
                              .onActivityTap(
                                context,
                                concrete: day.data,
                                activity: day.activity,
                              );
                        },
                        onDelete: (day) {
                          context.read<AnimeActivityHistoryCubit>().onDelete(
                                context: context,
                                activity: day.activity,
                              );
                        },
                      );
                    },
                  )
            ],
          ),
        );

        return const SizedBox();
      },
    );
  }

  Widget _buildMangaActivities() {
    return BlocBuilder<MangaActivityHistoryCubit, ActivityHistoryState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            return context.read<MangaActivityHistoryCubit>().init();
          },
          child: CustomScrollView(
            controller: _scrollListController,
            key: const PageStorageKey('manga'),
            slivers: [
              ElevatedAppbar(
                title: Text(
                  S.current.activity_history_manga_appbar_title,
                  style: medium(size: 24),
                ),
              ),
              if (state is ActivityHistoryInitial ||
                  state is ActivityHistoryLoading)
                SliverToBoxAdapter(
                  child: _wrapFullScreen(
                    context,
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else if (state is ActivityHistoryError)
                SliverToBoxAdapter(
                  child: _wrapFullScreen(
                    context,
                    Center(
                      child: Text(state.message),
                    ),
                  ),
                )
              else if (state is ActivityHistoryLoaded)
                if (state.mangaActivities.isEmpty)
                  _buildEmptyState(context,
                      S.current.activity_history_empty_manga_list_message)
                else
                  SliverList.builder(
                    itemCount: state.mangaActivities.length,
                    itemBuilder: (context, index) {
                      final item = state.mangaActivities[index];
                      return _buildDay(
                        context: context,
                        item: item,
                        onTap: (day) {
                          context
                              .read<MangaActivityHistoryCubit>()
                              .onActivityTap(
                                context,
                                concrete: day.data,
                                activity: day.activity,
                              );
                        },
                        onDelete: (day) {
                          context.read<MangaActivityHistoryCubit>().onDelete(
                                context: context,
                                activity: day.activity,
                              );
                        },
                      );
                    },
                  )
            ],
          ),
        );

        return const SizedBox();
      },
    );
  }

  SliverToBoxAdapter _buildEmptyState(
    BuildContext context,
    String message,
  ) {
    return SliverToBoxAdapter(
      child: _wrapFullScreen(
        context,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const InfiniteRotationAnimation(
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 32,
                    color: AppColors.mainWhite,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    message,
                    style: medium(
                      size: 16,
                      color: AppColors.mainWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildDay({
    required BuildContext context,
    required ActivityListItem<BaseActivityDomain> item,
    required void Function(DayActivityListItem<BaseActivityDomain> listItem)
        onTap,
    required void Function(DayActivityListItem<BaseActivityDomain> listItem)
        onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              _dateFormat.format(item.day),
              style: semibold(size: 18),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            children: [
              for (final listItem in item.listItems)
                _buildListItem(
                  context: context,
                  listItem: listItem,
                  onTap: onTap,
                  onDelete: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActivityDialog(
    BuildContext context, {
    required DayActivityListItem<BaseActivityDomain> listItem,
    required void Function(DayActivityListItem<BaseActivityDomain> listItem)
        onDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) => ActivityHistoryLongTapDialog<BaseActivityDomain>(
          domain: listItem.activity, onDelete: () => onDelete(listItem)),
    );
  }

  Padding _buildListItem({
    required BuildContext context,
    required DayActivityListItem<BaseActivityDomain> listItem,
    required void Function(DayActivityListItem<BaseActivityDomain> listItem)
        onTap,
    required void Function(DayActivityListItem<BaseActivityDomain> listItem)
        onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 4.0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          onTap(listItem);
        },
        onLongPress: () {
          _showActivityDialog(context, listItem: listItem, onDelete: onDelete);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: listItem.data.cover!,
                      width: 52,
                      height: 96,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, _) => CachedNetworkImage(
                        imageUrl: "https://via.placeholder.com/52x96",
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listItem.data.title.trim(),
                          style: semibold(size: 16),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listItem.activity.title.trim(),
                                    style: regular(size: 14),
                                  ),
                                  if (listItem.activity
                                          is ChapterActivityDomain &&
                                      (listItem.activity
                                                  as ChapterActivityDomain)
                                              .totalPages !=
                                          0)
                                    Text(
                                      "${(listItem.activity as ChapterActivityDomain).readPages}/${(listItem.activity as ChapterActivityDomain).totalPages}",
                                      style: regular(
                                          size: 12, color: AppColors.mainGrey),
                                    ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _dayTimeFormat.format(
                                  listItem.activity.updatedAt ??
                                      listItem.activity.createdAt),
                              style: semibold(size: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
