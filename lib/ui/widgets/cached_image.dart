import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/image_cache/image_cache_cubit.dart';

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
    return CachedNetworkImage(
        imageUrl: url,
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
        imageBuilder: (_, imageProvider) {
          context.read<ImageCacheCubit>().saveCacheIfNotExist(cacheKey: url);
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: imageProvider,
              fit: fit,
            )),
          );
        });
  }
}
