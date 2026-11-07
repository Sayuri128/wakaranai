import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';

class SourceAttentionPreferences {
  static const String _notifiedAtPrefix = 'SOURCE_ATTENTION_NOTIFIED_AT_';
  static const Duration notifyInterval = Duration(days: 1);

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    final SharedPreferences preferences =
        _preferences ??= await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences;
  }

  static String _keyFor(String sessionKey) => '$_notifiedAtPrefix$sessionKey';

  Future<List<SourceNeedsAttention>> dueForNotification(
    List<SourceNeedsAttention> attentions,
    DateTime now,
  ) async {
    if (attentions.isEmpty) {
      return const <SourceNeedsAttention>[];
    }
    final SharedPreferences preferences = await _load();
    final List<SourceNeedsAttention> due = <SourceNeedsAttention>[];
    for (final SourceNeedsAttention attention in attentions) {
      final int? notifiedAt =
          preferences.getInt(_keyFor(attention.sessionKey));
      if (notifiedAt == null) {
        due.add(attention);
        continue;
      }
      final DateTime last = DateTime.fromMillisecondsSinceEpoch(notifiedAt);
      if (now.difference(last) >= notifyInterval) {
        due.add(attention);
      }
    }
    return due;
  }

  Future<void> markNotified(
    List<SourceNeedsAttention> attentions,
    DateTime now,
  ) async {
    final SharedPreferences preferences = await _load();
    for (final SourceNeedsAttention attention in attentions) {
      await preferences.setInt(
        _keyFor(attention.sessionKey),
        now.millisecondsSinceEpoch,
      );
    }
  }

  Future<void> clear(String sessionKey) async {
    final SharedPreferences preferences = await _load();
    await preferences.remove(_keyFor(sessionKey));
  }
}
