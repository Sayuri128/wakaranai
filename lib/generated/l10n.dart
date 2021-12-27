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

  /// `HReader`
  String get app_name {
    return Intl.message(
      'HReader',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get bottom_navigation_gallery_menu_title {
    return Intl.message(
      'Gallery',
      name: 'bottom_navigation_gallery_menu_title',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get bottom_navigation_settings_menu_title {
    return Intl.message(
      'Settings',
      name: 'bottom_navigation_settings_menu_title',
      desc: '',
      args: [],
    );
  }

  /// `NHentai`
  String get gallery_view_menu_nhentai_title {
    return Intl.message(
      'NHentai',
      name: 'gallery_view_menu_nhentai_title',
      desc: '',
      args: [],
    );
  }

  /// `Cached`
  String get gallery_view_menu_cached_title {
    return Intl.message(
      'Cached',
      name: 'gallery_view_menu_cached_title',
      desc: '',
      args: [],
    );
  }

  /// `{title} data does not exist`
  String doujinshi_view_cached_data_does_not_exit_error_message(Object title) {
    return Intl.message(
      '$title data does not exist',
      name: 'doujinshi_view_cached_data_does_not_exit_error_message',
      desc: '',
      args: [title],
    );
  }

  /// `Save`
  String get doujinshi_view_cache_button_save_title {
    return Intl.message(
      'Save',
      name: 'doujinshi_view_cache_button_save_title',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get doujinshi_view_cache_button_delete_title {
    return Intl.message(
      'Delete',
      name: 'doujinshi_view_cache_button_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get doujinshi_view_cache_button_loading_title {
    return Intl.message(
      'Saving...',
      name: 'doujinshi_view_cache_button_loading_title',
      desc: '',
      args: [],
    );
  }

  /// `Deleting...`
  String get doujinshi_view_cache_button_deleting_title {
    return Intl.message(
      'Deleting...',
      name: 'doujinshi_view_cache_button_deleting_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete {title}?`
  String doujinshi_view_cache_button_delete_dialog_message(Object title) {
    return Intl.message(
      'Are you sure want to delete $title?',
      name: 'doujinshi_view_cache_button_delete_dialog_message',
      desc: '',
      args: [title],
    );
  }

  /// `Delete`
  String get doujinshi_view_cache_button_delete_dialog_ok {
    return Intl.message(
      'Delete',
      name: 'doujinshi_view_cache_button_delete_dialog_ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get doujinshi_view_cache_button_delete_dialog_cancel {
    return Intl.message(
      'Cancel',
      name: 'doujinshi_view_cache_button_delete_dialog_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Pages:`
  String get doujinshi_pages_count {
    return Intl.message(
      'Pages:',
      name: 'doujinshi_pages_count',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded:`
  String get doujinshi_uploaded {
    return Intl.message(
      'Uploaded:',
      name: 'doujinshi_uploaded',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard!`
  String get copied_to_clipboard_message {
    return Intl.message(
      'Copied to clipboard!',
      name: 'copied_to_clipboard_message',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_title {
    return Intl.message(
      'Settings',
      name: 'settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Cache`
  String get settings_caching_section_title {
    return Intl.message(
      'Cache',
      name: 'settings_caching_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Image caching`
  String get settings_caching_images_title {
    return Intl.message(
      'Image caching',
      name: 'settings_caching_images_title',
      desc: '',
      args: [],
    );
  }

  /// `Caching period`
  String get settings_caching_period_dialog_title {
    return Intl.message(
      'Caching period',
      name: 'settings_caching_period_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get settings_caching_period_one_day {
    return Intl.message(
      'Day',
      name: 'settings_caching_period_one_day',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get settings_caching_period_one_week {
    return Intl.message(
      'Week',
      name: 'settings_caching_period_one_week',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get settings_caching_period_one_month {
    return Intl.message(
      'Month',
      name: 'settings_caching_period_one_month',
      desc: '',
      args: [],
    );
  }

  /// `Forever`
  String get settings_caching_period_forever {
    return Intl.message(
      'Forever',
      name: 'settings_caching_period_forever',
      desc: '',
      args: [],
    );
  }

  /// `Clear {count} images cache.`
  String settings_cache_clear_title(Object count) {
    return Intl.message(
      'Clear $count images cache.',
      name: 'settings_cache_clear_title',
      desc: '',
      args: [count],
    );
  }

  /// `Are your sure want to clear image cache?`
  String get settings_cache_clear_dialog_title {
    return Intl.message(
      'Are your sure want to clear image cache?',
      name: 'settings_cache_clear_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Synchronize cache`
  String get settings_cache_sync_title {
    return Intl.message(
      'Synchronize cache',
      name: 'settings_cache_sync_title',
      desc: '',
      args: [],
    );
  }

  /// `Synchronize cache {progress}%`
  String settings_cache_sync_title_progress(Object progress) {
    return Intl.message(
      'Synchronize cache $progress%',
      name: 'settings_cache_sync_title_progress',
      desc: '',
      args: [progress],
    );
  }

  /// `{count} cached images were synchronized`
  String settings_cache_sync_complete_message(Object count) {
    return Intl.message(
      '$count cached images were synchronized',
      name: 'settings_cache_sync_complete_message',
      desc: '',
      args: [count],
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
