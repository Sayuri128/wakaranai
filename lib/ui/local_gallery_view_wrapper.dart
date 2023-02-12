import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/models/data/local_api_client.dart';

class LocalGalleryViewWrapper extends StatelessWidget {
  const LocalGalleryViewWrapper(
      {Key? key, required this.type, required this.uid, required this.builder})
      : super(key: key);

  final LocalApiClientType type;
  final String uid;
  final Widget Function(BuildContext context, LocalGalleryViewCardState state) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocalGalleryViewCardCubit(
          uid: uid, type: type)
        ..init(),
      child: BlocBuilder<LocalGalleryViewCardCubit, LocalGalleryViewCardState>(
        builder: (context, state) {
          return builder(context, state);
        },
      ),
    );
  }
}
