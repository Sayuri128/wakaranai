import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/tags_item/tags_item.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/text_styles.dart';

class TagItem extends StatelessWidget {
  const TagItem({Key? key, required this.item}) : super(key: key);

  final TagsItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: medium(),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                item.count.toString(),
                style: medium(color: AppColors.green),
              )
            ],
          ),
        ),
      ),
    );
  }
}
