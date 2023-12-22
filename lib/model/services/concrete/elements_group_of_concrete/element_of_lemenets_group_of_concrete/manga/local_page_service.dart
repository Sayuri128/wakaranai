import 'package:wakaranai/model/wakaranai_db.dart';

class LocalPageService {
  static final LocalPageService instance = LocalPageService();

  Future<int> add(String url, int pagesId) async {
    return await waka
        .into(waka.localPageTable)
        .insert(LocalPageTableCompanion.insert(url: url, pagesId: pagesId));
  }

  Future<void> delete(int pagesId) async {
    await (waka.delete(waka.localPageTable)
          ..where((tbl) => tbl.pagesId.equals(pagesId)))
        .go();
  }
}
