import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/services/concrete_viewer_mixin.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_scope.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/ui/widgets/selection_action_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/text_styles.dart';

abstract class ConcreteViewerPage<T extends ApiClient, C extends ConcreteView,
        G extends GalleryView> extends StatelessWidget
    with ConcreteViewerMixin<T, C, G> {
  ConcreteViewerPage({super.key});

  final GlobalKey _scaffoldKey = GlobalKey();

  T get client;

  ConfigInfo get configInfo;

  String get concreteUid;

  Map<String, dynamic> get galleryData;

  String? get galleryCover;

  bool get fromLibrary;

  Map<String, String> get coverHeaders;

  bool get showsAlternativeTitles;

  String get elementsSectionTitle;

  Widget buildCoverImage(BuildContext context, String cover);

  Widget buildElementTile(
    BuildContext context,
    ConcreteViewInitialized<T, C, G> state,
    int index,
  );

  @override
  Widget build(BuildContext context) {
    if (fromLibrary) {
      return WebBrowserWrapper<T>(
        configInfo: configInfo,
        apiClient: client,
        onInterceptorInitialized: () {
          _scaffoldKey.currentContext
              ?.read<ConcreteViewCubit<T, C, G>>()
              .getConcrete(concreteUid, galleryData);
        },
        builder: (BuildContext context, Completer<bool> completer) =>
            BrowserInterceptorScope(
          configInfo: configInfo,
          apiClient: client,
          initCompleter: completer,
          onRecovered: _reloadConcrete,
          child: _buildConcreteBody(init: false),
        ),
      );
    }
    return _buildConcreteBody(init: true);
  }

  Widget _buildConcreteBody({required bool init}) {
    return ConcreteViewCubitWrapper<T, C, G>(
      client: client,
      configInfo: configInfo,
      init: (ConcreteViewCubit<T, C, G> cubit) {
        if (init) {
          cubit.getConcrete(concreteUid, galleryData);
        }
      },
      builder: (BuildContext context, ConcreteViewState<T, C, G> state) =>
          _buildBody(),
    );
  }

  void _reloadConcrete() {
    _scaffoldKey.currentContext
        ?.read<ConcreteViewCubit<T, C, G>>()
        .getConcrete(concreteUid, galleryData, forceRemote: true);
  }

  Scaffold _buildBody() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<ConcreteViewCubit<T, C, G>, ConcreteViewState<T, C, G>>(
        builder: (BuildContext context, ConcreteViewState<T, C, G> state) {
          final ConcreteViewInitialized<T, C, G>? initialized =
              state is ConcreteViewInitialized<T, C, G> ? state : null;
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.backgroundColor,
                onRefresh: () async {
                  await getConcreteViewCubit(context)
                      .getConcrete(concreteUid, galleryData, forceRemote: true);
                },
                child: _buildScrollView(context, state),
              ),
              const Positioned(
                top: 0,
                left: 0,
                child: ConcreteBackButton(),
              ),
              if (initialized != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child:
                      _buildFavoriteButton(context, initialized.concreteView),
                ),
              if (initialized != null)
                getSelectionOverlay(context, initialized),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollView(
      BuildContext context, ConcreteViewState<T, C, G> state) {
    final ConcreteViewInitialized<T, C, G>? initialized =
        state is ConcreteViewInitialized<T, C, G> ? state : null;
    final int groupSize = initialized == null ? 0 : _groupSize(initialized);
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            if (galleryCover != null) _buildCover(galleryCover!, context),
            if (initialized != null)
              ..._buildHeaderSection(context, initialized, groupSize)
            else if (state is ConcreteViewError<T, C, G>) ...<Widget>[
              _buildErrorMessage(context, state),
            ] else ...<Widget>[
              ConcreteContentSkeleton(
                showCover: galleryCover == null,
              ),
            ],
          ]),
        ),
        if (initialized != null)
          SliverList.builder(
            itemCount: groupSize,
            itemBuilder: (BuildContext context, int index) =>
                buildElementTile(context, initialized, index),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
              height: (initialized != null && initialized.selection.isNotEmpty
                      ? 24 + kSelectionActionBarContentHeight
                      : 24) +
                  MediaQuery.of(context).padding.bottom),
        ),
      ],
    );
  }

  int _groupSize(ConcreteViewInitialized<T, C, G> state) {
    if (state.groupIndex == -1) {
      return 0;
    }
    return state.concreteView.groups[state.groupIndex].elements.length;
  }

  List<Widget> _buildHeaderSection(BuildContext context,
      ConcreteViewInitialized<T, C, G> state, int groupSize) {
    final C concreteView = state.concreteView;
    return <Widget>[
      if (galleryCover == null) _buildCover(concreteView.cover, context),
      const SizedBox(height: 16),
      _buildTitle(concreteView),
      if (state.offline) ...<Widget>[
        const SizedBox(height: 16),
        const ConcreteOfflineBanner(),
      ],
      if (ConcreteMetadataRow.hasContent(concreteView)) ...<Widget>[
        const SizedBox(height: 12),
        ConcreteMetadataRow(view: concreteView),
      ],
      if (concreteView.tags.isNotEmpty) ...<Widget>[
        const SizedBox(height: 16),
        _buildTags(concreteView),
      ],
      if (concreteView.description.isNotEmpty) ...<Widget>[
        const SizedBox(height: 20),
        _buildDescription(concreteView),
      ],
      if (concreteView.groups.length > 1) ...<Widget>[
        const SizedBox(height: 20),
        ConcreteGroupSelector(
          titles: concreteView.groups
              .map((ElementsGroupOfConcrete g) => g.title)
              .toList(),
          selectedIndex: state.groupIndex,
          onSelected: (int index) =>
              getConcreteViewCubit(context).changeGroup(index),
        ),
      ],
      const SizedBox(height: 20),
      ConcreteSectionHeader(
        title: elementsSectionTitle,
        count: groupSize,
      ),
    ];
  }

  Widget _buildFavoriteButton(BuildContext context, C concreteView) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (BuildContext context, LibraryState libState) {
        final bool isFavorite = libState.entries
            .any((LibraryEntryDomain e) => e.uid == concreteView.uid);
        return ConcreteFavoriteButton(
          isFavorite: isFavorite,
          onTap: () => context.read<LibraryCubit>().toggleFavorite(
                LibraryEntryDomain(
                  id: 0,
                  uid: concreteView.uid,
                  extensionUid: configInfo.uid,
                  title: concreteView.title,
                  cover: concreteView.cover,
                  data: jsonEncode(galleryData),
                  createdAt: DateTime.now(),
                ),
              ),
        );
      },
    );
  }

  Widget _buildErrorMessage(
      BuildContext context, ConcreteViewError<T, C, G> state) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.concrete_viewer_error_title,
        message: state.message,
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              final ConcreteViewCubit<T, C, G> cubit =
                  getConcreteViewCubit(context);
              unawaited(BrowserInterceptorScope.retry(
                context,
                () => cubit.getConcrete(concreteUid, galleryData,
                    forceRemote: true),
              ));
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.current.concrete_viewer_retry_button),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(C concreteView) {
    final Widget title = Text(concreteView.title, style: semibold(size: 22));
    if (!showsAlternativeTitles) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: title,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          if (concreteView.alternativeTitles.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              concreteView.alternativeTitles.join(', '),
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTags(C concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: concreteView.tags
            .map((String e) => ConcreteTagChip(label: e))
            .toList(),
      ),
    );
  }

  Widget _buildCover(String cover, BuildContext context) {
    return Hero(
      tag: Heroes.galleryViewToConcreteView(concreteUid),
      flightShuttleBuilder: Heroes.crossfadeFlightShuttle,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onLongPress: () => showSaveImageSheet(
            context,
            url: cover,
            headers: coverHeaders,
          ),
          child: Stack(
            children: <Widget>[
              buildCoverImage(context, cover),
              const Positioned.fill(child: ConcreteCoverScrim()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(C concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpandableDescription(
        text: concreteView.description.replaceAll('\\n', '\n\n').trim(),
      ),
    );
  }
}
