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

  static String m1(failed) => "Translated · ${failed} pages failed";

  static String m2(count) => "${count} chapters translated";

  static String m3(count) => "${count} chapters left";

  static String m4(done, total) => "Translating ${done}/${total}";

  static String m5(count) => "${count} chapters queued for translation";

  static String m6(count) => "${count} selected";

  static String m7(names) => "Art by ${names}";

  static String m8(names) => "By ${names}";

  static String m9(ending) => "Key ••••${ending}";

  static String m10(used, limit) => "${used} of ${limit} characters";

  static String m11(count) => "${count} left";

  static String m12(speed) => "${speed} MB/s";

  static String m13(time) => "${time} left";

  static String m14(done, total) => "${done}/${total} chapters downloaded";

  static String m15(count) => "${count} chapters downloaded";

  static String m16(done, total) => "${done}/${total} pages";

  static String m17(hours, minutes) => "${hours} h ${minutes} min";

  static String m18(minutes) => "${minutes} min";

  static String m19(seconds) => "${seconds} s";

  static String m20(size) => "${size} GB";

  static String m21(count) => "Apply (${count})";

  static String m22(count) => "+${count} more — refine your search";

  static String m23(title) => "Last opened: ${title}";

  static String m24(layout) => "Layout: ${layout}";

  static String m25(name) =>
      "Error occurred during initializing configs ${name} source";

  static String m26(count) => "${count} downloaded";

  static String m27(current, total) => "Downloading ${current} of ${total}";

  static String m28(position) => "Queued · #${position}";

  static String m29(count) =>
      "${Intl.plural(count, one: '1 title couldn\'t be loaded', other: '${count} titles couldn\'t be loaded')}";

  static String m30(count) =>
      "${Intl.plural(count, one: 'Looking up chapters for 1 title…', other: 'Looking up chapters for ${count} titles…')}";

  static String m31(query) => "Nothing in your library matches “${query}”";

  static String m32(count) => "${count} selected";

  static String m33(progress) => "Downloading AI model ${progress}%";

  static String m34(model, size) =>
      "${model} needs a one-time ${size} GB download. Use Wi-Fi: the model is stored on your phone and translation then runs fully offline.";

  static String m35(count) =>
      "${Intl.plural(count, one: '1 name', other: '${count} names')}";

  static String m36(current, total) =>
      "Downloading language packs ${current}/${total}…";

  static String m37(source, target) =>
      "Translating ${source} to ${target} needs on-device language packs, about 30 MB each. They are downloaded once, and pages are then translated entirely on your device.";

  static String m38(count) => "${count} pages saved";

  static String m39(count) => "${count} pages from an older version";

  static String m40(done, total) => "Translating chapter ${done}/${total}";

  static String m41(size) => "Up to ${size} px";

  static String m42(query) => "We couldn\'t find anything for “${query}”";

  static String m43(query) => "Results for “${query}”";

  static String m44(time) => "Daily to Download/Wakaranai · last ${time}";

  static String m45(version) => "New version ${version} available";

  static String m46(count) => "${count} skipped";

  static String m47(imported, total) =>
      "Imported ${imported} of ${total} items";

  static String m48(url) => "Load extensions from ${url}";

  static String m49(hours) => "Every ${hours} hours";

  static String m50(count) => "${count} activities";

  static String m51(current, longest) =>
      "Current ${current} · Longest ${longest}";

  static String m52(count) =>
      "${Intl.plural(count, one: '1 chapter', other: '${count} chapters')}";

  static String m53(count) => "Next ${count} chapters";

  static String m54(count) =>
      "${Intl.plural(count, one: '1 chapter queued', other: '${count} chapters queued')}";

  static String m55(number) => "Group ${number}";

  static String m56(size) =>
      "This frees ${size} GB. You can download it again at any time.";

  static String m57(model, size) => "${model} · ${size} GB · ready";

  static String m58(size) => "Not downloaded · ${size} GB";

  static String m59(need, ram) =>
      "Needs ${need} GB of RAM (this phone has ${ram} GB)";

  static String m60(model, ram) => "This phone: ${model} · ${ram} GB RAM";

  static String m61(ram) => "${ram} GB of RAM or more";

  static String m62(size) => "About ${size} GB of free storage";

  static String m63(size) => "Downloaded · ${size} GB";

  static String m64(count) =>
      "${Intl.plural(count, zero: 'No language packs yet', one: '1 language pack downloaded', other: '${count} language packs downloaded')}";

  static String m65(size) =>
      "Not downloaded · ${size} GB · choose it as the engine to download";

  static String m66(count, size) =>
      "${Intl.plural(count, zero: 'No AI models downloaded', one: '1 AI model · ${size} GB', other: '${count} AI models · ${size} GB')}";

  static String m67(count) => "${count} sources could not be checked";

  static String m68(count) => "${count} new items found";

  static String m69(title, count) => "${title} · ${count} new";

  static String m70(count) => "and ${count} more titles";

  static String m71(count) => "Across ${count} titles";

  static String m72(count) => "${count} new items";

  static String m73(count) => "${count}d ago";

  static String m74(count) => "${count}h ago";

  static String m75(count) => "${count}m ago";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activity_history_anime_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Anime",
    ),
    "activity_history_deleted_activity": MessageLookupByLibrary.simpleMessage(
      "Deleted activity successfully",
    ),
    "activity_history_empty_anime_list_message":
        MessageLookupByLibrary.simpleMessage(
          "No history :c\nStart watching anime to see your history here",
        ),
    "activity_history_empty_manga_list_message":
        MessageLookupByLibrary.simpleMessage(
          "No history :c\nStart reading manga to see your history here",
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
      "Manga",
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
    "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
    "chapter_translation_cancel": MessageLookupByLibrary.simpleMessage(
      "Stop translating",
    ),
    "chapter_translation_cancel_all": MessageLookupByLibrary.simpleMessage(
      "Cancel all",
    ),
    "chapter_translation_done": MessageLookupByLibrary.simpleMessage(
      "Translated",
    ),
    "chapter_translation_done_partial": m1,
    "chapter_translation_failed": MessageLookupByLibrary.simpleMessage(
      "Translation failed",
    ),
    "chapter_translation_notification_channel":
        MessageLookupByLibrary.simpleMessage("Chapter translation"),
    "chapter_translation_notification_done_body": m2,
    "chapter_translation_notification_done_title":
        MessageLookupByLibrary.simpleMessage("Translation finished"),
    "chapter_translation_notification_paused":
        MessageLookupByLibrary.simpleMessage("Paused"),
    "chapter_translation_notification_remaining": m3,
    "chapter_translation_pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "chapter_translation_preparing": MessageLookupByLibrary.simpleMessage(
      "Preparing translation…",
    ),
    "chapter_translation_progress": m4,
    "chapter_translation_queue_title": MessageLookupByLibrary.simpleMessage(
      "Translation queue",
    ),
    "chapter_translation_queued": m5,
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
    "concrete_offline_banner": MessageLookupByLibrary.simpleMessage(
      "Offline — showing cached content. Only downloaded chapters can be opened.",
    ),
    "concrete_selection_clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "concrete_selection_count": m6,
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
    "concrete_selection_select_all": MessageLookupByLibrary.simpleMessage(
      "All",
    ),
    "concrete_selection_translate": MessageLookupByLibrary.simpleMessage(
      "Translate",
    ),
    "concrete_viewer_art_by": m7,
    "concrete_viewer_by_authors": m8,
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
    "deepl_key_masked": m9,
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
    "deepl_usage_characters": m10,
    "deepl_usage_left": m11,
    "deepl_usage_unavailable": MessageLookupByLibrary.simpleMessage(
      "Usage is unavailable right now",
    ),
    "deepl_usage_used": MessageLookupByLibrary.simpleMessage("used this month"),
    "download_speed_megabytes": m12,
    "download_time_left": m13,
    "downloads_chapters_summary": m14,
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
    "downloads_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Downloads",
    ),
    "downloads_notification_complete_body": m15,
    "downloads_notification_complete_title":
        MessageLookupByLibrary.simpleMessage("Download complete"),
    "downloads_notification_downloading_title":
        MessageLookupByLibrary.simpleMessage("Downloading"),
    "downloads_order_newest": MessageLookupByLibrary.simpleMessage(
      "Newest first",
    ),
    "downloads_order_oldest": MessageLookupByLibrary.simpleMessage(
      "Oldest first",
    ),
    "downloads_pages_progress": m16,
    "downloads_status_downloading": MessageLookupByLibrary.simpleMessage(
      "Downloading",
    ),
    "downloads_status_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "downloads_status_queued": MessageLookupByLibrary.simpleMessage("Queued"),
    "downloads_title": MessageLookupByLibrary.simpleMessage("Downloads"),
    "duration_hours_minutes": m17,
    "duration_minutes": m18,
    "duration_seconds": m19,
    "engine_tag_best": MessageLookupByLibrary.simpleMessage("Best quality"),
    "engine_tag_fast": MessageLookupByLibrary.simpleMessage("Fast"),
    "engine_tag_literal": MessageLookupByLibrary.simpleMessage("Literal"),
    "engine_tag_natural": MessageLookupByLibrary.simpleMessage("Natural"),
    "engine_tag_offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "engine_tag_online": MessageLookupByLibrary.simpleMessage("Online"),
    "engine_tag_size": m20,
    "engine_tag_speed_e2b": MessageLookupByLibrary.simpleMessage(
      "≈4–10 s per page",
    ),
    "engine_tag_speed_e4b": MessageLookupByLibrary.simpleMessage(
      "≈20–45 s per page",
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
      "Theme, reader mode and toggles",
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
    "gallery_filters_apply_button": MessageLookupByLibrary.simpleMessage(
      "Apply",
    ),
    "gallery_filters_apply_button_count": m21,
    "gallery_filters_button_label": MessageLookupByLibrary.simpleMessage(
      "Filters",
    ),
    "gallery_filters_more_options": m22,
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
    "gallery_in_library": MessageLookupByLibrary.simpleMessage("In library"),
    "gallery_last_opened": m23,
    "gallery_layout_button_tooltip": m24,
    "gallery_layout_comfortable": MessageLookupByLibrary.simpleMessage(
      "Comfortable grid",
    ),
    "gallery_layout_compact": MessageLookupByLibrary.simpleMessage(
      "Compact grid",
    ),
    "gallery_layout_list": MessageLookupByLibrary.simpleMessage("List"),
    "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Anime"),
    "home_configs_source_initializing_error": m25,
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
    "home_nsfw_suffix": MessageLookupByLibrary.simpleMessage("NSFW"),
    "home_remote_configs_page_appbar_title":
        MessageLookupByLibrary.simpleMessage("Extensions"),
    "home_sources_button": MessageLookupByLibrary.simpleMessage("Sources"),
    "language_packs_available_section": MessageLookupByLibrary.simpleMessage(
      "Available",
    ),
    "language_packs_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "language_packs_downloaded_count": m26,
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
    "language_packs_queue_progress": m27,
    "language_packs_queued": m28,
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
    "library_delete_category": MessageLookupByLibrary.simpleMessage("Delete"),
    "library_download_first_group_hint": MessageLookupByLibrary.simpleMessage(
      "Each title downloads from its first chapter group",
    ),
    "library_download_many_failed": m29,
    "library_download_many_loading": m30,
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
    "library_search_no_results_message": m31,
    "library_search_no_results_title": MessageLookupByLibrary.simpleMessage(
      "No matches",
    ),
    "library_select_all": MessageLookupByLibrary.simpleMessage("Select all"),
    "library_selected_count": m32,
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
    "page_translation_ai_model_downloading": m33,
    "page_translation_ai_model_message": m34,
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
    "page_translation_glossary_count": m35,
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
    "page_translation_models_downloading_progress": m36,
    "page_translation_models_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t download language packs",
    ),
    "page_translation_models_message": m37,
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
    "page_translation_settings_clear_cache_subtitle": m38,
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
    "page_translation_settings_remove_outdated_subtitle": m39,
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
    "page_translation_status_chapter": m40,
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
    "page_translation_text_size_pixels": m41,
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
    "service_view_no_results_message": m42,
    "service_view_no_results_title": MessageLookupByLibrary.simpleMessage(
      "No results",
    ),
    "service_view_open_web_view_button_title":
        MessageLookupByLibrary.simpleMessage("Open in WebView"),
    "service_view_retry_button_title": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "service_view_search_results_for": m43,
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
    "settings_auto_backup_last": m44,
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
    "settings_download_latest_release": m45,
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
    "settings_import_skipped": m46,
    "settings_import_success": m47,
    "settings_local_extension_server_missing":
        MessageLookupByLibrary.simpleMessage(
          "Set LOCAL_REPOSITORY_URL in .env to enable",
        ),
    "settings_local_extension_server_subtitle": m48,
    "settings_local_extension_server_title":
        MessageLookupByLibrary.simpleMessage("Local extension server"),
    "settings_page_translation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Experimental · recognize and translate text on pages",
    ),
    "settings_page_translation_title": MessageLookupByLibrary.simpleMessage(
      "Page translation",
    ),
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
    "settings_transfer_notification_channel_name":
        MessageLookupByLibrary.simpleMessage("Import & export"),
    "settings_update_frequency": MessageLookupByLibrary.simpleMessage(
      "Check frequency",
    ),
    "settings_update_frequency_value": m49,
    "settings_update_notifications": MessageLookupByLibrary.simpleMessage(
      "Update notifications",
    ),
    "settings_update_notifications_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Show a notification when new items are found",
        ),
    "settings_updates_section": MessageLookupByLibrary.simpleMessage("Updates"),
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
    "stats_heatmap_week_count": m50,
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
    "stats_streak_summary": m51,
    "stats_title": MessageLookupByLibrary.simpleMessage("Statistics"),
    "title_download": MessageLookupByLibrary.simpleMessage("Download"),
    "title_download_all": MessageLookupByLibrary.simpleMessage("All chapters"),
    "title_download_chapter_count": m52,
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
    "title_download_next_count": m53,
    "title_download_no_chapters": MessageLookupByLibrary.simpleMessage(
      "This title has no chapters yet",
    ),
    "title_download_nothing": MessageLookupByLibrary.simpleMessage(
      "No new chapters to download",
    ),
    "title_download_queued": m54,
    "title_download_title": MessageLookupByLibrary.simpleMessage(
      "Download chapters",
    ),
    "title_download_unread": MessageLookupByLibrary.simpleMessage(
      "Unread chapters",
    ),
    "title_download_untitled_group": m55,
    "translation_ai_model_delete_message": m56,
    "translation_ai_model_delete_title": MessageLookupByLibrary.simpleMessage(
      "Delete the AI model?",
    ),
    "translation_ai_model_failed": MessageLookupByLibrary.simpleMessage(
      "Download failed · try again on Wi-Fi",
    ),
    "translation_ai_model_installed": m57,
    "translation_ai_model_missing": m58,
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
    "translation_engine_gemma_unavailable_ram": m59,
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
    "translation_engine_info_this_phone": m60,
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
    "translation_engine_req_ram_model": m61,
    "translation_engine_req_storage_model": m62,
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
    "translation_models_downloaded": m63,
    "translation_models_packs_count": m64,
    "translation_models_packs_section": MessageLookupByLibrary.simpleMessage(
      "ML Kit",
    ),
    "translation_models_pick_first": m65,
    "translation_models_summary": m66,
    "translation_models_title": MessageLookupByLibrary.simpleMessage(
      "Downloaded models",
    ),
    "translation_models_unsupported": MessageLookupByLibrary.simpleMessage(
      "Not supported on this phone",
    ),
    "updates_check_failed": m67,
    "updates_check_found": m68,
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
    "updates_notification_line": m69,
    "updates_notification_more": m70,
    "updates_notification_summary": m71,
    "updates_notification_title": m72,
    "updates_time_days": m73,
    "updates_time_hours": m74,
    "updates_time_minutes": m75,
    "updates_time_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "updates_title": MessageLookupByLibrary.simpleMessage("Updates"),
    "web_browser_no_login_button": MessageLookupByLibrary.simpleMessage("Done"),
  };
}
