import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_player_button.dart';
import 'package:wakaranai/ui/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
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
  final bool fromLibrary;

  const AnimeConcreteViewerData(
      {required this.uid,
      required this.galleryView,
      required this.client,
      required this.configInfo,
      this.fromLibrary = false});
}

class AnimeConcreteViewer extends StatelessWidget {
  AnimeConcreteViewer({Key? key, required this.data}) : super(key: key);

  final GlobalKey _scaffoldKey = GlobalKey();

  final AnimeConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    if (data.fromLibrary) {
      return WebBrowserWrapper(
        configInfo: data.configInfo,
        apiClient: data.client,
        onInterceptorInitialized: () {
          _scaffoldKey.currentContext
              ?.read<
                  ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                      AnimeGalleryView>>()
              .getConcrete(data.uid, data.galleryView);
        },
        builder: (context, completer) => _wrapWithBrowserInterceptorCubit(
            child: _buildConcreteBody(), completer: completer),
      );
    } else {
      return _buildConcreteBody();
    }
  }

  Widget _buildConcreteBody() {
    return ConcreteViewCubitWrapper<AnimeApiClient, AnimeConcreteView,
        AnimeGalleryView>(
      client: data.client,
      init: (cubit) {
        cubit.getConcrete(data.uid, data.galleryView);
      },
      builder: (context, state) => _buildBody(),
    );
  }

  Widget _wrapWithBrowserInterceptorCubit(
      {required Widget child, required Completer<bool> completer}) {
    if (data.configInfo.protectorConfig?.inAppBrowserInterceptor ?? false) {
      return BlocProvider<BrowserInterceptorCubit>(
        lazy: false,
        create: (context) {
          final cubit = BrowserInterceptorCubit()
            ..init(
                url: data.configInfo.protectorConfig!.pingUrl,
                initCompleter: completer);
          data.client.passWebBrowserInterceptorController(controller: cubit);
          return cubit;
        },
        child: child,
      );
    } else {
      return child;
    }
  }

  Scaffold _buildBody() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: BlocBuilder<
          ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>,
          ConcreteViewState<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>>(
        builder: (context, state) {
          if (state is ConcreteViewInitialized<AnimeApiClient,
              AnimeConcreteView, AnimeGalleryView>) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
              child: SwitchIconButton(
                iconOn: const Icon(Icons.filter_list_rounded),
                iconOff: Transform.rotate(
                  angle: pi / 1,
                  child: const Icon(Icons.filter_list_rounded),
                ),
                state: state.order == ConcreteViewOrder.DEFAULT,
                onTap: () {
                  context
                      .read<
                          ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                              AnimeGalleryView>>()
                      .changeOrder(state.order == ConcreteViewOrder.DEFAULT
                          ? ConcreteViewOrder.DEFAULT_REVERSE
                          : ConcreteViewOrder.DEFAULT);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      body: BlocBuilder<
          ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>,
          ConcreteViewState<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>>(
        builder: (context, state) {
          late final AnimeConcreteView concreteView;
          int currentGroupIndex = -1;

          if (state is ConcreteViewInitialized<AnimeApiClient,
              AnimeConcreteView, AnimeGalleryView>) {
            concreteView = state.concreteView;
            currentGroupIndex = state.groupIndex;
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 1 +
                ((state is ConcreteViewInitialized<AnimeApiClient,
                        AnimeConcreteView, AnimeGalleryView>)
                    ? (state.groupIndex != -1
                        ? concreteView.groups[state.groupIndex].elements.length
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
                      if (state is ConcreteViewInitialized<AnimeApiClient,
                          AnimeConcreteView, AnimeGalleryView>) ...[
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
                        _buildPlayerButtons(state, context, currentGroupIndex),
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
                final animeVideo =
                    concreteView.groups[currentGroupIndex].elements[index - 1];

                return ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.iframeAnimePlayer,
                        arguments: AnimeIframePlayerData(src: animeVideo.src));
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
    );
  }

  Wrap _buildPlayerButtons(
      ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>
          state,
      BuildContext context,
      int currentGroupIndex) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: state.concreteView.groups.map((e) {
        final elementVideoGroupIndex = state.concreteView.groups.indexOf(e);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: AnimePlayerButton(
            title: e.title,
            onClick: () {
              context
                  .read<
                      ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                          AnimeGalleryView>>()
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
