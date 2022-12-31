import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/chapter_storage/chapter_storage_cubit.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/downloaded_chapter_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/chapter/chapter.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

import '../../routes.dart';

class ConcreteViewerData {
  final String uid;
  final GalleryView galleryView;
  final ApiClient client;

  const ConcreteViewerData({
    required this.uid,
    required this.galleryView,
    required this.client,
  });
}

class ConcreteViewer extends StatelessWidget {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  const ConcreteViewer({Key? key, required this.data}) : super(key: key);

  final ConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConcreteViewCubit>(
          create: (context) =>
              ConcreteViewCubit(ConcreteViewState(apiClient: data.client))
                ..getConcrete(data.uid, data.galleryView),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ConcreteViewCubit, ConcreteViewState>(
          builder: (context, state) {
            if (state is ConcreteViewInitialized) {
              final concreteView = state.concreteView;
              return ListView.builder(
                itemCount: 1 + concreteView.chapters.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        _buildCover(state, context),
                        const SizedBox(height: 16.0),
                        _buildPrettyTitle(concreteView),
                        _buildOriginalTitle(concreteView),
                        const SizedBox(height: 16.0),
                        _buildTags(concreteView),
                        const SizedBox(height: 16.0),
                        const Divider(
                          thickness: 1,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  } else {
                    return _buildChapter(
                        context, concreteView.chapters[index - 1], state);
                  }
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildChapter(
      BuildContext context, Chapter e, ConcreteViewInitialized state) {
    return BlocProvider<ChapterStorageCubit>(
      create: (context) =>
          ChapterStorageCubit(uid: data.uid, client: data.client)..init(e),
      child: BlocBuilder<ChapterStorageCubit, ChapterStorageState>(
        builder: (context, storage) {
          return ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.chapterViewer,
                  arguments: ChapterViewerData(
                      apiClient: data.client,
                      chapter: e,
                      concreteView: state.concreteView,
                      galleryView: state.galleryView));
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title),
                if (e.timestamp != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    int.tryParse(e.timestamp ?? '') != null
                        ? DateFormat(chapterDateFormat).format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.tryParse(e.timestamp!)!))
                        : e.timestamp ?? '',
                    style: regular(color: AppColors.mainGrey, size: 12),
                  )
                ]
              ],
            ),
            trailing: storage is ChapterStorageInitialized
                ? storage.item != null
                    ? InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DownloadedChapterDialog(chapter: e))
                              .then((res) {
                            if (res != null) {
                              switch (res as DownloadedChapterDialogResult) {
                                case DownloadedChapterDialogResult
                                    .DOWNLOAD_AGAIN:
                                  context
                                      .read<ChapterStorageCubit>()
                                      .downloadChapter(e);
                                  break;
                                case DownloadedChapterDialogResult.DELETE:
                                  context.read<ChapterStorageCubit>().delete(e);
                                  break;
                              }
                            }
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.check),
                        ))
                    : InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          context
                              .read<ChapterStorageCubit>()
                              .downloadChapter(e);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.download),
                        ))
                : storage is ChapterStorageInitializing
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                      )
                    : null,
          );
        },
      ),
    );
  }

  Text _buildPrettyTitle(ConcreteView concreteView) {
    return Text(concreteView.title.pretty,
        textAlign: TextAlign.center, style: semibold(size: 18));
  }

  Text _buildOriginalTitle(ConcreteView concreteView) {
    return Text(
      concreteView.title.original,
      textAlign: TextAlign.center,
      style: semibold(size: 18),
    );
  }

  Wrap _buildTags(ConcreteView concreteView) {
    return Wrap(
      children: concreteView.tags.map((e) => _buildTagCard(e)).toList(),
    );
  }

  Card _buildTagCard(String e) {
    return Card(
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(e),
        ));
  }

  Widget _buildCover(ConcreteViewInitialized state, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
      child: Stack(
        children: [
          Hero(
            tag: Heroes.galleryViewToConcreteView(data.uid),
            child: Material(
              child: CachedNetworkImage(
                imageUrl: state.concreteView.cover,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, value: progress.progress),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: RadialGradient(radius: 2, colors: [
              Colors.transparent,
              AppColors.mainBlack.withOpacity(1)
            ])),
          )
        ],
      ),
    );
  }
}
