import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard({Key? key, this.onTap, required this.data}) : super(key: key);

  final VoidCallback? onTap;
  final GalleryView data;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: SizedBox(
        height: 220,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 8.0,
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
                  const SizedBox(height: 8),
                  Text(data.title.overflow, style: medium(), overflow: TextOverflow.ellipsis)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
