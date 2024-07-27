import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/concrete_viewer_mixin.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_provider_button.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MangaConcreteViewerData {
  final String uid;
  final Map<String, String> coverHeaders;

  // used for hero animation
  final String? galleryCover;
  final Map<String, dynamic> galleryData;
  final MangaApiClient client;
  final ConfigInfo configInfo;

  const MangaConcreteViewerData({
    required this.uid,
    required this.coverHeaders,
    required this.galleryCover,
    required this.galleryData,
    required this.client,
    required this.configInfo,
  });
}

class MangaConcreteViewer extends StatelessWidget
    with
        ConcreteViewerMixin<MangaApiClient, MangaConcreteView,
            MangaGalleryView> {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  MangaConcreteViewer({super.key, required this.data});

  final GlobalKey _scaffoldKey = GlobalKey();

  final MangaConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    return _buildConcreteBody(true);
  }

  Widget _buildConcreteBody(bool init) {
    return ConcreteViewCubitWrapper<MangaApiClient, MangaConcreteView,
        MangaGalleryView>(
      client: data.client,
      configInfo: data.configInfo,
      init: (ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          cubit) {
        if (init) {
          cubit.getConcrete(data.uid, data.galleryData);
        }
      },
      builder: (BuildContext context,
              ConcreteViewState<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>
                  state) =>
          _buildBody(),
    );
  }

  Widget _wrapWithBrowserInterceptorCubit(
      {required Widget child, required Completer<bool> completer}) {
    if (data.configInfo.protectorConfig?.inAppBrowserInterceptor ?? false) {
      return BlocProvider<BrowserInterceptorCubit>(
        lazy: false,
        create: (BuildContext context) {
          final BrowserInterceptorCubit cubit = BrowserInterceptorCubit()
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
      body: BlocConsumer<
          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>,
          ConcreteViewState<MangaApiClient, MangaConcreteView,
              MangaGalleryView>>(
        listener: (BuildContext context,
            ConcreteViewState<MangaApiClient, MangaConcreteView,
                    MangaGalleryView>
                state) {},
        builder: (BuildContext context,
            ConcreteViewState<MangaApiClient, MangaConcreteView,
                    MangaGalleryView>
                state) {
          late final MangaConcreteView concreteView;

          int currentGroupsIndex = -1;
          if (state is ConcreteViewInitialized<MangaApiClient,
              MangaConcreteView, MangaGalleryView>) {
            concreteView = state.concreteView;
            currentGroupsIndex = state.groupIndex;
          }

          final int groupSize = (state is ConcreteViewInitialized<
                  MangaApiClient, MangaConcreteView, MangaGalleryView>)
              ? state.groupIndex != -1
                  ? concreteView.groups[state.groupIndex].elements.length
                  : 0
              : 0;

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await context
                      .read<
                          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                              MangaGalleryView>>()
                      .getConcrete(data.uid, data.galleryData,
                          forceRemote: true);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        ...<Widget>[
                          if (data.galleryCover != null) ...[
                            _buildCover(data.galleryCover!, context),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                          if (state is ConcreteViewInitialized<MangaApiClient,
                              MangaConcreteView, MangaGalleryView>) ...<Widget>[
                            if (data.galleryCover == null)
                              _buildCover(concreteView.cover, context),
                            const SizedBox(height: 16.0),
                            _buildTitle(concreteView),
                            const SizedBox(height: 16.0),
                            _buildTags(context, concreteView),
                            const SizedBox(height: 16.0),
                            _buildDescription(context, concreteView),
                            const SizedBox(height: 16.0),
                            _buildMangaProviderButtons(
                                state, context, currentGroupsIndex),
                            const Divider(
                              thickness: 1,
                              color: AppColors.secondary,
                            ),
                          ] else if (state is ConcreteViewError<MangaApiClient,
                              MangaConcreteView, MangaGalleryView>) ...<Widget>[
                            _buildErrorMessage(context, state)
                          ] else ...<Widget>[
                            _buildLoader(context),
                          ],
                          const SizedBox(height: 16.0),
                        ],
                      ]),
                    ),
                    SliverList.builder(
                      itemCount: groupSize,
                      itemBuilder: (BuildContext context, int index) {
                        if (state is ConcreteViewInitialized<MangaApiClient,
                            MangaConcreteView, MangaGalleryView>) {
                          final Chapter chapter = concreteView
                              .groups[currentGroupsIndex].elements[index];
                          return _buildChapter(
                            context: context,
                            chapter: chapter,
                            group: concreteView.groups[currentGroupsIndex],
                            configInfo: data.configInfo,
                            chapterActivityDomain:
                                state.chapterActivities[chapter.uid],
                            concreteViewInitialized: state,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (state is ConcreteViewInitialized<MangaApiClient,
                  MangaConcreteView, MangaGalleryView>) ...[
                getExpandableFabWidget(context, state),
              ]
            ],
          );
        },
      ),
    );
  }

  SizedBox _buildLoader(BuildContext context) {
    return SizedBox(
      height:
          data.galleryCover == null ? MediaQuery.of(context).size.height : null,
      width:
          data.galleryCover == null ? MediaQuery.of(context).size.width : null,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  SizedBox _buildErrorMessage(
      BuildContext context,
      ConcreteViewError<MangaApiClient, MangaConcreteView, MangaGalleryView>
          state) {
    return SizedBox(
      height:
          data.galleryCover == null ? MediaQuery.of(context).size.height : null,
      width:
          data.galleryCover == null ? MediaQuery.of(context).size.width : null,
      child: Center(
        child: Text(
          state.message,
          style: regular(size: 18, color: AppColors.red),
        ),
      ),
    );
  }

  Widget _buildChapter(
      {required BuildContext context,
      required Chapter chapter,
      required ChaptersGroup group,
      required ConfigInfo configInfo,
      required ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          concreteViewInitialized,
      required ChapterActivityDomain? chapterActivityDomain}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: chapterActivityDomain?.isCompleted == true ? 0.5 : 1.0,
      child: ListTile(
        selectedTileColor: AppColors.mediumLight.withOpacity(
          0.15,
        ),
        selected: concreteViewInitialized.selection.contains(
          chapter.uid,
        ),
        onLongPress: () {
          context
              .read<
                  ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>>()
              .changeSelection(
                chapter.uid,
              );
        },
        onTap: () {
          if (concreteViewInitialized.selection.isEmpty) {
            Navigator.of(context)
                .pushNamed(
              Routes.chapterViewer,
              arguments: ChapterViewerData(
                  initialPage: chapterActivityDomain?.readPages ?? 1,
                  apiClient: data.client,
                  chapter: chapter,
                  concreteView: concreteViewInitialized.concreteView,
                  group: group,
                  configInfo: configInfo),
            )
                .then((_) {
              context
                  .read<
                      ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                          MangaGalleryView>>()
                  .updateActivities();
            });
          } else {
            context
                .read<
                    ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                        MangaGalleryView>>()
                .changeSelection(
                  chapter.uid,
                );
          }
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(chapter.title.trim(),
                style: medium(size: 18, color: AppColors.mainWhite)),
            ...<Widget>[
              const SizedBox(height: 8.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (chapter.timestamp != null &&
                      formatTimestamp(chapter).isNotEmpty)
                    Text(
                      formatTimestamp(chapter),
                      style: regular(color: AppColors.mainGrey, size: 12),
                    ),
                  if (chapterActivityDomain != null &&
                      chapterActivityDomain.totalPages != 0) ...<Widget>[
                    const SizedBox(width: 8.0),
                    Text(
                      "${chapterActivityDomain.readPages}/${chapterActivityDomain.totalPages}",
                      style: regular(color: AppColors.mainGrey, size: 12),
                    ),
                  ]
                ],
              )
            ],
          ],
        ),
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
      children: state.concreteView.groups.map((ChaptersGroup e) {
        final int elementVideoGroupIndex = state.concreteView.groups.indexOf(e);
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
      child: Column(
        children: [
          Text(
            concreteView.title,
            textAlign: TextAlign.center,
            style: semibold(size: 18),
          ),
          if (concreteView.alternativeTitles.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              concreteView.alternativeTitles.join(', '),
              textAlign: TextAlign.center,
              style: regular(size: 16),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context, MangaConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          children:
              concreteView.tags.map((String e) => _buildTagCard(e)).toList(),
        ),
      ),
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
        children: <Widget>[
          Hero(
            tag: Heroes.galleryViewToConcreteView(data.uid),
            child: Material(
              child: ImageWidget(
                uid: data.uid,
                url: cover,
                headers: data.coverHeaders,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: RadialGradient(radius: 2, colors: <Color>[
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
