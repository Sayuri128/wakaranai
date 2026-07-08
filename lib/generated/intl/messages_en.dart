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

  static String m1(count) => "${count} selected";

  static String m2(done, total) => "${done}/${total} pages";

  static String m3(name) =>
      "Error occurred during initializing configs ${name} source";

  static String m4(count) => "${count} selected";

  static String m5(query) => "We couldn\'t find anything for “${query}”";

  static String m6(query) => "Results for “${query}”";

  static String m7(version) => "New version ${version} available";

  static String m8(IMPORTED, TOTAL) =>
      "Activity history imported ${IMPORTED} out of ${TOTAL} activities";

  static String m9(count) => "${count} activities";

  static String m10(current, longest) =>
      "Current ${current} · Longest ${longest}";

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
    "chapter_viewer_webtoon": MessageLookupByLibrary.simpleMessage("Webtoon"),
    "common_add": MessageLookupByLibrary.simpleMessage("Add"),
    "common_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "common_ok_button": MessageLookupByLibrary.simpleMessage("OK"),
    "common_save": MessageLookupByLibrary.simpleMessage("Save"),
    "concrete_offline_banner": MessageLookupByLibrary.simpleMessage(
      "Offline — showing cached content. Only downloaded chapters can be opened.",
    ),
    "concrete_selection_clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "concrete_selection_count": m1,
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
    "concrete_viewer_retry_button": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
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
    "downloads_pages_progress": m2,
    "downloads_status_downloading": MessageLookupByLibrary.simpleMessage(
      "Downloading",
    ),
    "downloads_status_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "downloads_status_queued": MessageLookupByLibrary.simpleMessage("Queued"),
    "downloads_title": MessageLookupByLibrary.simpleMessage("Downloads"),
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
    "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Anime"),
    "home_configs_source_initializing_error": m3,
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
    "library_add_category": MessageLookupByLibrary.simpleMessage(
      "Add category",
    ),
    "library_category_all": MessageLookupByLibrary.simpleMessage("All"),
    "library_category_name_hint": MessageLookupByLibrary.simpleMessage(
      "Category name",
    ),
    "library_category_uncategorized": MessageLookupByLibrary.simpleMessage(
      "Uncategorized",
    ),
    "library_delete_category": MessageLookupByLibrary.simpleMessage("Delete"),
    "library_empty_message": MessageLookupByLibrary.simpleMessage(
      "Tap the heart on a title to add it here",
    ),
    "library_empty_title": MessageLookupByLibrary.simpleMessage(
      "Your library is empty",
    ),
    "library_manage_categories": MessageLookupByLibrary.simpleMessage(
      "Manage categories",
    ),
    "library_move_to_category": MessageLookupByLibrary.simpleMessage(
      "Move to category",
    ),
    "library_no_category": MessageLookupByLibrary.simpleMessage("No category"),
    "library_remove": MessageLookupByLibrary.simpleMessage(
      "Remove from library",
    ),
    "library_rename_category": MessageLookupByLibrary.simpleMessage("Rename"),
    "library_select_all": MessageLookupByLibrary.simpleMessage("Select all"),
    "library_selected_count": m4,
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
    "service_view_no_results_message": m5,
    "service_view_no_results_title": MessageLookupByLibrary.simpleMessage(
      "No results",
    ),
    "service_view_open_web_view_button_title":
        MessageLookupByLibrary.simpleMessage("Open in WebView"),
    "service_view_retry_button_title": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "service_view_search_results_for": m6,
    "service_viewer_search_field_hint_text":
        MessageLookupByLibrary.simpleMessage("Search"),
    "settings_about_section_title": MessageLookupByLibrary.simpleMessage(
      "About",
    ),
    "settings_appearance_section_title": MessageLookupByLibrary.simpleMessage(
      "Appearance",
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
    "settings_download_latest_release": m7,
    "settings_downloads_subtitle": MessageLookupByLibrary.simpleMessage(
      "Manage downloaded chapters",
    ),
    "settings_downloads_title": MessageLookupByLibrary.simpleMessage(
      "Downloads",
    ),
    "settings_export_activity_history_button":
        MessageLookupByLibrary.simpleMessage("Export activity history"),
    "settings_export_activity_history_error":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during exporting activity history",
        ),
    "settings_export_activity_history_success":
        MessageLookupByLibrary.simpleMessage(
          "Activity history exported successfully",
        ),
    "settings_import_activity_history_button":
        MessageLookupByLibrary.simpleMessage("Import activity history"),
    "settings_import_activity_history_error":
        MessageLookupByLibrary.simpleMessage(
          "Error occurred during importing activity history",
        ),
    "settings_import_activity_history_success": m8,
    "settings_import_export_info_export_body": MessageLookupByLibrary.simpleMessage(
      "Saves all your manga and anime reading history into a single JSON file that you can back up or move to another device.",
    ),
    "settings_import_export_info_export_title":
        MessageLookupByLibrary.simpleMessage("Export"),
    "settings_import_export_info_import_body": MessageLookupByLibrary.simpleMessage(
      "Loads history from a previously exported JSON file and merges it with what you already have — existing entries are updated and new ones are added, nothing is deleted.",
    ),
    "settings_import_export_info_import_title":
        MessageLookupByLibrary.simpleMessage("Import"),
    "settings_import_export_info_title": MessageLookupByLibrary.simpleMessage(
      "Import & export",
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
    "settings_storage_section_title": MessageLookupByLibrary.simpleMessage(
      "Storage",
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
    "stats_heatmap_week_count": m9,
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
    "stats_streak_summary": m10,
    "stats_title": MessageLookupByLibrary.simpleMessage("Statistics"),
    "web_browser_no_login_button": MessageLookupByLibrary.simpleMessage("Done"),
  };
}
