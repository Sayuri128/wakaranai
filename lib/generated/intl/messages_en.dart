// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(time) => "Watched at ${time}";

  static String m1(count) => "${count} pages";

  static String m2(failed) => "Translated · ${failed} pages failed";

  static String m3(count) => "${count} chapters translated";

  static String m4(count) => "${count} chapters left";

  static String m5(done, total) => "Translating ${done}/${total}";

  static String m6(count) => "${count} chapters queued for translation";

  static String m7(required, supported) =>
      "This source needs extension API ${required}, this app supports up to ${supported}.";

  static String m8(required, current) =>
      "This source needs app version ${required} or newer, you have ${current}.";

  static String m9(count) => "${count} selected";

  static String m10(names) => "Art by ${names}";

  static String m11(names) => "By ${names}";

  static String m12(ending) => "Key ••••${ending}";

  static String m13(used, limit) => "${used} of ${limit} characters";

  static String m14(count) => "${count} left";

  static String m15(count) =>
      "${Intl.plural(count, one: '1 chapter', other: '${count} chapters')}";

  static String m16(count) =>
      "${Intl.plural(count, one: '1 episode', other: '${count} episodes')}";

  static String m17(score) => "${score}%";

  static String m18(year) => "Fall ${year}";

  static String m19(year) => "Spring ${year}";

  static String m20(year) => "Summer ${year}";

  static String m21(year) => "Winter ${year}";

  static String m22(speed) => "${speed} MB/s";

  static String m23(time) => "${time} left";

  static String m24(done, total) => "${done}/${total} chapters downloaded";

  static String m25(downloaded) => "${downloaded} downloaded";

  static String m26(percent, downloaded, total) =>
      "${percent}% · ${downloaded} of ${total}";

  static String m27(size) => "Ready to watch offline · ${size}";

  static String m28(done, total) => "Segment ${done}/${total}";

  static String m29(size) => "${size} GB";

  static String m30(size) => "${size} MB";

  static String m31(done, total) => "${done}/${total} episodes downloaded";

  static String m32(count) => "${count} chapters downloaded";

  static String m33(done, total) => "${done}/${total} pages";

  static String m34(count) => "Queue (${count})";

  static String m35(progress) => "Paused · ${progress}";

  static String m36(title, size) =>
      "Every download of ${title} (${size}) will be removed from this device.";

  static String m37(count, title, size) =>
      "${count} watched episodes of ${title} (${size}) will be removed from this device.";

  static String m38(count) => "Deleted ${count} watched episodes";

  static String m39(size) => "Up to ${size} can be freed";

  static String m40(summary, size) => "${summary} · ${size}";

  static String m41(count, size) => "${count} downloads · ${size}";

  static String m42(count, size) => "${count} watched · ${size}";

  static String m43(hours, minutes) => "${hours} h ${minutes} min";

  static String m44(minutes) => "${minutes} min";

  static String m45(seconds) => "${seconds} s";

  static String m46(size) => "${size} GB";

  static String m47(source) => "Stored data for ${source} cleared";

  static String m48(value) => "Default: ${value}";

  static String m49(count) => "${count} per page (default)";

  static String m50(count) => "${count} per page";

  static String m51(source) => "Saved session for ${source} cleared";

  static String m52(name) => "Added ${name}";

  static String m53(name) => "${name} was uninstalled";

  static String m54(name) => "Uninstall ${name}?";

  static String m55(count) =>
      "${Intl.plural(count, one: '1 filter active', other: '${count} filters active')}";

  static String m56(count) =>
      "${Intl.plural(count, zero: 'Filters', one: 'Filters, 1 active', other: 'Filters, ${count} active')}";

  static String m57(value) => "Remove ${value}";

  static String m58(name) => "Search ${name}";

  static String m59(count) => "Show all ${count}";

  static String m60(count) => "Apply (${count})";

  static String m61(count) => "+${count} more — refine your search";

  static String m62(title) => "Last opened: ${title}";

  static String m63(layout) => "Layout: ${layout}";

  static String m64(sources) => "No results in ${sources}";

  static String m65(query) => "None of the selected sources has \"${query}\".";

  static String m66(count) =>
      "${Intl.plural(count, one: '1 result', other: '${count} results')}";

  static String m67(count) =>
      "${Intl.plural(count, zero: 'No sources selected', one: 'Searching 1 source', other: 'Searching ${count} sources')}";

  static String m68(name) =>
      "Error occurred during initializing configs ${name} source";

  static String m69(count) => "${count} downloaded";

  static String m70(current, total) => "Downloading ${current} of ${total}";

  static String m71(position) => "Queued · #${position}";

  static String m72(count) =>
      "${Intl.plural(count, one: '1 title couldn\'t be loaded', other: '${count} titles couldn\'t be loaded')}";

  static String m73(count) =>
      "${Intl.plural(count, one: 'Looking up chapters for 1 title…', other: 'Looking up chapters for ${count} titles…')}";

  static String m74(count) => "${count} new";

  static String m75(query) => "Nothing in your library matches “${query}”";

  static String m76(count) => "${count} selected";

  static String m77(count) =>
      "${Intl.plural(count, zero: 'Nothing was imported', one: 'Imported 1 file', other: 'Imported ${count} files')}";

  static String m78(path) =>
      "Copy folders of images, CBZ or ZIP files into\n${path}\n\nEach folder is a title and each archive or image folder inside it is a chapter. A cover.jpg and ComicInfo.xml are used when present. The folder is reachable over USB from a computer.";

  static String m79(seconds) => "Next episode in ${seconds}s";

  static String m80(index) => "Source ${index}";

  static String m81(seconds) => "−${seconds}s";

  static String m82(seconds) => "+${seconds}s";

  static String m83(seconds) => "+${seconds}s";

  static String m84(index) => "Subtitle ${index}";

  static String m85(percent) => "${percent}%";

  static String m86(title) => "Next: ${title}";

  static String m87(progress) => "Downloading AI model ${progress}%";

  static String m88(model, size) =>
      "${model} needs a one-time ${size} GB download. Use Wi-Fi: the model is stored on your phone and translation then runs fully offline.";

  static String m89(count) =>
      "${Intl.plural(count, one: '1 name', other: '${count} names')}";

  static String m90(current, total) =>
      "Downloading language packs ${current}/${total}…";

  static String m91(source, target) =>
      "Translating ${source} to ${target} needs on-device language packs, about 30 MB each. They are downloaded once, and pages are then translated entirely on your device.";

  static String m92(count) => "${count} pages saved";

  static String m93(count) => "${count} pages from an older version";

  static String m94(done, total) => "Translating chapter ${done}/${total}";

  static String m95(size) => "Up to ${size} px";

  static String m96(query) => "We couldn\'t find anything for “${query}”";

  static String m97(query) => "Results for “${query}”";

  static String m98(time) => "Daily to Download/Wakaranai · last ${time}";

  static String m99(version) => "New version ${version} available";

  static String m100(count) => "${count} skipped";

  static String m101(imported, total) =>
      "Imported ${imported} of ${total} items";

  static String m102(url) => "Load extensions from ${url}";

  static String m103(seconds) => "${seconds}s";

  static String m104(name) => "Could not sign in to ${name}";

  static String m105(name) => "Sign out of ${name}?";

  static String m106(name) => "Signed in as ${name}";

  static String m107(hours) => "Every ${hours} hours";

  static String m108(source) => "Sign in to ${source}";

  static String m109(count) =>
      "${Intl.plural(count, one: '1 title was removed from its source', other: '${count} titles were removed from their sources')}";

  static String m110(count) => "${count} activities";

  static String m111(current, longest) =>
      "Current ${current} · Longest ${longest}";

  static String m112(count) =>
      "${Intl.plural(count, one: '1 chapter', other: '${count} chapters')}";

  static String m113(count) =>
      "${Intl.plural(count, one: '1 episode', other: '${count} episodes')}";

  static String m114(count) =>
      "${Intl.plural(count, one: 'Looking up episodes for 1 title…', other: 'Looking up episodes for ${count} titles…')}";

  static String m115(count) =>
      "${Intl.plural(count, one: 'Looking up 1 title…', other: 'Looking up ${count} titles…')}";

  static String m116(count) => "Next ${count} chapters or episodes";

  static String m117(count) =>
      "${Intl.plural(count, one: '1 download queued', other: '${count} downloads queued')}";

  static String m118(count) => "Next ${count} episodes";

  static String m119(count) =>
      "${Intl.plural(count, one: '1 episode queued', other: '${count} episodes queued')}";

  static String m120(count) => "Next ${count} chapters";

  static String m121(count) =>
      "${Intl.plural(count, one: '1 chapter queued', other: '${count} chapters queued')}";

  static String m122(number) => "Group ${number}";

  static String m123(name) => "Find on ${name}";

  static String m124(size) =>
      "This frees ${size} GB. You can download it again at any time.";

  static String m125(model, size) => "${model} · ${size} GB · ready";

  static String m126(size) => "Not downloaded · ${size} GB";

  static String m127(need, ram) =>
      "Needs ${need} GB of RAM (this phone has ${ram} GB)";

  static String m128(model, ram) => "This phone: ${model} · ${ram} GB RAM";

  static String m129(ram) => "${ram} GB of RAM or more";

  static String m130(size) => "About ${size} GB of free storage";

  static String m131(size) => "Downloaded · ${size} GB";

  static String m132(count) =>
      "${Intl.plural(count, zero: 'No language packs yet', one: '1 language pack downloaded', other: '${count} language packs downloaded')}";

  static String m133(size) =>
      "Not downloaded · ${size} GB · choose it as the engine to download";

  static String m134(count, size) =>
      "${Intl.plural(count, zero: 'No AI models downloaded', one: '1 AI model · ${size} GB', other: '${count} AI models · ${size} GB')}";

  static String m135(source) => "${source} needs a quick check in the browser";

  static String m136(count) => "${count} sources need your attention";

  static String m137(sources) => "Browser check needed: ${sources}";

  static String m138(sources) => "Sign in needed: ${sources}";

  static String m139(source) =>
      "Session saved for ${source}. Pull to refresh to check again";

  static String m140(source) => "${source} needs you to sign in";

  static String m141(source) => "${source} needs you to sign in again";

  static String m142(source) => "${source} has no browser sign-in";

  static String m143(count) => "${count} sources could not be checked";

  static String m144(count) => "${count} new items found";

  static String m145(title, count) => "${title} · ${count} new";

  static String m146(count) => "and ${count} more titles";

  static String m147(count) => "Across ${count} titles";

  static String m148(count) => "${count} new items";

  static String m149(count) => "${count}d ago";

  static String m150(count) => "${count}h ago";

  static String m151(count) => "${count}m ago";

  static String m152(host) => "Cookies cleared for ${host}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activity_history_anime_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Watching",
    ),
    "activity_history_deleted_activity": MessageLookupByLibrary.simpleMessage(
      "Deleted activity successfully",
    ),
    "activity_history_empty_anime_list_message":
        MessageLookupByLibrary.simpleMessage(
          "No history :c\nStart watching to see your history here",
        ),
    "activity_history_empty_manga_list_message":
        MessageLookupByLibrary.simpleMessage(
          "No history :c\nStart reading to see your history here",
        ),
    "activity_history_error_loading_extension":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during loading extension",
        ),
    "activity_history_error_loading_history":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during loading history",
        ),
    "activity_history_long_tap_dialog_delete_button":
        MessageLookupByLibrary.simpleMessage("Delete"),
    "activity_history_manga_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Reading",
    ),
    "add_extension_source_page_add_button_title":
        MessageLookupByLibrary.simpleMessage("Save"),
    "add_extension_source_page_appbar_edit_title":
        MessageLookupByLibrary.simpleMessage("Edit Source"),
    "add_extension_source_page_appbar_title":
        MessageLookupByLibrary.simpleMessage("Add Source"),
    "add_extension_source_page_branch_default_option":
        MessageLookupByLibrary.simpleMessage("Default branch"),
    "add_extension_source_page_branch_fetch_button":
        MessageLookupByLibrary.simpleMessage("Fetch"),
    "add_extension_source_page_branch_fetch_error":
        MessageLookupByLibrary.simpleMessage("Couldn\'t load branches"),
    "add_extension_source_page_branch_field_label":
        MessageLookupByLibrary.simpleMessage("Branch"),
    "add_extension_source_page_branch_helper_text":
        MessageLookupByLibrary.simpleMessage(
          "Optional. Fetch the repository\'s branches to target a staging ref.",
        ),
    "add_extension_source_page_branch_invalid_url_error":
        MessageLookupByLibrary.simpleMessage("Enter a valid GitHub URL first"),
    "add_extension_source_page_description":
        MessageLookupByLibrary.simpleMessage(
          "Add a GitHub repository that hosts Wakaranai extensions.",
        ),
    "add_extension_source_page_name_field_error_text":
        MessageLookupByLibrary.simpleMessage("Invalid name"),
    "add_extension_source_page_name_field_hint_text":
        MessageLookupByLibrary.simpleMessage("Wakaranai configs repository"),
    "add_extension_source_page_name_field_label":
        MessageLookupByLibrary.simpleMessage("Name"),
    "add_extension_source_page_update_button_title":
        MessageLookupByLibrary.simpleMessage("Update"),
    "add_extension_source_page_url_field_error_text":
        MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "add_extension_source_page_url_field_hint_text":
        MessageLookupByLibrary.simpleMessage(
          "https://github.com/username/repository",
        ),
    "add_extension_source_page_url_field_label":
        MessageLookupByLibrary.simpleMessage("URL"),
    "anime_concrete_viewer_watched_at_title": m0,
    "api_client_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load this extension",
    ),
    "api_client_no_extension_selected": MessageLookupByLibrary.simpleMessage(
      "No extension was selected",
    ),
    "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
    "browser_check_dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
    "browser_check_open_button": MessageLookupByLibrary.simpleMessage(
      "Open browser",
    ),
    "browser_check_reconnecting": MessageLookupByLibrary.simpleMessage(
      "Reconnecting to the source…",
    ),
    "browser_check_required_message": MessageLookupByLibrary.simpleMessage(
      "Its protection page didn\'t clear on its own. Finish the check in the browser, then tap Done to continue.",
    ),
    "browser_check_required_title": MessageLookupByLibrary.simpleMessage(
      "This source needs a quick check in the browser",
    ),
    "chapter_divider_back": MessageLookupByLibrary.simpleMessage(
      "Back to title",
    ),
    "chapter_divider_downloaded": MessageLookupByLibrary.simpleMessage(
      "Downloaded",
    ),
    "chapter_divider_end_message": MessageLookupByLibrary.simpleMessage(
      "There are no more chapters",
    ),
    "chapter_divider_end_title": MessageLookupByLibrary.simpleMessage(
      "You\'re all caught up",
    ),
    "chapter_divider_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load the chapter",
    ),
    "chapter_divider_finished": MessageLookupByLibrary.simpleMessage(
      "Finished",
    ),
    "chapter_divider_load_previous": MessageLookupByLibrary.simpleMessage(
      "Load previous chapter",
    ),
    "chapter_divider_loading": MessageLookupByLibrary.simpleMessage(
      "Loading the next chapter…",
    ),
    "chapter_divider_next": MessageLookupByLibrary.simpleMessage("Next"),
    "chapter_divider_pages": m1,
    "chapter_divider_previous": MessageLookupByLibrary.simpleMessage(
      "Previous chapter",
    ),
    "chapter_translation_cancel": MessageLookupByLibrary.simpleMessage(
      "Stop translating",
    ),
    "chapter_translation_cancel_all": MessageLookupByLibrary.simpleMessage(
      "Cancel all",
    ),
    "chapter_translation_done": MessageLookupByLibrary.simpleMessage(
      "Translated",
    ),
    "chapter_translation_done_partial": m2,
    "chapter_translation_failed": MessageLookupByLibrary.simpleMessage(
      "Translation failed",
    ),
    "chapter_translation_notification_channel":
        MessageLookupByLibrary.simpleMessage("Chapter translation"),
    "chapter_translation_notification_done_body": m3,
    "chapter_translation_notification_done_title":
        MessageLookupByLibrary.simpleMessage("Translation finished"),
    "chapter_translation_notification_paused":
        MessageLookupByLibrary.simpleMessage("Paused"),
    "chapter_translation_notification_remaining": m4,
    "chapter_translation_pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "chapter_translation_preparing": MessageLookupByLibrary.simpleMessage(
      "Preparing translation…",
    ),
    "chapter_translation_progress": m5,
    "chapter_translation_queue_title": MessageLookupByLibrary.simpleMessage(
      "Translation queue",
    ),
    "chapter_translation_queued": m6,
    "chapter_translation_queued_status": MessageLookupByLibrary.simpleMessage(
      "Waiting to translate",
    ),
    "chapter_translation_resume": MessageLookupByLibrary.simpleMessage(
      "Resume",
    ),
    "chapter_translation_translate": MessageLookupByLibrary.simpleMessage(
      "Translate chapter",
    ),
    "chapter_translation_translate_all": MessageLookupByLibrary.simpleMessage(
      "Translate all downloaded chapters",
    ),
    "chapter_translation_waiting_download":
        MessageLookupByLibrary.simpleMessage("Downloading, then translating"),
    "chapter_viewer_bottom_modal_settings_reading_mode_title":
        MessageLookupByLibrary.simpleMessage("Reading Mode"),
    "chapter_viewer_bottom_modal_settings_tap_controls":
        MessageLookupByLibrary.simpleMessage("Enable tap controls"),
    "chapter_viewer_left_to_right_read_mode":
        MessageLookupByLibrary.simpleMessage("Left to right"),
    "chapter_viewer_next_chapter_button_title":
        MessageLookupByLibrary.simpleMessage("Next"),
    "chapter_viewer_previous_chapter_button_title":
        MessageLookupByLibrary.simpleMessage("Previous"),
    "chapter_viewer_right_to_left_read_mode":
        MessageLookupByLibrary.simpleMessage("Right to left"),
    "chapter_viewer_webtoon": MessageLookupByLibrary.simpleMessage("Webtoon"),
    "common_add": MessageLookupByLibrary.simpleMessage("Add"),
    "common_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "common_go_back": MessageLookupByLibrary.simpleMessage("Go back"),
    "common_ok_button": MessageLookupByLibrary.simpleMessage("OK"),
    "common_save": MessageLookupByLibrary.simpleMessage("Save"),
    "compat_download_latest_app": MessageLookupByLibrary.simpleMessage(
      "Download the latest app version",
    ),
    "compat_installed_keeps_working": MessageLookupByLibrary.simpleMessage(
      "Your installed version keeps working until you update the app.",
    ),
    "compat_open_installed": MessageLookupByLibrary.simpleMessage(
      "Open installed version",
    ),
    "compat_reason_api_version": m7,
    "compat_reason_min_app_version": m8,
    "compat_requires_newer_app": MessageLookupByLibrary.simpleMessage(
      "Update the app to use this source",
    ),
    "compat_update_needs_newer_app": MessageLookupByLibrary.simpleMessage(
      "Update available — needs a newer app version",
    ),
    "concrete_continue_resume": MessageLookupByLibrary.simpleMessage(
      "Continue",
    ),
    "concrete_continue_start": MessageLookupByLibrary.simpleMessage("Start"),
    "concrete_new_badge": MessageLookupByLibrary.simpleMessage("NEW"),
    "concrete_offline_banner": MessageLookupByLibrary.simpleMessage(
      "Offline — showing cached content. Only downloaded chapters can be opened.",
    ),
    "concrete_related_title": MessageLookupByLibrary.simpleMessage("Related"),
    "concrete_selection_clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "concrete_selection_count": m9,
    "concrete_selection_download": MessageLookupByLibrary.simpleMessage(
      "Download",
    ),
    "concrete_selection_invert": MessageLookupByLibrary.simpleMessage("Invert"),
    "concrete_selection_mark_read": MessageLookupByLibrary.simpleMessage(
      "Read",
    ),
    "concrete_selection_mark_unread": MessageLookupByLibrary.simpleMessage(
      "Unread",
    ),
    "concrete_selection_mark_unwatched": MessageLookupByLibrary.simpleMessage(
      "Unwatched",
    ),
    "concrete_selection_mark_watched": MessageLookupByLibrary.simpleMessage(
      "Watched",
    ),
    "concrete_selection_select_all": MessageLookupByLibrary.simpleMessage(
      "All",
    ),
    "concrete_selection_translate": MessageLookupByLibrary.simpleMessage(
      "Translate",
    ),
    "concrete_viewer_art_by": m10,
    "concrete_viewer_by_authors": m11,
    "concrete_viewer_chapters_section_title":
        MessageLookupByLibrary.simpleMessage("Chapters"),
    "concrete_viewer_description_show_less":
        MessageLookupByLibrary.simpleMessage("Show less"),
    "concrete_viewer_description_show_more":
        MessageLookupByLibrary.simpleMessage("Show more"),
    "concrete_viewer_episodes_section_title":
        MessageLookupByLibrary.simpleMessage("Episodes"),
    "concrete_viewer_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load title",
    ),
    "concrete_viewer_open_website": MessageLookupByLibrary.simpleMessage(
      "Open website",
    ),
    "concrete_viewer_retry_button": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "configs_filter_all_kinds": MessageLookupByLibrary.simpleMessage("All"),
    "configs_filter_all_languages": MessageLookupByLibrary.simpleMessage(
      "All languages",
    ),
    "configs_filter_language_title": MessageLookupByLibrary.simpleMessage(
      "Language",
    ),
    "configs_layout_cards": MessageLookupByLibrary.simpleMessage("Cards"),
    "configs_layout_compact": MessageLookupByLibrary.simpleMessage(
      "Compact list",
    ),
    "configs_layout_grid": MessageLookupByLibrary.simpleMessage("Grid"),
    "configs_pin": MessageLookupByLibrary.simpleMessage("Pin to top"),
    "configs_pinned_group_title": MessageLookupByLibrary.simpleMessage(
      "Pinned",
    ),
    "configs_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search sources",
    ),
    "configs_sort_listing": MessageLookupByLibrary.simpleMessage("As listed"),
    "configs_sort_name": MessageLookupByLibrary.simpleMessage("Name"),
    "configs_unpin": MessageLookupByLibrary.simpleMessage("Unpin"),
    "configs_view_layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "configs_view_options": MessageLookupByLibrary.simpleMessage(
      "View options",
    ),
    "configs_view_sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "content_kind_anime": MessageLookupByLibrary.simpleMessage("Anime"),
    "content_kind_cartoon": MessageLookupByLibrary.simpleMessage("Cartoons"),
    "content_kind_comic": MessageLookupByLibrary.simpleMessage("Comics"),
    "content_kind_documentary": MessageLookupByLibrary.simpleMessage(
      "Documentaries",
    ),
    "content_kind_dorama": MessageLookupByLibrary.simpleMessage("Dramas"),
    "content_kind_manga": MessageLookupByLibrary.simpleMessage("Manga"),
    "content_kind_manhua": MessageLookupByLibrary.simpleMessage("Manhua"),
    "content_kind_manhwa": MessageLookupByLibrary.simpleMessage("Manhwa"),
    "content_kind_movie": MessageLookupByLibrary.simpleMessage("Movies"),
    "content_kind_novel": MessageLookupByLibrary.simpleMessage("Novels"),
    "content_kind_series": MessageLookupByLibrary.simpleMessage("Series"),
    "deepl_key_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "deepl_key_change": MessageLookupByLibrary.simpleMessage("Change"),
    "deepl_key_dialog_message": MessageLookupByLibrary.simpleMessage(
      "Create a free DeepL API account and paste its authentication key here. The free plan includes a monthly character allowance; you can see it here once the key is saved. The key is stored only on this phone.",
    ),
    "deepl_key_get": MessageLookupByLibrary.simpleMessage("Get a free key"),
    "deepl_key_hint": MessageLookupByLibrary.simpleMessage(
      "Paste your API key",
    ),
    "deepl_key_invalid": MessageLookupByLibrary.simpleMessage(
      "DeepL did not accept this key",
    ),
    "deepl_key_masked": m12,
    "deepl_key_missing": MessageLookupByLibrary.simpleMessage("Not set"),
    "deepl_key_needed": MessageLookupByLibrary.simpleMessage(
      "Add a DeepL API key in Page translation settings first",
    ),
    "deepl_key_network": MessageLookupByLibrary.simpleMessage(
      "Could not reach DeepL. Check your connection.",
    ),
    "deepl_key_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "deepl_key_save": MessageLookupByLibrary.simpleMessage("Save"),
    "deepl_key_title": MessageLookupByLibrary.simpleMessage("DeepL API key"),
    "deepl_usage_characters": m13,
    "deepl_usage_left": m14,
    "deepl_usage_unavailable": MessageLookupByLibrary.simpleMessage(
      "Usage is unavailable right now",
    ),
    "deepl_usage_used": MessageLookupByLibrary.simpleMessage("used this month"),
    "discover_attribution": MessageLookupByLibrary.simpleMessage(
      "Data from AniList",
    ),
    "discover_chapters": m15,
    "discover_empty_title": MessageLookupByLibrary.simpleMessage(
      "Nothing here yet",
    ),
    "discover_episodes": m16,
    "discover_error_message": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again.",
    ),
    "discover_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load AniList",
    ),
    "discover_find_on_sources": MessageLookupByLibrary.simpleMessage(
      "Find on my sources",
    ),
    "discover_format_manga": MessageLookupByLibrary.simpleMessage("Manga"),
    "discover_format_movie": MessageLookupByLibrary.simpleMessage("Movie"),
    "discover_format_music": MessageLookupByLibrary.simpleMessage("Music"),
    "discover_format_novel": MessageLookupByLibrary.simpleMessage(
      "Light novel",
    ),
    "discover_format_ona": MessageLookupByLibrary.simpleMessage("ONA"),
    "discover_format_one_shot": MessageLookupByLibrary.simpleMessage(
      "One-shot",
    ),
    "discover_format_ova": MessageLookupByLibrary.simpleMessage("OVA"),
    "discover_format_special": MessageLookupByLibrary.simpleMessage("Special"),
    "discover_format_tv": MessageLookupByLibrary.simpleMessage("TV"),
    "discover_format_tv_short": MessageLookupByLibrary.simpleMessage(
      "TV short",
    ),
    "discover_load_more_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load more",
    ),
    "discover_no_synopsis": MessageLookupByLibrary.simpleMessage(
      "No synopsis yet.",
    ),
    "discover_open_tooltip": MessageLookupByLibrary.simpleMessage(
      "Discover on AniList",
    ),
    "discover_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "discover_score": m17,
    "discover_search_as": MessageLookupByLibrary.simpleMessage("Search as"),
    "discover_season_fall": m18,
    "discover_season_spring": m19,
    "discover_season_summer": m20,
    "discover_season_winter": m21,
    "discover_tab_novels": MessageLookupByLibrary.simpleMessage("Light novels"),
    "discover_tab_season": MessageLookupByLibrary.simpleMessage("This season"),
    "discover_tab_trending_anime": MessageLookupByLibrary.simpleMessage(
      "Trending anime",
    ),
    "discover_tab_trending_manga": MessageLookupByLibrary.simpleMessage(
      "Trending manga",
    ),
    "discover_title": MessageLookupByLibrary.simpleMessage("Discover"),
    "download_speed_megabytes": m22,
    "download_time_left": m23,
    "downloads_chapters_summary": m24,
    "downloads_confirm_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "downloads_confirm_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "downloads_delete_all": MessageLookupByLibrary.simpleMessage("Delete all"),
    "downloads_delete_all_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "This will remove every downloaded chapter from this device.",
        ),
    "downloads_delete_all_confirmation_title":
        MessageLookupByLibrary.simpleMessage("Delete all downloads?"),
    "downloads_delete_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "This chapter will be removed from this device.",
        ),
    "downloads_delete_confirmation_title": MessageLookupByLibrary.simpleMessage(
      "Delete download?",
    ),
    "downloads_empty_message": MessageLookupByLibrary.simpleMessage(
      "Chapters you download for offline reading will appear here.",
    ),
    "downloads_empty_title": MessageLookupByLibrary.simpleMessage(
      "No downloads",
    ),
    "downloads_episode_bytes_downloaded": m25,
    "downloads_episode_bytes_progress": m26,
    "downloads_episode_delete_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "This episode will be removed from this device.",
        ),
    "downloads_episode_done": MessageLookupByLibrary.simpleMessage(
      "Ready to watch offline",
    ),
    "downloads_episode_done_size": m27,
    "downloads_episode_files_missing": MessageLookupByLibrary.simpleMessage(
      "This episode\'s downloaded files are missing. Download it again to watch offline.",
    ),
    "downloads_episode_preparing": MessageLookupByLibrary.simpleMessage(
      "Preparing video…",
    ),
    "downloads_episode_retry": MessageLookupByLibrary.simpleMessage(
      "Retry download",
    ),
    "downloads_episode_segments_progress": m28,
    "downloads_episode_size_gb": m29,
    "downloads_episode_size_mb": m30,
    "downloads_episode_summary": m31,
    "downloads_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Downloads",
    ),
    "downloads_notification_complete_body": m32,
    "downloads_notification_complete_title":
        MessageLookupByLibrary.simpleMessage("Download complete"),
    "downloads_notification_downloading_title":
        MessageLookupByLibrary.simpleMessage("Downloading"),
    "downloads_novel_chapter_done": MessageLookupByLibrary.simpleMessage(
      "Saved for offline reading",
    ),
    "downloads_novel_chapter_downloading": MessageLookupByLibrary.simpleMessage(
      "Saving text…",
    ),
    "downloads_order_newest": MessageLookupByLibrary.simpleMessage(
      "Newest first",
    ),
    "downloads_order_oldest": MessageLookupByLibrary.simpleMessage(
      "Oldest first",
    ),
    "downloads_pages_progress": m33,
    "downloads_quality_1080": MessageLookupByLibrary.simpleMessage("1080p"),
    "downloads_quality_480": MessageLookupByLibrary.simpleMessage("480p"),
    "downloads_quality_720": MessageLookupByLibrary.simpleMessage("720p"),
    "downloads_quality_highest": MessageLookupByLibrary.simpleMessage(
      "Highest available",
    ),
    "downloads_quality_same_as_player": MessageLookupByLibrary.simpleMessage(
      "Same as player",
    ),
    "downloads_quality_title": MessageLookupByLibrary.simpleMessage(
      "Download quality",
    ),
    "downloads_queue_button": m34,
    "downloads_queue_download_next": MessageLookupByLibrary.simpleMessage(
      "Download next",
    ),
    "downloads_queue_empty": MessageLookupByLibrary.simpleMessage(
      "Nothing is waiting to download",
    ),
    "downloads_queue_move_title_to_top": MessageLookupByLibrary.simpleMessage(
      "Move to the top of the queue",
    ),
    "downloads_queue_now_downloading": MessageLookupByLibrary.simpleMessage(
      "Downloading now",
    ),
    "downloads_queue_pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "downloads_queue_pause_all": MessageLookupByLibrary.simpleMessage(
      "Pause all",
    ),
    "downloads_queue_pause_title": MessageLookupByLibrary.simpleMessage(
      "Pause downloads of this title",
    ),
    "downloads_queue_paused_progress": m35,
    "downloads_queue_remove": MessageLookupByLibrary.simpleMessage(
      "Remove from queue",
    ),
    "downloads_queue_reorder_hint": MessageLookupByLibrary.simpleMessage(
      "Drag the handles to change the download order",
    ),
    "downloads_queue_resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "downloads_queue_resume_all": MessageLookupByLibrary.simpleMessage(
      "Resume all",
    ),
    "downloads_queue_resume_title": MessageLookupByLibrary.simpleMessage(
      "Resume downloads of this title",
    ),
    "downloads_queue_status_paused": MessageLookupByLibrary.simpleMessage(
      "Paused",
    ),
    "downloads_queue_title": MessageLookupByLibrary.simpleMessage("Queue"),
    "downloads_runtime_app_must_stay_open": MessageLookupByLibrary.simpleMessage(
      "Android stopped background downloading. Keep the app open until downloads finish.",
    ),
    "downloads_runtime_waiting_for_wifi": MessageLookupByLibrary.simpleMessage(
      "Waiting for Wi-Fi",
    ),
    "downloads_runtime_waiting_for_wifi_message":
        MessageLookupByLibrary.simpleMessage(
          "Downloads resume automatically once you are back on Wi-Fi",
        ),
    "downloads_runtime_wifi_only_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Queued downloads wait until you are on Wi-Fi or ethernet",
        ),
    "downloads_runtime_wifi_only_title": MessageLookupByLibrary.simpleMessage(
      "Download over Wi-Fi only",
    ),
    "downloads_status_downloading": MessageLookupByLibrary.simpleMessage(
      "Downloading",
    ),
    "downloads_status_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "downloads_status_queued": MessageLookupByLibrary.simpleMessage("Queued"),
    "downloads_storage_calculating": MessageLookupByLibrary.simpleMessage(
      "Calculating…",
    ),
    "downloads_storage_delete_after_watching_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Remove a downloaded episode once you finish it in the player",
        ),
    "downloads_storage_delete_after_watching_title":
        MessageLookupByLibrary.simpleMessage("Delete episodes after watching"),
    "downloads_storage_delete_all_short": MessageLookupByLibrary.simpleMessage(
      "Delete all",
    ),
    "downloads_storage_delete_title_confirm_message": m36,
    "downloads_storage_delete_title_confirm_title":
        MessageLookupByLibrary.simpleMessage("Delete these downloads?"),
    "downloads_storage_delete_title_downloads":
        MessageLookupByLibrary.simpleMessage(
          "Delete all downloads of this title",
        ),
    "downloads_storage_delete_watched": MessageLookupByLibrary.simpleMessage(
      "Delete watched",
    ),
    "downloads_storage_delete_watched_confirm_message": m37,
    "downloads_storage_delete_watched_confirm_title":
        MessageLookupByLibrary.simpleMessage("Delete watched episodes?"),
    "downloads_storage_delete_watched_episodes":
        MessageLookupByLibrary.simpleMessage("Delete watched episodes"),
    "downloads_storage_deleted_watched": m38,
    "downloads_storage_free_up": MessageLookupByLibrary.simpleMessage(
      "Free up space",
    ),
    "downloads_storage_free_up_empty": MessageLookupByLibrary.simpleMessage(
      "Nothing to free up",
    ),
    "downloads_storage_free_up_reclaimable": m39,
    "downloads_storage_no_watched": MessageLookupByLibrary.simpleMessage(
      "No watched episodes to delete",
    ),
    "downloads_storage_playback_fallback": MessageLookupByLibrary.simpleMessage(
      "The downloaded file couldn\'t be played, so it\'s streaming instead.",
    ),
    "downloads_storage_redownload": MessageLookupByLibrary.simpleMessage(
      "Re-download",
    ),
    "downloads_storage_section_title": MessageLookupByLibrary.simpleMessage(
      "Downloads",
    ),
    "downloads_storage_summary_with_size": m40,
    "downloads_storage_title_size": m41,
    "downloads_storage_used": MessageLookupByLibrary.simpleMessage(
      "Storage used",
    ),
    "downloads_storage_watched_size": m42,
    "downloads_title": MessageLookupByLibrary.simpleMessage("Downloads"),
    "duration_hours_minutes": m43,
    "duration_minutes": m44,
    "duration_seconds": m45,
    "engine_tag_best": MessageLookupByLibrary.simpleMessage("Best quality"),
    "engine_tag_fast": MessageLookupByLibrary.simpleMessage("Fast"),
    "engine_tag_literal": MessageLookupByLibrary.simpleMessage("Literal"),
    "engine_tag_natural": MessageLookupByLibrary.simpleMessage("Natural"),
    "engine_tag_offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "engine_tag_online": MessageLookupByLibrary.simpleMessage("Online"),
    "engine_tag_size": m46,
    "engine_tag_speed_e2b": MessageLookupByLibrary.simpleMessage(
      "≈4–10 s per page",
    ),
    "engine_tag_speed_e4b": MessageLookupByLibrary.simpleMessage(
      "≈20–45 s per page",
    ),
    "episode_playback_fallback_notice": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load the video stream, opened the web player instead",
    ),
    "episode_playback_loading_sources": MessageLookupByLibrary.simpleMessage(
      "Loading video…",
    ),
    "export_section_categories": MessageLookupByLibrary.simpleMessage(
      "Categories",
    ),
    "export_section_categories_subtitle": MessageLookupByLibrary.simpleMessage(
      "Library categories",
    ),
    "export_section_history": MessageLookupByLibrary.simpleMessage(
      "Reading history",
    ),
    "export_section_history_subtitle": MessageLookupByLibrary.simpleMessage(
      "Chapters read and episodes watched",
    ),
    "export_section_library": MessageLookupByLibrary.simpleMessage("Library"),
    "export_section_library_subtitle": MessageLookupByLibrary.simpleMessage(
      "Titles you added to your library",
    ),
    "export_section_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "export_section_settings_subtitle": MessageLookupByLibrary.simpleMessage(
      "Theme, reader, player, layout and translation preferences",
    ),
    "export_section_sources": MessageLookupByLibrary.simpleMessage(
      "Extension sources",
    ),
    "export_section_sources_subtitle": MessageLookupByLibrary.simpleMessage(
      "Repositories you added",
    ),
    "export_section_translations": MessageLookupByLibrary.simpleMessage(
      "Page translations",
    ),
    "export_section_translations_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Translated pages, so they don\'t need to be translated again",
        ),
    "ext_prefs_clear_data": MessageLookupByLibrary.simpleMessage(
      "Clear stored data",
    ),
    "ext_prefs_clear_data_done": m47,
    "ext_prefs_default_hint": m48,
    "ext_prefs_done": MessageLookupByLibrary.simpleMessage("Done"),
    "ext_prefs_mirror_automatic": MessageLookupByLibrary.simpleMessage(
      "Automatic",
    ),
    "ext_prefs_mirror_summary": MessageLookupByLibrary.simpleMessage(
      "Which site address requests go to. Automatic tries each mirror until one responds.",
    ),
    "ext_prefs_mirror_title": MessageLookupByLibrary.simpleMessage("Mirror"),
    "ext_prefs_number_invalid": MessageLookupByLibrary.simpleMessage(
      "Enter a number",
    ),
    "ext_prefs_page_size_default_option": m49,
    "ext_prefs_page_size_option": m50,
    "ext_prefs_page_size_summary": MessageLookupByLibrary.simpleMessage(
      "How many titles each gallery page loads.",
    ),
    "ext_prefs_page_size_title": MessageLookupByLibrary.simpleMessage(
      "Page size",
    ),
    "ext_prefs_reset": MessageLookupByLibrary.simpleMessage(
      "Reset to defaults",
    ),
    "ext_prefs_reset_one": MessageLookupByLibrary.simpleMessage(
      "Reset to default",
    ),
    "ext_prefs_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Extension settings",
    ),
    "extension_clear_session": MessageLookupByLibrary.simpleMessage(
      "Clear saved session",
    ),
    "extension_clear_session_done": m51,
    "extension_instance_add": MessageLookupByLibrary.simpleMessage(
      "Add another server",
    ),
    "extension_instance_add_confirm": MessageLookupByLibrary.simpleMessage(
      "Add",
    ),
    "extension_instance_add_failed": MessageLookupByLibrary.simpleMessage(
      "Could not add the server. Check your connection and try again.",
    ),
    "extension_instance_added": m52,
    "extension_instance_rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "extension_instance_rename_confirm": MessageLookupByLibrary.simpleMessage(
      "Save",
    ),
    "extension_source_page_error_adding_source":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during adding source",
        ),
    "extension_source_page_error_removing_source":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during removing source",
        ),
    "extension_source_page_error_updating_source":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during updating source",
        ),
    "extension_source_page_remove_source_dialog_cancel_label":
        MessageLookupByLibrary.simpleMessage("Cancel"),
    "extension_source_page_remove_source_dialog_message":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to remove this source?",
        ),
    "extension_source_page_remove_source_dialog_ok_label":
        MessageLookupByLibrary.simpleMessage("Remove"),
    "extension_source_page_remove_source_dialog_title":
        MessageLookupByLibrary.simpleMessage("Remove source"),
    "extension_sources_page_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Repositories",
    ),
    "extension_sources_page_default_badge":
        MessageLookupByLibrary.simpleMessage("Default"),
    "extension_sources_page_error_loading_sources":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during loading sources",
        ),
    "extension_sources_page_wakaranai_github_repo_title":
        MessageLookupByLibrary.simpleMessage("Wakaranai Extensions"),
    "extension_uninstall": MessageLookupByLibrary.simpleMessage("Uninstall"),
    "extension_uninstall_done": m53,
    "extension_uninstall_message": MessageLookupByLibrary.simpleMessage(
      "Removes the downloaded script, its settings, stored data and sign-in. Library titles and downloads stay; opening one of them installs the extension again.",
    ),
    "extension_uninstall_title": m54,
    "external_player_action": MessageLookupByLibrary.simpleMessage(
      "External player",
    ),
    "external_player_unavailable": MessageLookupByLibrary.simpleMessage(
      "No external video player is installed. Playing in the built-in player instead.",
    ),
    "feeds_row_label": MessageLookupByLibrary.simpleMessage("Feeds"),
    "filters_active_summary": m55,
    "filters_add_value": MessageLookupByLibrary.simpleMessage("Add"),
    "filters_any_option": MessageLookupByLibrary.simpleMessage("Any"),
    "filters_button_semantics": m56,
    "filters_clear_search": MessageLookupByLibrary.simpleMessage(
      "Clear search",
    ),
    "filters_clear_section": MessageLookupByLibrary.simpleMessage("Clear"),
    "filters_empty_message": MessageLookupByLibrary.simpleMessage(
      "This source doesn\'t offer any filters.",
    ),
    "filters_empty_title": MessageLookupByLibrary.simpleMessage("No filters"),
    "filters_none_active": MessageLookupByLibrary.simpleMessage(
      "Showing everything",
    ),
    "filters_range_any": MessageLookupByLibrary.simpleMessage("Any"),
    "filters_remove_value": m57,
    "filters_search_hint": m58,
    "filters_show_all": m59,
    "filters_show_less": MessageLookupByLibrary.simpleMessage("Show less"),
    "gallery_filters_apply_button": MessageLookupByLibrary.simpleMessage(
      "Apply",
    ),
    "gallery_filters_apply_button_count": m60,
    "gallery_filters_button_label": MessageLookupByLibrary.simpleMessage(
      "Filters",
    ),
    "gallery_filters_more_options": m61,
    "gallery_filters_multiple_of_any_hint":
        MessageLookupByLibrary.simpleMessage("Type and add"),
    "gallery_filters_no_matches": MessageLookupByLibrary.simpleMessage(
      "No matches",
    ),
    "gallery_filters_one_of_any_hint": MessageLookupByLibrary.simpleMessage(
      "Enter a value",
    ),
    "gallery_filters_option_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search",
    ),
    "gallery_filters_range_from_hint": MessageLookupByLibrary.simpleMessage(
      "From",
    ),
    "gallery_filters_range_to_hint": MessageLookupByLibrary.simpleMessage("To"),
    "gallery_filters_reset_button": MessageLookupByLibrary.simpleMessage(
      "Reset",
    ),
    "gallery_filters_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Filters",
    ),
    "gallery_last_opened": m62,
    "gallery_layout_button_tooltip": m63,
    "gallery_layout_comfortable": MessageLookupByLibrary.simpleMessage(
      "Comfortable grid",
    ),
    "gallery_layout_compact": MessageLookupByLibrary.simpleMessage(
      "Compact grid",
    ),
    "gallery_layout_list": MessageLookupByLibrary.simpleMessage("List"),
    "global_search_empty_sources": m64,
    "global_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search titles in your sources",
    ),
    "global_search_idle_message": MessageLookupByLibrary.simpleMessage(
      "Each source shows its results as soon as it answers.",
    ),
    "global_search_idle_title": MessageLookupByLibrary.simpleMessage(
      "Search across your sources",
    ),
    "global_search_no_results_message": m65,
    "global_search_no_results_title": MessageLookupByLibrary.simpleMessage(
      "Nothing found",
    ),
    "global_search_no_scope_message": MessageLookupByLibrary.simpleMessage(
      "Pick at least one source to search in.",
    ),
    "global_search_no_scope_title": MessageLookupByLibrary.simpleMessage(
      "No sources to search",
    ),
    "global_search_open_tooltip": MessageLookupByLibrary.simpleMessage(
      "Search all sources",
    ),
    "global_search_rail_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t search this source",
    ),
    "global_search_rail_open": MessageLookupByLibrary.simpleMessage("Open"),
    "global_search_rail_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "global_search_rail_sign_in": MessageLookupByLibrary.simpleMessage(
      "Sign-in needed",
    ),
    "global_search_rail_timeout": MessageLookupByLibrary.simpleMessage(
      "The source took too long to answer",
    ),
    "global_search_rail_unavailable": MessageLookupByLibrary.simpleMessage(
      "This source couldn\'t be loaded",
    ),
    "global_search_rail_verify": MessageLookupByLibrary.simpleMessage(
      "Verification needed",
    ),
    "global_search_recent_clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "global_search_recent_title": MessageLookupByLibrary.simpleMessage(
      "Recent searches",
    ),
    "global_search_results_count": m66,
    "global_search_scope_custom_hint": MessageLookupByLibrary.simpleMessage(
      "Your own selection",
    ),
    "global_search_scope_default_hint": MessageLookupByLibrary.simpleMessage(
      "By default: pinned sources and sources you have used",
    ),
    "global_search_scope_edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "global_search_scope_empty": MessageLookupByLibrary.simpleMessage(
      "No sources with search are available",
    ),
    "global_search_scope_loading": MessageLookupByLibrary.simpleMessage(
      "Looking for more sources…",
    ),
    "global_search_scope_reset": MessageLookupByLibrary.simpleMessage(
      "Use default",
    ),
    "global_search_scope_select_all": MessageLookupByLibrary.simpleMessage(
      "Select all",
    ),
    "global_search_scope_select_none": MessageLookupByLibrary.simpleMessage(
      "Clear",
    ),
    "global_search_scope_summary": m67,
    "global_search_scope_title": MessageLookupByLibrary.simpleMessage(
      "Sources to search",
    ),
    "global_search_title": MessageLookupByLibrary.simpleMessage(
      "Search sources",
    ),
    "global_search_try_titles": MessageLookupByLibrary.simpleMessage(
      "Search as",
    ),
    "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Video"),
    "home_configs_source_initializing_error": m68,
    "home_extensions_error_message": MessageLookupByLibrary.simpleMessage(
      "Configs source error :c",
    ),
    "home_extensions_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load extensions",
    ),
    "home_fetching_mangas_configs_error": MessageLookupByLibrary.simpleMessage(
      "Error occurred during fetching manga configs",
    ),
    "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Manga"),
    "home_navigation_bar_activity_history_title":
        MessageLookupByLibrary.simpleMessage("History"),
    "home_navigation_bar_library_title": MessageLookupByLibrary.simpleMessage(
      "Library",
    ),
    "home_navigation_bar_settings_title": MessageLookupByLibrary.simpleMessage(
      "Settings",
    ),
    "home_navigation_bar_sources_title": MessageLookupByLibrary.simpleMessage(
      "Explore",
    ),
    "home_no_extensions_message": MessageLookupByLibrary.simpleMessage(
      "This source doesn\'t have any extensions yet",
    ),
    "home_no_extensions_title": MessageLookupByLibrary.simpleMessage(
      "No extensions",
    ),
    "home_novel_group_title": MessageLookupByLibrary.simpleMessage("Novels"),
    "home_nsfw_suffix": MessageLookupByLibrary.simpleMessage("NSFW"),
    "home_remote_configs_page_appbar_title":
        MessageLookupByLibrary.simpleMessage("Extensions"),
    "home_sources_button": MessageLookupByLibrary.simpleMessage("Sources"),
    "language_packs_available_section": MessageLookupByLibrary.simpleMessage(
      "Available",
    ),
    "language_packs_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "language_packs_downloaded_count": m69,
    "language_packs_downloaded_section": MessageLookupByLibrary.simpleMessage(
      "Downloaded",
    ),
    "language_packs_failed": MessageLookupByLibrary.simpleMessage(
      "Download failed",
    ),
    "language_packs_hint": MessageLookupByLibrary.simpleMessage(
      "Each pack is about 30 MB. You only need the languages you translate from and to.",
    ),
    "language_packs_hint_wifi": MessageLookupByLibrary.simpleMessage(
      "Each pack is about 30 MB. You only need the languages you translate from and to. Downloads wait for Wi-Fi.",
    ),
    "language_packs_queue_progress": m70,
    "language_packs_queued": m71,
    "language_packs_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "language_packs_title": MessageLookupByLibrary.simpleMessage(
      "Language packs",
    ),
    "library_add": MessageLookupByLibrary.simpleMessage("Add to library"),
    "library_add_category": MessageLookupByLibrary.simpleMessage(
      "Add category",
    ),
    "library_add_to_category": MessageLookupByLibrary.simpleMessage(
      "Add to category",
    ),
    "library_added_message": MessageLookupByLibrary.simpleMessage(
      "Added to library",
    ),
    "library_category_all": MessageLookupByLibrary.simpleMessage("All"),
    "library_category_name_hint": MessageLookupByLibrary.simpleMessage(
      "Category name",
    ),
    "library_category_uncategorized": MessageLookupByLibrary.simpleMessage(
      "Uncategorized",
    ),
    "library_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "library_delete_category": MessageLookupByLibrary.simpleMessage("Delete"),
    "library_download_first_group_hint": MessageLookupByLibrary.simpleMessage(
      "Each title downloads from its first chapter group",
    ),
    "library_download_many_failed": m72,
    "library_download_many_loading": m73,
    "library_empty_message": MessageLookupByLibrary.simpleMessage(
      "Tap the heart on a title to add it here",
    ),
    "library_empty_title": MessageLookupByLibrary.simpleMessage(
      "Your library is empty",
    ),
    "library_manage_categories": MessageLookupByLibrary.simpleMessage(
      "Manage categories",
    ),
    "library_more_actions": MessageLookupByLibrary.simpleMessage("More"),
    "library_move_to_category": MessageLookupByLibrary.simpleMessage(
      "Move to category",
    ),
    "library_mute_notifications": MessageLookupByLibrary.simpleMessage(
      "Mute notifications",
    ),
    "library_new_chapters": m74,
    "library_no_category": MessageLookupByLibrary.simpleMessage("No category"),
    "library_remove": MessageLookupByLibrary.simpleMessage(
      "Remove from library",
    ),
    "library_removed_message": MessageLookupByLibrary.simpleMessage(
      "Removed from library",
    ),
    "library_rename_category": MessageLookupByLibrary.simpleMessage("Rename"),
    "library_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search library",
    ),
    "library_search_no_results_message": m75,
    "library_search_no_results_title": MessageLookupByLibrary.simpleMessage(
      "No matches",
    ),
    "library_select_all": MessageLookupByLibrary.simpleMessage("Select all"),
    "library_selected_count": m76,
    "library_sort_added_newest": MessageLookupByLibrary.simpleMessage(
      "Recently added",
    ),
    "library_sort_added_oldest": MessageLookupByLibrary.simpleMessage(
      "Oldest added",
    ),
    "library_sort_alphabetical": MessageLookupByLibrary.simpleMessage("Title"),
    "library_sort_last_read": MessageLookupByLibrary.simpleMessage("Last read"),
    "library_sort_title": MessageLookupByLibrary.simpleMessage("Sort by"),
    "library_source_unavailable_message": MessageLookupByLibrary.simpleMessage(
      "The extension for this title is no longer installed",
    ),
    "library_source_unavailable_title": MessageLookupByLibrary.simpleMessage(
      "Source unavailable",
    ),
    "library_tab_titles": MessageLookupByLibrary.simpleMessage("Titles"),
    "library_track_updates": MessageLookupByLibrary.simpleMessage(
      "Check for updates",
    ),
    "library_unmute_notifications": MessageLookupByLibrary.simpleMessage(
      "Unmute notifications",
    ),
    "local_extension_server_source_name": MessageLookupByLibrary.simpleMessage(
      "Local server",
    ),
    "local_source_import": MessageLookupByLibrary.simpleMessage(
      "Import CBZ or ZIP files",
    ),
    "local_source_imported": m77,
    "local_source_imported_title": MessageLookupByLibrary.simpleMessage(
      "Imported",
    ),
    "local_source_name": MessageLookupByLibrary.simpleMessage("Local files"),
    "local_source_where": MessageLookupByLibrary.simpleMessage(
      "Where to put files",
    ),
    "local_source_where_message": m78,
    "native_player_auto_next_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "native_player_auto_next_countdown": m79,
    "native_player_auto_next_play_now": MessageLookupByLibrary.simpleMessage(
      "Play now",
    ),
    "native_player_cancel_switch": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "native_player_debug_action": MessageLookupByLibrary.simpleMessage(
      "Play URL in native player",
    ),
    "native_player_debug_play": MessageLookupByLibrary.simpleMessage("Play"),
    "native_player_debug_url_hint": MessageLookupByLibrary.simpleMessage(
      "https://example.com/video.m3u8",
    ),
    "native_player_debug_url_label": MessageLookupByLibrary.simpleMessage(
      "Stream URL",
    ),
    "native_player_debug_url_title": MessageLookupByLibrary.simpleMessage(
      "Play a stream URL",
    ),
    "native_player_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t play this video",
    ),
    "native_player_fit_mode": MessageLookupByLibrary.simpleMessage("Video fit"),
    "native_player_fit_mode_fill": MessageLookupByLibrary.simpleMessage("Fill"),
    "native_player_fit_mode_fit": MessageLookupByLibrary.simpleMessage("Fit"),
    "native_player_fit_mode_stretch": MessageLookupByLibrary.simpleMessage(
      "Stretch",
    ),
    "native_player_lock": MessageLookupByLibrary.simpleMessage("Lock controls"),
    "native_player_more": MessageLookupByLibrary.simpleMessage("More options"),
    "native_player_next_episode": MessageLookupByLibrary.simpleMessage(
      "Next episode",
    ),
    "native_player_no_streams": MessageLookupByLibrary.simpleMessage(
      "No playable streams",
    ),
    "native_player_open_web_player": MessageLookupByLibrary.simpleMessage(
      "Open in web player",
    ),
    "native_player_pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "native_player_pip_enter": MessageLookupByLibrary.simpleMessage(
      "Picture-in-picture",
    ),
    "native_player_play": MessageLookupByLibrary.simpleMessage("Play"),
    "native_player_quality": MessageLookupByLibrary.simpleMessage("Quality"),
    "native_player_quality_auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "native_player_quality_fallback": m80,
    "native_player_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "native_player_seek_backward": m81,
    "native_player_seek_forward": m82,
    "native_player_skip_opening": m83,
    "native_player_speed": MessageLookupByLibrary.simpleMessage(
      "Playback speed",
    ),
    "native_player_speed_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "native_player_speed_unsupported": MessageLookupByLibrary.simpleMessage(
      "This playback speed isn\'t supported",
    ),
    "native_player_subtitle_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load these subtitles",
    ),
    "native_player_subtitle_fallback": m84,
    "native_player_subtitles": MessageLookupByLibrary.simpleMessage(
      "Subtitles",
    ),
    "native_player_subtitles_off": MessageLookupByLibrary.simpleMessage("Off"),
    "native_player_unlock": MessageLookupByLibrary.simpleMessage(
      "Unlock controls",
    ),
    "novel_progress_percent": m85,
    "novel_reader_background_sepia": MessageLookupByLibrary.simpleMessage(
      "Sepia",
    ),
    "novel_reader_empty_chapter": MessageLookupByLibrary.simpleMessage(
      "This chapter has no text",
    ),
    "novel_reader_font_family": MessageLookupByLibrary.simpleMessage("Font"),
    "novel_reader_font_serif": MessageLookupByLibrary.simpleMessage("Serif"),
    "novel_reader_font_size": MessageLookupByLibrary.simpleMessage("Text size"),
    "novel_reader_font_ubuntu": MessageLookupByLibrary.simpleMessage("Ubuntu"),
    "novel_reader_justify": MessageLookupByLibrary.simpleMessage(
      "Justify text",
    ),
    "novel_reader_keep_screen_on": MessageLookupByLibrary.simpleMessage(
      "Keep screen on",
    ),
    "novel_reader_line_height": MessageLookupByLibrary.simpleMessage(
      "Line spacing",
    ),
    "novel_reader_margins": MessageLookupByLibrary.simpleMessage(
      "Side margins",
    ),
    "novel_reader_next_chapter": MessageLookupByLibrary.simpleMessage(
      "Next chapter",
    ),
    "novel_reader_next_chapter_named": m86,
    "novel_reader_previous_chapter": MessageLookupByLibrary.simpleMessage(
      "Previous chapter",
    ),
    "novel_reader_settings_title": MessageLookupByLibrary.simpleMessage(
      "Reading settings",
    ),
    "page_language_arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "page_language_chinese": MessageLookupByLibrary.simpleMessage("Chinese"),
    "page_language_english": MessageLookupByLibrary.simpleMessage("English"),
    "page_language_french": MessageLookupByLibrary.simpleMessage("French"),
    "page_language_german": MessageLookupByLibrary.simpleMessage("German"),
    "page_language_indonesian": MessageLookupByLibrary.simpleMessage(
      "Indonesian",
    ),
    "page_language_italian": MessageLookupByLibrary.simpleMessage("Italian"),
    "page_language_japanese": MessageLookupByLibrary.simpleMessage("Japanese"),
    "page_language_korean": MessageLookupByLibrary.simpleMessage("Korean"),
    "page_language_polish": MessageLookupByLibrary.simpleMessage("Polish"),
    "page_language_portuguese": MessageLookupByLibrary.simpleMessage(
      "Portuguese",
    ),
    "page_language_russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "page_language_spanish": MessageLookupByLibrary.simpleMessage("Spanish"),
    "page_language_thai": MessageLookupByLibrary.simpleMessage("Thai"),
    "page_language_turkish": MessageLookupByLibrary.simpleMessage("Turkish"),
    "page_language_ukrainian": MessageLookupByLibrary.simpleMessage(
      "Ukrainian",
    ),
    "page_language_vietnamese": MessageLookupByLibrary.simpleMessage(
      "Vietnamese",
    ),
    "page_translation_ai_model_downloading": m87,
    "page_translation_ai_model_message": m88,
    "page_translation_ai_model_title": MessageLookupByLibrary.simpleMessage(
      "Download the AI model",
    ),
    "page_translation_appearance_section": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "page_translation_copied": MessageLookupByLibrary.simpleMessage("Copied"),
    "page_translation_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "page_translation_copy_original": MessageLookupByLibrary.simpleMessage(
      "Copy original",
    ),
    "page_translation_copy_translation": MessageLookupByLibrary.simpleMessage(
      "Copy translation",
    ),
    "page_translation_edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "page_translation_font": MessageLookupByLibrary.simpleMessage("Font"),
    "page_translation_font_comic": MessageLookupByLibrary.simpleMessage(
      "Comic",
    ),
    "page_translation_font_system": MessageLookupByLibrary.simpleMessage(
      "System",
    ),
    "page_translation_glossary_add": MessageLookupByLibrary.simpleMessage(
      "Add name",
    ),
    "page_translation_glossary_count": m89,
    "page_translation_glossary_empty": MessageLookupByLibrary.simpleMessage(
      "None yet",
    ),
    "page_translation_glossary_save": MessageLookupByLibrary.simpleMessage(
      "Save",
    ),
    "page_translation_glossary_save_retranslate":
        MessageLookupByLibrary.simpleMessage("Save & retranslate chapter"),
    "page_translation_glossary_subtitle": MessageLookupByLibrary.simpleMessage(
      "Keep character names and terms consistent in this title. Used by DeepL and Gemma.",
    ),
    "page_translation_glossary_title": MessageLookupByLibrary.simpleMessage(
      "Names & terms",
    ),
    "page_translation_glossary_unsupported": MessageLookupByLibrary.simpleMessage(
      "ML Kit can\'t use names & terms. Switch to DeepL or Gemma in Page translation settings.",
    ),
    "page_translation_label_background": MessageLookupByLibrary.simpleMessage(
      "Label background",
    ),
    "page_translation_label_background_subtitle":
        MessageLookupByLibrary.simpleMessage("For text outside speech bubbles"),
    "page_translation_languages_from": MessageLookupByLibrary.simpleMessage(
      "Text on pages",
    ),
    "page_translation_languages_save": MessageLookupByLibrary.simpleMessage(
      "Save",
    ),
    "page_translation_languages_start": MessageLookupByLibrary.simpleMessage(
      "Translate",
    ),
    "page_translation_languages_subtitle": MessageLookupByLibrary.simpleMessage(
      "Saved for this title only.",
    ),
    "page_translation_languages_title": MessageLookupByLibrary.simpleMessage(
      "Translation languages",
    ),
    "page_translation_languages_to": MessageLookupByLibrary.simpleMessage(
      "Translate to",
    ),
    "page_translation_models_cancel": MessageLookupByLibrary.simpleMessage(
      "Not now",
    ),
    "page_translation_models_download": MessageLookupByLibrary.simpleMessage(
      "Download",
    ),
    "page_translation_models_downloading": MessageLookupByLibrary.simpleMessage(
      "Downloading language packs…",
    ),
    "page_translation_models_downloading_progress": m90,
    "page_translation_models_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t download language packs",
    ),
    "page_translation_models_message": m91,
    "page_translation_models_title": MessageLookupByLibrary.simpleMessage(
      "Download language packs",
    ),
    "page_translation_models_wifi_note": MessageLookupByLibrary.simpleMessage(
      "Downloads wait for Wi-Fi. You can change this in Settings → Page translation.",
    ),
    "page_translation_original_edit_hint": MessageLookupByLibrary.simpleMessage(
      "Fix recognition mistakes, then retranslate",
    ),
    "page_translation_original_label": MessageLookupByLibrary.simpleMessage(
      "Original",
    ),
    "page_translation_peek_hint": MessageLookupByLibrary.simpleMessage(
      "Hold to see the original page",
    ),
    "page_translation_preview_bubble": MessageLookupByLibrary.simpleMessage(
      "What are you doing here?!",
    ),
    "page_translation_preview_label": MessageLookupByLibrary.simpleMessage(
      "Meanwhile, in Tokyo…",
    ),
    "page_translation_region_empty": MessageLookupByLibrary.simpleMessage(
      "No text found in the selected area",
    ),
    "page_translation_retranslate": MessageLookupByLibrary.simpleMessage(
      "Retranslate",
    ),
    "page_translation_retranslate_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t retranslate this bubble",
    ),
    "page_translation_settings_clear_cache":
        MessageLookupByLibrary.simpleMessage("Clear translated pages"),
    "page_translation_settings_clear_cache_confirm_message":
        MessageLookupByLibrary.simpleMessage(
          "Pages will be translated again the next time you open them.",
        ),
    "page_translation_settings_clear_cache_confirm_ok":
        MessageLookupByLibrary.simpleMessage("Clear"),
    "page_translation_settings_clear_cache_confirm_title":
        MessageLookupByLibrary.simpleMessage("Clear translated pages?"),
    "page_translation_settings_clear_cache_subtitle": m92,
    "page_translation_settings_delete_pack":
        MessageLookupByLibrary.simpleMessage("Delete"),
    "page_translation_settings_download_pack":
        MessageLookupByLibrary.simpleMessage("Download"),
    "page_translation_settings_enable": MessageLookupByLibrary.simpleMessage(
      "Enable page translation",
    ),
    "page_translation_settings_enable_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Adds a translate button to the reader. Text is recognized and translated on your device.",
        ),
    "page_translation_settings_experimental":
        MessageLookupByLibrary.simpleMessage("Experimental"),
    "page_translation_settings_languages_section":
        MessageLookupByLibrary.simpleMessage("Languages"),
    "page_translation_settings_ocr_note": MessageLookupByLibrary.simpleMessage(
      "Japanese, Korean and Chinese recognition is provided by Google Play services and downloads automatically the first time it is used.",
    ),
    "page_translation_settings_ocr_title": MessageLookupByLibrary.simpleMessage(
      "Text recognition",
    ),
    "page_translation_settings_pack_downloaded":
        MessageLookupByLibrary.simpleMessage("Downloaded"),
    "page_translation_settings_pack_missing":
        MessageLookupByLibrary.simpleMessage("Not downloaded · about 30 MB"),
    "page_translation_settings_packs_section":
        MessageLookupByLibrary.simpleMessage("Language packs"),
    "page_translation_settings_remove_outdated":
        MessageLookupByLibrary.simpleMessage("Remove older translations"),
    "page_translation_settings_remove_outdated_subtitle": m93,
    "page_translation_settings_storage_section":
        MessageLookupByLibrary.simpleMessage("Storage"),
    "page_translation_settings_target": MessageLookupByLibrary.simpleMessage(
      "Translate to",
    ),
    "page_translation_settings_target_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Default for titles you translate for the first time. Each title remembers its own languages.",
        ),
    "page_translation_settings_title": MessageLookupByLibrary.simpleMessage(
      "Page translation",
    ),
    "page_translation_settings_wifi_only": MessageLookupByLibrary.simpleMessage(
      "Download on Wi-Fi only",
    ),
    "page_translation_show_original": MessageLookupByLibrary.simpleMessage(
      "Show original",
    ),
    "page_translation_show_translation": MessageLookupByLibrary.simpleMessage(
      "Show translation",
    ),
    "page_translation_status_chapter": m94,
    "page_translation_status_failed": MessageLookupByLibrary.simpleMessage(
      "Translation failed · tap to retry",
    ),
    "page_translation_status_model_pending":
        MessageLookupByLibrary.simpleMessage(
          "Google Play services is downloading text recognition…",
        ),
    "page_translation_status_outdated": MessageLookupByLibrary.simpleMessage(
      "Older translation · tap to update",
    ),
    "page_translation_status_preparing": MessageLookupByLibrary.simpleMessage(
      "Preparing translation…",
    ),
    "page_translation_status_translating": MessageLookupByLibrary.simpleMessage(
      "Translating page…",
    ),
    "page_translation_text_size": MessageLookupByLibrary.simpleMessage(
      "Text size",
    ),
    "page_translation_text_size_auto": MessageLookupByLibrary.simpleMessage(
      "Auto",
    ),
    "page_translation_text_size_pixels": m95,
    "page_translation_text_size_subtitle": MessageLookupByLibrary.simpleMessage(
      "Largest size translated text may use on screen",
    ),
    "page_translation_translate_chapter": MessageLookupByLibrary.simpleMessage(
      "Translate whole chapter",
    ),
    "page_translation_translate_chapter_hint":
        MessageLookupByLibrary.simpleMessage(
          "Translate every page in the background",
        ),
    "page_translation_translation_label": MessageLookupByLibrary.simpleMessage(
      "Translation",
    ),
    "player_dub_player": MessageLookupByLibrary.simpleMessage("Dub / player"),
    "player_episodes": MessageLookupByLibrary.simpleMessage("Episodes"),
    "player_playlist": MessageLookupByLibrary.simpleMessage("Playlist"),
    "player_previous_episode": MessageLookupByLibrary.simpleMessage(
      "Previous episode",
    ),
    "player_skip_auto_subtitle": MessageLookupByLibrary.simpleMessage(
      "Jump past them when the extension marks where they are",
    ),
    "player_skip_auto_title": MessageLookupByLibrary.simpleMessage(
      "Auto-skip intros and outros",
    ),
    "player_skip_intro": MessageLookupByLibrary.simpleMessage("Skip intro"),
    "player_skip_outro": MessageLookupByLibrary.simpleMessage("Skip outro"),
    "player_skip_recap": MessageLookupByLibrary.simpleMessage("Skip recap"),
    "player_skip_skipped_intro": MessageLookupByLibrary.simpleMessage(
      "Skipped intro",
    ),
    "player_skip_skipped_outro": MessageLookupByLibrary.simpleMessage(
      "Skipped outro",
    ),
    "player_skip_skipped_recap": MessageLookupByLibrary.simpleMessage(
      "Skipped recap",
    ),
    "reader_background_black": MessageLookupByLibrary.simpleMessage("Black"),
    "reader_background_grey": MessageLookupByLibrary.simpleMessage("Grey"),
    "reader_background_theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "reader_background_title": MessageLookupByLibrary.simpleMessage(
      "Background",
    ),
    "reader_background_white": MessageLookupByLibrary.simpleMessage("White"),
    "reader_crop_borders_subtitle": MessageLookupByLibrary.simpleMessage(
      "Trim empty white or black margins in page modes",
    ),
    "reader_crop_borders_title": MessageLookupByLibrary.simpleMessage(
      "Crop borders",
    ),
    "reader_double_page_subtitle": MessageLookupByLibrary.simpleMessage(
      "Show pages side by side when the phone is turned sideways",
    ),
    "reader_double_page_title": MessageLookupByLibrary.simpleMessage(
      "Two pages in landscape",
    ),
    "reader_page_fit_height": MessageLookupByLibrary.simpleMessage(
      "Fit height",
    ),
    "reader_page_fit_screen": MessageLookupByLibrary.simpleMessage(
      "Fit screen",
    ),
    "reader_page_fit_title": MessageLookupByLibrary.simpleMessage("Page fit"),
    "reader_page_fit_width": MessageLookupByLibrary.simpleMessage("Fit width"),
    "reader_volume_keys_invert_title": MessageLookupByLibrary.simpleMessage(
      "Invert volume keys",
    ),
    "reader_volume_keys_title": MessageLookupByLibrary.simpleMessage(
      "Turn pages with volume keys",
    ),
    "save_image_error": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t save image",
    ),
    "save_image_save_button": MessageLookupByLibrary.simpleMessage("Save as…"),
    "save_image_sheet_title": MessageLookupByLibrary.simpleMessage("Image"),
    "save_image_success": MessageLookupByLibrary.simpleMessage("Image saved"),
    "service_view_clear_search": MessageLookupByLibrary.simpleMessage("Clear"),
    "service_view_empty_message": MessageLookupByLibrary.simpleMessage(
      "Pull down to refresh",
    ),
    "service_view_empty_title": MessageLookupByLibrary.simpleMessage(
      "Nothing here yet",
    ),
    "service_view_error": MessageLookupByLibrary.simpleMessage("Error :c"),
    "service_view_error_title": MessageLookupByLibrary.simpleMessage(
      "Something went wrong",
    ),
    "service_view_no_results_message": m96,
    "service_view_no_results_title": MessageLookupByLibrary.simpleMessage(
      "No results",
    ),
    "service_view_open_web_view_button_title":
        MessageLookupByLibrary.simpleMessage("Open in WebView"),
    "service_view_retry_button_title": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "service_view_search_results_for": m97,
    "service_viewer_search_field_hint_text":
        MessageLookupByLibrary.simpleMessage("Search"),
    "settings_about_section_title": MessageLookupByLibrary.simpleMessage(
      "About",
    ),
    "settings_appearance_section_title": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "settings_auto_backup_failed": MessageLookupByLibrary.simpleMessage(
      "The last backup failed · tap Back up now to retry",
    ),
    "settings_auto_backup_last": m98,
    "settings_auto_backup_never": MessageLookupByLibrary.simpleMessage(
      "Daily to Download/Wakaranai · no backup yet",
    ),
    "settings_auto_backup_now": MessageLookupByLibrary.simpleMessage(
      "Back up now",
    ),
    "settings_auto_backup_off": MessageLookupByLibrary.simpleMessage(
      "Off · use Export to save a backup yourself",
    ),
    "settings_auto_backup_saved": MessageLookupByLibrary.simpleMessage(
      "Backup saved to Download/Wakaranai",
    ),
    "settings_auto_backup_title": MessageLookupByLibrary.simpleMessage(
      "Automatic backups",
    ),
    "settings_check_updates": MessageLookupByLibrary.simpleMessage(
      "Check library for updates",
    ),
    "settings_check_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "Periodically look for new chapters and episodes in the background",
    ),
    "settings_clear_activity_history": MessageLookupByLibrary.simpleMessage(
      "Clear activity history",
    ),
    "settings_clear_activity_history_dialog_confirmation_cancel_label":
        MessageLookupByLibrary.simpleMessage("Cancel"),
    "settings_clear_activity_history_dialog_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "This action cannot be canceled later",
        ),
    "settings_clear_activity_history_dialog_confirmation_ok_label":
        MessageLookupByLibrary.simpleMessage("Delete"),
    "settings_clear_activity_history_dialog_confirmation_title":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to clear your history?",
        ),
    "settings_clear_activity_history_dialog_error":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during clearing history",
        ),
    "settings_clear_activity_history_dialog_success":
        MessageLookupByLibrary.simpleMessage("History has been cleared"),
    "settings_clear_cookies_cache": MessageLookupByLibrary.simpleMessage(
      "Clear cookies cache",
    ),
    "settings_clear_cookies_cache_dialog_confirmation_cancel_label":
        MessageLookupByLibrary.simpleMessage("Cancel"),
    "settings_clear_cookies_cache_dialog_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "This action cannot be canceled later",
        ),
    "settings_clear_cookies_cache_dialog_confirmation_ok_label":
        MessageLookupByLibrary.simpleMessage("Delete"),
    "settings_clear_cookies_cache_dialog_confirmation_title":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to clear your cookies?",
        ),
    "settings_clear_cookies_dialog_success":
        MessageLookupByLibrary.simpleMessage("Cookies has been cleared"),
    "settings_clear_history_title": MessageLookupByLibrary.simpleMessage(
      "Clear history",
    ),
    "settings_collect_statistics_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Track activity to build statistics",
        ),
    "settings_collect_statistics_title": MessageLookupByLibrary.simpleMessage(
      "Collect statistics",
    ),
    "settings_content_section_title": MessageLookupByLibrary.simpleMessage(
      "Content",
    ),
    "settings_default_reader_mode_title": MessageLookupByLibrary.simpleMessage(
      "Default reader mode",
    ),
    "settings_developer_section": MessageLookupByLibrary.simpleMessage(
      "Developer",
    ),
    "settings_download_latest_release": m99,
    "settings_export_data_button": MessageLookupByLibrary.simpleMessage(
      "Export data",
    ),
    "settings_export_error": MessageLookupByLibrary.simpleMessage(
      "Export failed",
    ),
    "settings_export_notification_complete":
        MessageLookupByLibrary.simpleMessage("Export complete"),
    "settings_export_progress_title": MessageLookupByLibrary.simpleMessage(
      "Exporting",
    ),
    "settings_export_select_all": MessageLookupByLibrary.simpleMessage(
      "Select all",
    ),
    "settings_export_sheet_confirm": MessageLookupByLibrary.simpleMessage(
      "Export",
    ),
    "settings_export_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Export data",
    ),
    "settings_export_success": MessageLookupByLibrary.simpleMessage(
      "Export complete",
    ),
    "settings_hide_nsfw_titles_subtitle": MessageLookupByLibrary.simpleMessage(
      "Keep them out of the library, history, updates and downloads",
    ),
    "settings_hide_nsfw_titles_title": MessageLookupByLibrary.simpleMessage(
      "Hide titles from NSFW sources",
    ),
    "settings_import_data_button": MessageLookupByLibrary.simpleMessage(
      "Import data",
    ),
    "settings_import_error": MessageLookupByLibrary.simpleMessage(
      "Import failed",
    ),
    "settings_import_export_info_export_body": MessageLookupByLibrary.simpleMessage(
      "Saves the sections you pick — reading history, library, categories, extension sources and settings — into a single JSON file you can back up or move to another device.",
    ),
    "settings_import_export_info_export_title":
        MessageLookupByLibrary.simpleMessage("Export"),
    "settings_import_export_info_import_body": MessageLookupByLibrary.simpleMessage(
      "Loads a previously exported JSON file and merges the sections you pick with what you already have — existing entries are updated and new ones are added, nothing is deleted.",
    ),
    "settings_import_export_info_import_title":
        MessageLookupByLibrary.simpleMessage("Import"),
    "settings_import_export_info_title": MessageLookupByLibrary.simpleMessage(
      "Import & export",
    ),
    "settings_import_nothing_to_import": MessageLookupByLibrary.simpleMessage(
      "This file has nothing to import",
    ),
    "settings_import_notification_complete":
        MessageLookupByLibrary.simpleMessage("Import complete"),
    "settings_import_progress_title": MessageLookupByLibrary.simpleMessage(
      "Importing",
    ),
    "settings_import_sheet_confirm": MessageLookupByLibrary.simpleMessage(
      "Import",
    ),
    "settings_import_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Import data",
    ),
    "settings_import_skipped": m100,
    "settings_import_success": m101,
    "settings_incognito_subtitle": MessageLookupByLibrary.simpleMessage(
      "Don\'t save reading or watching progress, history or statistics",
    ),
    "settings_incognito_title": MessageLookupByLibrary.simpleMessage(
      "Incognito mode",
    ),
    "settings_language_english": MessageLookupByLibrary.simpleMessage(
      "English",
    ),
    "settings_language_system": MessageLookupByLibrary.simpleMessage("System"),
    "settings_language_title": MessageLookupByLibrary.simpleMessage(
      "App language",
    ),
    "settings_language_ukrainian": MessageLookupByLibrary.simpleMessage(
      "Українська",
    ),
    "settings_local_extension_server_missing":
        MessageLookupByLibrary.simpleMessage(
          "Set LOCAL_REPOSITORY_URL in .env to enable",
        ),
    "settings_local_extension_server_subtitle": m102,
    "settings_local_extension_server_title":
        MessageLookupByLibrary.simpleMessage("Local extension server"),
    "settings_page_translation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Experimental · recognize and translate text on pages",
    ),
    "settings_page_translation_title": MessageLookupByLibrary.simpleMessage(
      "Page translation",
    ),
    "settings_player_auto_next_subtitle": MessageLookupByLibrary.simpleMessage(
      "Count down and start the next episode when one ends",
    ),
    "settings_player_auto_next_title": MessageLookupByLibrary.simpleMessage(
      "Auto-play next episode",
    ),
    "settings_player_hold_speed_subtitle": MessageLookupByLibrary.simpleMessage(
      "Long-press the video to play faster while you hold",
    ),
    "settings_player_hold_speed_title": MessageLookupByLibrary.simpleMessage(
      "Hold to speed up",
    ),
    "settings_player_section_title": MessageLookupByLibrary.simpleMessage(
      "Player",
    ),
    "settings_player_skip_opening_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "How far the skip button jumps ahead",
        ),
    "settings_player_skip_opening_title": MessageLookupByLibrary.simpleMessage(
      "Skip opening",
    ),
    "settings_player_skip_opening_value": m103,
    "settings_progress_preparing": MessageLookupByLibrary.simpleMessage(
      "Preparing…",
    ),
    "settings_reader_section_title": MessageLookupByLibrary.simpleMessage(
      "Reader",
    ),
    "settings_reading_statistics_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "View your reading and watching activity",
        ),
    "settings_reading_statistics_title": MessageLookupByLibrary.simpleMessage(
      "Reading statistics",
    ),
    "settings_service_viewer_filters_title":
        MessageLookupByLibrary.simpleMessage("Filters"),
    "settings_show_nsfw_subtitle": MessageLookupByLibrary.simpleMessage(
      "Display extensions marked as adult content",
    ),
    "settings_show_nsfw_title": MessageLookupByLibrary.simpleMessage(
      "Show NSFW sources",
    ),
    "settings_statistics_section_title": MessageLookupByLibrary.simpleMessage(
      "Statistics",
    ),
    "settings_submit_issue": MessageLookupByLibrary.simpleMessage(
      "Submit issue/feature request/extension request",
    ),
    "settings_theme_amoled": MessageLookupByLibrary.simpleMessage("AMOLED"),
    "settings_theme_dracula": MessageLookupByLibrary.simpleMessage("Dracula"),
    "settings_theme_ember": MessageLookupByLibrary.simpleMessage("Ember"),
    "settings_theme_light": MessageLookupByLibrary.simpleMessage("Light"),
    "settings_theme_midnight": MessageLookupByLibrary.simpleMessage("Midnight"),
    "settings_theme_ocean": MessageLookupByLibrary.simpleMessage("Ocean"),
    "settings_theme_sakura": MessageLookupByLibrary.simpleMessage("Sakura"),
    "settings_theme_sepia": MessageLookupByLibrary.simpleMessage("Sepia"),
    "settings_theme_sky": MessageLookupByLibrary.simpleMessage("Sky"),
    "settings_theme_title": MessageLookupByLibrary.simpleMessage("Theme"),
    "settings_tracker_login_failed": m104,
    "settings_tracker_logout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "settings_tracker_logout_message": MessageLookupByLibrary.simpleMessage(
      "Titles linked to this tracker stop syncing and their links are removed.",
    ),
    "settings_tracker_logout_title": m105,
    "settings_tracker_signed_in": m106,
    "settings_tracker_signed_out": MessageLookupByLibrary.simpleMessage(
      "Not signed in. Tap to sign in",
    ),
    "settings_trackers_title": MessageLookupByLibrary.simpleMessage("Trackers"),
    "settings_transfer_notification_channel_name":
        MessageLookupByLibrary.simpleMessage("Import & export"),
    "settings_update_frequency": MessageLookupByLibrary.simpleMessage(
      "Check frequency",
    ),
    "settings_update_frequency_value": m107,
    "settings_update_notifications": MessageLookupByLibrary.simpleMessage(
      "Update notifications",
    ),
    "settings_update_notifications_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Show a notification when new items are found",
        ),
    "settings_updates_section": MessageLookupByLibrary.simpleMessage("Updates"),
    "settings_video_player_auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "settings_video_player_external": MessageLookupByLibrary.simpleMessage(
      "External player",
    ),
    "settings_video_player_subtitle": MessageLookupByLibrary.simpleMessage(
      "Play videos in the built-in player when the source provides a direct stream",
    ),
    "settings_video_player_title": MessageLookupByLibrary.simpleMessage(
      "Video player",
    ),
    "settings_video_player_web_only": MessageLookupByLibrary.simpleMessage(
      "Web player only",
    ),
    "source_error_login_required_title": m108,
    "source_error_not_found_title": MessageLookupByLibrary.simpleMessage(
      "Removed from the source",
    ),
    "source_error_open_saved_button": MessageLookupByLibrary.simpleMessage(
      "Open saved details",
    ),
    "source_error_rate_limited_title": MessageLookupByLibrary.simpleMessage(
      "Too many requests, try again later",
    ),
    "source_error_region_blocked_title": MessageLookupByLibrary.simpleMessage(
      "Not available in your region",
    ),
    "source_error_remove_from_library_button":
        MessageLookupByLibrary.simpleMessage("Remove from library"),
    "source_error_removed_titles_found": m109,
    "source_error_retry_button": MessageLookupByLibrary.simpleMessage("Retry"),
    "source_error_sign_in_button": MessageLookupByLibrary.simpleMessage(
      "Sign in",
    ),
    "source_error_source_down_title": MessageLookupByLibrary.simpleMessage(
      "The source is down, try again later",
    ),
    "source_error_unsupported_title": MessageLookupByLibrary.simpleMessage(
      "Not supported by this source",
    ),
    "stats_activity_section_title": MessageLookupByLibrary.simpleMessage(
      "Activity",
    ),
    "stats_disabled_message": MessageLookupByLibrary.simpleMessage(
      "Enable statistics collection to see your reading and watching activity here.",
    ),
    "stats_disabled_title": MessageLookupByLibrary.simpleMessage(
      "Statistics are off",
    ),
    "stats_empty_message": MessageLookupByLibrary.simpleMessage(
      "Start reading or watching to build up your statistics.",
    ),
    "stats_empty_title": MessageLookupByLibrary.simpleMessage(
      "No activity yet",
    ),
    "stats_enable_button": MessageLookupByLibrary.simpleMessage("Enable"),
    "stats_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load statistics",
    ),
    "stats_heatmap_hint": MessageLookupByLibrary.simpleMessage(
      "Tap a week for details",
    ),
    "stats_heatmap_less": MessageLookupByLibrary.simpleMessage("Less"),
    "stats_heatmap_more": MessageLookupByLibrary.simpleMessage("More"),
    "stats_heatmap_week_count": m110,
    "stats_kpi_active_days": MessageLookupByLibrary.simpleMessage(
      "Active days",
    ),
    "stats_kpi_chapters_read": MessageLookupByLibrary.simpleMessage(
      "Chapters read",
    ),
    "stats_kpi_day_streak": MessageLookupByLibrary.simpleMessage("Day streak"),
    "stats_kpi_episodes_watched": MessageLookupByLibrary.simpleMessage(
      "Episodes watched",
    ),
    "stats_kpi_pages_read": MessageLookupByLibrary.simpleMessage("Pages read"),
    "stats_kpi_time_watched": MessageLookupByLibrary.simpleMessage(
      "Time watched",
    ),
    "stats_overview_section_title": MessageLookupByLibrary.simpleMessage(
      "Overview",
    ),
    "stats_sources_section_title": MessageLookupByLibrary.simpleMessage(
      "Top sources",
    ),
    "stats_streak_summary": m111,
    "stats_title": MessageLookupByLibrary.simpleMessage("Statistics"),
    "title_download": MessageLookupByLibrary.simpleMessage("Download"),
    "title_download_all": MessageLookupByLibrary.simpleMessage("All chapters"),
    "title_download_chapter_count": m112,
    "title_download_episode_all": MessageLookupByLibrary.simpleMessage(
      "All episodes",
    ),
    "title_download_episode_count": m113,
    "title_download_episode_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load the episode list",
    ),
    "title_download_episode_first_group_hint":
        MessageLookupByLibrary.simpleMessage(
          "Each title downloads from its first episode group",
        ),
    "title_download_episode_groups": MessageLookupByLibrary.simpleMessage(
      "Episode groups",
    ),
    "title_download_episode_how_many": MessageLookupByLibrary.simpleMessage(
      "Episodes to download",
    ),
    "title_download_episode_loading": MessageLookupByLibrary.simpleMessage(
      "Looking up episodes…",
    ),
    "title_download_episode_many_loading": m114,
    "title_download_episode_mixed_all": MessageLookupByLibrary.simpleMessage(
      "All chapters and episodes",
    ),
    "title_download_episode_mixed_hint": MessageLookupByLibrary.simpleMessage(
      "Each title downloads from its first group",
    ),
    "title_download_episode_mixed_loading": m115,
    "title_download_episode_mixed_next": MessageLookupByLibrary.simpleMessage(
      "Next chapter or episode",
    ),
    "title_download_episode_mixed_next_count": m116,
    "title_download_episode_mixed_nothing":
        MessageLookupByLibrary.simpleMessage("Nothing new to download"),
    "title_download_episode_mixed_queued": m117,
    "title_download_episode_mixed_title": MessageLookupByLibrary.simpleMessage(
      "Download chapters and episodes",
    ),
    "title_download_episode_mixed_unread": MessageLookupByLibrary.simpleMessage(
      "Unread chapters and unwatched episodes",
    ),
    "title_download_episode_next": MessageLookupByLibrary.simpleMessage(
      "Next episode",
    ),
    "title_download_episode_next_count": m118,
    "title_download_episode_none": MessageLookupByLibrary.simpleMessage(
      "This title has no episodes yet",
    ),
    "title_download_episode_nothing": MessageLookupByLibrary.simpleMessage(
      "No new episodes to download",
    ),
    "title_download_episode_queued": m119,
    "title_download_episode_title": MessageLookupByLibrary.simpleMessage(
      "Download episodes",
    ),
    "title_download_episode_unwatched": MessageLookupByLibrary.simpleMessage(
      "Unwatched episodes",
    ),
    "title_download_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load the chapter list",
    ),
    "title_download_groups": MessageLookupByLibrary.simpleMessage(
      "Chapter groups",
    ),
    "title_download_how_many": MessageLookupByLibrary.simpleMessage(
      "Chapters to download",
    ),
    "title_download_loading": MessageLookupByLibrary.simpleMessage(
      "Looking up chapters…",
    ),
    "title_download_next": MessageLookupByLibrary.simpleMessage("Next chapter"),
    "title_download_next_count": m120,
    "title_download_no_chapters": MessageLookupByLibrary.simpleMessage(
      "This title has no chapters yet",
    ),
    "title_download_nothing": MessageLookupByLibrary.simpleMessage(
      "No new chapters to download",
    ),
    "title_download_queued": m121,
    "title_download_title": MessageLookupByLibrary.simpleMessage(
      "Download chapters",
    ),
    "title_download_unread": MessageLookupByLibrary.simpleMessage(
      "Unread chapters",
    ),
    "title_download_untitled_group": m122,
    "title_status_announce": MessageLookupByLibrary.simpleMessage("Announced"),
    "title_status_canceled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "title_status_ongoing": MessageLookupByLibrary.simpleMessage("Ongoing"),
    "title_status_paused": MessageLookupByLibrary.simpleMessage("Paused"),
    "title_status_released": MessageLookupByLibrary.simpleMessage("Completed"),
    "tracker_chip_untracked": MessageLookupByLibrary.simpleMessage(
      "Track this title",
    ),
    "tracker_link_action": MessageLookupByLibrary.simpleMessage("Link"),
    "tracker_link_failed": MessageLookupByLibrary.simpleMessage(
      "Could not link the title. Try again.",
    ),
    "tracker_search_empty": MessageLookupByLibrary.simpleMessage(
      "Nothing found. Try another title.",
    ),
    "tracker_search_failed": MessageLookupByLibrary.simpleMessage(
      "Search failed. Check your connection and try again.",
    ),
    "tracker_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search by title",
    ),
    "tracker_search_title": m123,
    "tracker_sheet_title": MessageLookupByLibrary.simpleMessage("Tracking"),
    "tracker_status_completed": MessageLookupByLibrary.simpleMessage(
      "Completed",
    ),
    "tracker_status_dropped": MessageLookupByLibrary.simpleMessage("Dropped"),
    "tracker_status_paused": MessageLookupByLibrary.simpleMessage("Paused"),
    "tracker_status_planning": MessageLookupByLibrary.simpleMessage("Planning"),
    "tracker_status_reading": MessageLookupByLibrary.simpleMessage("Reading"),
    "tracker_status_rereading": MessageLookupByLibrary.simpleMessage(
      "Rereading",
    ),
    "tracker_status_rewatching": MessageLookupByLibrary.simpleMessage(
      "Rewatching",
    ),
    "tracker_status_watching": MessageLookupByLibrary.simpleMessage("Watching"),
    "tracker_unlink_action": MessageLookupByLibrary.simpleMessage("Unlink"),
    "translation_ai_model_delete_message": m124,
    "translation_ai_model_delete_title": MessageLookupByLibrary.simpleMessage(
      "Delete the AI model?",
    ),
    "translation_ai_model_failed": MessageLookupByLibrary.simpleMessage(
      "Download failed · try again on Wi-Fi",
    ),
    "translation_ai_model_installed": m125,
    "translation_ai_model_missing": m126,
    "translation_ai_model_title": MessageLookupByLibrary.simpleMessage(
      "AI model",
    ),
    "translation_engine_change": MessageLookupByLibrary.simpleMessage("Change"),
    "translation_engine_deepl": MessageLookupByLibrary.simpleMessage(
      "DeepL · online",
    ),
    "translation_engine_deepl_subtitle": MessageLookupByLibrary.simpleMessage(
      "Best quality · sends the recognised text to DeepL · needs a free API key",
    ),
    "translation_engine_gemma": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 E2B · on-device AI",
    ),
    "translation_engine_gemma_e4b": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 E4B · on-device AI",
    ),
    "translation_engine_gemma_e4b_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Better translations, about twice as slow · 3.7 GB · 12 GB RAM",
        ),
    "translation_engine_gemma_subtitle": MessageLookupByLibrary.simpleMessage(
      "Natural translations that fix text-recognition mistakes · 2.6 GB · 8 GB RAM",
    ),
    "translation_engine_gemma_unavailable_64bit":
        MessageLookupByLibrary.simpleMessage("Needs a 64-bit phone"),
    "translation_engine_gemma_unavailable_android":
        MessageLookupByLibrary.simpleMessage("Needs Android 11 or newer"),
    "translation_engine_gemma_unavailable_platform":
        MessageLookupByLibrary.simpleMessage("Not available on this device"),
    "translation_engine_gemma_unavailable_ram": m127,
    "translation_engine_info_examples": MessageLookupByLibrary.simpleMessage(
      "Speed by phone (estimated)",
    ),
    "translation_engine_info_footer": MessageLookupByLibrary.simpleMessage(
      "Speeds are estimates; the fast tier was measured on a Galaxy S24 Ultra. Translating ahead while you read, and translating downloaded chapters in advance, hides most of the wait.",
    ),
    "translation_engine_info_intro": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 runs entirely on your phone. It reads the whole page at once, fixes text-recognition mistakes and translates naturally. E4B translates noticeably better than E2B but is about twice as slow. Nothing leaves your device.",
    ),
    "translation_engine_info_requirements":
        MessageLookupByLibrary.simpleMessage("Requirements"),
    "translation_engine_info_this_phone": m128,
    "translation_engine_mlkit": MessageLookupByLibrary.simpleMessage("ML Kit"),
    "translation_engine_mlkit_subtitle": MessageLookupByLibrary.simpleMessage(
      "Fast and light · works on every phone · literal translations",
    ),
    "translation_engine_req_64bit": MessageLookupByLibrary.simpleMessage(
      "64-bit (arm64) processor",
    ),
    "translation_engine_req_android": MessageLookupByLibrary.simpleMessage(
      "Android 11 or newer",
    ),
    "translation_engine_req_ram_model": m129,
    "translation_engine_req_storage_model": m130,
    "translation_engine_section": MessageLookupByLibrary.simpleMessage(
      "Translation engine",
    ),
    "translation_engine_tier_e4b": MessageLookupByLibrary.simpleMessage(
      "About 20–45 s per page",
    ),
    "translation_engine_tier_e4b_no_phones":
        MessageLookupByLibrary.simpleMessage("Phones with less than 12 GB RAM"),
    "translation_engine_tier_fast": MessageLookupByLibrary.simpleMessage(
      "Fast · about 4–10 s per page",
    ),
    "translation_engine_tier_fast_phones": MessageLookupByLibrary.simpleMessage(
      "Galaxy S24 / S25, Pixel 9 / 10, OnePlus 12 / 13, Xiaomi 14 / 15 and other 2024+ flagships with 12 GB RAM",
    ),
    "translation_engine_tier_no": MessageLookupByLibrary.simpleMessage(
      "Not supported",
    ),
    "translation_engine_tier_no_phones": MessageLookupByLibrary.simpleMessage(
      "Phones with less than 8 GB RAM, 32-bit phones and Android 10 or older",
    ),
    "translation_engine_tier_ok": MessageLookupByLibrary.simpleMessage(
      "Usable · noticeably slower",
    ),
    "translation_engine_tier_ok_phones": MessageLookupByLibrary.simpleMessage(
      "Galaxy S22 / S23, Pixel 8, Galaxy A55 and other phones with 8 GB RAM",
    ),
    "translation_models_ai_section": MessageLookupByLibrary.simpleMessage(
      "On-device AI",
    ),
    "translation_models_downloaded": m131,
    "translation_models_packs_count": m132,
    "translation_models_packs_section": MessageLookupByLibrary.simpleMessage(
      "ML Kit",
    ),
    "translation_models_pick_first": m133,
    "translation_models_summary": m134,
    "translation_models_title": MessageLookupByLibrary.simpleMessage(
      "Downloaded models",
    ),
    "translation_models_unsupported": MessageLookupByLibrary.simpleMessage(
      "Not supported on this phone",
    ),
    "updates_attention_action_open": MessageLookupByLibrary.simpleMessage(
      "Open",
    ),
    "updates_attention_action_review": MessageLookupByLibrary.simpleMessage(
      "Review",
    ),
    "updates_attention_browser_check": m135,
    "updates_attention_many": m136,
    "updates_attention_notification_body": MessageLookupByLibrary.simpleMessage(
      "Update checks are paused for these sources. Pull to refresh your library to fix it.",
    ),
    "updates_attention_notification_browser_title": m137,
    "updates_attention_notification_sign_in_title": m138,
    "updates_attention_session_saved": m139,
    "updates_attention_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Sources need attention",
    ),
    "updates_attention_sign_in": m140,
    "updates_attention_sign_in_again": m141,
    "updates_attention_unavailable": m142,
    "updates_check_failed": m143,
    "updates_check_found": m144,
    "updates_check_none": MessageLookupByLibrary.simpleMessage(
      "No new updates found",
    ),
    "updates_checking": MessageLookupByLibrary.simpleMessage(
      "Checking for updates…",
    ),
    "updates_clear": MessageLookupByLibrary.simpleMessage("Clear updates"),
    "updates_empty_message": MessageLookupByLibrary.simpleMessage(
      "New chapters and episodes for titles in your library will appear here",
    ),
    "updates_empty_title": MessageLookupByLibrary.simpleMessage(
      "No new updates",
    ),
    "updates_mark_all_seen": MessageLookupByLibrary.simpleMessage(
      "Mark all as seen",
    ),
    "updates_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Library updates",
    ),
    "updates_notification_line": m145,
    "updates_notification_more": m146,
    "updates_notification_summary": m147,
    "updates_notification_title": m148,
    "updates_time_days": m149,
    "updates_time_hours": m150,
    "updates_time_minutes": m151,
    "updates_time_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "updates_title": MessageLookupByLibrary.simpleMessage("Updates"),
    "web_browser_back": MessageLookupByLibrary.simpleMessage("Back"),
    "web_browser_clear_cookies": MessageLookupByLibrary.simpleMessage(
      "Clear cookies for this site",
    ),
    "web_browser_cookies_cleared": m152,
    "web_browser_copy_link": MessageLookupByLibrary.simpleMessage("Copy link"),
    "web_browser_error_title": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load this page",
    ),
    "web_browser_forward": MessageLookupByLibrary.simpleMessage("Forward"),
    "web_browser_link_copied": MessageLookupByLibrary.simpleMessage(
      "Link copied",
    ),
    "web_browser_looks_good": MessageLookupByLibrary.simpleMessage(
      "Looks good — continue",
    ),
    "web_browser_more": MessageLookupByLibrary.simpleMessage("More"),
    "web_browser_no_login_button": MessageLookupByLibrary.simpleMessage("Done"),
    "web_browser_open_external": MessageLookupByLibrary.simpleMessage(
      "Open in external browser",
    ),
    "web_browser_open_external_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t open an external browser",
    ),
    "web_browser_popup_close": MessageLookupByLibrary.simpleMessage(
      "Close window",
    ),
    "web_browser_reload": MessageLookupByLibrary.simpleMessage("Reload"),
    "web_browser_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "web_browser_stop": MessageLookupByLibrary.simpleMessage("Stop loading"),
  };
}
