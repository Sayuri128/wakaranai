import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';

class ServiceViewCubitWrapper<T extends ApiClient, G extends GalleryView>
    extends StatelessWidget {
  const ServiceViewCubitWrapper(
      {super.key, required this.client, required this.builder});

  final T client;
  final Widget Function(BuildContext context, ServiceViewState<T, G> state)
      builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceViewCubit<T, G>>(
      create: (BuildContext context) =>
          ServiceViewCubit(ServiceViewInitial<T, G>(client: client)),
      child: BlocBuilder<ServiceViewCubit<T, G>, ServiceViewState<T, G>>(
        builder: (BuildContext context, ServiceViewState<T, G> state) =>
            builder(context, state),
      ),
    );
  }
}
