import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/utils/globals.dart';
import 'package:wakascript/api_controller.dart';

import 'package:wakascript/models/concrete_view/chapter/chapter.dart';

import '../../models/data/manga_storage_item.dart';

part 'chapter_storage_state.dart';

class ChapterStorageCubit extends Cubit<ChapterStorageState> {
  ChapterStorageCubit({required this.client, required this.uid})
      : super(ChapterStorageInitial());

  final ApiClient client;
  final String uid;
  String? docDir;

  void init(Chapter chapter) async {
    try {
      emit(ChapterStorageInitializing());

      Directory concreteDir = await _getConcreteDir(chapter);

      final chapterDir = Directory('${concreteDir.path}/${chapter.uid}');
      if (!chapterDir.existsSync()) {
        emit(ChapterStorageInitialized(chapter: chapter));
        return;
      }

      emit(ChapterStorageInitialized(
          chapter: chapter,
          item: ChapterStorageItem(
              uid: uid,
              files: chapterDir
                  .listSync()
                  .where((element) => element.isAbsolute)
                  .map((e) => File(e.path))
                  .toList())));
    } on Exception {
      emit(ChapterStorageInitialized(chapter: chapter));
    }
  }

  Future<Directory> _getConcreteDir(Chapter chapter) async {
    docDir ??= '${await getAppDocumentsDir()}/cache';

    final serviceInfo = await client.getConfigInfo();

    final serviceDir =
        Directory('$docDir/${serviceInfo.name.replaceAll(" ", '_')}');

    if (!serviceDir.existsSync()) {
      await serviceDir.create(recursive: true);
      emit(ChapterStorageInitialized(chapter: chapter));
    }

    final concreteDir = Directory('${serviceDir.path}/$uid');

    if (!concreteDir.existsSync()) {
      await concreteDir.create();
      emit(ChapterStorageInitialized(chapter: chapter));
    }
    return concreteDir;
  }

  void downloadChapter(Chapter chapter) async {
    emit(ChapterStorageInitializing());

    try {
      final pages = await client.getPages(uid: chapter.uid);

      final concreteDir = await _getConcreteDir(chapter);

      final chapterDir = Directory('${concreteDir.path}/${chapter.uid}');

      if (!chapterDir.existsSync()) {
        await chapterDir.create();
      }

      final files = <File>[];

      final httpClient = HttpClient();
      for (var i = 0; i < pages.value.length; i++) {
        final element = pages.value[i];
        final req = await httpClient.getUrl(Uri.parse(element));
        final res = await req.close();
        final bytes = await consolidateHttpClientResponseBytes(res);
        File file = File('${chapterDir.path}/$i');
        files.add(file);
        file.writeAsBytesSync(bytes);
      }

      emit(ChapterStorageInitialized(
          chapter: chapter,
          item: ChapterStorageItem(uid: chapter.uid, files: files)));
    } on Exception {
      emit(ChapterStorageInitialized(chapter: chapter));
    }
  }

  void delete(Chapter chapter) async {
    emit(ChapterStorageInitializing());

    try {
      final concreteDir = await _getConcreteDir(chapter);

      final chapterDir = Directory('${concreteDir.path}/${chapter.uid}');

      if (!chapterDir.existsSync()) {
        emit(ChapterStorageInitialized(chapter: chapter));
      } else {
        chapterDir.deleteSync();
        emit(ChapterStorageInitialized(chapter: chapter));
      }
    } on Exception {
      emit(ChapterStorageInitialized(chapter: chapter));
    }
  }
}
