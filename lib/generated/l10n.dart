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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Wakaranai`
  String get app_name {
    return Intl.message(
      'Wakaranai',
      name: 'app_name',
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
    return Intl.message(
      'NSFW',
      name: 'home_nsfw_suffix',
      desc: '',
      args: [],
    );
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

  /// `Done`
  String get web_browser_no_login_button {
    return Intl.message(
      'Done',
      name: 'web_browser_no_login_button',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
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
