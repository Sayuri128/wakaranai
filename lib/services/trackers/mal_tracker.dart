import 'dart:math';

import 'package:dio/dio.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';
import 'package:wakaranai/utils/http_client.dart';

class MalTracker extends TrackerService {
  MalTracker({
    required this.clientId,
    Dio? dio,
    TrackerBrowserAuth? browserAuth,
    Random? random,
  })  : _dio = dio ?? createDio(),
        _browserAuth = browserAuth ?? defaultTrackerBrowserAuth,
        _random = random ?? Random.secure();

  static const String _api = 'https://api.myanimelist.net/v2';
  static const String _tokenUrl = 'https://myanimelist.net/v1/oauth2/token';
  static const String _verifierAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  final String clientId;
  final Dio _dio;
  final TrackerBrowserAuth _browserAuth;
  final Random _random;

  @override
  TrackerId get id => TrackerId.mal;

  @override
  String get name => 'MyAnimeList';

  @override
  bool get isConfigured => clientId.isNotEmpty;

  @override
  Future<TrackerAccount> login() async {
    final String verifier = _randomString(96);
    final String state = _randomString(24);
    final Uri url = Uri.https('myanimelist.net', '/v1/oauth2/authorize',
        <String, String>{
          'response_type': 'code',
          'client_id': clientId,
          'code_challenge': verifier,
          'code_challenge_method': 'plain',
          'redirect_uri': trackerRedirectUri(id),
          'state': state,
        });
    final Uri callback = Uri.parse(await _browserAuth(url));
    final String? code = callback.queryParameters['code'];
    if (code == null || callback.queryParameters['state'] != state) {
      throw const TrackerAuthException('MyAnimeList login was cancelled');
    }
    final TrackerAccount tokens = await _token(<String, String>{
      'client_id': clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': trackerRedirectUri(id),
      'code_verifier': verifier,
    });
    final Map<String, Object?> me = await _get(tokens, '/users/@me');
    return tokens.copyWith(
      userId: me['id'] as int? ?? 0,
      userName: me['name'] as String? ?? '',
    );
  }

