import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/utils/http_client.dart';

const String deepLEngineId = 'deepl';

const int _maxTextsPerRequest = 50;
const String _freeKeySuffix = ':fx';
const int _invalidKeyStatus = 403;
const int _quotaExceededStatus = 456;
const int _maxCachedGlossaries = 20;

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
  String? glossaryId,
}) {
  return <String, Object>{
    'text': texts,
    'source_lang': deepLSourceCode(from),
    'target_lang': deepLTargetCode(to),
    if (context != null && context.isNotEmpty) 'context': context,
    if (glossaryId != null) 'glossary_id': glossaryId,
  };
}

String deepLGlossaryEntries(List<GlossaryEntry> glossary) {
  String clean(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return glossary
      .where((GlossaryEntry entry) => entry.isComplete)
      .map(
        (GlossaryEntry entry) =>
            '${clean(entry.source)}\t${clean(entry.target)}',
      )
      .join('\n');
}

class _DeepLGlossaryCache {
  static const String _preferencesKey = 'page_translation_deepl_glossaries';

  static Future<Map<String, String>> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? stored = preferences.getString(_preferencesKey);
    if (stored == null) {
      return <String, String>{};
    }
    try {
      final Map<String, dynamic> json =
          jsonDecode(stored) as Map<String, dynamic>;
      return json.map(
        (String key, dynamic value) => MapEntry<String, String>(key, '$value'),
      );
    } on FormatException {
      return <String, String>{};
    }
  }

  static Future<void> write(Map<String, String> glossaries) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferencesKey, jsonEncode(glossaries));
  }
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
    List<GlossaryEntry> glossary = const <GlossaryEntry>[],
  }) async {
    final List<GlossaryEntry> used = glossaryUsedIn(glossary, texts);
    String? glossaryId;
    if (used.isNotEmpty) {
      glossaryId = await _glossaryId(glossary, from: from, to: to);
    }
    try {
      return await _translateBatches(
        texts,
        from: from,
        to: to,
        glossaryId: glossaryId,
        hint: glossaryId == null ? used : const <GlossaryEntry>[],
      );
    } on DeepLException catch (e) {
      if (glossaryId == null || e.error != DeepLError.unknown) {
        rethrow;
      }
      logger.w('DeepL rejected the glossary, using a hint instead: $e');
      await _forgetGlossary(glossaryId);
      return _translateBatches(texts, from: from, to: to, hint: used);
    }
  }

  Future<List<String>> _translateBatches(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
    String? glossaryId,
    List<GlossaryEntry> hint = const <GlossaryEntry>[],
  }) async {
    String context = texts.join('\n');
    if (hint.isNotEmpty) {
      context = 'Names: ${glossaryHint(hint)}\n$context';
    }
    final List<String> translations = <String>[];
    for (int start = 0; start < texts.length; start += _maxTextsPerRequest) {
      final List<String> batch = texts.sublist(
        start,
        (start + _maxTextsPerRequest).clamp(0, texts.length),
      );
      final Response<Object?> response = await _send(
        () => _dio.post<Object?>(
          '${deepLBaseUrl(apiKey)}/v2/translate',
          data: buildDeepLRequest(
            batch,
            from: from,
            to: to,
            context: context,
            glossaryId: glossaryId,
          ),
          options: _options,
        ),
      );
      translations.addAll(parseDeepLTranslations(response.data, batch.length));
    }
    return translations;
  }

  Future<String?> _glossaryId(
    List<GlossaryEntry> glossary, {
    required PageLanguage from,
    required PageLanguage to,
  }) async {
    final String entries = deepLGlossaryEntries(glossary);
    if (entries.isEmpty) {
      return null;
    }
    final String keyTail = apiKey.substring(
      (apiKey.length - 6).clamp(0, apiKey.length),
    );
    final String cacheKey = '$keyTail|${from.code}>${to.code}|$entries';
    final Map<String, String> cached = await _DeepLGlossaryCache.read();
    final String? existing = cached[cacheKey];
    if (existing != null) {
      return existing;
    }

    final String? created = await _createGlossary(entries, from: from, to: to);
    if (created == null) {
      return null;
    }
    cached[cacheKey] = created;
    while (cached.length > _maxCachedGlossaries) {
      final String oldestKey = cached.keys.first;
      final String? oldestId = cached.remove(oldestKey);
      if (oldestId != null) {
        await _deleteGlossary(oldestId);
      }
    }
    await _DeepLGlossaryCache.write(cached);
    return created;
  }

  Future<String?> _createGlossary(
    String entries, {
    required PageLanguage from,
    required PageLanguage to,
  }) async {
    try {
      final Response<Object?> response = await _send(
        () => _dio.post<Object?>(
          '${deepLBaseUrl(apiKey)}/v2/glossaries',
          data: <String, String>{
            'name': 'Wakaranai ${from.code}-${to.code}',
            'source_lang': from.code,
            'target_lang': to.code,
            'entries': entries,
            'entries_format': 'tsv',
          },
          options: _options,
        ),
      );
      final Object? body = response.data;
      if (body is Map<String, dynamic>) {
        return body['glossary_id'] as String?;
      }
      return null;
    } on DeepLException catch (e) {
      logger.w('DeepL glossary could not be created: $e');
      return null;
    }
  }

  Future<void> _forgetGlossary(String glossaryId) async {
    final Map<String, String> cached = await _DeepLGlossaryCache.read();
    cached.removeWhere((String key, String id) => id == glossaryId);
    await _DeepLGlossaryCache.write(cached);
  }

  Future<void> _deleteGlossary(String glossaryId) async {
    try {
      await _send(
        () => _dio.delete<Object?>(
          '${deepLBaseUrl(apiKey)}/v2/glossaries/$glossaryId',
          options: _options,
        ),
      );
    } on DeepLException catch (e) {
      logger.w('Old DeepL glossary could not be deleted: $e');
    }
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
    List<GlossaryEntry> glossary = const <GlossaryEntry>[],
  }) async {
    if (texts.isEmpty) {
      return texts;
    }
    final String? apiKey = await DeepLApiKeyStore.read();
    if (apiKey == null) {
      throw const DeepLException(DeepLError.invalidKey);
    }
    return DeepLClient(
      apiKey,
    ).translate(texts, from: from, to: to, glossary: glossary);
  }

  @override
  Future<void> close() async {}
}
