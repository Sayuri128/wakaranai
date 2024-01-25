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

  static String m0(name) =>
      "Error occurred during initializing configs ${name} source";

  static String m1(version) => "New version ${version} available";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
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
        "chapter_viewer_webtoon":
            MessageLookupByLibrary.simpleMessage("Webtoon"),
        "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Anime"),
        "home_configs_source_initializing_error": m0,
        "home_fetching_mangas_configs_error":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during fetching manga configs"),
        "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Manga"),
        "home_navigation_bar_settings_title":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "home_navigation_bar_sources_title":
            MessageLookupByLibrary.simpleMessage("Explore"),
        "home_nsfw_suffix": MessageLookupByLibrary.simpleMessage("NSFW"),
        "home_remote_configs_page_appbar_title":
            MessageLookupByLibrary.simpleMessage("Extensions"),
        "service_view_error": MessageLookupByLibrary.simpleMessage("Error :c"),
        "service_view_open_web_view_button_title":
            MessageLookupByLibrary.simpleMessage("Open in WebView"),
        "service_view_retry_button_title":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "service_viewer_search_field_hint_text":
            MessageLookupByLibrary.simpleMessage("Search"),
        "settings_clear_cookies_cache":
            MessageLookupByLibrary.simpleMessage("Clear cookies cache"),
        "settings_clear_cookies_cache_dialog_confirmation_cancel_label":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "settings_clear_cookies_cache_dialog_confirmation_message":
            MessageLookupByLibrary.simpleMessage(
                "This action cannot be canceled later"),
        "settings_clear_cookies_cache_dialog_confirmation_ok_label":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "settings_clear_cookies_cache_dialog_confirmation_title":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to clear your cookies?"),
        "settings_clear_cookies_dialog_success":
            MessageLookupByLibrary.simpleMessage("Cookies has been cleared"),
        "settings_clear_history_title":
            MessageLookupByLibrary.simpleMessage("Clear history"),
        "settings_default_reader_mode_title":
            MessageLookupByLibrary.simpleMessage("Default reader mode"),
        "settings_download_latest_release": m1,
        "settings_service_viewer_filters_title":
            MessageLookupByLibrary.simpleMessage("Filters"),
        "settings_submit_issue": MessageLookupByLibrary.simpleMessage(
            "Submit issue/feature request/extension request"),
        "web_browser_no_login_button":
            MessageLookupByLibrary.simpleMessage("Done")
      };
}
