part of 'api_client_controller_cubit.dart';

class ApiClientControllerState {
  const ApiClientControllerState();
}

class ApiClientControllerInitialized<T extends ApiClient>
    extends ApiClientControllerState {
  final T apiClient;
  final ConfigInfo configInfo;

  ApiClientControllerInitialized(
      {required this.apiClient, required this.configInfo});
}
