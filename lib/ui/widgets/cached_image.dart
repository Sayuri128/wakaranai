import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/caching_image/caching_image_cubit.dart';

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
    return BlocBuilder<CachingImageCubit, CachingImageState>(
      builder: (context, state) => CachedNetworkImage(
        imageUrl: url,
        cacheManager: (state as CachingImageInitial).cacheManager,
        progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
        ),
        errorWidget: (_, url, error) => const Icon(Icons.error),
        imageBuilder: (_, imageProvider) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: imageProvider,
            fit: fit,
          )),
        ),
      ),
    );
  }
}
