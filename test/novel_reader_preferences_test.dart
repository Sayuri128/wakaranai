import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/novel_reader_preferences/novel_reader_preferences_cubit.dart';
import 'package:wakaranai/repositories/shared_pref/novel_reader_preferences.dart';
import 'package:wakaranai/services/import_export/exported_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('defaults apply when nothing is stored', () async {
    final NovelReaderPreferences read =
        await NovelReaderPreferencesStore().read();

    expect(read, const NovelReaderPreferences());
    expect(read.keepScreenOn, isTrue);
    expect(read.font, NovelReaderFont.ubuntu);
    expect(read.background, NovelReaderBackground.theme);
  });

  test('settings survive a write and read round trip', () async {
    const NovelReaderPreferences written = NovelReaderPreferences(
      fontSize: 22,
      lineHeight: 1.9,
      horizontalMargin: 32,
      font: NovelReaderFont.serif,
      background: NovelReaderBackground.sepia,
      justify: true,
      keepScreenOn: false,
    );

    await NovelReaderPreferencesStore().write(written);
    final NovelReaderPreferences read =
        await NovelReaderPreferencesStore().read();

    expect(read, written);
  });

  test('out of range or unknown stored values fall back safely', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      NovelReaderPreferencesStore.fontSizeKey: 200.0,
      NovelReaderPreferencesStore.lineHeightKey: 0.2,
      NovelReaderPreferencesStore.marginKey: -10.0,
      NovelReaderPreferencesStore.fontKey: 'comic-sans',
      NovelReaderPreferencesStore.backgroundKey: 'neon',
    });

    final NovelReaderPreferences read =
        await NovelReaderPreferencesStore().read();

    expect(read.fontSize, NovelReaderPreferences.maxFontSize);
    expect(read.lineHeight, NovelReaderPreferences.minLineHeight);
    expect(read.horizontalMargin, NovelReaderPreferences.minMargin);
    expect(read.font, NovelReaderFont.ubuntu);
    expect(read.background, NovelReaderBackground.theme);
  });

  test('the cubit steps values within their limits and persists them',
      () async {
    final NovelReaderPreferencesCubit cubit = NovelReaderPreferencesCubit();
    await cubit.init();

    await cubit.changeFontSize(2);
    await cubit.changeLineHeight(3);
    await cubit.changeMargin(-100);
    await cubit.setBackground(NovelReaderBackground.black);

    expect(cubit.state.fontSize, NovelReaderPreferences.defaultFontSize + 2);
    expect(cubit.state.lineHeight, 1.9);
    expect(cubit.state.horizontalMargin, NovelReaderPreferences.minMargin);

    final NovelReaderPreferences stored =
        await NovelReaderPreferencesStore().read();
    expect(stored, cubit.state);
    await cubit.close();
  });

  test('novel reader settings are part of exported preferences', () {
    expect(
      ExportedPreferences.isExportable(NovelReaderPreferencesStore.fontSizeKey),
      isTrue,
    );
    expect(
      ExportedPreferences.isExportable(
        NovelReaderPreferencesStore.keepScreenOnKey,
      ),
      isTrue,
    );
  });
}
