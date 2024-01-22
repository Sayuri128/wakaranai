import 'package:wakaranai/generated/l10n.dart';

// TODO: add local configs (that are stored locally on user's device)
enum ConfigsSourceType { GIT_HUB, REST }

String configsSourceTypeToString(ConfigsSourceType type) {
  switch (type) {
    case ConfigsSourceType.GIT_HUB:
      return S.current.github_configs_source_type;
    case ConfigsSourceType.REST:
      return S.current.rest_configs_source_type;
  }
}
