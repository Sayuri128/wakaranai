import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_pages/local_page.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/pages/pages.dart';

class LocalPages extends Pages {
  final int? id;

  LocalPages(
      {required this.id,
      required String chapterUid,
      required List<String> value})
      : super(chapterUid: chapterUid, value: value);

  factory LocalPages.fromDrift(
          DriftLocalPages drift, List<DriftLocalPage> driftPages) =>
      LocalPages(
          id: drift.id,
          chapterUid: drift.chapterUid,
          value: driftPages
              .map((e) => LocalPage.fromDrift(e))
              .map((e) => e.url)
              .toList());
}
