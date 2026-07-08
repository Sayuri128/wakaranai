import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/ui/widgets/selection_action_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';

mixin ConcreteViewerMixin<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> {
  ConcreteViewCubit<T, C, G> getConcreteViewCubit(BuildContext context) {
    return context.read<ConcreteViewCubit<T, C, G>>();
  }

  Future<void> _downloadSelected(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) async {
    if (state.configInfo.type != ConfigInfoType.MANGA) return;
    if (state.domain == null || state.apiClient is! MangaApiClient) return;

    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    final elements = state.concreteView.groups[state.groupIndex].elements;

    for (final String uid in List<String>.of(state.selection)) {
      final ElementOfElementsGroupOfConcrete element = elements.firstWhere(
          (ElementOfElementsGroupOfConcrete e) => e.uid == uid);
      await manager.enqueueChapter(
        client: state.apiClient as MangaApiClient,
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

  Widget getSelectionOverlay(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) {
    final ConcreteViewCubit<T, C, G> cubit = getConcreteViewCubit(context);
    final bool selecting = state.selection.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
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
              if (state.configInfo.type == ConfigInfoType.MANGA)
                SelectionAction(
                  icon: Icons.download_outlined,
                  label: S.of(context).concrete_selection_download,
                  color: AppColors.primary,
                  onTap: () => _downloadSelected(context, state),
                ),
              SelectionAction(
                icon: Icons.done_all,
                label: S.of(context).concrete_selection_mark_read,
                color: AppColors.primary,
                onTap: cubit.markSelectedAsCompleted,
              ),
              SelectionAction(
                icon: Icons.remove_done,
                label: S.of(context).concrete_selection_mark_unread,
                onTap: cubit.markSelectedAsNotCompleted,
              ),
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
