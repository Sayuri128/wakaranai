import 'package:dio/dio.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';
import 'package:wakaranai/utils/http_client.dart';

class AniListTracker extends TrackerService {
  AniListTracker({
    required this.clientId,
    Dio? dio,
    TrackerBrowserAuth? browserAuth,
  })  : _dio = dio ?? createDio(),
        _browserAuth = browserAuth ?? defaultTrackerBrowserAuth;

  static const String _endpoint = 'https://graphql.anilist.co';

  static const String _mediaFields = 'id idMal title { userPreferred romaji english } '
      'coverImage { medium } format startDate { year } chapters episodes';

  final String clientId;
  final Dio _dio;
  final TrackerBrowserAuth _browserAuth;

  @override
  TrackerId get id => TrackerId.anilist;

  @override
  String get name => 'AniList';

  @override
  bool get isConfigured => clientId.isNotEmpty;

  @override
  Future<TrackerAccount> login() async {
    final Uri url = Uri.https('anilist.co', '/api/v2/oauth/authorize',
        <String, String>{'client_id': clientId, 'response_type': 'token'});
    final Uri callback = Uri.parse(await _browserAuth(url));
    final Map<String, String> fragment =
        Uri.splitQueryString(callback.fragment);
    final String? token = fragment['access_token'];
    if (token == null || token.isEmpty) {
      throw const TrackerAuthException('AniList did not return a token');
    }
    final int? expiresIn = int.tryParse(fragment['expires_in'] ?? '');
    final Map<String, Object?> data = await _query(
      token,
      'query { Viewer { id name } }',
      const <String, Object?>{},
    );
    final Map<String, Object?> viewer = _map(data['Viewer']);
    return TrackerAccount(
      accessToken: token,
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().add(Duration(seconds: expiresIn)),
      userId: viewer['id']! as int,
      userName: viewer['name'] as String? ?? '',
    );
  }

  @override
  Future<List<TrackerSearchResult>> search(
    TrackerAccount account,
    String query,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> data = await _query(
      account.accessToken,
      r'query ($search: String, $type: MediaType) { Page(perPage: 15) { media(search: $search, type: $type) { '
      '$_mediaFields } } }',
      <String, Object?>{'search': query, 'type': _mediaType(type)},
    );
    final List<Object?> media =
        (_map(data['Page'])['media'] as List<Object?>?) ?? <Object?>[];
    return media
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> item) => _result(item, type))
        .toList(growable: false);
  }

  @override
  Future<TrackerSearchResult?> byId(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> data = await _query(
      account.accessToken,
      r'query ($id: Int) { Media(id: $id) { ' '$_mediaFields } }',
      <String, Object?>{'id': remoteId},
    );
    final Object? media = data['Media'];
    if (media is! Map<String, Object?>) {
      return null;
    }
    return _result(media, type);
  }

  Future<int?> idForMalId(
    TrackerAccount account,
    int malId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> data = await _query(
      account.accessToken,
      r'query ($malId: Int, $type: MediaType) { Media(idMal: $malId, type: $type) { id } }',
      <String, Object?>{'malId': malId, 'type': _mediaType(type)},
    );
    final Object? media = data['Media'];
    if (media is! Map<String, Object?>) {
      return null;
    }
    return media['id'] as int?;
  }

  @override
  Future<TrackerEntry?> entry(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> data = await _query(
      account.accessToken,
      r'query ($userId: Int, $mediaId: Int) { MediaList(userId: $userId, mediaId: $mediaId) { status progress media { chapters episodes } } }',
      <String, Object?>{'userId': account.userId, 'mediaId': remoteId},
      allowNotFound: true,
    );
    final Object? list = data['MediaList'];
    if (list is! Map<String, Object?>) {
      return null;
    }
    return _entry(list, type);
  }

  @override
  Future<TrackerEntry> update(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type, {
    required TrackerStatus status,
    required int progress,
  }) async {
    final Map<String, Object?> data = await _query(
      account.accessToken,
      r'mutation ($mediaId: Int, $progress: Int, $status: MediaListStatus) { SaveMediaListEntry(mediaId: $mediaId, progress: $progress, status: $status) { status progress media { chapters episodes } } }',
      <String, Object?>{
        'mediaId': remoteId,
        'progress': progress,
        'status': _statusName(status),
      },
    );
    return _entry(_map(data['SaveMediaListEntry']), type);
  }

  Future<Map<String, Object?>> _query(
    String token,
    String query,
    Map<String, Object?> variables, {
    bool allowNotFound = false,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      _endpoint,
      data: <String, Object?>{'query': query, 'variables': variables},
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        validateStatus: (int? status) =>
            status != null &&
            (status < 400 || (allowNotFound && status == 404)),
      ),
    );
    final Map<String, Object?> body = _map(response.data);
    if (response.statusCode == 404) {
      return <String, Object?>{};
    }
    final Object? errors = body['errors'];
    if (errors is List && errors.isNotEmpty && body['data'] == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: errors.first.toString(),
      );
    }
    return _map(body['data']);
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    return <String, Object?>{};
  }

  TrackerSearchResult _result(Map<String, Object?> media, TrackerMediaType type) {
    final Map<String, Object?> title = _map(media['title']);
    final String name = (title['userPreferred'] ??
        title['english'] ??
        title['romaji'] ??
        '') as String;
    return TrackerSearchResult(
      remoteId: media['id']! as int,
      malId: media['idMal'] as int?,
      title: name,
      cover: _map(media['coverImage'])['medium'] as String?,
      format: media['format'] as String?,
      year: _map(media['startDate'])['year'] as int?,
      totalCount: _total(media, type),
    );
  }

  TrackerEntry _entry(Map<String, Object?> list, TrackerMediaType type) {
    return TrackerEntry(
      status: _status(list['status'] as String?),
      progress: list['progress'] as int? ?? 0,
      totalCount: _total(_map(list['media']), type),
    );
  }

  int? _total(Map<String, Object?> media, TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return media['chapters'] as int?;
    }
    return media['episodes'] as int?;
  }

  String _mediaType(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'MANGA';
    }
    return 'ANIME';
  }

  TrackerStatus _status(String? value) {
    switch (value) {
      case 'CURRENT':
        return TrackerStatus.current;
      case 'COMPLETED':
        return TrackerStatus.completed;
      case 'PAUSED':
        return TrackerStatus.paused;
      case 'DROPPED':
        return TrackerStatus.dropped;
      case 'REPEATING':
        return TrackerStatus.repeating;
      default:
        return TrackerStatus.planning;
    }
  }

  String _statusName(TrackerStatus status) {
    switch (status) {
      case TrackerStatus.planning:
        return 'PLANNING';
      case TrackerStatus.current:
        return 'CURRENT';
      case TrackerStatus.completed:
        return 'COMPLETED';
      case TrackerStatus.paused:
        return 'PAUSED';
      case TrackerStatus.dropped:
        return 'DROPPED';
      case TrackerStatus.repeating:
        return 'REPEATING';
    }
  }
}
