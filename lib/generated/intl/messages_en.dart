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

  static String m1(name) => "Are you sure you want to delete ${name} source?";

  static String m2(date) => "Last visit: ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_new_configs_source_button":
            MessageLookupByLibrary.simpleMessage("Add"),
        "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
        "change_configs_source_dialog":
            MessageLookupByLibrary.simpleMessage("Change configs source"),
        "clear_cookies_cache":
            MessageLookupByLibrary.simpleMessage("Clear cookies cache"),
        "clear_cookies_cache_dialog_confirmation_cancel_label":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "clear_cookies_cache_dialog_confirmation_message":
            MessageLookupByLibrary.simpleMessage(
                "This action cannot be canceled later"),
        "clear_cookies_cache_dialog_confirmation_ok_label":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "clear_cookies_cache_dialog_confirmation_title":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to clear your cookies?"),
        "clear_cookies_dialog_success":
            MessageLookupByLibrary.simpleMessage("Cookies has been cleared"),
        "clear_history_dialog_confirmation_cancel_label":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "clear_history_dialog_confirmation_message":
            MessageLookupByLibrary.simpleMessage(
                "This action cannot be canceled later"),
        "clear_history_dialog_confirmation_ok_label":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "clear_history_dialog_confirmation_title":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to clear your history?"),
        "clear_history_dialog_success":
            MessageLookupByLibrary.simpleMessage("History has been cleared"),
        "configs_source_initializing_error": m0,
        "create_new_configs_source_button":
            MessageLookupByLibrary.simpleMessage("Create"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_configs_source_confirmation_dialog_message": m1,
        "delete_configs_source_confirmation_dialog_title":
            MessageLookupByLibrary.simpleMessage("Confirmation"),
        "download_again":
            MessageLookupByLibrary.simpleMessage("Download again"),
        "fetching_mangas_configs_error": MessageLookupByLibrary.simpleMessage(
            "Error occurred during fetching manga configs"),
        "github_configs_source_type":
            MessageLookupByLibrary.simpleMessage("GitHub"),
        "history_last_visit": m2,
        "history_page_title": MessageLookupByLibrary.simpleMessage("History"),
        "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Manga"),
        "left_to_right_read_mode":
            MessageLookupByLibrary.simpleMessage("Left to right"),
        "navigation_bar_history_title":
            MessageLookupByLibrary.simpleMessage("History"),
        "navigation_bar_settings_title":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "navigation_bar_sources_title":
            MessageLookupByLibrary.simpleMessage("Source"),
        "new_configs_base_url_field_label":
            MessageLookupByLibrary.simpleMessage("URL"),
        "new_configs_base_url_required_error":
            MessageLookupByLibrary.simpleMessage("Base URL is required"),
        "new_configs_name_field_label":
            MessageLookupByLibrary.simpleMessage("Name"),
        "new_configs_name_required_error":
            MessageLookupByLibrary.simpleMessage("Name is required"),
        "official_github_configs_source_repository":
            MessageLookupByLibrary.simpleMessage("Wakaranai GitHub"),
        "rest_configs_source_type":
            MessageLookupByLibrary.simpleMessage("REST"),
        "right_to_left_read_mode":
            MessageLookupByLibrary.simpleMessage("Right to left"),
        "service_view_error": MessageLookupByLibrary.simpleMessage("Error :c"),
        "service_view_open_web_view_button_title":
            MessageLookupByLibrary.simpleMessage("Open in WebView"),
        "service_view_retry_button_title":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "service_viewer_filters_title":
            MessageLookupByLibrary.simpleMessage("Filters"),
        "service_viewer_search_field_hint_text":
            MessageLookupByLibrary.simpleMessage("Search"),
        "settings_clear_history_title":
            MessageLookupByLibrary.simpleMessage("Clear history"),
        "settings_default_reader_mode_title":
            MessageLookupByLibrary.simpleMessage("Default reader mode"),
        "web_browser_no_login_button": MessageLookupByLibrary.simpleMessage(
            "Click once the page is loaded"),
        "webtoon": MessageLookupByLibrary.simpleMessage("Webtoon")
      };
}
