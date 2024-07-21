import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/activity_history_cubit.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final ScrollController _scrollListController = ScrollController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dayTimeFormat = DateFormat('HH:mm');

  @override
  void dispose() {
    _scrollListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ActivityHistoryCubit(
        chapterActivityRepository: RepositoryProvider.of(context),
        concreteDataRepository: RepositoryProvider.of(context),
        extensionRepository: RepositoryProvider.of(context),
      )..init(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: BlocBuilder<ActivityHistoryCubit, ActivityHistoryState>(
          builder: (context, state) {
            if (state is ActivityHistoryInitial ||
                state is ActivityHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ActivityHistoryError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is ActivityHistoryLoaded) {
              return CustomScrollView(
                controller: _scrollListController,
                slivers: [
                  SliverList.builder(
                    itemCount: state.activities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: MediaQuery.of(context).padding.top + 8.0,
                        );
                      }
                      final item = state.activities[index - 1];
                      return _buildDay(item, context);
                    },
                  )
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Padding _buildDay(ActivityListItem item, BuildContext context) {
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
                _buildListItem(context, listItem),
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildListItem(BuildContext context, DayActivityListItem listItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 4.0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          context.read<ActivityHistoryCubit>().onActivityTap(
                context,
                concrete: listItem.data,
                activity: listItem.activity,
              );
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
                                  Text(
                                    "${listItem.activity.readPages}/${listItem.activity.totalPages}",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
