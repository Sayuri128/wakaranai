import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/models/data/gallery/local_gallery_view.dart';
import 'package:wakaranai/models/data/library/library_item.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LocalGalleryViewWrapper<I extends LibraryItem<G>,
    G extends LocalGalleryView> extends StatelessWidget {
  const LocalGalleryViewWrapper(
      {Key? key, required this.type, required this.uid, required this.builder})
      : super(key: key);

  final ConfigInfoType type;
  final String uid;
  final Widget Function(BuildContext context, LocalGalleryViewCardState<I, G> state)
      builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocalGalleryViewCardCubit<I, G>(uid: uid)..init(),
      child: BlocBuilder<LocalGalleryViewCardCubit<I, G>,
          LocalGalleryViewCardState<I, G>>(
        builder: (context, state) {
          return builder(context, state);
        },
      ),
    );
  }
}
