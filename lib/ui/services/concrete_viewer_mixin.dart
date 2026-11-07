import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/downloads/episode_title_downloader.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_button.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/chapter_translation_actions.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/ui/widgets/selection_action_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/config_info_type_kinds.dart';

mixin ConcreteViewerMixin<T extends ApiClient, C extends ConcreteView,
    G extends GalleryView> {
  ConcreteViewCubit<T, C, G> getConcreteViewCubit(BuildContext context) {
    return context.read<ConcreteViewCubit<T, C, G>>();
  }

  Future<void> _downloadSelected(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) async {
    if (state.configInfo.type == ConfigInfoType.ANIME) {
      await _downloadSelectedEpisodes(context, state);
      return;
    }
    if (!state.configInfo.type.readsChapters) {
      return;
    }
    if (state.domain == null) {
      return;
    }

    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    final elements = state.concreteView.groups[state.groupIndex].elements;

    for (final String uid in List<String>.of(state.selection)) {
      final ElementOfElementsGroupOfConcrete element = elements.firstWhere(
          (ElementOfElementsGroupOfConcrete e) => e.uid == uid);
      await manager.enqueueChapter(
        client: state.apiClient,
        extensionUid: state.configInfo.uid,
        concreteUid: state.concreteView.uid,
        concreteId: state.domain!.id,
        concreteTitle: state.concreteView.title,
        concreteCover: state.concreteView.cover,
        chapterUid: uid,
        title: element.title,
        data: element.data,
        autoStart: false,
      );
    }

    manager.startQueue();
    getConcreteViewCubit(context).clearSelection();
  }

  Future<void> _downloadSelectedEpisodes(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) async {
    final ConcreteDataDomain? domain = state.domain;
    if (domain == null || state.apiClient is! AnimeApiClient) {
      return;
    }

    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    final ConcreteViewCubit<T, C, G> cubit = getConcreteViewCubit(context);
    final List<AnimeVideo> groupEpisodes = state
        .concreteView.groups[state.groupIndex].elements
        .whereType<AnimeVideo>()
        .toList();
    final List<AnimeVideo> episodes =
        selectedEpisodesInWatchOrder(groupEpisodes, state.selection);

    for (final AnimeVideo episode in episodes) {
      await manager.enqueueEpisode(
        extensionUid: state.configInfo.uid,
        concreteUid: state.concreteView.uid,
        concreteId: domain.id,
        concreteTitle: state.concreteView.title,
        concreteCover: state.concreteView.cover,
        episode: episode,
        autoStart: false,
      );
    }

    manager.startQueue();
    cubit.clearSelection();
  }

  Future<void> _translateSelected(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) async {
    if (state.configInfo.type != ConfigInfoType.MANGA) {
      return;
    }
    if (state.domain == null || state.apiClient is! MangaApiClient) {
      return;
    }

    final List<ElementOfElementsGroupOfConcrete> elements =
        state.concreteView.groups[state.groupIndex].elements;
    final List<ChapterToTranslate> chapters = <ChapterToTranslate>[];
    for (final String uid in state.selection) {
      for (final ElementOfElementsGroupOfConcrete chapter in elements) {
        if (chapter.uid == uid) {
          chapters.add(ChapterToTranslate(
            uid: uid,
            title: chapter.title,
            data: chapter.data,
          ));
        }
      }
    }
    final ConcreteViewCubit<T, C, G> cubit = getConcreteViewCubit(context);
    await translateChapters(
      context,
      client: state.apiClient as MangaApiClient,
      extensionUid: state.configInfo.uid,
      extensionLanguage: state.configInfo.language,
      concreteUid: state.concreteView.uid,
      concreteId: state.domain!.id,
      concreteTitle: state.concreteView.title,
      concreteCover: state.concreteView.cover,
      chapters: chapters,
    );
    cubit.clearSelection();
  }

  String _markDoneLabel(
    BuildContext context,
    ConcreteViewInitialized<T, C, G> state,
  ) {
    if (state.configInfo.type == ConfigInfoType.ANIME) {
      return S.of(context).concrete_selection_mark_watched;
    }
    return S.of(context).concrete_selection_mark_read;
  }

  String _markNotDoneLabel(
    BuildContext context,
    ConcreteViewInitialized<T, C, G> state,
  ) {
    if (state.configInfo.type == ConfigInfoType.ANIME) {
      return S.of(context).concrete_selection_mark_unwatched;
    }
    return S.of(context).concrete_selection_mark_unread;
  }

  List<SelectionAction> extraSelectionActions(
    BuildContext context,
    ConcreteViewInitialized<T, C, G> state,
  ) {
    return const <SelectionAction>[];
  }

  Widget getSelectionOverlay(
      BuildContext context, ConcreteViewInitialized<T, C, G> state,
      {ConcreteContinueAction? continueAction}) {
    final ConcreteViewCubit<T, C, G> cubit = getConcreteViewCubit(context);
    final bool canTranslate = state.configInfo.type == ConfigInfoType.MANGA &&
        context.read<PageTranslationSettingsCubit>().state.enabled;
    final bool selecting = state.selection.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (continueAction != null)
          Positioned(
            left: 16.0,
            right: 76.0,
            bottom: 16.0 + MediaQuery.of(context).padding.bottom,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selecting ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: selecting,
                child: ConcreteContinueButton(action: continueAction),
              ),
            ),
          ),
        Positioned(
          right: 16.0,
          bottom: 16.0 + MediaQuery.of(context).padding.bottom,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: selecting ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: selecting,
              child: SwitchIconButton(
                iconOn: const Icon(Icons.filter_list_rounded),
                state: state.order == ConcreteViewOrder.def,
                onTap: () {
                  cubit.changeOrder(state.order == ConcreteViewOrder.def
                      ? ConcreteViewOrder.defReverse
                      : ConcreteViewOrder.def);
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SelectionActionBar(
            visible: selecting,
            countLabel: S.of(context).concrete_selection_count(
                  state.selection.length,
                ),
            actions: <SelectionAction>[
              SelectionAction(
                icon: Icons.download_outlined,
                label: S.of(context).concrete_selection_download,
                color: AppColors.primary,
                onTap: () => _downloadSelected(context, state),
              ),
              if (canTranslate)
                SelectionAction(
                  icon: Icons.translate_rounded,
                  label: S.of(context).concrete_selection_translate,
                  color: AppColors.primary,
                  onTap: () => _translateSelected(context, state),
                ),
              SelectionAction(
                icon: Icons.done_all,
                label: _markDoneLabel(context, state),
                color: AppColors.primary,
                onTap: cubit.markSelectedAsCompleted,
              ),
              SelectionAction(
                icon: Icons.remove_done,
                label: _markNotDoneLabel(context, state),
                onTap: cubit.markSelectedAsNotCompleted,
              ),
            ],
            secondaryActions: <SelectionAction>[
              ...extraSelectionActions(context, state),
              SelectionAction(
                icon: Icons.select_all,
                label: S.of(context).concrete_selection_select_all,
                onTap: cubit.selectAll,
              ),
              SelectionAction(
                icon: Icons.flip,
                label: S.of(context).concrete_selection_invert,
                onTap: cubit.invertSelection,
              ),
              SelectionAction(
                icon: Icons.close,
                label: S.of(context).concrete_selection_clear,
                onTap: cubit.clearSelection,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
