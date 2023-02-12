import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/model/services/pages_read_service.dart';
import 'package:wakaranai/models/data/pages_read.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'pages_read_state.dart';

class PagesReadCubit extends Cubit<PagesReadState> {
  late final StreamSubscription _concreteSub;

  PagesReadCubit({required this.concreteViewCubit})
      : super(PagesReadInitial()) {
    _concreteSub = concreteViewCubit.stream.listen(_initFromConcrete);
  }

  final ConcreteViewCubit<MangaApiClient, MangaConcreteView, MangaGalleryView>
      concreteViewCubit;

  final PagesReadService _pagesReadService = PagesReadService.instance;

  void _initFromConcrete(ConcreteViewState event) {
    if (event is ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
        MangaGalleryView>) {
      init(event.concreteView.groups
          .expand((element) => element.elements)
          .map((e) => e.uid)
          .toList());
      _concreteSub.cancel();
    }
  }

  void init(List<String> chapterUid) async {
    emit(PagesReadInitialized(
        pagesRead: (await Future.wait(chapterUid
                .map((e) async => await _pagesReadService.getByUid(e))))
            .where((element) => element != null)
            .toList()
            .cast()));
  }
}