  @override
  Future<TrackerAccount> refresh(TrackerAccount account) async {
    final String? refreshToken = account.refreshToken;
    if (refreshToken == null) {
      throw const TrackerAuthException('MyAnimeList session expired');
    }
    final TrackerAccount tokens = await _token(<String, String>{
      'client_id': clientId,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    return tokens.copyWith(userId: account.userId, userName: account.userName);
  }

  @override
  Future<List<TrackerSearchResult>> search(
    TrackerAccount account,
    String query,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> body = await _get(
      account,
      '/${_path(type)}',
      <String, Object?>{
        'q': query.length > 64 ? query.substring(0, 64) : query,
        'limit': 15,
        'fields': _fields(type),
      },
    );
    final List<Object?> data = (body['data'] as List<Object?>?) ?? <Object?>[];
    return data
        .whereType<Map>()
        .map((Map item) => _result(item.cast<String, Object?>()['node'], type))
        .whereType<TrackerSearchResult>()
        .toList(growable: false);
  }

  @override
  Future<TrackerSearchResult?> byId(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> body = await _get(
      account,
      '/${_path(type)}/$remoteId',
      <String, Object?>{'fields': _fields(type)},
    );
    return _result(body, type);
  }

  @override
  Future<TrackerEntry?> entry(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?> body = await _get(
      account,
      '/${_path(type)}/$remoteId',
      <String, Object?>{'fields': 'my_list_status,${_totalField(type)}'},
    );
    final Object? status = body['my_list_status'];
    if (status is! Map) {
      return null;
    }
    return _entry(status.cast<String, Object?>(), type,
        total: body[_totalField(type)] as int?);
  }

  @override
  Future<TrackerEntry> update(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type, {
    required TrackerStatus status,
    required int progress,
  }) async {
    final Response<Object?> response = await _dio.patch<Object?>(
      '$_api/${_path(type)}/$remoteId/my_list_status',
      data: <String, Object?>{
        'status': _statusName(status, type),
        _progressField(type): progress,
        if (status == TrackerStatus.repeating) _rewatchField(type): true,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: _auth(account),
      ),
    );
    final Object? body = response.data;
    if (body is! Map) {
      return TrackerEntry(status: status, progress: progress);
    }
    return _entry(body.cast<String, Object?>(), type);
  }

  Future<TrackerAccount> _token(Map<String, String> form) async {
    final Response<Object?> response = await _dio.post<Object?>(
      _tokenUrl,
      data: form,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final Object? body = response.data;
    if (body is! Map || body['access_token'] is! String) {
      throw const TrackerAuthException('MyAnimeList did not return a token');
    }
    final int? expiresIn = body['expires_in'] as int?;
    return TrackerAccount(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String?,
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().add(Duration(seconds: expiresIn)),
      userId: 0,
      userName: '',
    );
  }

  Future<Map<String, Object?>> _get(
    TrackerAccount account,
    String path, [
    Map<String, Object?>? query,
  ]) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '$_api$path',
      queryParameters: query,
      options: Options(headers: _auth(account)),
    );
    final Object? body = response.data;
    if (body is Map) {
      return body.cast<String, Object?>();
    }
    return <String, Object?>{};
  }

  Map<String, String> _auth(TrackerAccount account) {
    return <String, String>{'Authorization': 'Bearer ${account.accessToken}'};
  }

  TrackerSearchResult? _result(Object? node, TrackerMediaType type) {
    if (node is! Map) {
      return null;
    }
    final Map<String, Object?> media = node.cast<String, Object?>();
    final Object? picture = media['main_picture'];
    final String? startDate = media['start_date'] as String?;
    final int remoteId = media['id']! as int;
    return TrackerSearchResult(
      remoteId: remoteId,
      malId: remoteId,
      title: media['title'] as String? ?? '',
      cover: picture is Map ? picture['medium'] as String? : null,
      format: media['media_type'] as String?,
      year: startDate == null || startDate.length < 4
          ? null
          : int.tryParse(startDate.substring(0, 4)),
      totalCount: _positiveOrNull(media[_totalField(type)]),
    );
  }

  TrackerEntry _entry(
    Map<String, Object?> status,
    TrackerMediaType type, {
    int? total,
  }) {
    return TrackerEntry(
      status: _status(status['status'] as String?),
      progress: status[_progressField(type)] as int? ?? 0,
      totalCount: _positiveOrNull(total),
    );
  }

  int? _positiveOrNull(Object? value) {
    if (value is int && value > 0) {
      return value;
    }
    return null;
  }

  String _path(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'manga';
    }
    return 'anime';
  }

  String _fields(TrackerMediaType type) {
    return 'id,title,main_picture,media_type,start_date,${_totalField(type)}';
  }

  String _totalField(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'num_chapters';
    }
    return 'num_episodes';
  }

  String _progressField(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'num_chapters_read';
    }
    return 'num_watched_episodes';
  }

  String _rewatchField(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'is_rereading';
    }
    return 'is_rewatching';
  }

  TrackerStatus _status(String? value) {
    switch (value) {
      case 'reading':
      case 'watching':
        return TrackerStatus.current;
      case 'completed':
        return TrackerStatus.completed;
      case 'on_hold':
        return TrackerStatus.paused;
      case 'dropped':
        return TrackerStatus.dropped;
      default:
        return TrackerStatus.planning;
    }
  }

  String _statusName(TrackerStatus status, TrackerMediaType type) {
    final bool manga = type == TrackerMediaType.manga;
    switch (status) {
      case TrackerStatus.planning:
        return manga ? 'plan_to_read' : 'plan_to_watch';
      case TrackerStatus.current:
      case TrackerStatus.repeating:
        return manga ? 'reading' : 'watching';
      case TrackerStatus.completed:
        return 'completed';
      case TrackerStatus.paused:
        return 'on_hold';
      case TrackerStatus.dropped:
        return 'dropped';
    }
  }

  String _randomString(int length) {
    return List<String>.generate(
      length,
      (_) => _verifierAlphabet[_random.nextInt(_verifierAlphabet.length)],
    ).join();
  }
}
