import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/widgets/change_order_icon_button.dart';
import 'package:wakaranai/ui/widgets/expandable_fab_widget.dart';

mixin ConcreteViewerMixin<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> {
  ConcreteViewCubit<T, C, G> getConcreteViewCubit(BuildContext context) {
    return context.read<ConcreteViewCubit<T, C, G>>();
  }

  ExpandableFabWidget getExpandableFabWidget(
      BuildContext context, ConcreteViewInitialized<T, C, G> state) {
    return ExpandableFabWidget(
      expanded: state.selection.isNotEmpty,
      items: {
        ExpandableFabDirection.left: [
          ExpandableFabItemData(
            icon: SwitchIconButton(
              iconOn: const Icon(Icons.delete),
              state: false,
              onTap: () {
                getConcreteViewCubit(context).markSelectedAsNotCompleted();
              },
            ),
          ),
          ExpandableFabItemData(
            icon: SwitchIconButton(
              iconOn: const Icon(Icons.check),
              state: false,
              onTap: () {
                getConcreteViewCubit(context).markSelectedAsCompleted();
              },
            ),
          ),
        ],
        ExpandableFabDirection.top: [
          ExpandableFabItemData(
            icon: SwitchIconButton(
              iconOn: const Icon(Icons.clear),
              state: false,
              onTap: () {
                getConcreteViewCubit(context).clearSelection();
              },
            ),
          ),
          ExpandableFabItemData(
            icon: SwitchIconButton(
              iconOn: const Icon(Icons.border_clear),
              state: false,
              onTap: () {
                getConcreteViewCubit(context).invertSelection();
              },
            ),
          ),
          ExpandableFabItemData(
            icon: SwitchIconButton(
              iconOn: const Icon(Icons.select_all),
              state: false,
              onTap: () {
                getConcreteViewCubit(context).selectAll();
              },
            ),
          ),
        ],
      },
      child: SwitchIconButton(
        iconOn: const Icon(Icons.filter_list_rounded),
        state: state.order == ConcreteViewOrder.def,
        onTap: () {
          getConcreteViewCubit(context).changeOrder(
              state.order == ConcreteViewOrder.def
                  ? ConcreteViewOrder.defReverse
                  : ConcreteViewOrder.def);
        },
      ),
    );
  }
}
