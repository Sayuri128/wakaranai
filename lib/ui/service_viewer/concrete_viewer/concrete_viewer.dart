import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/chapter/chapter.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/concrete_view.dart';

import '../../routes.dart';

class ConcreteViewerData {
  final String uid;
  final ApiClient client;

  const ConcreteViewerData({
    required this.uid,
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
                ..getConcrete(data.uid),
        )
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ConcreteViewCubit, ConcreteViewState>(
          builder: (context, state) {
            if (state is ConcreteViewInitialized) {
              final concreteView = state.concreteView;
              return SingleChildScrollView(
                child: Column(
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
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(height: 16.0),
                    _buildChapters(context, concreteView)
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Column _buildChapters(BuildContext context, ConcreteView concreteView) {
    return Column(
      children:
          concreteView.chapters.map((e) => _buildChapter(context, e)).toList(),
    );
  }

  ListTile _buildChapter(BuildContext context, Chapter e) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.chapterViewer,
            arguments: ChapterViewerData(apiClient: data.client, chapter: e));
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

  ClipRRect _buildCover(ConcreteViewInitialized state, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: state.concreteView.cover,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, progress) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.accentGreen, value: progress.progress),
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
