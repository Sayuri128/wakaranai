import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/data/models/web_browser_result/web_browser_result.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';

ConfigInfo _config({int version = 1, String? sessionGroup}) => ConfigInfo(
      uid: 'uid-1',
      name: 'Source',
      logoUrl: '',
      nsfw: false,
      language: 'English',
      version: version,
      filters: const [],
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
      protectorConfig: ProtectorConfig(
        pingUrl: 'https://example.com',
        needToLogin: true,
        inAppBrowserInterceptor: true,
        sessionGroup: sessionGroup,
      ),
    );

String _stored(String uid, String body) => jsonEncode(ProtectorStorageItem(
      uid: uid,
      data: WebBrowserPageResult(headers: const {}, cookies: const {}, body: body),
    ).toJson());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sessions are keyed by uid, or by session group when set', () {
    expect(ProtectorStorageService.sessionKey(_config()), 'protector_uid-1');
    expect(ProtectorStorageService.sessionKey(_config(sessionGroup: 'lib')), 'lib');
  });

  test('a login stored under the old name_version key survives a version bump', () async {
    FlutterSecureStorage.setMockInitialValues({
      'Source_1': _stored('Source_1', 'v1'),
      'Source_3': _stored('Source_3', 'v3'),
      'Other_9': _stored('Other_9', 'other'),
    });
    final service = ProtectorStorageService();

    final item = await service.getItemForConfig(_config(version: 4));

    expect(item?.data.body, 'v3');
    expect(item?.uid, 'protector_uid-1');
    expect((await service.getItem(uid: 'protector_uid-1'))?.data.body, 'v3');
  });

  test('the uid key wins once it exists', () async {
    FlutterSecureStorage.setMockInitialValues({
      'Source_1': _stored('Source_1', 'old'),
      'protector_uid-1': _stored('protector_uid-1', 'current'),
    });

    final item = await ProtectorStorageService().getItemForConfig(_config());

    expect(item?.data.body, 'current');
  });

  test('returns null when nothing was stored', () async {
    FlutterSecureStorage.setMockInitialValues({});

    expect(await ProtectorStorageService().getItemForConfig(_config()), isNull);
  });
}
