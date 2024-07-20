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
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_provider_button.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MangaConcreteViewerData {
  final String uid;
  final MangaGalleryView galleryView;
  final Map<String, String> coverHeaders;
  final MangaApiClient client;
  final ConfigInfo configInfo;

  const MangaConcreteViewerData({
    required this.uid,
    required this.galleryView,
    required this.coverHeaders,
    required this.client,
    required this.configInfo,
  });
}

class MangaConcreteViewer extends StatelessWidget {
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
          cubit.getConcrete(data.uid, data.galleryView);
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
                onRefresh: () async {
                  await context
                      .read<
                          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                              MangaGalleryView>>()
                      .getConcrete(data.uid, data.galleryView,
                          forceRemote: true);
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 1 + groupSize + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            _buildCover(data.galleryView.cover, context),
                            const SizedBox(height: 16.0),
                            if (state is ConcreteViewInitialized<
                                MangaApiClient,
                                MangaConcreteView,
                                MangaGalleryView>) ...<Widget>[
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
                            ] else if (state is ConcreteViewError<
                                MangaApiClient,
                                MangaConcreteView,
                                MangaGalleryView>) ...<Widget>[
                              const SizedBox(height: 16.0),
                              Text(
                                state.message,
                                style: regular(size: 18, color: AppColors.red),
                              ),
                              const SizedBox(height: 16.0),
                            ] else ...<Widget>[
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
                    } else if (index == 1 + groupSize) {
                      return const SizedBox(height: 48);
                    } else {
                      if (state is ConcreteViewInitialized<MangaApiClient,
                          MangaConcreteView, MangaGalleryView>) {
                        final Chapter chapter = concreteView
                            .groups[currentGroupsIndex].elements[index - 1];
                        return _buildChapter(
                            context: context,
                            chapter: chapter,
                            galleryView: data.galleryView,
                            group: concreteView.groups[currentGroupsIndex],
                            configInfo: data.configInfo,
                            concreteViewInitialized: state);
                      } else {
                        return const SizedBox();
                      }
                    }
                  },
                ),
              ),
              if (state is ConcreteViewInitialized<MangaApiClient,
                  MangaConcreteView, MangaGalleryView>)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, right: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // AnimatedSwitcher(
                        //   duration: const Duration(milliseconds: 500),
                        //   child: multiSelect.items.isNotEmpty
                        //       ? SwitchIconButton(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //           iconOn: const Icon(
                        //             Icons.clear,
                        //           ),
                        //           iconOff: const SizedBox(),
                        //           state: true,
                        //           onTap: () {
                        //             context.read<MultiSelectCubit>().clear();
                        //           },
                        //         )
                        //       : SizedBox(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //         ),
                        // ),
                        const SizedBox(
                          height: 24,
                        ),
                        // AnimatedSwitcher(
                        //   duration: const Duration(milliseconds: 500),
                        //   child: multiSelect.items.isNotEmpty
                        //       ? SwitchIconButton(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //           iconOn: const Icon(Icons.border_clear),
                        //           iconOff: const SizedBox(),
                        //           state: true,
                        //           onTap: () {
                        //             context
                        //                 .read<MultiSelectCubit>()
                        //                 .unselectMultiple(state.concreteView
                        //                     .groups[state.groupIndex].elements
                        //                     .map((e) => e.uid)
                        //                     .toList());
                        //           },
                        //         )
                        //       : SizedBox(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //         ),
                        // ),
                        const SizedBox(
                          height: 24,
                        ),
                        // AnimatedSwitcher(
                        //   duration: const Duration(milliseconds: 500),
                        //   child: multiSelect.items.isNotEmpty
                        //       ? SwitchIconButton(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //           iconOn: const Icon(Icons.select_all),
                        //           iconOff: const SizedBox(),
                        //           state: true,
                        //           onTap: () {
                        //             context
                        //                 .read<MultiSelectCubit>()
                        //                 .selectMultiple(state.concreteView
                        //                     .groups[state.groupIndex].elements
                        //                     .map((e) => e.uid)
                        //                     .toList());
                        //           },
                        //         )
                        //       : SizedBox(
                        //           key: ValueKey(multiSelect.items.isNotEmpty),
                        //         ),
                        // ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(
                              width: 24,
                            ),
                            SwitchIconButton(
                              iconOn: const Icon(Icons.filter_list_rounded),
                              state: state.order == ConcreteViewOrder.def,
                              onTap: () {
                                context
                                    .read<
                                        ConcreteViewCubit<
                                            MangaApiClient,
                                            MangaConcreteView,
                                            MangaGalleryView>>()
                                    .changeOrder(
                                        state.order == ConcreteViewOrder.def
                                            ? ConcreteViewOrder.defReverse
                                            : ConcreteViewOrder.def);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapter(
      {required BuildContext context,
      required Chapter chapter,
      required MangaGalleryView galleryView,
      required ChaptersGroup group,
      required ConfigInfo configInfo,
      required ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          concreteViewInitialized}) {
    return ListTile(
      selectedTileColor: AppColors.mediumLight.withOpacity(0.15),
      onTap: () {
        Navigator.of(context)
            .pushNamed(
              Routes.chapterViewer,
              arguments: ChapterViewerData(
                  initialPage: 1,
                  apiClient: data.client,
                  chapter: chapter,
                  concreteView: concreteViewInitialized.concreteView,
                  group: group,
                  galleryView: galleryView,
                  configInfo: configInfo),
            )
            .then((_) {});
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(chapter.title.trim(),
              style: medium(size: 18, color: AppColors.mainWhite)),
          if (chapter.timestamp != null &&
              formatTimestamp(chapter).isNotEmpty) ...<Widget>[
            const SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Text(
                  formatTimestamp(chapter),
                  style: regular(color: AppColors.mainGrey, size: 12),
                ),
              ],
            )
          ],
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

  Wrap _buildTags(MangaConcreteView concreteView) {
    return Wrap(
      children: concreteView.tags.map((String e) => _buildTagCard(e)).toList(),
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
                url: data.galleryView.cover,
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
