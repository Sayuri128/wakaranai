import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/blocs/multi_select_cubit/multi_select_cubit.dart';
import 'package:wakaranai/blocs/pages_read/pages_read_cubit.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/models/data/pages_read.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_provider_button.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
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
      builder: (context, state) => MultiBlocProvider(providers: [
        BlocProvider<PagesReadCubit>(
          create: (context) => PagesReadCubit(
              concreteViewCubit: context.read<
                  ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>>()),
        ),
        BlocProvider<MultiSelectCubit>(create: (context) => MultiSelectCubit())
      ], child: _buildBody()),
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
      body: BlocConsumer<
          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>,
          ConcreteViewState<MangaApiClient, MangaConcreteView,
              MangaGalleryView>>(
        listener: (context, state) {
          if (state is ConcreteViewInitialized<MangaApiClient,
              MangaConcreteView, MangaGalleryView>) {
            context.read<PagesReadCubit>().init(state.concreteView.groups
                .expand((element) => element.elements)
                .map((e) => e.uid)
                .toList());
          }
        },
        builder: (context, state) {
          late final MangaConcreteView concreteView;

          int currentGroupsIndex = -1;
          if (state is ConcreteViewInitialized<MangaApiClient,
              MangaConcreteView, MangaGalleryView>) {
            concreteView = state.concreteView;
            currentGroupsIndex = state.groupIndex;
          }

          final groupSize = (state is ConcreteViewInitialized<MangaApiClient,
                  MangaConcreteView, MangaGalleryView>)
              ? state.groupIndex != -1
                  ? concreteView.groups[state.groupIndex].elements.length
                  : 0
              : 0;
          return BlocBuilder<MultiSelectCubit, MultiSelectState>(
            builder: (context, multiSelect) => Stack(
              alignment: Alignment.center,
              children: [
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 1 + groupSize + 1,
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
                    } else if (index == 1 + groupSize) {
                      return const SizedBox(height: 48);
                    } else {
                      if (state is ConcreteViewInitialized<MangaApiClient,
                          MangaConcreteView, MangaGalleryView>) {
                        return BlocBuilder<PagesReadCubit, PagesReadState>(
                          builder: (context, pagesState) {
                            final chapter = concreteView
                                .groups[currentGroupsIndex].elements[index - 1];
                            return _buildChapter(
                                context: context,
                                chapter: chapter,
                                galleryView: data.galleryView,
                                group: concreteView.groups[currentGroupsIndex],
                                configInfo: data.configInfo,
                                pagesReadState: pagesState,
                                isSelected:
                                    multiSelect.items.contains(chapter.uid),
                                multiselect: multiSelect.items.isNotEmpty,
                                concreteViewInitialized: state);
                          },
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                  },
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
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: multiSelect.items.isNotEmpty
                                ? SwitchIconButton(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                    iconOn: const Icon(
                                      Icons.clear,
                                    ),
                                    iconOff: const SizedBox(),
                                    state: true,
                                    onTap: () {
                                      context.read<MultiSelectCubit>().clear();
                                    },
                                  )
                                : SizedBox(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                  ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: multiSelect.items.isNotEmpty
                                ? SwitchIconButton(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                    iconOn: const Icon(Icons.border_clear),
                                    iconOff: const SizedBox(),
                                    state: true,
                                    onTap: () {
                                      context
                                          .read<MultiSelectCubit>()
                                          .unselectMultiple(state.concreteView
                                              .groups[state.groupIndex].elements
                                              .map((e) => e.uid)
                                              .toList());
                                    },
                                  )
                                : SizedBox(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                  ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: multiSelect.items.isNotEmpty
                                ? SwitchIconButton(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                    iconOn: const Icon(Icons.select_all),
                                    iconOff: const SizedBox(),
                                    state: true,
                                    onTap: () {
                                      context
                                          .read<MultiSelectCubit>()
                                          .selectMultiple(state.concreteView
                                              .groups[state.groupIndex].elements
                                              .map((e) => e.uid)
                                              .toList());
                                    },
                                  )
                                : SizedBox(
                                    key: ValueKey(multiSelect.items.isNotEmpty),
                                  ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: multiSelect.items.isNotEmpty
                                    ? SwitchIconButton(
                                        key: ValueKey(
                                            multiSelect.items.isNotEmpty),
                                        iconOn: const Icon(Icons.remove_done),
                                        iconOff: const SizedBox(),
                                        state: true,
                                        onTap: () {
                                          context
                                              .read<PagesReadCubit>()
                                              .deleteBuild(multiSelect.items)
                                              .then((value) => value.init(state
                                                  .concreteView.groups
                                                  .expand((element) =>
                                                      element.elements)
                                                  .map((e) => e.uid)
                                                  .toList()));
                                          context
                                              .read<MultiSelectCubit>()
                                              .clear();
                                        },
                                      )
                                    : SizedBox(
                                        key: ValueKey(
                                            multiSelect.items.isNotEmpty),
                                      ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: multiSelect.items.isNotEmpty
                                    ? SwitchIconButton(
                                        key: ValueKey(
                                            multiSelect.items.isNotEmpty),
                                        iconOn: const Icon(Icons.done_all),
                                        iconOff: const SizedBox(),
                                        state: true,
                                        onTap: () {
                                          context
                                              .read<PagesReadCubit>()
                                              .markAsRead(
                                                  List.of(multiSelect.items))
                                              .then((value) => value.init(state
                                                  .concreteView.groups
                                                  .expand((element) =>
                                                      element.elements)
                                                  .map((e) => e.uid)
                                                  .toList()));
                                          context
                                              .read<MultiSelectCubit>()
                                              .clear();
                                        },
                                      )
                                    : SizedBox(
                                        key: ValueKey(
                                            multiSelect.items.isNotEmpty),
                                      ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: SwitchIconButton(
                                  key: ValueKey(multiSelect.items.isNotEmpty),
                                  iconOn: const Icon(Icons.filter_list_rounded),
                                  iconOff: Transform.rotate(
                                    angle: pi / 1,
                                    child:
                                        const Icon(Icons.filter_list_rounded),
                                  ),
                                  state:
                                      state.order == ConcreteViewOrder.DEFAULT,
                                  onTap: () {
                                    context
                                        .read<
                                            ConcreteViewCubit<
                                                MangaApiClient,
                                                MangaConcreteView,
                                                MangaGalleryView>>()
                                        .changeOrder(state.order ==
                                                ConcreteViewOrder.DEFAULT
                                            ? ConcreteViewOrder.DEFAULT_REVERSE
                                            : ConcreteViewOrder.DEFAULT);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
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
      required PagesReadState pagesReadState,
      required bool isSelected,
      required bool multiselect,
      required ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          concreteViewInitialized}) {
    PagesRead? pagesRead;

    if (pagesReadState is PagesReadInitialized) {
      pagesRead = pagesReadState.pagesRead
          .firstWhereOrNull((element) => element.uid == chapter.uid);
    }

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.mediumLight.withOpacity(0.15),
      onTap: () {
        if (isSelected || multiselect) {
          if (isSelected) {
            context.read<MultiSelectCubit>().unselectItem(chapter.uid);
          } else {
            context.read<MultiSelectCubit>().selectItem(chapter.uid);
          }

          return;
        }
        Navigator.of(context)
            .pushNamed(Routes.chapterViewer,
                arguments: ChapterViewerData(
                    initialPage: pagesRead != null ? pagesRead.readPages : 1,
                    apiClient: data.client,
                    chapter: chapter,
                    group: group,
                    galleryView: galleryView,
                    configInfo: configInfo))
            .then((_) {
          context.read<PagesReadCubit>().init(concreteViewInitialized
              .concreteView.groups
              .expand((element) => element.elements)
              .map((e) => e.uid)
              .toList());
        });
      },
      onLongPress: () {
        if (isSelected) {
          context.read<MultiSelectCubit>().unselectItem(chapter.uid);
        } else {
          context.read<MultiSelectCubit>().selectItem(chapter.uid);
        }
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chapter.title.trim(),
              style: medium(
                  size: 18,
                  color: pagesRead != null && pagesRead.isRead
                      ? AppColors.mainGrey
                      : AppColors.mainWhite)),
          if (chapter.timestamp != null &&
              formatTimestamp(chapter).isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  formatTimestamp(chapter),
                  style: regular(color: AppColors.mainGrey, size: 12),
                ),
                if (pagesReadState is PagesReadInitialized &&
                    pagesRead != null &&
                    !pagesRead.isRead) ...[
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "${pagesRead.readPages} / ${pagesRead.totalPages}",
                    style: medium(color: AppColors.mainGrey, size: 12),
                  )
                ]
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
