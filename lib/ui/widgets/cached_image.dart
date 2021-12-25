import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/image_cache/image_cache_cubit.dart';
import 'package:h_reader/ui/widgets/skeleton_loaders.dart';

class CachedImage extends StatelessWidget {
  const CachedImage(
      {Key? key,
      this.fit = BoxFit.cover,
      required this.url,
      required this.width,
      required this.height})
      : super(key: key);

  final BoxFit fit;
  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageCacheCubit>(
        create: (_) => ImageCacheCubit(isPrimary: false)..saveCacheIfNotExist(url: url),
        child: BlocBuilder<ImageCacheCubit, ImageCacheState>(
          builder: (context, state) {
            if (state is ImageCacheSaved) {
              return Image.memory(state.data);
            } else {
              return buildImageSkeletonLoader(height: height, width: width);
            }
          },
        ));
  }
}
