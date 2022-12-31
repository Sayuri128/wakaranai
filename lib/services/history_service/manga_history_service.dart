import 'package:wakaranai/models/data/history_manga_item/history_manga_item.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class MangaHistoryService extends SqfliteService<HistoryMangaItem> {
  MangaHistoryService()
      : super(tableName: SqfliteService.mangaHistoryTableName);
}
