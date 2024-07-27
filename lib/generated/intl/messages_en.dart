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

  static String m1(name) =>
      "Error occurred during initializing configs ${name} source";

  static String m2(version) => "New version ${version} available";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activity_history_anime_appbar_title":
            MessageLookupByLibrary.simpleMessage("Anime"),
        "activity_history_deleted_activity":
            MessageLookupByLibrary.simpleMessage(
                "Deleted activity successfully"),
        "activity_history_empty_anime_list_message":
            MessageLookupByLibrary.simpleMessage(
                "No history :c\nStart watching anime to see your history here"),
        "activity_history_empty_manga_list_message":
            MessageLookupByLibrary.simpleMessage(
                "No history :c\nStart reading manga to see your history here"),
        "activity_history_error_loading_extension":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during loading extension"),
        "activity_history_error_loading_history":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during loading history"),
        "activity_history_long_tap_dialog_delete_button":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "activity_history_manga_appbar_title":
            MessageLookupByLibrary.simpleMessage("Manga"),
        "add_extension_source_page_add_button_title":
            MessageLookupByLibrary.simpleMessage("Save"),
        "add_extension_source_page_appbar_edit_title":
            MessageLookupByLibrary.simpleMessage("Edit Source"),
        "add_extension_source_page_appbar_title":
            MessageLookupByLibrary.simpleMessage("Add Source"),
        "add_extension_source_page_name_field_error_text":
            MessageLookupByLibrary.simpleMessage("Invalid name"),
        "add_extension_source_page_name_field_hint_text":
            MessageLookupByLibrary.simpleMessage(
                "Wakaranai configs repository"),
        "add_extension_source_page_name_field_label":
            MessageLookupByLibrary.simpleMessage("Name"),
        "add_extension_source_page_update_button_title":
            MessageLookupByLibrary.simpleMessage("Update"),
        "add_extension_source_page_url_field_error_text":
            MessageLookupByLibrary.simpleMessage("Invalid URL"),
        "add_extension_source_page_url_field_hint_text":
            MessageLookupByLibrary.simpleMessage(
                "https://github.com/username/repository"),
        "add_extension_source_page_url_field_label":
            MessageLookupByLibrary.simpleMessage("URL"),
        "anime_concrete_viewer_watched_at_title": m0,
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
        "extension_source_page_error_adding_source":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during adding source"),
        "extension_source_page_error_removing_source":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during removing source"),
        "extension_source_page_error_updating_source":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during updating source"),
        "extension_source_page_remove_source_dialog_cancel_label":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "extension_source_page_remove_source_dialog_message":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to remove this source?"),
        "extension_source_page_remove_source_dialog_ok_label":
            MessageLookupByLibrary.simpleMessage("Remove"),
        "extension_source_page_remove_source_dialog_title":
            MessageLookupByLibrary.simpleMessage("Remove source"),
        "extension_sources_page_appbar_title":
            MessageLookupByLibrary.simpleMessage("Repositories"),
        "extension_sources_page_error_loading_sources":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during loading sources"),
        "extension_sources_page_wakaranai_github_repo_title":
            MessageLookupByLibrary.simpleMessage("Wakaranai Extensions"),
        "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Anime"),
        "home_configs_source_initializing_error": m1,
        "home_fetching_mangas_configs_error":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during fetching manga configs"),
        "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Manga"),
        "home_navigation_bar_activity_history_title":
            MessageLookupByLibrary.simpleMessage("History"),
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
        "settings_clear_activity_history":
            MessageLookupByLibrary.simpleMessage("Clear activity history"),
        "settings_clear_activity_history_dialog_confirmation_cancel_label":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "settings_clear_activity_history_dialog_confirmation_message":
            MessageLookupByLibrary.simpleMessage(
                "This action cannot be canceled later"),
        "settings_clear_activity_history_dialog_confirmation_ok_label":
            MessageLookupByLibrary.simpleMessage("Delete"),
        "settings_clear_activity_history_dialog_confirmation_title":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to clear your history?"),
        "settings_clear_activity_history_dialog_error":
            MessageLookupByLibrary.simpleMessage(
                "Error occurred during clearing history"),
        "settings_clear_activity_history_dialog_success":
            MessageLookupByLibrary.simpleMessage("History has been cleared"),
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
        "settings_download_latest_release": m2,
        "settings_service_viewer_filters_title":
            MessageLookupByLibrary.simpleMessage("Filters"),
        "settings_submit_issue": MessageLookupByLibrary.simpleMessage(
            "Submit issue/feature request/extension request"),
        "web_browser_no_login_button":
            MessageLookupByLibrary.simpleMessage("Done")
      };
}
