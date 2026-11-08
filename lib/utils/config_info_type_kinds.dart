import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';

extension ConfigInfoTypeKinds on ConfigInfoType {
  bool get readsChapters {
    return this == ConfigInfoType.MANGA || this == ConfigInfoType.NOVEL;
  }

  bool get usesChapterActivities {
    return readsChapters || this == ConfigInfoType.AUDIO;
  }

  bool get supportsDownloads {
    return this != ConfigInfoType.AUDIO;
  }

  bool get supportsTracking {
    return this != ConfigInfoType.AUDIO;
  }
}
