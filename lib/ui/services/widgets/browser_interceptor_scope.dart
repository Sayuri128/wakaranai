import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/services/widgets/browser_check_banner.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_escalation.dart';

class BrowserInterceptorScope extends StatefulWidget {
  const BrowserInterceptorScope({
    super.key,
    required this.configInfo,
    required this.apiClient,
    required this.initCompleter,
    required this.onRecovered,
    required this.child,
  });

  final ConfigInfo configInfo;
  final ApiClient apiClient;
  final Completer<bool> initCompleter;
  final VoidCallback onRecovered;
  final Widget child;

  static bool isEnabledFor(ConfigInfo configInfo) {
    return configInfo.protectorConfig?.inAppBrowserInterceptor ?? false;
  }

  static Future<void> retry(BuildContext context, VoidCallback reload) async {
    final _BrowserInterceptorScopeState? scope = context
        .findAncestorStateOfType<_BrowserInterceptorScopeState>();
    if (scope == null) {
      reload();
      return;
    }
    await scope.retryWithReconnect(reload);
  }

  @override
  State<BrowserInterceptorScope> createState() =>
      _BrowserInterceptorScopeState();
}

class _BrowserInterceptorScopeState extends State<BrowserInterceptorScope> {
  static const Duration _bannerAnimationDuration = Duration(milliseconds: 220);
  static final Tween<Offset> _bannerOffset = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  );

  BrowserInterceptorCubit? _interceptor;
  StreamSubscription<BrowserInterceptorState>? _subscription;
  BrowserInterceptorEscalation _escalation = BrowserInterceptorEscalation.none;
  bool _bannerDismissed = false;
  bool _browserOpen = false;
  Future<bool>? _reconnecting;

  bool get _enabled => BrowserInterceptorScope.isEnabledFor(widget.configInfo);

  String get _pingUrl => widget.configInfo.protectorConfig?.pingUrl ?? '';

  bool get _bannerVisible {
    if (_reconnecting != null) {
      return true;
    }
    return _escalation.needsUser && !_bannerDismissed;
  }

  @override
  void initState() {
    super.initState();
    if (!_enabled) {
      return;
    }
    final BrowserInterceptorCubit interceptor = _attachNewInterceptor();
    unawaited(_passToApiClient(interceptor));
    _startInterceptor(interceptor, widget.initCompleter);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_interceptor?.close());
    super.dispose();
  }

  void _update(VoidCallback change) {
    if (!mounted) {
      return;
    }
    setState(change);
  }

  BrowserInterceptorCubit _attachNewInterceptor() {
    final BrowserInterceptorCubit interceptor = BrowserInterceptorCubit();
    _interceptor = interceptor;
    _subscription = interceptor.stream.listen(_onInterceptorState);
    return interceptor;
  }

  void _startInterceptor(
    BrowserInterceptorCubit interceptor,
    Completer<bool> initCompleter,
  ) {
    unawaited(
      initCompleter.future.then(
        (bool succeeded) => _onInitCompleted(interceptor, succeeded),
      ),
    );
    unawaited(interceptor.init(url: _pingUrl, initCompleter: initCompleter));
  }

  Future<void> _passToApiClient(BrowserInterceptorCubit interceptor) async {
    try {
      await widget.apiClient.passWebBrowserInterceptorController(
        controller: interceptor,
      );
    } catch (e) {
      logger.w('Failed to pass the browser interceptor to the script: $e');
    }
  }

  void _onInitCompleted(BrowserInterceptorCubit interceptor, bool succeeded) {
    if (!identical(interceptor, _interceptor)) {
      return;
    }
    _update(() {
      _escalation = _escalation.onInitCompleted(succeeded);
    });
  }

  void _onInterceptorState(BrowserInterceptorState state) {
    final BrowserInterceptorEscalation next = _escalation.onState(state);
    final bool challengeReported = state is BrowserInterceptorChallengeRequired;
    if (next == _escalation && !challengeReported) {
      return;
    }
    _update(() {
      _escalation = next;
      if (challengeReported) {
        _bannerDismissed = false;
      }
    });
  }

  Future<bool> _reconnect() async {
    final Future<bool>? inFlight = _reconnecting;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<bool> attempt = _replaceInterceptor();
    _update(() {
      _reconnecting = attempt;
    });
    try {
      return await attempt;
    } finally {
      _reconnecting = null;
      _update(() {});
    }
  }

  Future<bool> _replaceInterceptor() async {
    final BrowserInterceptorCubit? previous = _interceptor;
    final StreamSubscription<BrowserInterceptorState>? previousSubscription =
        _subscription;
    final BrowserInterceptorCubit interceptor = _attachNewInterceptor();
    _escalation = BrowserInterceptorEscalation.none;
    _bannerDismissed = false;

    await previousSubscription?.cancel();
    await previous?.close();

    final Completer<bool> initCompleter = Completer<bool>();
    _startInterceptor(interceptor, initCompleter);
    final bool succeeded = await initCompleter.future;
    if (!mounted) {
      return false;
    }
    await _passToApiClient(interceptor);
    return succeeded;
  }

  Future<void> retryWithReconnect(VoidCallback reload) async {
    final Future<bool>? inFlight = _reconnecting;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    if (_interceptor == null || !_escalation.needsReconnect) {
      reload();
      return;
    }
    await _reconnect();
    if (!mounted || _escalation.needsUser) {
      return;
    }
    reload();
  }

  Future<void> _openBrowserCheck() async {
    if (_browserOpen || _reconnecting != null) {
      return;
    }
    _browserOpen = true;
    bool collected = false;
    try {
      collected = await openWebView(
        context,
        widget.apiClient,
        widget.configInfo,
      );
    } finally {
      _browserOpen = false;
    }
    if (!mounted || !collected) {
      return;
    }
    await _reconnect();
    if (!mounted || _escalation.needsUser) {
      return;
    }
    widget.onRecovered();
  }

  void _dismissBanner() {
    _update(() {
      _bannerDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final BrowserInterceptorCubit? interceptor = _interceptor;
    if (interceptor == null) {
      return widget.child;
    }
    return BlocProvider<BrowserInterceptorCubit>.value(
      value: interceptor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AnimatedSwitcher(
                  duration: _bannerAnimationDuration,
                  transitionBuilder: _bannerTransition,
                  child: _bannerVisible
                      ? BrowserCheckBanner(
                          reconnecting: _reconnecting != null,
                          onOpenBrowser: () => unawaited(_openBrowserCheck()),
                          onDismiss: _dismissBanner,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: _bannerOffset.animate(animation),
        child: child,
      ),
    );
  }
}
