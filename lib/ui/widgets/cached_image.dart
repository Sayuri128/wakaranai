import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
              return Image.memory(state.data, width: width, height: height, fit: fit);
            } else {
              return buildImageSkeletonLoader(height: height, width: width);
            }
          },
        ));
  }
}

class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  final String url;

  const CachedImageProvider({
    required this.url,
  });

  @override
  ImageStreamCompleter load(CachedImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      scale: 1.0,
      codec: _loadAsync(decode),
      informationCollector: () sync* {
        yield ErrorDescription('Path: $url');
      },
    );
  }

  Future<Codec> _loadAsync(DecoderCallback decode) async {
    final file = await ImageCacheCubit.instance.getFileFromCache(url);

    Uint8List? bytes;

    if (file == null) {
      bytes = (await http.get(Uri.parse(url))).bodyBytes;
      ImageCacheCubit.instance.putFile(url, bytes);
    } else {
      bytes = file.file.readAsBytesSync();
    }

    if (bytes.lengthInBytes == 0) {
      PaintingBinding.instance?.imageCache?.evict(this);
      throw StateError('$url is empty and cannot be loaded as an image.');
    }

    return await decode(bytes);
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }
}
