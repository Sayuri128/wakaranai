import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';

enum SourceAttentionReason { notSignedIn, challengeRequired, sessionExpired }

class SourceNeedsAttention implements Exception {
  const SourceNeedsAttention({
    required this.config,
    required this.reason,
  });

  final ConfigInfo config;
  final SourceAttentionReason reason;

  String get extensionUid => config.uid;

  String get sessionKey => ProtectorStorageService.sessionKey(config);

  String get sourceName => config.name.trim();

  bool get needsLogin => config.protectorConfig?.needToLogin ?? false;

  @override
  String toString() =>
      'SourceNeedsAttention($sourceName, ${reason.name}, session: $sessionKey)';
}
