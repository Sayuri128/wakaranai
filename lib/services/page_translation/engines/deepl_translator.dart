import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/utils/http_client.dart';

const String deepLEngineId = 'deepl';

const int _maxTextsPerRequest = 50;
const String _freeKeySuffix = ':fx';
const int _invalidKeyStatus = 403;
const int _quotaExceededStatus = 456;

class DeepLUsage {
  const DeepLUsage({
    required this.characterCount,
    required this.characterLimit,
  });

  final int characterCount;
  final int characterLimit;

  double get usedShare {
    if (characterLimit <= 0) {
      return 0;
    }
    return characterCount / characterLimit;
  }
}

enum DeepLError { invalidKey, quotaExceeded, network, unknown }

class DeepLException implements Exception {
  const DeepLException(this.error, [this.details]);

  final DeepLError error;
  final String? details;

  @override
  String toString() => 'DeepLException(${error.name}, $details)';
}

class DeepLApiKeyStore {
  static const String _storageKey = 'page_translation_deepl_api_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> read() async {
    final String? key = await _storage.read(key: _storageKey);
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  }

  static Future<void> write(String key) {
    return _storage.write(key: _storageKey, value: key.trim());
  }

  static Future<void> delete() => _storage.delete(key: _storageKey);
}

String deepLBaseUrl(String apiKey) {
  if (apiKey.endsWith(_freeKeySuffix)) {
    return 'https://api-free.deepl.com';
  }
  return 'https://api.deepl.com';
}

String deepLSourceCode(PageLanguage language) => language.code.toUpperCase();

String deepLTargetCode(PageLanguage language) {
  return switch (language.code) {
    'en' => 'EN-US',
    'pt' => 'PT-BR',
    'zh' => 'ZH-HANS',
    _ => language.code.toUpperCase(),
  };
}

Map<String, Object> buildDeepLRequest(
  List<String> texts, {
  required PageLanguage from,
  required PageLanguage to,
  String? context,
}) {
  return <String, Object>{
    'text': texts,
    'source_lang': deepLSourceCode(from),
    'target_lang': deepLTargetCode(to),
    if (context != null && context.isNotEmpty) 'context': context,
  };
}

List<String> parseDeepLTranslations(Object? body, int count) {
  List<dynamic> items = const <dynamic>[];
  if (body is Map<String, dynamic>) {
    items = body['translations'] as List<dynamic>? ?? const <dynamic>[];
  }
  final List<String> translations = <String>[];
  for (int i = 0; i < count; i++) {
    String text = '';
    if (i < items.length) {
      final Map<String, dynamic> item = items[i] as Map<String, dynamic>;
      text = (item['text'] as String? ?? '').trim();
    }
    translations.add(text);
  }
  return translations;
}

class DeepLClient {
  DeepLClient(this.apiKey, {Dio? dio}) : _dio = dio ?? createDio();

  final String apiKey;
  final Dio _dio;

  Options get _options => Options(
    headers: <String, String>{'Authorization': 'DeepL-Auth-Key $apiKey'},
    contentType: Headers.jsonContentType,
  );

  Future<List<String>> translate(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
  }) async {
    final String context = texts.join('\n');
    final List<String> translations = <String>[];
    for (int start = 0; start < texts.length; start += _maxTextsPerRequest) {
      final List<String> batch = texts.sublist(
        start,
        (start + _maxTextsPerRequest).clamp(0, texts.length),
      );
      final Response<Object?> response = await _send(
        () => _dio.post<Object?>(
          '${deepLBaseUrl(apiKey)}/v2/translate',
          data: buildDeepLRequest(batch, from: from, to: to, context: context),
          options: _options,
        ),
      );
      translations.addAll(parseDeepLTranslations(response.data, batch.length));
    }
    return translations;
  }

  Future<DeepLUsage> usage() async {
    final Response<Object?> response = await _send(
      () => _dio.get<Object?>(
        '${deepLBaseUrl(apiKey)}/v2/usage',
        options: _options,
      ),
    );
    final Map<String, dynamic> body =
        response.data as Map<String, dynamic>? ?? const <String, dynamic>{};
    return DeepLUsage(
      characterCount: (body['character_count'] as num?)?.toInt() ?? 0,
      characterLimit: (body['character_limit'] as num?)?.toInt() ?? 0,
    );
  }

  Future<Response<Object?>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _toDeepLException(e);
    }
  }

  DeepLException _toDeepLException(DioException exception) {
    final int? status = exception.response?.statusCode;
    if (status == _invalidKeyStatus) {
      return const DeepLException(DeepLError.invalidKey);
    }
    if (status == _quotaExceededStatus) {
      return const DeepLException(DeepLError.quotaExceeded);
    }
    if (status == null) {
      return DeepLException(DeepLError.network, exception.message);
    }
    return DeepLException(
      DeepLError.unknown,
      '$status ${exception.response?.data}',
    );
  }
}

class DeepLTranslator implements PageTranslator {
  static const String engineId = deepLEngineId;

  @override
  String get id => engineId;

  @override
  bool get isLocal => false;

  @override
  Future<bool> isReady(PageLanguage from, PageLanguage to) async {
    return await DeepLApiKeyStore.read() != null;
  }

  @override
  Future<List<String>> translate(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
  }) async {
    if (texts.isEmpty) {
      return texts;
    }
    final String? apiKey = await DeepLApiKeyStore.read();
    if (apiKey == null) {
      throw const DeepLException(DeepLError.invalidKey);
    }
    return DeepLClient(apiKey).translate(texts, from: from, to: to);
  }

  @override
  Future<void> close() async {}
}
