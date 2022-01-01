part of 'api_client_controller_cubit.dart';

class ApiClientControllerState {

  final ApiClient client;
  final ConfigInfo? configInfo;

  const ApiClientControllerState({
    required this.client,
    this.configInfo
  });

  ApiClientControllerState copyWith({
    ApiClient? client,
    ConfigInfo? configInfo,
  }) {
    return ApiClientControllerState(
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
    );
  }
}
