import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/service_view/gallery_feed_memory.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_entry.dart';

typedef _Cubit = ServiceViewCubit<MangaApiClient, MangaGalleryView>;
typedef _Gallery = ServiceGalleryCubit<MangaApiClient, MangaGalleryView>;
typedef _Initialized
    = ServiceViewInitialized<MangaApiClient, MangaGalleryView>;

const String _echoPageSizeScript = '''
  import "manga_models";
  function getGallery(page, query, filters, feed, pageSize) {
    return [buildGallery({"uid": "page" + page + "size" + pageSize, "title": "", "cover": "", "data": {}})];
  }
  function getImageHeaders(uid, data) {
    return {};
  }
''';

ConfigInfo _config() {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': 'Paged',
    'uid': 'ext.paged',
    'logoUrl': '',
    'type': 0,
    'nsfw': false,
    'language': 'en',
    'version': 1,
    'filters': <dynamic>[],
    'searchAvailable': true,
    'pagination': <String, dynamic>{
      'pageSizes': <int>[20, 50, 100],
      'defaultPageSize': 50,
    },
  });
}

Future<_Initialized> _settled(_Cubit cubit) async {
  for (int attempt = 0; attempt < 400; attempt++) {
    final ServiceViewState<MangaApiClient, MangaGalleryView> state =
        cubit.state;
    if (state is _Initialized && !state.loading) {
      return state;
    }
    await Future<void>.delayed(Duration.zero);
  }
  fail('the gallery never finished loading');
}

List<String> _uids(_Initialized state) {
  return state.galleryViews.map((MangaGalleryView view) => view.uid).toList();
}

void main() {
  late ExtensionPreferencesStore store;
  late ConfigInfo config;
  late _Gallery gallery;
  late _Cubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    store = ExtensionPreferencesStore();
    config = _config();
    final MangaApiClient client = ApiClientFactory(
      hostFactory: ExtensionHostFactory(preferenceStore: store),
    ).manga(config: config, code: _echoPageSizeScript);
    gallery = _Gallery(
      client: client,
      configInfo: config,
      feedMemory: GalleryFeedMemory(),
    );
    cubit = gallery.singleGallery!;
  });

  tearDown(() => gallery.close());

  test('a changed page size reloads the open gallery from page one', () async {
    gallery.start();
    expect(_uids(await _settled(cubit)), <String>['page1size50']);

    await cubit.getGallery();
    expect((await _settled(cubit)).currentPage, 2);

    await store.write(config.uid, ExtensionPreference.pageSizeKey, 100);
    await reloadServiceViewAfterPreferenceChange(gallery);
    final _Initialized reloaded = await _settled(cubit);

    expect(reloaded.currentPage, 1);
    expect(_uids(reloaded), <String>['page1size100']);
  });
}
