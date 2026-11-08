import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/ui/home/configs_page/configs_view_options.dart';

ExtensionDomain _extension(String uid, String name, {String language = 'en'}) {
  return ExtensionDomain(
    id: 0,
    config: ConfigInfo.fromJson(<String, dynamic>{
      'name': name,
      'uid': uid,
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': language,
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
    }),
    sourceCode: '',
    createdAt: DateTime(2026),
  );
}

void main() {
  final List<BaseExtension> listed = <BaseExtension>[
    _extension('c', 'Zenko', language: 'Українська'),
    _extension('a', 'MangaDex'),
    _extension('b', 'anihub', language: 'Українська'),
  ];

  test('sorts by name only when asked', () {
    const ConfigsViewOptions listing = ConfigsViewOptions();
    expect(listing.sorted(listed).map((BaseExtension e) => e.config.uid),
        <String>['c', 'a', 'b']);
    const ConfigsViewOptions byName = ConfigsViewOptions(sort: ConfigsSort.name);
    expect(byName.sorted(listed).map((BaseExtension e) => e.config.uid),
        <String>['b', 'a', 'c']);
  });

  test('pinned sources leave their groups and keep pin order', () {
    const ConfigsViewOptions options =
        ConfigsViewOptions(pinned: <String>['c', 'missing', 'a']);
    expect(options.pinnedIn(listed).map((BaseExtension e) => e.config.uid),
        <String>['c', 'a']);
    expect(options.unpinned(listed).map((BaseExtension e) => e.config.uid),
        <String>['b']);
  });

  test('search matches names and languages', () {
    expect(matchesConfigsQuery(listed[0], 'zen'), isTrue);
    expect(matchesConfigsQuery(listed[0], 'укр'), isTrue);
    expect(matchesConfigsQuery(listed[1], 'укр'), isFalse);
    expect(matchesConfigsQuery(listed[1], '  '), isTrue);
  });

  test('layout, sort and pins are remembered', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ConfigsViewOptionsCubit cubit = ConfigsViewOptionsCubit();
    await cubit.setLayout(ConfigsLayout.grid);
    await cubit.setSort(ConfigsSort.name);
    await cubit.togglePin('a');
    await cubit.togglePin('b');
    await cubit.togglePin('a');
    await cubit.close();

    final ConfigsViewOptionsCubit restored = ConfigsViewOptionsCubit();
    await restored.init();
    expect(restored.state.layout, ConfigsLayout.grid);
    expect(restored.state.sort, ConfigsSort.name);
    expect(restored.state.pinned, <String>['b']);
    await restored.close();
  });
}
