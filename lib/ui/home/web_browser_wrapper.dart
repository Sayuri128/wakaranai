import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/data/models/web_browser_result/web_browser_result.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';

class WebBrowserWrapper<T extends ApiClient> extends StatefulWidget {
  const WebBrowserWrapper(
      {super.key,
      required this.builder,
      required this.onInterceptorInitialized,
      required this.configInfo,
      required this.apiClient});

  final Widget Function(BuildContext context, Completer<bool>) builder;
  final VoidCallback onInterceptorInitialized;

  final T apiClient;
  final ConfigInfo configInfo;

  @override
  State<WebBrowserWrapper> createState() => _WebBrowserWrapperState();
}

class _WebBrowserWrapperState extends State<WebBrowserWrapper> {
  final Completer<bool> _interceptorInitCompleter = Completer();
  final Completer<bool> _protectorInitCompleter = Completer();

  late Future<bool> _interceptorInitDone;
  late Future<bool> _protectorInitDone;

  bool _initDone = false;

  @override
  void initState() {
    super.initState();

    _interceptorInitDone = _interceptorInitCompleter.future;
    _protectorInitDone = _protectorInitCompleter.future;

    _initDone =
        !(widget.configInfo.protectorConfig?.inAppBrowserInterceptor ?? false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initDone) {
        _interceptorInitDone.then((_) {
          _initProtector().then((value) {
            logger.i("Init after interceptor and protector");
            widget.onInterceptorInitialized();
          });
        });
      } else if (widget.configInfo.protectorConfig != null) {
        _initProtector().then((value) {
          logger.i("init after protector");
          widget.onInterceptorInitialized();
        });
      } else {
        logger.i("Init no protector");
        widget.onInterceptorInitialized();
      }
    });
  }

  Future<bool> _initProtector() async {
    await _init().then((value) {
      _protectorInitCompleter.complete(true);
      _initDone = true;
      setState(() {});
    });
    return _protectorInitDone;
  }

  Future<void> _init() async {
    final uid = '${widget.configInfo.name}_${widget.configInfo.version}';

    final cachedProtector = await ProtectorStorageService().getItem(uid: uid);
    if (cachedProtector == null) {
      final result = await Navigator.of(context).pushNamed(Routes.webBrowser,
          arguments:
              WebBrowserData(config: widget.configInfo.protectorConfig!));
      if (result != null && result is WebBrowserPageResult) {
        await widget.apiClient.passProtector(
            cookies: result.cookies,
            headers: result.headers,
            body: result.body);
        await ProtectorStorageService()
            .saveItem(item: ProtectorStorageItem(uid: uid, data: result));
      } else {
        return;
      }
    } else if (widget.configInfo.protectorConfig != null) {
      await widget.apiClient.passProtector(
          cookies: cachedProtector.data.cookies,
          headers: cachedProtector.data.headers,
          body: cachedProtector.data.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _interceptorInitCompleter);
  }
}
