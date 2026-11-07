import 'package:dio/dio.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';
import 'package:wakaranai/utils/http_client.dart';

class ShikimoriTracker extends TrackerService {
  ShikimoriTracker({
    required this.clientId,
    required this.clientSecret,
    Dio? dio,
    TrackerBrowserAuth? browserAuth,
  })  : _dio = dio ?? createDio(headers: const <String, String>{'User-Agent': 'Wakaranai'}),
        _browserAuth = browserAuth ?? defaultTrackerBrowserAuth;

  static const String _host = 'shikimori.io';
  static const String _base = 'https://$_host';

  final String clientId;
  final String clientSecret;
  final Dio _dio;
  final TrackerBrowserAuth _browserAuth;

  @override
  TrackerId get id => TrackerId.shikimori;

  @override
  String get name => 'Shikimori';

  @override
  bool get isConfigured => clientId.isNotEmpty && clientSecret.isNotEmpty;

  @override
  Future<TrackerAccount> login() async {
    final Uri url = Uri.https(_host, '/oauth/authorize', <String, String>{
      'client_id': clientId,
      'redirect_uri': trackerRedirectUri(id),
      'response_type': 'code',
      'scope': 'user_rates',
    });
    final Uri callback = Uri.parse(await _browserAuth(url));
    final String? code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const TrackerAuthException('Shikimori login was cancelled');
    }
    final TrackerAccount tokens = await _token(<String, String>{
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
      'redirect_uri': trackerRedirectUri(id),
    });
    final Map<String, Object?> me = _map(
      (await _dio.get<Object?>('$_base/api/users/whoami',
              options: Options(headers: _auth(tokens))))
          .data,
    );
    return tokens.copyWith(
      userId: me['id'] as int? ?? 0,
      userName: me['nickname'] as String? ?? '',
    );
  }

  @override
  Future<TrackerAccount> refresh(TrackerAccount account) async {
    final String? refreshToken = account.refreshToken;
    if (refreshToken == null) {
      throw const TrackerAuthException('Shikimori session expired');
    }
    final TrackerAccount tokens = await _token(<String, String>{
      'grant_type': 'refresh_token',
      'client_id': clientId,
      'client_secret': clientSecret,
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
    final Response<Object?> response = await _dio.get<Object?>(
      '$_base/api/${_collection(type)}',
      queryParameters: <String, Object?>{'search': query, 'limit': 15},
      options: Options(headers: _auth(account)),
    );
    final Object? body = response.data;
    if (body is! List) {
      return const <TrackerSearchResult>[];
    }
    return body
        .whereType<Map>()
        .map((Map item) => _result(item.cast<String, Object?>(), type))
        .toList(growable: false);
  }

  @override
  Future<TrackerSearchResult?> byId(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '$_base/api/${_collection(type)}/$remoteId',
      options: Options(
        headers: _auth(account),
        validateStatus: (int? status) =>
            status != null && (status < 400 || status == 404),
      ),
    );
    final Object? body = response.data;
    if (response.statusCode == 404 || body is! Map) {
      return null;
    }
    return _result(body.cast<String, Object?>(), type);
  }

  @override
  Future<TrackerEntry?> entry(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Map<String, Object?>? rate = await _rate(account, remoteId, type);
    if (rate == null) {
      return null;
    }
    return _entry(rate, type);
  }

  @override
  Future<TrackerEntry> update(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type, {
    required TrackerStatus status,
    required int progress,
  }) async {
    final Map<String, Object?>? existing = await _rate(account, remoteId, type);
    final Map<String, Object?> fields = <String, Object?>{
      'status': _statusName(status),
      _progressField(type): progress,
    };
    final Response<Object?> response;
    if (existing == null) {
      response = await _dio.post<Object?>(
        '$_base/api/v2/user_rates',
        data: <String, Object?>{
          'user_rate': <String, Object?>{
            'user_id': account.userId,
            'target_id': remoteId,
            'target_type': _targetType(type),
            ...fields,
          },
        },
        options: Options(headers: _auth(account)),
      );
    } else {
      response = await _dio.patch<Object?>(
        '$_base/api/v2/user_rates/${existing['id']}',
        data: <String, Object?>{'user_rate': fields},
        options: Options(headers: _auth(account)),
      );
    }
    final Object? body = response.data;
    if (body is! Map) {
      return TrackerEntry(status: status, progress: progress);
    }
    return _entry(body.cast<String, Object?>(), type);
  }

  Future<Map<String, Object?>?> _rate(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '$_base/api/v2/user_rates',
      queryParameters: <String, Object?>{
        'user_id': account.userId,
        'target_id': remoteId,
        'target_type': _targetType(type),
      },
      options: Options(headers: _auth(account)),
    );
    final Object? body = response.data;
    if (body is! List || body.isEmpty || body.first is! Map) {
      return null;
    }
    return (body.first as Map).cast<String, Object?>();
  }

  Future<TrackerAccount> _token(Map<String, String> form) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '$_base/oauth/token',
      data: form,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final Map<String, Object?> body = _map(response.data);
    final Object? token = body['access_token'];
    if (token is! String) {
      throw const TrackerAuthException('Shikimori did not return a token');
    }
    final int? expiresIn = body['expires_in'] as int?;
    return TrackerAccount(
      accessToken: token,
      refreshToken: body['refresh_token'] as String?,
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().add(Duration(seconds: expiresIn)),
      userId: 0,
      userName: '',
    );
  }

  Map<String, String> _auth(TrackerAccount account) {
    return <String, String>{'Authorization': 'Bearer ${account.accessToken}'};
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    return <String, Object?>{};
  }

  TrackerSearchResult _result(Map<String, Object?> item, TrackerMediaType type) {
    final String? preview = _map(item['image'])['preview'] as String?;
    final String? airedOn = item['aired_on'] as String?;
    final String russian = item['russian'] as String? ?? '';
    final int remoteId = item['id']! as int;
    return TrackerSearchResult(
      remoteId: remoteId,
      malId: remoteId,
      title: russian.isNotEmpty ? russian : item['name'] as String? ?? '',
      cover: preview == null ? null : _absolute(preview),
      format: item['kind'] as String?,
      year: airedOn == null || airedOn.length < 4
          ? null
          : int.tryParse(airedOn.substring(0, 4)),
      totalCount: _positiveOrNull(item[_progressField(type)]),
    );
  }

  String _absolute(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return '$_base$path';
  }

  TrackerEntry _entry(Map<String, Object?> rate, TrackerMediaType type) {
    return TrackerEntry(
      status: _status(rate['status'] as String?),
      progress: rate[_progressField(type)] as int? ?? 0,
    );
  }

  int? _positiveOrNull(Object? value) {
    if (value is int && value > 0) {
      return value;
    }
    return null;
  }

  String _collection(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'mangas';
    }
    return 'animes';
  }

  String _targetType(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'Manga';
    }
    return 'Anime';
  }

  String _progressField(TrackerMediaType type) {
    if (type == TrackerMediaType.manga) {
      return 'chapters';
    }
    return 'episodes';
  }

  TrackerStatus _status(String? value) {
    switch (value) {
      case 'watching':
        return TrackerStatus.current;
      case 'rewatching':
        return TrackerStatus.repeating;
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

  String _statusName(TrackerStatus status) {
    switch (status) {
      case TrackerStatus.planning:
        return 'planned';
      case TrackerStatus.current:
        return 'watching';
      case TrackerStatus.repeating:
        return 'rewatching';
      case TrackerStatus.completed:
        return 'completed';
      case TrackerStatus.paused:
        return 'on_hold';
      case TrackerStatus.dropped:
        return 'dropped';
    }
  }
}
