part of 'browser_interceptor_cubit.dart';

@immutable
abstract class BrowserInterceptorState {
  const BrowserInterceptorState();
}

class BrowserInterceptorInitial extends BrowserInterceptorState {}

class BrowserInterceptorInitialized extends BrowserInterceptorState {}

class BrowserInterceptorLoadingPage extends BrowserInterceptorState {
  final String url;
  final String? method;
  final Map<String, String>? headers;
  final String? body;
  final Completer<HttpInterceptorControllerResponse> onLoaded;

  const BrowserInterceptorLoadingPage(
      {required this.url,
      required this.onLoaded,
      this.method,
      this.headers,
      required this.body});
}

class BrowserInterceptorPageLoaded extends BrowserInterceptorState {
  final String body;
  final Map<String, dynamic> data;

  const BrowserInterceptorPageLoaded({required this.body, required this.data});
}
