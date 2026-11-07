import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';

abstract class TrackerAccountsStore {
  Future<TrackerAccount?> read(TrackerId id);

  Future<void> write(TrackerId id, TrackerAccount account);

  Future<void> remove(TrackerId id);
}

class SecureTrackerAccountsStore implements TrackerAccountsStore {
  SecureTrackerAccountsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(TrackerId id) => 'tracker_account_${id.name}';

  @override
  Future<TrackerAccount?> read(TrackerId id) async {
    try {
      final String? stored = await _storage.read(key: _key(id));
      if (stored == null) {
        return null;
      }
      final Object? json = jsonDecode(stored);
      if (json is! Map) {
        return null;
      }
      return TrackerAccount.fromJson(json.cast<String, Object?>());
    } catch (error) {
      logger.w('Could not read the ${id.name} account: $error');
      return null;
    }
  }

  @override
  Future<void> write(TrackerId id, TrackerAccount account) {
    return _storage.write(key: _key(id), value: jsonEncode(account.toJson()));
  }

  @override
  Future<void> remove(TrackerId id) {
    return _storage.delete(key: _key(id));
  }
}

class MemoryTrackerAccountsStore implements TrackerAccountsStore {
  final Map<TrackerId, TrackerAccount> accounts = <TrackerId, TrackerAccount>{};

  @override
  Future<TrackerAccount?> read(TrackerId id) async => accounts[id];

  @override
  Future<void> write(TrackerId id, TrackerAccount account) async {
    accounts[id] = account;
  }

  @override
  Future<void> remove(TrackerId id) async {
    accounts.remove(id);
  }
}
