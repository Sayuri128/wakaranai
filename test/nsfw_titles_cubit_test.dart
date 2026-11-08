import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';

ExtensionDomain _extension(String uid, {required bool nsfw}) {
  return ExtensionDomain(
    id: 0,
    config: ConfigInfo.fromJson(<String, dynamic>{
      'name': uid,
      'uid': uid,
      'logoUrl': '',
      'type': 0,
      'nsfw': nsfw,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
    }),
    sourceCode: '',
    revision: 'r',
    createdAt: DateTime(2026),
  );
}

void main() {
  test('hides titles of installed nsfw sources only when switched on', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final WakaranaiDatabase database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    addTearDown(database.close);
    final ExtensionRepository repository = ExtensionRepository(database: database);
    await repository.createUpdateByUid(_extension('adult', nsfw: true));
    await repository.createUpdateByUid(_extension('safe', nsfw: false));

    final NsfwTitlesCubit cubit = NsfwTitlesCubit(extensionRepository: repository);
    addTearDown(cubit.close);
    await cubit.init();
    expect(cubit.state.hides('adult'), isFalse);

    await cubit.setHideTitles(true);
    expect(cubit.state.hides('adult'), isTrue);
    expect(cubit.state.hides('safe'), isFalse);
    expect(cubit.state.hides('unknown'), isFalse);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(NsfwTitlesCubit.hideTitlesKey), isTrue);
  });
}
