import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/anime_concrete_viewer/anime_concrete_viewer_cubit.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_player_button.dart';
import 'package:wakaranai/ui/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class AnimeConcreteViewerData {
  final String uid;
  final AnimeGalleryView galleryView;
  final AnimeApiClient client;
  final ConfigInfo configInfo;

  const AnimeConcreteViewerData(
      {required this.uid,
      required this.galleryView,
      required this.client,
      required this.configInfo});
}

class AnimeConcreteViewer extends StatelessWidget {
  const AnimeConcreteViewer({Key? key, required this.data}) : super(key: key);

  final AnimeConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AnimeConcreteViewCubit>(
          create: (context) => AnimeConcreteViewCubit(
              AnimeConcreteViewState(apiClient: data.client))
            ..getConcrete(data.uid, data.galleryView),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton:
            BlocBuilder<AnimeConcreteViewCubit, AnimeConcreteViewState>(
          builder: (context, state) {
            if (state is AnimeConcreteViewInitialized) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
                child: ChangeOrderIconButton(
                  state: state.order == AnimeConcreteViewOrder.DEFAULT,
                  onTap: () {
                    context.read<AnimeConcreteViewCubit>().changeOrder(
                        state.order == AnimeConcreteViewOrder.DEFAULT
                            ? AnimeConcreteViewOrder.DEFAULT_REVERSE
                            : AnimeConcreteViewOrder.DEFAULT);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
        body: BlocBuilder<AnimeConcreteViewCubit, AnimeConcreteViewState>(
          builder: (context, state) {
            late final AnimeConcreteView concreteView;
            int currentGroupIndex = -1;

            if (state is AnimeConcreteViewInitialized) {
              concreteView = state.concreteView;
              currentGroupIndex = state.videoGroupIndex;
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 1 +
                  ((state is AnimeConcreteViewInitialized)
                      ? (state.videoGroupIndex != -1
                          ? concreteView
                              .videoGroups[state.videoGroupIndex].videos.length
                          : 0)
                      : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        _buildCover(data.galleryView.cover, context),
                        const SizedBox(height: 16.0),
                        if (state is AnimeConcreteViewInitialized) ...[
                          _buildTitle(concreteView),
                          const SizedBox(height: 16.0),
                          _buildTags(concreteView),
                          const SizedBox(height: 16.0),
                          _buildDescription(context, concreteView),
                          const SizedBox(height: 16.0),
                          const Divider(
                            thickness: 1,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16.0),
                          _buildPlayerButtons(
                              state, context, currentGroupIndex),
                        ] else ...[
                          const SizedBox(
                            height: 32,
                          ),
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ],
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  );
                } else {
                  final animeVideo = concreteView
                      .videoGroups[currentGroupIndex].videos[index - 1];

                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.iframeAnimePlayer,
                          arguments:
                              AnimeIframePlayerData(src: animeVideo.src));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(animeVideo.title.trim()),
                        if (animeVideo.timestamp != null) ...[
                          const SizedBox(height: 8.0),
                          Text(
                            int.tryParse(animeVideo.timestamp ?? '') != null
                                ? DateFormat(animeVideo.timestamp).format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.tryParse(animeVideo.timestamp!)!))
                                : animeVideo.timestamp ?? '',
                            style: regular(color: AppColors.mainGrey, size: 12),
                          )
                        ]
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Wrap _buildPlayerButtons(AnimeConcreteViewInitialized state,
      BuildContext context, int currentGroupIndex) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: state.concreteView.videoGroups.map((e) {
        final elementVideoGroupIndex =
            state.concreteView.videoGroups.indexOf(e);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: AnimePlayerButton(
            title: e.title,
            onClick: () {
              context
                  .read<AnimeConcreteViewCubit>()
                  .changeGroup(elementVideoGroupIndex);
            },
            selected: currentGroupIndex == elementVideoGroupIndex,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitle(AnimeConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(concreteView.title,
          textAlign: TextAlign.center, style: semibold(size: 18)),
    );
  }

  Wrap _buildTags(AnimeConcreteView concreteView) {
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

  Widget _buildCover(String cover, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
      child: Stack(
        children: [
          Hero(
            tag: Heroes.galleryViewToConcreteView(data.uid),
            child: Material(
              child: CachedNetworkImage(
                imageUrl: cover,
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

  Widget _buildDescription(
      BuildContext context, AnimeConcreteView concreteView) {
    if (concreteView.description.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          concreteView.description.replaceAll('\\n', '\n\n'),
          textAlign: TextAlign.left,
          style: regular(size: 16),
        ),
      ),
    );
  }
}
