import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/gallery_view.dart';

class ServiceViewCubitWrapper<T extends ApiClient, G extends GalleryView> extends StatelessWidget {
  const ServiceViewCubitWrapper(
      {Key? key, required this.client, required this.builder})
      : super(key: key);

  final T client;
  final Widget Function(BuildContext context, ServiceViewState<T, G> state)
      builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceViewCubit<T, G>>(
      create: (context) =>
          ServiceViewCubit(ServiceViewInitial<T, G>(client: client)),
      child: BlocBuilder<ServiceViewCubit<T, G>, ServiceViewState<T, G>>(
        builder: (context, state) => builder(context, state),
      ),
    );
  }
}
