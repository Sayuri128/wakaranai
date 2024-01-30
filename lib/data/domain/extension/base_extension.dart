import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/models/remote_config/remote_category.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';

mixin BaseExtension {
  abstract final RemoteCategory category;
  abstract final ConfigInfo config;
}
