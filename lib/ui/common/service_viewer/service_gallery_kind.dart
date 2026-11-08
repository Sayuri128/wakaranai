import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/widgets.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';

abstract class ServiceGalleryKind<T extends ApiClient, G extends GalleryView> {
  const ServiceGalleryKind();

  String get concreteRoute;

  String titleOf(G galleryView);

  String coverOf(G galleryView);

  String? statusOf(G galleryView);

  Future<List<BaseActivityDomain>?> loadActivities(
    BuildContext context,
    String concreteUid,
  );

  Object concreteArguments({
    required T client,
    required ConfigInfo configInfo,
    required G galleryView,
    required Map<String, String> coverHeaders,
  });
}
