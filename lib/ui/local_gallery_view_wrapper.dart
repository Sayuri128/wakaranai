// import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class LocalGalleryViewWrapper<I extends LibraryItem<G>,
//     G extends LocalGalleryView> extends StatelessWidget {
//   const LocalGalleryViewWrapper(
//       {Key? key, required this.type, required this.uid, required this.builder})
//       : super(key: key);
//
//   final ConfigInfoType type;
//   final String uid;
//   final Widget Function(BuildContext context, LocalGalleryViewCardState<I, G> state)
//       builder;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => LocalGalleryViewCardCubit<I, G>(uid: uid)..init(),
//       child: BlocBuilder<LocalGalleryViewCardCubit<I, G>,
//           LocalGalleryViewCardState<I, G>>(
//         builder: (context, state) {
//           return builder(context, state);
//         },
//       ),
//     );
//   }
// }
