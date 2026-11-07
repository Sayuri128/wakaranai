import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';

class SourceAttentionText {
  const SourceAttentionText._();

  static bool asksToSignIn(SourceNeedsAttention attention) {
    return attention.needsLogin &&
        attention.reason != SourceAttentionReason.challengeRequired;
  }

  static String message(SourceNeedsAttention attention) {
    final String source = attention.sourceName;
    if (!asksToSignIn(attention)) {
      return S.current.updates_attention_browser_check(source);
    }
    if (attention.reason == SourceAttentionReason.sessionExpired) {
      return S.current.updates_attention_sign_in_again(source);
    }
    return S.current.updates_attention_sign_in(source);
  }

  static String notificationTitle(List<SourceNeedsAttention> attentions) {
    final String sources = attentions
        .map((SourceNeedsAttention attention) => attention.sourceName)
        .join(', ');
    if (attentions.any(asksToSignIn)) {
      return S.current.updates_attention_notification_sign_in_title(sources);
    }
    return S.current.updates_attention_notification_browser_title(sources);
  }
}
