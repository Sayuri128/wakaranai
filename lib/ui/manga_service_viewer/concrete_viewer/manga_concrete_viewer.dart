import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_provider_button.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

import '../../routes.dart';

class MangaConcreteViewerData {
  final String uid;
  final MangaGalleryView galleryView;
  final MangaApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;

  const MangaConcreteViewerData(
      {required this.uid,
      required this.galleryView,
      required this.client,
      required this.configInfo,
      this.fromLibrary = false});
}

class MangaConcreteViewer extends StatelessWidget {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  MangaConcreteViewer({Key? key, required this.data}) : super(key: key);

  final GlobalKey _scaffoldKey = GlobalKey();

  final MangaConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    if (data.fromLibrary) {
      return WebBrowserWrapper(
        onInterceptorInitialized: () {
          _scaffoldKey.currentContext
              ?.read<
                  ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>>()
              .getConcrete(data.uid, data.galleryView);
        },
        apiClient: data.client,
        configInfo: data.configInfo,
        builder: (context, completer) => _wrapWithBrowserInterceptorCubit(
            child: _buildConcreteBody(false), completer: completer),
      );
    } else {
      return _buildConcreteBody(true);
    }
  }

  Widget _buildConcreteBody(bool init) {
    return ConcreteViewCubitWrapper<MangaApiClient, MangaConcreteView,
        MangaGalleryView>(
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
          });
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
          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>,
          ConcreteViewState<MangaApiClient, MangaConcreteView,
              MangaGalleryView>>(
        builder: (context, state) {
          if (state is ConcreteViewInitialized<MangaApiClient,
              MangaConcreteView, MangaGalleryView>) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
              child: ChangeOrderIconButton(
                state: state.order == ConcreteViewOrder.DEFAULT,
                onTap: () {
                  context
                      .read<
                          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                              MangaGalleryView>>()
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
          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>,
          ConcreteViewState<MangaApiClient, MangaConcreteView,
              MangaGalleryView>>(
        builder: (context, state) {
          late final MangaConcreteView concreteView;

          int currentGroupsIndex = -1;
          if (state is ConcreteViewInitialized<MangaApiClient,
              MangaConcreteView, MangaGalleryView>) {
            concreteView = state.concreteView;
            currentGroupsIndex = state.groupIndex;
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 1 +
                ((state is ConcreteViewInitialized<MangaApiClient,
                        MangaConcreteView, MangaGalleryView>)
                    ? state.groupIndex != -1
                        ? concreteView.groups[state.groupIndex].elements.length
                        : 0
                    : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      _buildCover(data.galleryView.cover, context),
                      const SizedBox(height: 16.0),
                      if (state is ConcreteViewInitialized<MangaApiClient,
                          MangaConcreteView, MangaGalleryView>) ...[
                        _buildTitle(concreteView),
                        const SizedBox(height: 16.0),
                        _buildTags(concreteView),
                        const SizedBox(height: 16.0),
                        _buildDescription(context, concreteView),
                        const SizedBox(height: 16.0),
                        _buildMangaProviderButtons(
                            state, context, currentGroupsIndex),
                        const Divider(
                          thickness: 1,
                          color: AppColors.secondary,
                        ),
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
                return _buildChapter(
                    context,
                    concreteView.groups[currentGroupsIndex].elements[index - 1],
                    data.galleryView,
                    concreteView.groups[currentGroupsIndex],
                    data.configInfo);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildChapter(
      BuildContext context,
      Chapter e,
      MangaGalleryView galleryView,
      ChaptersGroup group,
      ConfigInfo configInfo) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.chapterViewer,
            arguments: ChapterViewerData(
                apiClient: data.client,
                chapter: e,
                group: group,
                galleryView: galleryView,
                configInfo: configInfo));
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(e.title.trim(), style: medium(size: 18)),
          if (e.timestamp != null && formatTimestamp(e).isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              formatTimestamp(e),
              style: regular(color: AppColors.mainGrey, size: 12),
            )
          ]
        ],
      ),
    );
  }

  String formatTimestamp(Chapter e) {
    return int.tryParse(e.timestamp ?? '') != null
        ? DateFormat(chapterDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(e.timestamp!)!))
        : e.timestamp ?? '';
  }

  Wrap _buildMangaProviderButtons(
      ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          state,
      BuildContext context,
      int currentGroupIndex) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: state.concreteView.groups.map((e) {
        final elementVideoGroupIndex = state.concreteView.groups.indexOf(e);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: MangaProviderButton(
            title: e.title,
            onClick: () {
              context
                  .read<
                      ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                          MangaGalleryView>>()
                  .changeGroup(elementVideoGroupIndex);
            },
            selected: currentGroupIndex == elementVideoGroupIndex,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitle(MangaConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        concreteView.title,
        textAlign: TextAlign.center,
        style: semibold(size: 18),
      ),
    );
  }

  Wrap _buildTags(MangaConcreteView concreteView) {
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
      BuildContext context, MangaConcreteView concreteView) {
    if (concreteView.description.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          concreteView.description.replaceAll('\\n', '\n\n').trim(),
          textAlign: TextAlign.left,
          style: regular(size: 16),
        ),
      ),
    );
  }
}
