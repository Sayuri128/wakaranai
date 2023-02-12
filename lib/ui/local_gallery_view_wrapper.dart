import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/services/library_service/library_service.dart';

class LocalGalleryViewWrapper extends StatelessWidget {
  const LocalGalleryViewWrapper(
      {Key? key, required this.type, required this.uid, required this.builder})
      : super(key: key);

  final LibraryItemType type;
  final String uid;
  final Widget Function(BuildContext context, LocalGalleryViewCardState state) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocalGalleryViewCardCubit(
          uid: uid, type: type, libraryService: context.read<LibraryService>())
        ..init(),
      child: BlocBuilder<LocalGalleryViewCardCubit, LocalGalleryViewCardState>(
        builder: (context, state) {
          return builder(context, state);
        },
      ),
    );
  }
}
