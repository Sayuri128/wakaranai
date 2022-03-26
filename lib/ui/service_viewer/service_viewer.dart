import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/ui/service_viewer/gallery_view_card.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';

import '../routes.dart';
import 'concrete_viewer/concrete_viewer.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({Key? key, required this.apiClient}) : super(key: key);

  final ApiClient apiClient;

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.home, (route) => false);
        return Future.value(false);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ApiClientControllerCubit>(
              create: (context) =>
                  ApiClientControllerCubit(apiClient: widget.apiClient)
                    ..getConfigInfo()
                    ..getGallery())
        ],
        child: BlocListener<ApiClientControllerCubit, ApiClientControllerState>(
          listener: (context, state) {
            if (state is ApiClientControllerGalleryView) {
              _refreshController.loadComplete();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            extendBodyBehindAppBar: true,
            body:
                BlocBuilder<ApiClientControllerCubit, ApiClientControllerState>(
              builder: (context, state) {
                return SmartRefresher(
                    enablePullUp: true,
                    enablePullDown: false,
                    footer: CustomFooter(
                      builder: (context, mode) {
                        if (mode == LoadStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    controller: _refreshController,
                    onLoading: () {
                      context.read<ApiClientControllerCubit>().getGallery();
                    },
                    child: state is ApiClientControllerGalleryView
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: 200,
                                    crossAxisCount: 2),
                            itemCount: state.galleryViews.length,
                            itemBuilder: (context, index) => GalleryViewCard(
                                  data: state.galleryViews[index],
                                  onTap: () {
                                    _onGalleryViewClick(
                                        context, state.galleryViews[index]);
                                  },
                                ))
                        : const SizedBox());
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onGalleryViewClick(BuildContext context, GalleryView e) {
    Navigator.of(context).pushNamed(Routes.concreteViewer,
        arguments: ConcreteViewerData(client: widget.apiClient, uid: e.uid));
  }
}
