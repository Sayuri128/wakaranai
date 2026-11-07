import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';

extension ConfigInfoTypeKinds on ConfigInfoType {
  bool get readsChapters {
    return this == ConfigInfoType.MANGA || this == ConfigInfoType.NOVEL;
  }
}
