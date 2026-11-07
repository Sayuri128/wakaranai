import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';

typedef TrackerBrowserAuth = Future<String> Function(Uri url);

const String trackerCallbackScheme = 'wakaranai';

Future<String> defaultTrackerBrowserAuth(Uri url) {
  return FlutterWebAuth2.authenticate(
    url: url.toString(),
    callbackUrlScheme: trackerCallbackScheme,
  );
}

String trackerRedirectUri(TrackerId id) {
  return '$trackerCallbackScheme://tracker/${id.name}';
}

abstract class TrackerService {
  TrackerId get id;

  String get name;

  bool get isConfigured;

  Future<TrackerAccount> login();

  Future<TrackerAccount> refresh(TrackerAccount account) async => account;

  Future<List<TrackerSearchResult>> search(
    TrackerAccount account,
    String query,
    TrackerMediaType type,
  );

  Future<TrackerSearchResult?> byId(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  );

  Future<TrackerEntry?> entry(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  );

  Future<TrackerEntry> update(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type, {
    required TrackerStatus status,
    required int progress,
  });
}
