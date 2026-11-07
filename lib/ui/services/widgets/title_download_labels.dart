import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';

enum TitleDownloadKind { chapters, episodes, mixed }

class TitleDownloadLabels {
  const TitleDownloadLabels(this.kind);

  factory TitleDownloadLabels.forType(ConfigInfoType type) {
    return TitleDownloadLabels(_kindOf(type));
  }

  factory TitleDownloadLabels.forTypes(Iterable<ConfigInfoType> types) {
    final Set<TitleDownloadKind> kinds = types.map(_kindOf).toSet();
    if (kinds.length == 1) {
      return TitleDownloadLabels(kinds.single);
    }
    if (kinds.isEmpty) {
      return const TitleDownloadLabels(TitleDownloadKind.chapters);
    }
    return const TitleDownloadLabels(TitleDownloadKind.mixed);
  }

  final TitleDownloadKind kind;

  static TitleDownloadKind _kindOf(ConfigInfoType type) {
    switch (type) {
      case ConfigInfoType.MANGA:
        return TitleDownloadKind.chapters;
      case ConfigInfoType.ANIME:
        return TitleDownloadKind.episodes;
    }
  }

  String get sheetTitle {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return S.current.title_download_title;
      case TitleDownloadKind.episodes:
        return S.current.title_download_episode_title;
      case TitleDownloadKind.mixed:
        return S.current.title_download_episode_mixed_title;
    }
  }

  String get firstGroupHint {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return S.current.library_download_first_group_hint;
      case TitleDownloadKind.episodes:
        return S.current.title_download_episode_first_group_hint;
      case TitleDownloadKind.mixed:
        return S.current.title_download_episode_mixed_hint;
    }
  }

  String get nothing {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return S.current.title_download_nothing;
      case TitleDownloadKind.episodes:
        return S.current.title_download_episode_nothing;
      case TitleDownloadKind.mixed:
        return S.current.title_download_episode_mixed_nothing;
    }
  }

  String queued(int count) {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return S.current.title_download_queued(count);
      case TitleDownloadKind.episodes:
        return S.current.title_download_episode_queued(count);
      case TitleDownloadKind.mixed:
        return S.current.title_download_episode_mixed_queued(count);
    }
  }

  String manyLoading(int count) {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return S.current.library_download_many_loading(count);
      case TitleDownloadKind.episodes:
        return S.current.title_download_episode_many_loading(count);
      case TitleDownloadKind.mixed:
        return S.current.title_download_episode_mixed_loading(count);
    }
  }

  String amount(ChapterDownloadAmount amount) {
    switch (kind) {
      case TitleDownloadKind.chapters:
        return chapterDownloadAmountLabel(amount);
      case TitleDownloadKind.episodes:
        return _episodeAmount(amount);
      case TitleDownloadKind.mixed:
        return _mixedAmount(amount);
    }
  }

  bool get _episodes => kind == TitleDownloadKind.episodes;

  String get groups => _episodes
      ? S.current.title_download_episode_groups
      : S.current.title_download_groups;

  String get howMany => _episodes
      ? S.current.title_download_episode_how_many
      : S.current.title_download_how_many;

  String get loading => _episodes
      ? S.current.title_download_episode_loading
      : S.current.title_download_loading;

  String get failed => _episodes
      ? S.current.title_download_episode_failed
      : S.current.title_download_failed;

  String get empty => _episodes
      ? S.current.title_download_episode_none
      : S.current.title_download_no_chapters;

  String elementCount(int count) => _episodes
      ? S.current.title_download_episode_count(count)
      : S.current.title_download_chapter_count(count);

  static String _episodeAmount(ChapterDownloadAmount amount) {
    switch (amount) {
      case ChapterDownloadAmount.next:
        return S.current.title_download_episode_next;
      case ChapterDownloadAmount.nextFive:
        return S.current.title_download_episode_next_count(5);
      case ChapterDownloadAmount.nextTen:
        return S.current.title_download_episode_next_count(10);
      case ChapterDownloadAmount.unread:
        return S.current.title_download_episode_unwatched;
      case ChapterDownloadAmount.all:
        return S.current.title_download_episode_all;
    }
  }

  static String _mixedAmount(ChapterDownloadAmount amount) {
    switch (amount) {
      case ChapterDownloadAmount.next:
        return S.current.title_download_episode_mixed_next;
      case ChapterDownloadAmount.nextFive:
        return S.current.title_download_episode_mixed_next_count(5);
      case ChapterDownloadAmount.nextTen:
        return S.current.title_download_episode_mixed_next_count(10);
      case ChapterDownloadAmount.unread:
        return S.current.title_download_episode_mixed_unread;
      case ChapterDownloadAmount.all:
        return S.current.title_download_episode_mixed_all;
    }
  }
}

String chapterDownloadAmountLabel(ChapterDownloadAmount amount) {
  switch (amount) {
    case ChapterDownloadAmount.next:
      return S.current.title_download_next;
    case ChapterDownloadAmount.nextFive:
      return S.current.title_download_next_count(5);
    case ChapterDownloadAmount.nextTen:
      return S.current.title_download_next_count(10);
    case ChapterDownloadAmount.unread:
      return S.current.title_download_unread;
    case ChapterDownloadAmount.all:
      return S.current.title_download_all;
  }
}
