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

  /// `Image`
  String get save_image_sheet_title {
    return Intl.message(
      'Image',
      name: 'save_image_sheet_title',
      desc: '',
      args: [],
    );
  }

  /// `Save as…`
  String get save_image_save_button {
    return Intl.message(
      'Save as…',
      name: 'save_image_save_button',
      desc: '',
      args: [],
    );
  }

  /// `Image saved`
  String get save_image_success {
    return Intl.message(
      'Image saved',
      name: 'save_image_success',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't save image`
  String get save_image_error {
    return Intl.message(
      'Couldn\'t save image',
      name: 'save_image_error',
      desc: '',
      args: [],
    );
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

  /// `Library`
  String get home_navigation_bar_library_title {
    return Intl.message(
      'Library',
      name: 'home_navigation_bar_library_title',
      desc: '',
      args: [],
    );
  }

  /// `Your library is empty`
  String get library_empty_title {
    return Intl.message(
      'Your library is empty',
      name: 'library_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Tap the heart on a title to add it here`
  String get library_empty_message {
    return Intl.message(
      'Tap the heart on a title to add it here',
      name: 'library_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get library_category_all {
    return Intl.message(
      'All',
      name: 'library_category_all',
      desc: '',
      args: [],
    );
  }

  /// `Uncategorized`
  String get library_category_uncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'library_category_uncategorized',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get library_sort_title {
    return Intl.message(
      'Sort by',
      name: 'library_sort_title',
      desc: '',
      args: [],
    );
  }

  /// `Recently added`
  String get library_sort_added_newest {
    return Intl.message(
      'Recently added',
      name: 'library_sort_added_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest added`
  String get library_sort_added_oldest {
    return Intl.message(
      'Oldest added',
      name: 'library_sort_added_oldest',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get library_sort_alphabetical {
    return Intl.message(
      'Title',
      name: 'library_sort_alphabetical',
      desc: '',
      args: [],
    );
  }

  /// `Last read`
  String get library_sort_last_read {
    return Intl.message(
      'Last read',
      name: 'library_sort_last_read',
      desc: '',
      args: [],
    );
  }

  /// `Manage categories`
  String get library_manage_categories {
    return Intl.message(
      'Manage categories',
      name: 'library_manage_categories',
      desc: '',
      args: [],
    );
  }

  /// `Add category`
  String get library_add_category {
    return Intl.message(
      'Add category',
      name: 'library_add_category',
      desc: '',
      args: [],
    );
  }

  /// `Category name`
  String get library_category_name_hint {
    return Intl.message(
      'Category name',
      name: 'library_category_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get library_rename_category {
    return Intl.message(
      'Rename',
      name: 'library_rename_category',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get library_delete_category {
    return Intl.message(
      'Delete',
      name: 'library_delete_category',
      desc: '',
      args: [],
    );
  }

  /// `Move to category`
  String get library_move_to_category {
    return Intl.message(
      'Move to category',
      name: 'library_move_to_category',
      desc: '',
      args: [],
    );
  }

  /// `Remove from library`
  String get library_remove {
    return Intl.message(
      'Remove from library',
      name: 'library_remove',
      desc: '',
      args: [],
    );
  }

  /// `No category`
  String get library_no_category {
    return Intl.message(
      'No category',
      name: 'library_no_category',
      desc: '',
      args: [],
    );
  }

  /// `Source unavailable`
  String get library_source_unavailable_title {
    return Intl.message(
      'Source unavailable',
      name: 'library_source_unavailable_title',
      desc: '',
      args: [],
    );
  }

  /// `The extension for this title is no longer installed`
  String get library_source_unavailable_message {
    return Intl.message(
      'The extension for this title is no longer installed',
      name: 'library_source_unavailable_message',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String library_selected_count(int count) {
    return Intl.message(
      '$count selected',
      name: 'library_selected_count',
      desc: '',
      args: [count],
    );
  }

  /// `Select all`
  String get library_select_all {
    return Intl.message(
      'Select all',
      name: 'library_select_all',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get common_add {
    return Intl.message('Add', name: 'common_add', desc: '', args: []);
  }

  /// `Cancel`
  String get common_cancel {
    return Intl.message('Cancel', name: 'common_cancel', desc: '', args: []);
  }

  /// `Save`
  String get common_save {
    return Intl.message('Save', name: 'common_save', desc: '', args: []);
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

  /// `Appearance`
  String get settings_appearance_section_title {
    return Intl.message(
      'Appearance',
      name: 'settings_appearance_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get settings_content_section_title {
    return Intl.message(
      'Content',
      name: 'settings_content_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Show NSFW sources`
  String get settings_show_nsfw_title {
    return Intl.message(
      'Show NSFW sources',
      name: 'settings_show_nsfw_title',
      desc: '',
      args: [],
    );
  }

  /// `Display extensions marked as adult content`
  String get settings_show_nsfw_subtitle {
    return Intl.message(
      'Display extensions marked as adult content',
      name: 'settings_show_nsfw_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get settings_statistics_section_title {
    return Intl.message(
      'Statistics',
      name: 'settings_statistics_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Reading statistics`
  String get settings_reading_statistics_title {
    return Intl.message(
      'Reading statistics',
      name: 'settings_reading_statistics_title',
      desc: '',
      args: [],
    );
  }

  /// `View your reading and watching activity`
  String get settings_reading_statistics_subtitle {
    return Intl.message(
      'View your reading and watching activity',
      name: 'settings_reading_statistics_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Collect statistics`
  String get settings_collect_statistics_title {
    return Intl.message(
      'Collect statistics',
      name: 'settings_collect_statistics_title',
      desc: '',
      args: [],
    );
  }

  /// `Track activity to build statistics`
  String get settings_collect_statistics_subtitle {
    return Intl.message(
      'Track activity to build statistics',
      name: 'settings_collect_statistics_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settings_theme_title {
    return Intl.message(
      'Theme',
      name: 'settings_theme_title',
      desc: '',
      args: [],
    );
  }

  /// `Midnight`
  String get settings_theme_midnight {
    return Intl.message(
      'Midnight',
      name: 'settings_theme_midnight',
      desc: '',
      args: [],
    );
  }

  /// `AMOLED`
  String get settings_theme_amoled {
    return Intl.message(
      'AMOLED',
      name: 'settings_theme_amoled',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settings_theme_light {
    return Intl.message(
      'Light',
      name: 'settings_theme_light',
      desc: '',
      args: [],
    );
  }

  /// `Ocean`
  String get settings_theme_ocean {
    return Intl.message(
      'Ocean',
      name: 'settings_theme_ocean',
      desc: '',
      args: [],
    );
  }

  /// `Dracula`
  String get settings_theme_dracula {
    return Intl.message(
      'Dracula',
      name: 'settings_theme_dracula',
      desc: '',
      args: [],
    );
  }

  /// `Ember`
  String get settings_theme_ember {
    return Intl.message(
      'Ember',
      name: 'settings_theme_ember',
      desc: '',
      args: [],
    );
  }

  /// `Sky`
  String get settings_theme_sky {
    return Intl.message('Sky', name: 'settings_theme_sky', desc: '', args: []);
  }

  /// `Sakura`
  String get settings_theme_sakura {
    return Intl.message(
      'Sakura',
      name: 'settings_theme_sakura',
      desc: '',
      args: [],
    );
  }

  /// `Sepia`
  String get settings_theme_sepia {
    return Intl.message(
      'Sepia',
      name: 'settings_theme_sepia',
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

  /// `Statistics`
  String get stats_title {
    return Intl.message('Statistics', name: 'stats_title', desc: '', args: []);
  }

  /// `Overview`
  String get stats_overview_section_title {
    return Intl.message(
      'Overview',
      name: 'stats_overview_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get stats_activity_section_title {
    return Intl.message(
      'Activity',
      name: 'stats_activity_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Top sources`
  String get stats_sources_section_title {
    return Intl.message(
      'Top sources',
      name: 'stats_sources_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Chapters read`
  String get stats_kpi_chapters_read {
    return Intl.message(
      'Chapters read',
      name: 'stats_kpi_chapters_read',
      desc: '',
      args: [],
    );
  }

  /// `Pages read`
  String get stats_kpi_pages_read {
    return Intl.message(
      'Pages read',
      name: 'stats_kpi_pages_read',
      desc: '',
      args: [],
    );
  }

  /// `Episodes watched`
  String get stats_kpi_episodes_watched {
    return Intl.message(
      'Episodes watched',
      name: 'stats_kpi_episodes_watched',
      desc: '',
      args: [],
    );
  }

  /// `Time watched`
  String get stats_kpi_time_watched {
    return Intl.message(
      'Time watched',
      name: 'stats_kpi_time_watched',
      desc: '',
      args: [],
    );
  }

  /// `Day streak`
  String get stats_kpi_day_streak {
    return Intl.message(
      'Day streak',
      name: 'stats_kpi_day_streak',
      desc: '',
      args: [],
    );
  }

  /// `Active days`
  String get stats_kpi_active_days {
    return Intl.message(
      'Active days',
      name: 'stats_kpi_active_days',
      desc: '',
      args: [],
    );
  }

  /// `Current {current} · Longest {longest}`
  String stats_streak_summary(Object current, Object longest) {
    return Intl.message(
      'Current $current · Longest $longest',
      name: 'stats_streak_summary',
      desc: '',
      args: [current, longest],
    );
  }

  /// `Less`
  String get stats_heatmap_less {
    return Intl.message('Less', name: 'stats_heatmap_less', desc: '', args: []);
  }

  /// `More`
  String get stats_heatmap_more {
    return Intl.message('More', name: 'stats_heatmap_more', desc: '', args: []);
  }

  /// `Tap a week for details`
  String get stats_heatmap_hint {
    return Intl.message(
      'Tap a week for details',
      name: 'stats_heatmap_hint',
      desc: '',
      args: [],
    );
  }

  /// `{count} activities`
  String stats_heatmap_week_count(Object count) {
    return Intl.message(
      '$count activities',
      name: 'stats_heatmap_week_count',
      desc: '',
      args: [count],
    );
  }

  /// `Statistics are off`
  String get stats_disabled_title {
    return Intl.message(
      'Statistics are off',
      name: 'stats_disabled_title',
      desc: '',
      args: [],
    );
  }

  /// `Enable statistics collection to see your reading and watching activity here.`
  String get stats_disabled_message {
    return Intl.message(
      'Enable statistics collection to see your reading and watching activity here.',
      name: 'stats_disabled_message',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get stats_enable_button {
    return Intl.message(
      'Enable',
      name: 'stats_enable_button',
      desc: '',
      args: [],
    );
  }

  /// `No activity yet`
  String get stats_empty_title {
    return Intl.message(
      'No activity yet',
      name: 'stats_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Start reading or watching to build up your statistics.`
  String get stats_empty_message {
    return Intl.message(
      'Start reading or watching to build up your statistics.',
      name: 'stats_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load statistics`
  String get stats_error_title {
    return Intl.message(
      'Couldn\'t load statistics',
      name: 'stats_error_title',
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

  /// `Chapters`
  String get concrete_viewer_chapters_section_title {
    return Intl.message(
      'Chapters',
      name: 'concrete_viewer_chapters_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Episodes`
  String get concrete_viewer_episodes_section_title {
    return Intl.message(
      'Episodes',
      name: 'concrete_viewer_episodes_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Show more`
  String get concrete_viewer_description_show_more {
    return Intl.message(
      'Show more',
      name: 'concrete_viewer_description_show_more',
      desc: '',
      args: [],
    );
  }

  /// `Show less`
  String get concrete_viewer_description_show_less {
    return Intl.message(
      'Show less',
      name: 'concrete_viewer_description_show_less',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load title`
  String get concrete_viewer_error_title {
    return Intl.message(
      'Couldn\'t load title',
      name: 'concrete_viewer_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get concrete_viewer_retry_button {
    return Intl.message(
      'Retry',
      name: 'concrete_viewer_retry_button',
      desc: '',
      args: [],
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

  /// `Download`
  String get concrete_selection_download {
    return Intl.message(
      'Download',
      name: 'concrete_selection_download',
      desc: '',
      args: [],
    );
  }

  /// `Offline — showing cached content. Only downloaded chapters can be opened.`
  String get concrete_offline_banner {
    return Intl.message(
      'Offline — showing cached content. Only downloaded chapters can be opened.',
      name: 'concrete_offline_banner',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get settings_storage_section_title {
    return Intl.message(
      'Storage',
      name: 'settings_storage_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get settings_downloads_title {
    return Intl.message(
      'Downloads',
      name: 'settings_downloads_title',
      desc: '',
      args: [],
    );
  }

  /// `Manage downloaded chapters`
  String get settings_downloads_subtitle {
    return Intl.message(
      'Manage downloaded chapters',
      name: 'settings_downloads_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get downloads_title {
    return Intl.message(
      'Downloads',
      name: 'downloads_title',
      desc: '',
      args: [],
    );
  }

  /// `No downloads`
  String get downloads_empty_title {
    return Intl.message(
      'No downloads',
      name: 'downloads_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Chapters you download for offline reading will appear here.`
  String get downloads_empty_message {
    return Intl.message(
      'Chapters you download for offline reading will appear here.',
      name: 'downloads_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Queued`
  String get downloads_status_queued {
    return Intl.message(
      'Queued',
      name: 'downloads_status_queued',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get downloads_status_downloading {
    return Intl.message(
      'Downloading',
      name: 'downloads_status_downloading',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get downloads_status_failed {
    return Intl.message(
      'Failed',
      name: 'downloads_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Delete all`
  String get downloads_delete_all {
    return Intl.message(
      'Delete all',
      name: 'downloads_delete_all',
      desc: '',
      args: [],
    );
  }

  /// `Delete all downloads?`
  String get downloads_delete_all_confirmation_title {
    return Intl.message(
      'Delete all downloads?',
      name: 'downloads_delete_all_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This will remove every downloaded chapter from this device.`
  String get downloads_delete_all_confirmation_message {
    return Intl.message(
      'This will remove every downloaded chapter from this device.',
      name: 'downloads_delete_all_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete download?`
  String get downloads_delete_confirmation_title {
    return Intl.message(
      'Delete download?',
      name: 'downloads_delete_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This chapter will be removed from this device.`
  String get downloads_delete_confirmation_message {
    return Intl.message(
      'This chapter will be removed from this device.',
      name: 'downloads_delete_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get downloads_confirm_delete {
    return Intl.message(
      'Delete',
      name: 'downloads_confirm_delete',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get downloads_confirm_cancel {
    return Intl.message(
      'Cancel',
      name: 'downloads_confirm_cancel',
      desc: '',
      args: [],
    );
  }

  /// `{done}/{total} pages`
  String downloads_pages_progress(Object done, Object total) {
    return Intl.message(
      '$done/$total pages',
      name: 'downloads_pages_progress',
      desc: '',
      args: [done, total],
    );
  }

  /// `{done}/{total} chapters downloaded`
  String downloads_chapters_summary(Object done, Object total) {
    return Intl.message(
      '$done/$total chapters downloaded',
      name: 'downloads_chapters_summary',
      desc: '',
      args: [done, total],
    );
  }

  /// `Downloads`
  String get downloads_notification_channel_name {
    return Intl.message(
      'Downloads',
      name: 'downloads_notification_channel_name',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get downloads_notification_downloading_title {
    return Intl.message(
      'Downloading',
      name: 'downloads_notification_downloading_title',
      desc: '',
      args: [],
    );
  }

  /// `Download complete`
  String get downloads_notification_complete_title {
    return Intl.message(
      'Download complete',
      name: 'downloads_notification_complete_title',
      desc: '',
      args: [],
    );
  }

  /// `{count} chapters downloaded`
  String downloads_notification_complete_body(Object count) {
    return Intl.message(
      '$count chapters downloaded',
      name: 'downloads_notification_complete_body',
      desc: '',
      args: [count],
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
