import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/models/concrete_view/chapter/chapter.dart';

enum DownloadedChapterDialogResult { DOWNLOAD_AGAIN, DELETE }

class DownloadedChapterDialog extends StatelessWidget {
  const DownloadedChapterDialog({Key? key, required this.chapter})
      : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(chapter.title.overflow,
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            style: medium(size: 18),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 16,
        ),
        const Divider(
          thickness: 2,
        ),
        ListTile(
          title: Text(S.current.download_again, style: regular(size: 16)),
          onTap: () {
            Navigator.of(context)
                .pop(DownloadedChapterDialogResult.DOWNLOAD_AGAIN);
          },
        ),
        ListTile(
          title: Text(S.current.delete, style: regular(size: 16)),
          onTap: () {
            Navigator.of(context).pop(DownloadedChapterDialogResult.DELETE);
          },
        )
      ]),
    );
  }
}
