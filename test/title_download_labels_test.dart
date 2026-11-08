import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/ui/services/widgets/title_download_labels.dart';

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('manga titles keep the chapter wording', () {
    final TitleDownloadLabels labels =
        TitleDownloadLabels.forType(ConfigInfoType.MANGA);

    expect(labels.sheetTitle, 'Download chapters');
    expect(labels.amount(ChapterDownloadAmount.unread), 'Unread chapters');
    expect(labels.queued(2), '2 chapters queued');
  });

  test('anime titles talk about episodes', () {
    final TitleDownloadLabels labels =
        TitleDownloadLabels.forType(ConfigInfoType.ANIME);

    expect(labels.sheetTitle, 'Download episodes');
    expect(labels.amount(ChapterDownloadAmount.nextFive), 'Next 5 episodes');
    expect(labels.amount(ChapterDownloadAmount.unread), 'Unwatched episodes');
    expect(labels.elementCount(1), '1 episode');
  });

  test('a mixed library selection uses neutral wording', () {
    final TitleDownloadLabels labels = TitleDownloadLabels.forTypes(
      <ConfigInfoType>[ConfigInfoType.MANGA, ConfigInfoType.ANIME],
    );

    expect(labels.kind, TitleDownloadKind.mixed);
    expect(labels.queued(3), '3 downloads queued');
    expect(
      TitleDownloadLabels.forTypes(
        <ConfigInfoType>[ConfigInfoType.ANIME, ConfigInfoType.ANIME],
      ).kind,
      TitleDownloadKind.episodes,
    );
  });
}
