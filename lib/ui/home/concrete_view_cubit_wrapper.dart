import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/concrete_view.dart';
import 'package:wakascript/models/gallery_view.dart';

class ConcreteViewCubitWrapper<T extends ApiClient, C extends ConcreteView,
    G extends GalleryView> extends StatelessWidget {
  const ConcreteViewCubitWrapper(
      {Key? key, required this.client, required this.builder, this.init})
      : super(key: key);

  final void Function(ConcreteViewCubit<T, C, G>)? init;
  final T client;
  final Widget Function(BuildContext context, ConcreteViewState<T, C, G> state)
      builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConcreteViewCubit<T, C, G>>(
      create: (context) {
        final cubit = ConcreteViewCubit<T, C, G>(
            ConcreteViewState<T, C, G>(apiClient: client));

        if (init != null) {
          init!(cubit);
        }

        return cubit;
      },
      child:
          BlocBuilder<ConcreteViewCubit<T, C, G>, ConcreteViewState<T, C, G>>(
        builder: (context, state) => builder(context, state),
      ),
    );
  }
}
