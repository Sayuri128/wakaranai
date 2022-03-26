import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard({Key? key, this.onTap, required this.data})
      : super(key: key);

  final VoidCallback? onTap;
  final GalleryView data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ThemeData.dark().cardColor,
          borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: data.cover,
                    height: 155,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )),
              const Spacer(),
              Text(data.title.overflow,
                  style: medium(), overflow: TextOverflow.ellipsis)
            ],
          ),
        ),
      ),
    );
  }
}
