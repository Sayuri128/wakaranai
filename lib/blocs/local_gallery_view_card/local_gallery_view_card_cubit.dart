import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/services/library_service/library_service.dart';
import 'package:wakaranai/services/sqflite_service/query_item.dart';

part 'local_gallery_view_card_state.dart';

class LocalGalleryViewCardCubit extends Cubit<LocalGalleryViewCardState> {
  LocalGalleryViewCardCubit(
      {required this.uid, required this.type, required this.libraryService})
      : super(LocalGalleryViewCardInitial());

  final LibraryService libraryService;

  final String uid;
  final LibraryItemType type;

  void init() async {
    libraryService.query(query: [
      SqfliteQueryKeyValueItem(key: 'galleryViewId', value: uid)
    ]).then((value) {
      if (value.isNotEmpty) {
        emit(LocalGalleryViewCardLoaded(libraryItem: value.first));
      } else {
        emit(LocalGalleryViewCardLoaded(libraryItem: null));
      }
    });
  }

  void create(LibraryItem item, VoidCallback onDone) async {
    item.id = await libraryService.insert(item);
    emit(LocalGalleryViewCardLoaded(libraryItem: item));
    onDone();
  }

  void delete(VoidCallback onDone) async {
    if (state is LocalGalleryViewCardLoaded) {
      final item = (state as LocalGalleryViewCardLoaded).libraryItem;
      if (item == null) {
        return;
      }
      await libraryService.delete(item.id!);
      emit(LocalGalleryViewCardLoaded(libraryItem: null));
      onDone();
    }
  }
}
