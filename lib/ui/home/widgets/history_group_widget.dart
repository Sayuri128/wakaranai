import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/history/history_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/data/history_manga_group/history_manga_group.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class HistoryGroupWidget extends StatelessWidget {
  const HistoryGroupWidget(
      {Key? key,
      required this.group,
      required this.index,
      required this.showAll})
      : super(key: key);

  final HistoryMangaGroup group;
  final int index;
  final bool showAll;
  static DateFormat dateFormat = DateFormat("yyyy-MM-dd - kk:mm");

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            onTap: () {
              context.read<HistoryCubit>().expand(index: index);
            },
            onLongPress: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.mangaConcreteViewer, (_) => true,
                  arguments: MangaConcreteViewerData(
                      uid: group.concreteView.uid,
                      client: group.client,
                      galleryView: group.galleryView,
                      configInfo: group.configInfo));
            },
            leading: SizedBox(
              height: 64,
              width: 48,
              child: CachedNetworkImage(imageUrl: group.concreteView.cover),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    group.concreteView.title.pretty.isEmpty
                        ? group.concreteView.title.original
                        : group.concreteView.title.pretty,
                    maxLines: 3,
                    style: medium(size: 16)),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  S.current.history_last_visit(
                      dateFormat.format(group.mangaItems.first.timestamp)),
                  style: regular(color: AppColors.mediumLight, size: 12),
                )
              ],
            ),
          ),
        ),
        if (showAll) ...[
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(group.configInfo.name),
                Text(group.configInfo.language),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ...group.mangaItems.map((e) {
            var chapter = e.concreteView.chapters
                .firstWhere((element) => element.uid == e.chapterUid);

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Dismissible(
                onDismissed: ((direction) {
                  if (direction == DismissDirection.endToStart) {
                    context
                        .read<HistoryCubit>()
                        .deleteItemFromGroup(group: group, item: e);
                  }
                }),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: const BoxDecoration(color: AppColors.red),
                  child: Row(
                    children: const [
                      Spacer(),
                      Icon(Icons.delete_forever),
                      SizedBox(width: 16.0)
                    ],
                  ),
                ),
                key: ValueKey(chapter.uid),
                child: InkWell(
                  onTap: () async {
                    final config = await group.client.getConfigInfo();

                    if (config.protectorConfig != null) {
                      final cachedHeaders = await ProtectorStorageService()
                          .getItem(uid: '${config.name}_${config.version}');

                      final Map<String, dynamic> headers = {};

                      if (cachedHeaders == null) {
                        final result = await Navigator.of(context).pushNamed(
                            Routes.webBrowser,
                            arguments: config.protectorConfig);
                        if (result != null) {
                          headers.addAll(result as Map<String, dynamic>);
                        } else {
                          return;
                        }
                      } else {
                        headers.addAll(cachedHeaders.headers);
                      }

                      await group.client.passProtector(data: headers);
                    }

                    Navigator.of(context).pushNamed(Routes.chapterViewer,
                        arguments: ChapterViewerData(
                            apiClient: group.client,
                            chapter: chapter,
                            galleryView: e.galleryView,
                            concreteView: e.concreteView,
                            configInfo: config));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title.overflow,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: medium(),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          dateFormat.format(e.timestamp.toLocal()),
                          style: medium(),
                        ),
                        const Divider(
                          color: AppColors.primary,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
        ]
      ],
    );
  }
}
