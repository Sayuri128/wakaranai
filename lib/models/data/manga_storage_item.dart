import 'dart:io';

class ChapterStorageItem {

  final String uid;
  final List<File> files;

  const ChapterStorageItem({
    required this.uid,
    required this.files,
  });
}
