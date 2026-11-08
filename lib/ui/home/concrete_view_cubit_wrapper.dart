import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';
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

  void Function(String concreteUid, int? progress)? _trackerProgressHandler(
    BuildContext context,
  ) {
    final TrackerSyncService sync;
    try {
      sync = context.read<TrackerSyncService>();
    } on ProviderNotFoundException {
      return null;
    }
    return (String concreteUid, int? progress) {
      unawaited(sync.recordProgress(concreteUid, progress));
    };
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double>? routeAnimation = ModalRoute.of(context)?.animation;
    return BlocProvider<ConcreteViewCubit<T, C, G>>(
      create: (BuildContext context) {
        final ConcreteViewCubit<T, C, G> cubit = ConcreteViewCubit<T, C, G>(
          ConcreteViewState<T, C, G>(
            apiClient: client,
            configInfo: configInfo,
          ),
          concreteDataRepository: context.read<ConcreteDataRepository>(),
          chapterActivityRepository: context.read<ChapterActivityRepository>(),
          animeEpisodeActivityRepository: context.read<AnimeEpisodeActivityRepository>(),
          onTrackerProgress: _trackerProgressHandler(context),
        );

        final void Function(ConcreteViewCubit<T, C, G>)? start = init;
        if (start != null) {
          _afterTransition(routeAnimation, () {
            if (!cubit.isClosed) {
              start(cubit);
            }
          });
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

void _afterTransition(Animation<double>? animation, VoidCallback action) {
  if (animation == null || animation.isCompleted) {
    action();
    return;
  }
  late final AnimationStatusListener listener;
  listener = (AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animation.removeStatusListener(listener);
      action();
    } else if (status == AnimationStatus.dismissed) {
      animation.removeStatusListener(listener);
    }
  };
  animation.addStatusListener(listener);
}
