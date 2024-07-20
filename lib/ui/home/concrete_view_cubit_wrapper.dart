import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';

class ConcreteViewCubitWrapper<T extends ApiClient, C extends ConcreteView,
    G extends GalleryView> extends StatelessWidget {
  const ConcreteViewCubitWrapper({
    super.key,
    required this.client,
    required this.configInfo,
    required this.builder,
    this.init,
  });

  final void Function(ConcreteViewCubit<T, C, G>)? init;
  final T client;
  final ConfigInfo configInfo;
  final Widget Function(BuildContext context, ConcreteViewState<T, C, G> state)
      builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConcreteViewCubit<T, C, G>>(
      create: (BuildContext context) {
        final ConcreteViewCubit<T, C, G> cubit = ConcreteViewCubit<T, C, G>(
          ConcreteViewState<T, C, G>(
            apiClient: client,
            configInfo: configInfo,
          ),
          concreteDataRepository: context.read<ConcreteDataRepository>(),
          chapterActivityRepository: context.read<ChapterActivityRepository>(),
        );

        if (init != null) {
          init!(cubit);
        }

        return cubit;
      },
      child:
          BlocBuilder<ConcreteViewCubit<T, C, G>, ConcreteViewState<T, C, G>>(
        builder: (BuildContext context, ConcreteViewState<T, C, G> state) =>
            builder(context, state),
      ),
    );
  }
}
