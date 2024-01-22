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

  /// `Search`
  String get service_viewer_search_field_hint_text {
    return Intl.message(
      'Search',
      name: 'service_viewer_search_field_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `Download again`
  String get download_again {
    return Intl.message(
      'Download again',
      name: 'download_again',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Right to left`
  String get right_to_left_read_mode {
    return Intl.message(
      'Right to left',
      name: 'right_to_left_read_mode',
      desc: '',
      args: [],
    );
  }

  /// `Left to right`
  String get left_to_right_read_mode {
    return Intl.message(
      'Left to right',
      name: 'left_to_right_read_mode',
      desc: '',
      args: [],
    );
  }

  /// `Webtoon`
  String get webtoon {
    return Intl.message(
      'Webtoon',
      name: 'webtoon',
      desc: '',
      args: [],
    );
  }

  /// `Extensions`
  String get remote_configs_page_appbar_title {
    return Intl.message(
      'Extensions',
      name: 'remote_configs_page_appbar_title',
      desc: '',
      args: [],
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
  String get service_viewer_filters_title {
    return Intl.message(
      'Filters',
      name: 'service_viewer_filters_title',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get navigation_bar_sources_title {
    return Intl.message(
      'Explore',
      name: 'navigation_bar_sources_title',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get navigation_bar_library_title {
    return Intl.message(
      'Library',
      name: 'navigation_bar_library_title',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get navigation_bar_history_title {
    return Intl.message(
      'History',
      name: 'navigation_bar_history_title',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get navigation_bar_settings_title {
    return Intl.message(
      'Settings',
      name: 'navigation_bar_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history_page_title {
    return Intl.message(
      'History',
      name: 'history_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Last visit: {date}`
  String history_last_visit(Object date) {
    return Intl.message(
      'Last visit: $date',
      name: 'history_last_visit',
      desc: '',
      args: [date],
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

  /// `Wakaranai GitHub`
  String get official_github_configs_source_repository {
    return Intl.message(
      'Wakaranai GitHub',
      name: 'official_github_configs_source_repository',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get github_configs_source_type {
    return Intl.message(
      'GitHub',
      name: 'github_configs_source_type',
      desc: '',
      args: [],
    );
  }

  /// `REST`
  String get rest_configs_source_type {
    return Intl.message(
      'REST',
      name: 'rest_configs_source_type',
      desc: '',
      args: [],
    );
  }

  /// `Change extensions source`
  String get change_configs_source_dialog {
    return Intl.message(
      'Change extensions source',
      name: 'change_configs_source_dialog',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add_new_configs_source_button {
    return Intl.message(
      'Add',
      name: 'add_new_configs_source_button',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create_new_configs_source_button {
    return Intl.message(
      'Create',
      name: 'create_new_configs_source_button',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get new_configs_name_field_label {
    return Intl.message(
      'Name',
      name: 'new_configs_name_field_label',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get new_configs_base_url_field_label {
    return Intl.message(
      'URL',
      name: 'new_configs_base_url_field_label',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get new_configs_name_required_error {
    return Intl.message(
      'Name is required',
      name: 'new_configs_name_required_error',
      desc: '',
      args: [],
    );
  }

  /// `Base URL is required`
  String get new_configs_base_url_required_error {
    return Intl.message(
      'Base URL is required',
      name: 'new_configs_base_url_required_error',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get delete_configs_source_confirmation_dialog_title {
    return Intl.message(
      'Confirmation',
      name: 'delete_configs_source_confirmation_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete {name} source?`
  String delete_configs_source_confirmation_dialog_message(Object name) {
    return Intl.message(
      'Are you sure you want to delete $name source?',
      name: 'delete_configs_source_confirmation_dialog_message',
      desc: '',
      args: [name],
    );
  }

  /// `Error occurred during fetching manga configs`
  String get fetching_mangas_configs_error {
    return Intl.message(
      'Error occurred during fetching manga configs',
      name: 'fetching_mangas_configs_error',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred during initializing configs {name} source`
  String configs_source_initializing_error(Object name) {
    return Intl.message(
      'Error occurred during initializing configs $name source',
      name: 'configs_source_initializing_error',
      desc: '',
      args: [name],
    );
  }

  /// `Are you sure you want to clear your history?`
  String get clear_history_dialog_confirmation_title {
    return Intl.message(
      'Are you sure you want to clear your history?',
      name: 'clear_history_dialog_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be canceled later`
  String get clear_history_dialog_confirmation_message {
    return Intl.message(
      'This action cannot be canceled later',
      name: 'clear_history_dialog_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get clear_history_dialog_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'clear_history_dialog_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get clear_history_dialog_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name: 'clear_history_dialog_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `History has been cleared`
  String get clear_history_dialog_success {
    return Intl.message(
      'History has been cleared',
      name: 'clear_history_dialog_success',
      desc: '',
      args: [],
    );
  }

  /// `Clear cookies cache`
  String get clear_cookies_cache {
    return Intl.message(
      'Clear cookies cache',
      name: 'clear_cookies_cache',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear your cookies?`
  String get clear_cookies_cache_dialog_confirmation_title {
    return Intl.message(
      'Are you sure you want to clear your cookies?',
      name: 'clear_cookies_cache_dialog_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be canceled later`
  String get clear_cookies_cache_dialog_confirmation_message {
    return Intl.message(
      'This action cannot be canceled later',
      name: 'clear_cookies_cache_dialog_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get clear_cookies_cache_dialog_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'clear_cookies_cache_dialog_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get clear_cookies_cache_dialog_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name: 'clear_cookies_cache_dialog_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `Submit issue/feature request/extension request`
  String get submit_issue {
    return Intl.message(
      'Submit issue/feature request/extension request',
      name: 'submit_issue',
      desc: '',
      args: [],
    );
  }

  /// `Default extension source`
  String get settings_default_configs_source_title {
    return Intl.message(
      'Default extension source',
      name: 'settings_default_configs_source_title',
      desc: '',
      args: [],
    );
  }

  /// `Cookies has been cleared`
  String get clear_cookies_dialog_success {
    return Intl.message(
      'Cookies has been cleared',
      name: 'clear_cookies_dialog_success',
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

  /// `{manga} Added to you library!`
  String gallery_view_manga_item_added_to_library_notification(Object manga) {
    return Intl.message(
      '$manga Added to you library!',
      name: 'gallery_view_manga_item_added_to_library_notification',
      desc: '',
      args: [manga],
    );
  }

  /// `{anime} Added to you library!`
  String gallery_view_anime_item_added_to_library_notification(Object anime) {
    return Intl.message(
      '$anime Added to you library!',
      name: 'gallery_view_anime_item_added_to_library_notification',
      desc: '',
      args: [anime],
    );
  }

  /// `{manga} Deleted from your library!`
  String gallery_view_manga_item_deleted_from_library_notification(
      Object manga) {
    return Intl.message(
      '$manga Deleted from your library!',
      name: 'gallery_view_manga_item_deleted_from_library_notification',
      desc: '',
      args: [manga],
    );
  }

  /// `{anime} Deleted from your library!`
  String gallery_view_anime_item_deleted_from_library_notification(
      Object anime) {
    return Intl.message(
      '$anime Deleted from your library!',
      name: 'gallery_view_anime_item_deleted_from_library_notification',
      desc: '',
      args: [anime],
    );
  }

  /// `Are you sure you want to delete "{manga}" from your library?`
  String gallery_view_manga_item_delete_from_library_confirmation_title(
      Object manga) {
    return Intl.message(
      'Are you sure you want to delete "$manga" from your library?',
      name: 'gallery_view_manga_item_delete_from_library_confirmation_title',
      desc: '',
      args: [manga],
    );
  }

  /// `Delete`
  String get gallery_view_manga_item_delete_from_library_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'gallery_view_manga_item_delete_from_library_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String
      get gallery_view_manga_item_delete_from_library_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name:
          'gallery_view_manga_item_delete_from_library_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{anime}" from your library?`
  String gallery_view_anime_item_delete_from_library_confirmation_title(
      Object anime) {
    return Intl.message(
      'Are you sure you want to delete "$anime" from your library?',
      name: 'gallery_view_anime_item_delete_from_library_confirmation_title',
      desc: '',
      args: [anime],
    );
  }

  /// `Delete`
  String get gallery_view_anime_item_delete_from_library_confirmation_ok_label {
    return Intl.message(
      'Delete',
      name: 'gallery_view_anime_item_delete_from_library_confirmation_ok_label',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String
      get gallery_view_anime_item_delete_from_library_confirmation_cancel_label {
    return Intl.message(
      'Cancel',
      name:
          'gallery_view_anime_item_delete_from_library_confirmation_cancel_label',
      desc: '',
      args: [],
    );
  }

  /// `In library`
  String get gallery_view_item_in_library_title {
    return Intl.message(
      'In library',
      name: 'gallery_view_item_in_library_title',
      desc: '',
      args: [],
    );
  }

  /// `No saved configs`
  String get local_configs_0_length {
    return Intl.message(
      'No saved configs',
      name: 'local_configs_0_length',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get local_configs_update_button {
    return Intl.message(
      'Update',
      name: 'local_configs_update_button',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get local_configs_no_updates {
    return Intl.message(
      'Latest',
      name: 'local_configs_no_updates',
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
