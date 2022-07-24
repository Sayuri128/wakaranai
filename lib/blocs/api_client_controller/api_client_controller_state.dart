part of 'api_client_controller_cubit.dart';

class ApiClientControllerState {
  final ApiClient client;

  const ApiClientControllerState({
    required this.client,
  });
}

class ApiClientControllerConfigInfo extends ApiClientControllerState {
  final ConfigInfo configInfo;

  ApiClientControllerConfigInfo(
      {required ApiClient client, required this.configInfo})
      : super(client: client);
}

class ApiClientControllerConcreteView extends ApiClientControllerState {
  final ConcreteView concreteView;

  ApiClientControllerConcreteView(
      {required ApiClient client, required this.concreteView})
      : super(client: client);
}
