part of 'api_client_controller_cubit.dart';

class ApiClientControllerState {

  final ApiClient client;
  final ConfigInfo? configInfo;
  final List<GalleryView>? galleryViews;

  const ApiClientControllerState({
    required this.client,
    this.configInfo,
    this.galleryViews
  });

  ApiClientControllerState copyWith({
    ApiClient? client,
    ConfigInfo? configInfo,
    List<GalleryView>? galleryViews,
  }) {
    return ApiClientControllerState(
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      galleryViews: galleryViews ?? this.galleryViews,
    );
  }
}
