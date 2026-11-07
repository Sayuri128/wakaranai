import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';

class GalleryFeedMemory {
  GalleryFeedMemory();

  static final GalleryFeedMemory session = GalleryFeedMemory();

  final Map<String, String> _selectedByExtension = <String, String>{};

  String? feedFor(String extensionUid) => _selectedByExtension[extensionUid];

  void remember(String extensionUid, String feedId) {
    _selectedByExtension[extensionUid] = feedId;
  }

  void clear() {
    _selectedByExtension.clear();
  }

  static bool offers(ConfigInfo configInfo, String? feedId) {
    if (feedId == null) {
      return false;
    }
    return configInfo.feeds.any((GalleryFeed feed) => feed.id == feedId);
  }
}
