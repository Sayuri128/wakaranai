import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/logger.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class ServiceViewer<T extends ApiClient> extends StatefulWidget {
  const ServiceViewer(
      {Key? key,
      required this.builder,
      required this.onInterceptorInitialized,
      required this.configInfo,
      required this.apiClient})
      : super(key: key);

  final Widget Function(BuildContext context, bool initDone, Completer<bool>)
      builder;
  final VoidCallback onInterceptorInitialized;

  final T apiClient;
  final ConfigInfo configInfo;

  @override
  State<ServiceViewer> createState() => _ServiceViewerState();
}

class _ServiceViewerState extends State<ServiceViewer> {
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
      if (result != null) {
        await widget.apiClient
            .passProtector(data: result as Map<String, dynamic>);
        await ProtectorStorageService()
            .saveItem(item: ProtectorStorageItem(uid: uid, headers: result));
      } else {
        return;
      }
    } else if (widget.configInfo.protectorConfig != null) {
      await widget.apiClient.passProtector(data: cachedProtector.headers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _initDone, _interceptorInitCompleter);
  }
}
