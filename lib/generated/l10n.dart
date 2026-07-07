// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Wakaranai`
  String get app_name {
    return Intl.message('Wakaranai', name: 'app_name', desc: '', args: []);
  }

  /// `OK`
  String get common_ok_button {
    return Intl.message('OK', name: 'common_ok_button', desc: '', args: []);
  }

  /// `Manga`
  String get home_manga_group_title {
    return Intl.message(
      'Manga',
      name: 'home_manga_group_title',
      desc: '',
      args: [],
    );
  }

  /// `Anime`
  String get home_anime_group_title {
    return Intl.message(
      'Anime',
      name: 'home_anime_group_title',
      desc: '',
      args: [],
    );
  }

  /// `NSFW`
  String get home_nsfw_suffix {
    return Intl.message('NSFW', name: 'home_nsfw_suffix', desc: '', args: []);
  }

  /// `Extensions`
  String get home_remote_configs_page_appbar_title {
    return Intl.message(
      'Extensions',
      name: 'home_remote_configs_page_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Sources`
  String get home_sources_button {
    return Intl.message(
      'Sources',
      name: 'home_sources_button',
      desc: '',
      args: [],
    );
  }

  /// `No extensions`
  String get home_no_extensions_title {
    return Intl.message(
      'No extensions',
      name: 'home_no_extensions_title',
      desc: '',
      args: [],
    );
  }

  /// `This source doesn't have any extensions yet`
  String get home_no_extensions_message {
    return Intl.message(
      'This source doesn\'t have any extensions yet',
      name: 'home_no_extensions_message',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load extensions`
  String get home_extensions_error_title {
    return Intl.message(
      'Couldn\'t load extensions',
      name: 'home_extensions_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get home_navigation_bar_sources_title {
    return Intl.message(
      'Explore',
      name: 'home_navigation_bar_sources_title',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get home_navigation_bar_activity_history_title {
    return Intl.message(
      'History',
      name: 'home_navigation_bar_activity_history_title',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get home_navigation_bar_settings_title {
    return Intl.message(
      'Settings',
      name: 'home_navigation_bar_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during fetching manga configs`
  String get home_fetching_mangas_configs_error {
    return Intl.message(
      'Error occurred during fetching manga configs',
      name: 'home_fetching_mangas_configs_error',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during initializing configs {name} source`
  String home_configs_source_initializing_error(Object name) {
    return Intl.message(
      'Error occurred during initializing configs $name source',
      name: 'home_configs_source_initializing_error',
      desc: '',
      args: [name],
    );
  }

  /// `Repositories`
  String get extension_sources_page_appbar_title {
    return Intl.message(
      'Repositories',
      name: 'extension_sources_page_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get extension_sources_page_default_badge {
    return Intl.message(
      'Default',
      name: 'extension_sources_page_default_badge',
      desc: '',
      args: [],
    );
  }

  /// `Wakaranai Extensions`
  String get extension_sources_page_wakaranai_github_repo_title {
    return Intl.message(
      'Wakaranai Extensions',
      name: 'extension_sources_page_wakaranai_github_repo_title',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during loading sources`
  String get extension_sources_page_error_loading_sources {
    return Intl.message(
      'Error occurred during loading sources',
      name: 'extension_sources_page_error_loading_sources',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during adding source`
  String get extension_source_page_error_adding_source {
    return Intl.message(
      'Error occurred during adding source',
      name: 'extension_source_page_error_adding_source',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during updating source`
  String get extension_source_page_error_updating_source {
    return Intl.message(
      'Error occurred during updating source',
      name: 'extension_source_page_error_updating_source',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during removing source`
  String get extension_source_page_error_removing_source {
    return Intl.message(
      'Error occurred during removing source',
      name: 'extension_source_page_error_removing_source',
      desc: '',
      args: [],
    );
  }

  /// `Remove source`
  String get extension_source_page_remove_source_dialog_title {
    return Intl.message(
      'Remove source',
      name: 'extension_source_page_remove_source_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this source?`
  String get extension_source_page_remove_source_dialog_message {
    return Intl.message(
      'Are you sure you want to remove this source?',
      name: 'extension_source_page_remove_source_dialog_message',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get extension_source_page_remove_source_dialog_ok_label {
    return Intl.message(
      'Remove',
      name: 'extension_source_page_remove_source_dialog_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get extension_source_page_remove_source_dialog_cancel_label {
    return Intl.message(
      'Cancel',
      name: 'extension_source_page_remove_source_dialog_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `Add a GitHub repository that hosts Wakaranai extensions.`
  String get add_extension_source_page_description {
    return Intl.message(
      'Add a GitHub repository that hosts Wakaranai extensions.',
      name: 'add_extension_source_page_description',
      desc: '',
      args: [],
    );
  }

  /// `Add Source`
  String get add_extension_source_page_appbar_title {
    return Intl.message(
      'Add Source',
      name: 'add_extension_source_page_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit Source`
  String get add_extension_source_page_appbar_edit_title {
    return Intl.message(
      'Edit Source',
      name: 'add_extension_source_page_appbar_edit_title',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get add_extension_source_page_url_field_label {
    return Intl.message(
      'URL',
      name: 'add_extension_source_page_url_field_label',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/username/repository`
  String get add_extension_source_page_url_field_hint_text {
    return Intl.message(
      'https://github.com/username/repository',
      name: 'add_extension_source_page_url_field_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL`
  String get add_extension_source_page_url_field_error_text {
    return Intl.message(
      'Invalid URL',
      name: 'add_extension_source_page_url_field_error_text',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get add_extension_source_page_name_field_label {
    return Intl.message(
      'Name',
      name: 'add_extension_source_page_name_field_label',
      desc: '',
      args: [],
    );
  }

  /// `Wakaranai configs repository`
  String get add_extension_source_page_name_field_hint_text {
    return Intl.message(
      'Wakaranai configs repository',
      name: 'add_extension_source_page_name_field_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `Invalid name`
  String get add_extension_source_page_name_field_error_text {
    return Intl.message(
      'Invalid name',
      name: 'add_extension_source_page_name_field_error_text',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get add_extension_source_page_add_button_title {
    return Intl.message(
      'Save',
      name: 'add_extension_source_page_add_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get add_extension_source_page_update_button_title {
    return Intl.message(
      'Update',
      name: 'add_extension_source_page_update_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Error :c`
  String get service_view_error {
    return Intl.message(
      'Error :c',
      name: 'service_view_error',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get service_view_retry_button_title {
    return Intl.message(
      'Retry',
      name: 'service_view_retry_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Open in WebView`
  String get service_view_open_web_view_button_title {
    return Intl.message(
      'Open in WebView',
      name: 'service_view_open_web_view_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get service_viewer_search_field_hint_text {
    return Intl.message(
      'Search',
      name: 'service_viewer_search_field_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get service_view_error_title {
    return Intl.message(
      'Something went wrong',
      name: 'service_view_error_title',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get service_view_no_results_title {
    return Intl.message(
      'No results',
      name: 'service_view_no_results_title',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't find anything for “{query}”`
  String service_view_no_results_message(Object query) {
    return Intl.message(
      'We couldn\'t find anything for “$query”',
      name: 'service_view_no_results_message',
      desc: '',
      args: [query],
    );
  }

  /// `Nothing here yet`
  String get service_view_empty_title {
    return Intl.message(
      'Nothing here yet',
      name: 'service_view_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to refresh`
  String get service_view_empty_message {
    return Intl.message(
      'Pull down to refresh',
      name: 'service_view_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Results for “{query}”`
  String service_view_search_results_for(Object query) {
    return Intl.message(
      'Results for “$query”',
      name: 'service_view_search_results_for',
      desc: '',
      args: [query],
    );
  }

  /// `Clear`
  String get service_view_clear_search {
    return Intl.message(
      'Clear',
      name: 'service_view_clear_search',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get chapter_viewer_next_chapter_button_title {
    return Intl.message(
      'Next',
      name: 'chapter_viewer_next_chapter_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get chapter_viewer_previous_chapter_button_title {
    return Intl.message(
      'Previous',
      name: 'chapter_viewer_previous_chapter_button_title',
      desc: '',
      args: [],
    );
  }

  /// `Reading Mode`
  String get chapter_viewer_bottom_modal_settings_reading_mode_title {
    return Intl.message(
      'Reading Mode',
      name: 'chapter_viewer_bottom_modal_settings_reading_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `Enable tap controls`
  String get chapter_viewer_bottom_modal_settings_tap_controls {
    return Intl.message(
      'Enable tap controls',
      name: 'chapter_viewer_bottom_modal_settings_tap_controls',
      desc: '',
      args: [],
    );
  }

  /// `Right to left`
  String get chapter_viewer_right_to_left_read_mode {
    return Intl.message(
      'Right to left',
      name: 'chapter_viewer_right_to_left_read_mode',
      desc: '',
      args: [],
    );
  }

  /// `Left to right`
  String get chapter_viewer_left_to_right_read_mode {
    return Intl.message(
      'Left to right',
      name: 'chapter_viewer_left_to_right_read_mode',
      desc: '',
      args: [],
    );
  }

  /// `Webtoon`
  String get chapter_viewer_webtoon {
    return Intl.message(
      'Webtoon',
      name: 'chapter_viewer_webtoon',
      desc: '',
      args: [],
    );
  }

  /// `New version {version} available`
  String settings_download_latest_release(Object version) {
    return Intl.message(
      'New version $version available',
      name: 'settings_download_latest_release',
      desc: '',
      args: [version],
    );
  }

  /// `Default reader mode`
  String get settings_default_reader_mode_title {
    return Intl.message(
      'Default reader mode',
      name: 'settings_default_reader_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `Reader`
  String get settings_reader_section_title {
    return Intl.message(
      'Reader',
      name: 'settings_reader_section_title',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settings_about_section_title {
    return Intl.message(
      'About',
      name: 'settings_about_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Clear history`
  String get settings_clear_history_title {
    return Intl.message(
      'Clear history',
      name: 'settings_clear_history_title',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get settings_service_viewer_filters_title {
    return Intl.message(
      'Filters',
      name: 'settings_service_viewer_filters_title',
      desc: '',
      args: [],
    );
  }

  /// `Cookies has been cleared`
  String get settings_clear_cookies_dialog_success {
    return Intl.message(
      'Cookies has been cleared',
      name: 'settings_clear_cookies_dialog_success',
      desc: '',
      args: [],
    );
  }

  /// `Submit issue/feature request/extension request`
  String get settings_submit_issue {
    return Intl.message(
      'Submit issue/feature request/extension request',
      name: 'settings_submit_issue',
      desc: '',
      args: [],
    );
  }

  /// `Clear cookies cache`
  String get settings_clear_cookies_cache {
    return Intl.message(
      'Clear cookies cache',
      name: 'settings_clear_cookies_cache',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear your cookies?`
  String get settings_clear_cookies_cache_dialog_confirmation_title {
    return Intl.message(
      'Are you sure you want to clear your cookies?',
      name: 'settings_clear_cookies_cache_dialog_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be canceled later`
  String get settings_clear_cookies_cache_dialog_confirmation_message {
    return Intl.message(
      'This action cannot be canceled later',
      name: 'settings_clear_cookies_cache_dialog_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get settings_clear_cookies_cache_dialog_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'settings_clear_cookies_cache_dialog_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get settings_clear_cookies_cache_dialog_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name: 'settings_clear_cookies_cache_dialog_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `Clear activity history`
  String get settings_clear_activity_history {
    return Intl.message(
      'Clear activity history',
      name: 'settings_clear_activity_history',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear your history?`
  String get settings_clear_activity_history_dialog_confirmation_title {
    return Intl.message(
      'Are you sure you want to clear your history?',
      name: 'settings_clear_activity_history_dialog_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be canceled later`
  String get settings_clear_activity_history_dialog_confirmation_message {
    return Intl.message(
      'This action cannot be canceled later',
      name: 'settings_clear_activity_history_dialog_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get settings_clear_activity_history_dialog_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'settings_clear_activity_history_dialog_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get settings_clear_activity_history_dialog_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name: 'settings_clear_activity_history_dialog_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `History has been cleared`
  String get settings_clear_activity_history_dialog_success {
    return Intl.message(
      'History has been cleared',
      name: 'settings_clear_activity_history_dialog_success',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during clearing history`
  String get settings_clear_activity_history_dialog_error {
    return Intl.message(
      'Error occurred during clearing history',
      name: 'settings_clear_activity_history_dialog_error',
      desc: '',
      args: [],
    );
  }

  /// `Export activity history`
  String get settings_export_activity_history_button {
    return Intl.message(
      'Export activity history',
      name: 'settings_export_activity_history_button',
      desc: '',
      args: [],
    );
  }

  /// `Activity history exported successfully`
  String get settings_export_activity_history_success {
    return Intl.message(
      'Activity history exported successfully',
      name: 'settings_export_activity_history_success',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during exporting activity history`
  String get settings_export_activity_history_error {
    return Intl.message(
      'Error occurred during exporting activity history',
      name: 'settings_export_activity_history_error',
      desc: '',
      args: [],
    );
  }

  /// `Import & export`
  String get settings_import_export_info_title {
    return Intl.message(
      'Import & export',
      name: 'settings_import_export_info_title',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get settings_import_export_info_export_title {
    return Intl.message(
      'Export',
      name: 'settings_import_export_info_export_title',
      desc: '',
      args: [],
    );
  }

  /// `Saves all your manga and anime reading history into a single JSON file that you can back up or move to another device.`
  String get settings_import_export_info_export_body {
    return Intl.message(
      'Saves all your manga and anime reading history into a single JSON file that you can back up or move to another device.',
      name: 'settings_import_export_info_export_body',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get settings_import_export_info_import_title {
    return Intl.message(
      'Import',
      name: 'settings_import_export_info_import_title',
      desc: '',
      args: [],
    );
  }

  /// `Loads history from a previously exported JSON file and merges it with what you already have — existing entries are updated and new ones are added, nothing is deleted.`
  String get settings_import_export_info_import_body {
    return Intl.message(
      'Loads history from a previously exported JSON file and merges it with what you already have — existing entries are updated and new ones are added, nothing is deleted.',
      name: 'settings_import_export_info_import_body',
      desc: '',
      args: [],
    );
  }

  /// `Import activity history`
  String get settings_import_activity_history_button {
    return Intl.message(
      'Import activity history',
      name: 'settings_import_activity_history_button',
      desc: '',
      args: [],
    );
  }

  /// `Activity history imported {IMPORTED} out of {TOTAL} activities`
  String settings_import_activity_history_success(
    Object IMPORTED,
    Object TOTAL,
  ) {
    return Intl.message(
      'Activity history imported $IMPORTED out of $TOTAL activities',
      name: 'settings_import_activity_history_success',
      desc: '',
      args: [IMPORTED, TOTAL],
    );
  }

  /// `Error occurred during importing activity history`
  String get settings_import_activity_history_error {
    return Intl.message(
      'Error occurred during importing activity history',
      name: 'settings_import_activity_history_error',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get web_browser_no_login_button {
    return Intl.message(
      'Done',
      name: 'web_browser_no_login_button',
      desc: '',
      args: [],
    );
  }

  /// `Manga`
  String get activity_history_manga_appbar_title {
    return Intl.message(
      'Manga',
      name: 'activity_history_manga_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Anime`
  String get activity_history_anime_appbar_title {
    return Intl.message(
      'Anime',
      name: 'activity_history_anime_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during loading history`
  String get activity_history_error_loading_history {
    return Intl.message(
      'Error occurred during loading history',
      name: 'activity_history_error_loading_history',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during loading extension`
  String get activity_history_error_loading_extension {
    return Intl.message(
      'Error occurred during loading extension',
      name: 'activity_history_error_loading_extension',
      desc: '',
      args: [],
    );
  }

  /// `Deleted activity successfully`
  String get activity_history_deleted_activity {
    return Intl.message(
      'Deleted activity successfully',
      name: 'activity_history_deleted_activity',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get activity_history_long_tap_dialog_delete_button {
    return Intl.message(
      'Delete',
      name: 'activity_history_long_tap_dialog_delete_button',
      desc: '',
      args: [],
    );
  }

  /// `No history :c\nStart reading manga to see your history here`
  String get activity_history_empty_manga_list_message {
    return Intl.message(
      'No history :c\nStart reading manga to see your history here',
      name: 'activity_history_empty_manga_list_message',
      desc: '',
      args: [],
    );
  }

  /// `No history :c\nStart watching anime to see your history here`
  String get activity_history_empty_anime_list_message {
    return Intl.message(
      'No history :c\nStart watching anime to see your history here',
      name: 'activity_history_empty_anime_list_message',
      desc: '',
      args: [],
    );
  }

  /// `Watched at {time}`
  String anime_concrete_viewer_watched_at_title(Object time) {
    return Intl.message(
      'Watched at $time',
      name: 'anime_concrete_viewer_watched_at_title',
      desc: '',
      args: [time],
    );
  }

  /// `{count} selected`
  String concrete_selection_count(Object count) {
    return Intl.message(
      '$count selected',
      name: 'concrete_selection_count',
      desc: '',
      args: [count],
    );
  }

  /// `Read`
  String get concrete_selection_mark_read {
    return Intl.message(
      'Read',
      name: 'concrete_selection_mark_read',
      desc: '',
      args: [],
    );
  }

  /// `Unread`
  String get concrete_selection_mark_unread {
    return Intl.message(
      'Unread',
      name: 'concrete_selection_mark_unread',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get concrete_selection_select_all {
    return Intl.message(
      'All',
      name: 'concrete_selection_select_all',
      desc: '',
      args: [],
    );
  }

  /// `Invert`
  String get concrete_selection_invert {
    return Intl.message(
      'Invert',
      name: 'concrete_selection_invert',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get concrete_selection_clear {
    return Intl.message(
      'Clear',
      name: 'concrete_selection_clear',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
