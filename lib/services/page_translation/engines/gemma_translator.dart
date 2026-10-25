import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_variant.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class GemmaModel {
  static const int contextTokens = 4096;

  static const double _temperature = 0.2;
  static const int _topK = 40;
  static const int _maxOutputTokens = 1536;

  static Future<void>? _initialized;
  static Future<InferenceModel>? _model;
  static GemmaVariant? _loadedVariant;
  static int _users = 0;
  static Future<void> _queue = Future<void>.value();

  static Future<void> ensureInitialized() =>
      _initialized ??= FlutterEdgeAi.initialize(
        inferenceEngines: const <InferenceEngineProvider>[LiteRtLmEngine()],
      );

  static Future<bool> isInstalled(GemmaVariant variant) async {
    await ensureInitialized();
    return FlutterEdgeAi.isModelInstalled(variant.fileName);
  }

  static Future<void> install(
    GemmaVariant variant, {
    void Function(int percent)? onProgress,
    CancelToken? cancelToken,
  }) async {
    await ensureInitialized();
    InferenceInstallationBuilder builder = FlutterEdgeAi.installModel(
      modelType: ModelType.gemma4,
      fileType: ModelFileType.litertlm,
    ).fromNetwork(variant.downloadUrl).withProgress(onProgress ?? (_) {});
    if (cancelToken != null) {
      builder = builder.withCancelToken(cancelToken);
    }
    await builder.install();
  }

  static Future<void> uninstall(GemmaVariant variant) async {
    await ensureInitialized();
    if (_loadedVariant == variant) {
      await _close();
    }
    await FlutterEdgeAi.uninstallModel(variant.fileName);
  }

  static void retain() => _users++;

  static Future<void> releaseUser() async {
    if (_users > 0) {
      _users--;
    }
    if (_users == 0) {
      await _close();
    }
  }

  static Future<String> generate(GemmaVariant variant, String prompt) {
    return _exclusive(variant, (InferenceModel model) async {
      final InferenceModelSession session = await model.createSession(
        temperature: _temperature,
        topK: _topK,
        maxOutputTokens: _maxOutputTokens,
      );
      try {
        await session.addQueryChunk(Message.text(text: prompt, isUser: true));
        return await session.getResponse();
      } finally {
        await session.close();
      }
    });
  }

  static Future<T> _exclusive<T>(
    GemmaVariant variant,
    Future<T> Function(InferenceModel model) task,
  ) {
    final Future<T> result = _queue.then((_) async {
      final InferenceModel model = await _load(variant);
      return task(model);
    });
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  static Future<InferenceModel> _load(GemmaVariant variant) async {
    if (_loadedVariant != variant) {
      await _unload();
    }
    _loadedVariant = variant;
    return _model ??= _loadModel(variant);
  }

  static Future<InferenceModel> _loadModel(GemmaVariant variant) async {
    await ensureInitialized();
    if (!await isInstalled(variant)) {
      throw StateError('${variant.displayName} is not downloaded');
    }
    await install(variant);
    final Stopwatch watch = Stopwatch()..start();
    final InferenceModel model = await FlutterEdgeAi.getActiveModel(
      maxTokens: contextTokens,
      preferredBackend: PreferredBackend.gpu,
    );
    logger.i(
      '[gemma] ${variant.displayName} loaded in ${watch.elapsedMilliseconds}ms',
    );
    return model;
  }

  static Future<void> _close() async {
    await _queue;
    await _unload();
  }

  static Future<void> _unload() async {
    final Future<InferenceModel>? model = _model;
    _model = null;
    _loadedVariant = null;
    if (model == null) {
      return;
    }
    try {
      await (await model).close();
    } catch (e) {
      logger.w('Closing the Gemma model failed: $e');
    }
  }
}

class GemmaTranslator implements PageTranslator {
  GemmaTranslator(this.variant);

  final GemmaVariant variant;
  bool _retained = false;

  @override
  String get id => variant.engineId;

  @override
  bool get isLocal => true;

  @override
  Future<bool> isReady(PageLanguage from, PageLanguage to) =>
      GemmaModel.isInstalled(variant);

  @override
  Future<List<String>> translate(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
  }) async {
    if (texts.isEmpty) {
      return texts;
    }
    if (!_retained) {
      _retained = true;
      GemmaModel.retain();
    }
    final List<String?> translations = await _ask(texts, from, to);

    final List<int> retry = <int>[
      for (int i = 0; i < texts.length; i++)
        if (_needsRetry(texts[i], translations[i], from, to)) i,
    ];
    if (retry.isNotEmpty) {
      final List<String?> retried = await _ask(
        <String>[for (final int i in retry) texts[i]],
        from,
        to,
      );
      for (int k = 0; k < retry.length; k++) {
        final String? answer = retried[k];
        if (answer != null) {
          translations[retry[k]] = answer;
        }
      }
    }

    return <String>[
      for (final String? translation in translations) translation ?? '',
    ];
  }

  bool _needsRetry(
    String source,
    String? translation,
    PageLanguage from,
    PageLanguage to,
  ) {
    if (translation == null) {
      return true;
    }
    return from != to && isUntranslatedEcho(source, translation);
  }

  Future<List<String?>> _ask(
    List<String> texts,
    PageLanguage from,
    PageLanguage to,
  ) async {
    final String prompt = buildGemmaPrompt(texts, from: from, to: to);
    final Stopwatch watch = Stopwatch()..start();
    final String output = await GemmaModel.generate(variant, prompt);
    logger.i(
      '[gemma] bubbles=${texts.length} outputChars=${output.length} '
      'time=${watch.elapsedMilliseconds}ms',
    );
    return parseTranslations(output, texts.length);
  }

  @override
  Future<void> close() async {
    if (!_retained) {
      return;
    }
    _retained = false;
    await GemmaModel.releaseUser();
  }
}

class GemmaModelFiles implements GemmaModelStore {
  static const String _downloadGroup = 'smart_downloads';

  CancelToken? _cancelToken;

  @override
  Future<void> cancelStaleDownloads() async {
    final int cancelled = await FileDownloader().reset(group: _downloadGroup);
    if (cancelled > 0) {
      logger.i('[gemma] cancelled $cancelled stale model downloads');
    }
  }

  @override
  Future<bool> isInstalled(GemmaVariant variant) =>
      GemmaModel.isInstalled(variant);

  @override
  Future<void> install(
    GemmaVariant variant, {
    required void Function(int percent) onProgress,
  }) async {
    final CancelToken token = CancelToken();
    _cancelToken = token;
    try {
      await GemmaModel.install(
        variant,
        onProgress: onProgress,
        cancelToken: token,
      );
    } finally {
      _cancelToken = null;
    }
  }

  @override
  void cancel() => _cancelToken?.cancel();

  @override
  Future<void> uninstall(GemmaVariant variant) => GemmaModel.uninstall(variant);
}
