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

  /// `Couldn't load this extension`
  String get api_client_error_title {
    return Intl.message(
      'Couldn\'t load this extension',
      name: 'api_client_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get common_go_back {
    return Intl.message('Go back', name: 'common_go_back', desc: '', args: []);
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

  /// `More`
  String get library_more_actions {
    return Intl.message(
      'More',
      name: 'library_more_actions',
      desc: '',
      args: [],
    );
  }

  /// `Each title downloads from its first chapter group`
  String get library_download_first_group_hint {
    return Intl.message(
      'Each title downloads from its first chapter group',
      name: 'library_download_first_group_hint',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{Looking up chapters for 1 title…} other{Looking up chapters for {count} titles…}}`
  String library_download_many_loading(int count) {
    return Intl.plural(
      count,
      one: 'Looking up chapters for 1 title…',
      other: 'Looking up chapters for $count titles…',
      name: 'library_download_many_loading',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 title couldn't be loaded} other{{count} titles couldn't be loaded}}`
  String library_download_many_failed(int count) {
    return Intl.plural(
      count,
      one: '1 title couldn\'t be loaded',
      other: '$count titles couldn\'t be loaded',
      name: 'library_download_many_failed',
      desc: '',
      args: [count],
    );
  }

  /// `Add to library`
  String get library_add {
    return Intl.message(
      'Add to library',
      name: 'library_add',
      desc: '',
      args: [],
    );
  }

  /// `Add to category`
  String get library_add_to_category {
    return Intl.message(
      'Add to category',
      name: 'library_add_to_category',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get title_download {
    return Intl.message('Download', name: 'title_download', desc: '', args: []);
  }

  /// `Download chapters`
  String get title_download_title {
    return Intl.message(
      'Download chapters',
      name: 'title_download_title',
      desc: '',
      args: [],
    );
  }

  /// `Next chapter`
  String get title_download_next {
    return Intl.message(
      'Next chapter',
      name: 'title_download_next',
      desc: '',
      args: [],
    );
  }

  /// `Next {count} chapters`
  String title_download_next_count(int count) {
    return Intl.message(
      'Next $count chapters',
      name: 'title_download_next_count',
      desc: '',
      args: [count],
    );
  }

  /// `Unread chapters`
  String get title_download_unread {
    return Intl.message(
      'Unread chapters',
      name: 'title_download_unread',
      desc: '',
      args: [],
    );
  }

  /// `All chapters`
  String get title_download_all {
    return Intl.message(
      'All chapters',
      name: 'title_download_all',
      desc: '',
      args: [],
    );
  }

  /// `Looking up chapters…`
  String get title_download_loading {
    return Intl.message(
      'Looking up chapters…',
      name: 'title_download_loading',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 chapter queued} other{{count} chapters queued}}`
  String title_download_queued(int count) {
    return Intl.plural(
      count,
      one: '1 chapter queued',
      other: '$count chapters queued',
      name: 'title_download_queued',
      desc: '',
      args: [count],
    );
  }

  /// `No new chapters to download`
  String get title_download_nothing {
    return Intl.message(
      'No new chapters to download',
      name: 'title_download_nothing',
      desc: '',
      args: [],
    );
  }

  /// `Chapter groups`
  String get title_download_groups {
    return Intl.message(
      'Chapter groups',
      name: 'title_download_groups',
      desc: '',
      args: [],
    );
  }

  /// `Chapters to download`
  String get title_download_how_many {
    return Intl.message(
      'Chapters to download',
      name: 'title_download_how_many',
      desc: '',
      args: [],
    );
  }

  /// `Group {number}`
  String title_download_untitled_group(int number) {
    return Intl.message(
      'Group $number',
      name: 'title_download_untitled_group',
      desc: '',
      args: [number],
    );
  }

  /// `{count, plural, =1{1 chapter} other{{count} chapters}}`
  String title_download_chapter_count(int count) {
    return Intl.plural(
      count,
      one: '1 chapter',
      other: '$count chapters',
      name: 'title_download_chapter_count',
      desc: '',
      args: [count],
    );
  }

  /// `This title has no chapters yet`
  String get title_download_no_chapters {
    return Intl.message(
      'This title has no chapters yet',
      name: 'title_download_no_chapters',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load the chapter list`
  String get title_download_failed {
    return Intl.message(
      'Couldn\'t load the chapter list',
      name: 'title_download_failed',
      desc: '',
      args: [],
    );
  }

  /// `Added to library`
  String get library_added_message {
    return Intl.message(
      'Added to library',
      name: 'library_added_message',
      desc: '',
      args: [],
    );
  }

  /// `Removed from library`
  String get library_removed_message {
    return Intl.message(
      'Removed from library',
      name: 'library_removed_message',
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

  /// `Search library`
  String get library_search_hint {
    return Intl.message(
      'Search library',
      name: 'library_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `No matches`
  String get library_search_no_results_title {
    return Intl.message(
      'No matches',
      name: 'library_search_no_results_title',
      desc: '',
      args: [],
    );
  }

  /// `Nothing in your library matches “{query}”`
  String library_search_no_results_message(Object query) {
    return Intl.message(
      'Nothing in your library matches “$query”',
      name: 'library_search_no_results_message',
      desc: '',
      args: [query],
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

  /// `Branch`
  String get add_extension_source_page_branch_field_label {
    return Intl.message(
      'Branch',
      name: 'add_extension_source_page_branch_field_label',
      desc: '',
      args: [],
    );
  }

  /// `Optional. Fetch the repository's branches to target a staging ref.`
  String get add_extension_source_page_branch_helper_text {
    return Intl.message(
      'Optional. Fetch the repository\'s branches to target a staging ref.',
      name: 'add_extension_source_page_branch_helper_text',
      desc: '',
      args: [],
    );
  }

  /// `Default branch`
  String get add_extension_source_page_branch_default_option {
    return Intl.message(
      'Default branch',
      name: 'add_extension_source_page_branch_default_option',
      desc: '',
      args: [],
    );
  }

  /// `Fetch`
  String get add_extension_source_page_branch_fetch_button {
    return Intl.message(
      'Fetch',
      name: 'add_extension_source_page_branch_fetch_button',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid GitHub URL first`
  String get add_extension_source_page_branch_invalid_url_error {
    return Intl.message(
      'Enter a valid GitHub URL first',
      name: 'add_extension_source_page_branch_invalid_url_error',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load branches`
  String get add_extension_source_page_branch_fetch_error {
    return Intl.message(
      'Couldn\'t load branches',
      name: 'add_extension_source_page_branch_fetch_error',
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

  /// `Filters`
  String get gallery_filters_button_label {
    return Intl.message(
      'Filters',
      name: 'gallery_filters_button_label',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get gallery_filters_sheet_title {
    return Intl.message(
      'Filters',
      name: 'gallery_filters_sheet_title',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get gallery_filters_reset_button {
    return Intl.message(
      'Reset',
      name: 'gallery_filters_reset_button',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get gallery_filters_apply_button {
    return Intl.message(
      'Apply',
      name: 'gallery_filters_apply_button',
      desc: '',
      args: [],
    );
  }

  /// `Apply ({count})`
  String gallery_filters_apply_button_count(Object count) {
    return Intl.message(
      'Apply ($count)',
      name: 'gallery_filters_apply_button_count',
      desc: '',
      args: [count],
    );
  }

  /// `Enter a value`
  String get gallery_filters_one_of_any_hint {
    return Intl.message(
      'Enter a value',
      name: 'gallery_filters_one_of_any_hint',
      desc: '',
      args: [],
    );
  }

  /// `Type and add`
  String get gallery_filters_multiple_of_any_hint {
    return Intl.message(
      'Type and add',
      name: 'gallery_filters_multiple_of_any_hint',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get gallery_filters_range_from_hint {
    return Intl.message(
      'From',
      name: 'gallery_filters_range_from_hint',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get gallery_filters_range_to_hint {
    return Intl.message(
      'To',
      name: 'gallery_filters_range_to_hint',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get gallery_filters_option_search_hint {
    return Intl.message(
      'Search',
      name: 'gallery_filters_option_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `+{count} more — refine your search`
  String gallery_filters_more_options(Object count) {
    return Intl.message(
      '+$count more — refine your search',
      name: 'gallery_filters_more_options',
      desc: '',
      args: [count],
    );
  }

  /// `No matches`
  String get gallery_filters_no_matches {
    return Intl.message(
      'No matches',
      name: 'gallery_filters_no_matches',
      desc: '',
      args: [],
    );
  }

  /// `Comfortable grid`
  String get gallery_layout_comfortable {
    return Intl.message(
      'Comfortable grid',
      name: 'gallery_layout_comfortable',
      desc: '',
      args: [],
    );
  }

  /// `Compact grid`
  String get gallery_layout_compact {
    return Intl.message(
      'Compact grid',
      name: 'gallery_layout_compact',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get gallery_layout_list {
    return Intl.message(
      'List',
      name: 'gallery_layout_list',
      desc: '',
      args: [],
    );
  }

  /// `Layout: {layout}`
  String gallery_layout_button_tooltip(Object layout) {
    return Intl.message(
      'Layout: $layout',
      name: 'gallery_layout_button_tooltip',
      desc: '',
      args: [layout],
    );
  }

  /// `Last opened: {title}`
  String gallery_last_opened(Object title) {
    return Intl.message(
      'Last opened: $title',
      name: 'gallery_last_opened',
      desc: '',
      args: [title],
    );
  }

  /// `Completed`
  String get title_status_released {
    return Intl.message(
      'Completed',
      name: 'title_status_released',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get title_status_ongoing {
    return Intl.message(
      'Ongoing',
      name: 'title_status_ongoing',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get title_status_paused {
    return Intl.message(
      'Paused',
      name: 'title_status_paused',
      desc: '',
      args: [],
    );
  }

  /// `Announced`
  String get title_status_announce {
    return Intl.message(
      'Announced',
      name: 'title_status_announce',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get title_status_canceled {
    return Intl.message(
      'Cancelled',
      name: 'title_status_canceled',
      desc: '',
      args: [],
    );
  }

  /// `{count} new`
  String library_new_chapters(Object count) {
    return Intl.message(
      '$count new',
      name: 'library_new_chapters',
      desc: '',
      args: [count],
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

  /// `NEW`
  String get concrete_new_badge {
    return Intl.message('NEW', name: 'concrete_new_badge', desc: '', args: []);
  }

  /// `Finished`
  String get chapter_divider_finished {
    return Intl.message(
      'Finished',
      name: 'chapter_divider_finished',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get chapter_divider_next {
    return Intl.message(
      'Next',
      name: 'chapter_divider_next',
      desc: '',
      args: [],
    );
  }

  /// `{count} pages`
  String chapter_divider_pages(Object count) {
    return Intl.message(
      '$count pages',
      name: 'chapter_divider_pages',
      desc: '',
      args: [count],
    );
  }

  /// `Downloaded`
  String get chapter_divider_downloaded {
    return Intl.message(
      'Downloaded',
      name: 'chapter_divider_downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Loading the next chapter…`
  String get chapter_divider_loading {
    return Intl.message(
      'Loading the next chapter…',
      name: 'chapter_divider_loading',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load the chapter`
  String get chapter_divider_failed {
    return Intl.message(
      'Couldn\'t load the chapter',
      name: 'chapter_divider_failed',
      desc: '',
      args: [],
    );
  }

  /// `You're all caught up`
  String get chapter_divider_end_title {
    return Intl.message(
      'You\'re all caught up',
      name: 'chapter_divider_end_title',
      desc: '',
      args: [],
    );
  }

  /// `There are no more chapters`
  String get chapter_divider_end_message {
    return Intl.message(
      'There are no more chapters',
      name: 'chapter_divider_end_message',
      desc: '',
      args: [],
    );
  }

  /// `Back to title`
  String get chapter_divider_back {
    return Intl.message(
      'Back to title',
      name: 'chapter_divider_back',
      desc: '',
      args: [],
    );
  }

  /// `Previous chapter`
  String get chapter_divider_previous {
    return Intl.message(
      'Previous chapter',
      name: 'chapter_divider_previous',
      desc: '',
      args: [],
    );
  }

  /// `Load previous chapter`
  String get chapter_divider_load_previous {
    return Intl.message(
      'Load previous chapter',
      name: 'chapter_divider_load_previous',
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

  /// `Developer`
  String get settings_developer_section {
    return Intl.message(
      'Developer',
      name: 'settings_developer_section',
      desc: '',
      args: [],
    );
  }

  /// `By {names}`
  String concrete_viewer_by_authors(Object names) {
    return Intl.message(
      'By $names',
      name: 'concrete_viewer_by_authors',
      desc: '',
      args: [names],
    );
  }

  /// `Art by {names}`
  String concrete_viewer_art_by(Object names) {
    return Intl.message(
      'Art by $names',
      name: 'concrete_viewer_art_by',
      desc: '',
      args: [names],
    );
  }

  /// `Open website`
  String get concrete_viewer_open_website {
    return Intl.message(
      'Open website',
      name: 'concrete_viewer_open_website',
      desc: '',
      args: [],
    );
  }

  /// `Local extension server`
  String get settings_local_extension_server_title {
    return Intl.message(
      'Local extension server',
      name: 'settings_local_extension_server_title',
      desc: '',
      args: [],
    );
  }

  /// `Load extensions from {url}`
  String settings_local_extension_server_subtitle(Object url) {
    return Intl.message(
      'Load extensions from $url',
      name: 'settings_local_extension_server_subtitle',
      desc: '',
      args: [url],
    );
  }

  /// `Set LOCAL_REPOSITORY_URL in .env to enable`
  String get settings_local_extension_server_missing {
    return Intl.message(
      'Set LOCAL_REPOSITORY_URL in .env to enable',
      name: 'settings_local_extension_server_missing',
      desc: '',
      args: [],
    );
  }

  /// `Local server`
  String get local_extension_server_source_name {
    return Intl.message(
      'Local server',
      name: 'local_extension_server_source_name',
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

  /// `Export complete`
  String get settings_export_success {
    return Intl.message(
      'Export complete',
      name: 'settings_export_success',
      desc: '',
      args: [],
    );
  }

  /// `Export failed`
  String get settings_export_error {
    return Intl.message(
      'Export failed',
      name: 'settings_export_error',
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

  /// `Saves the sections you pick — reading history, library, categories, extension sources and settings — into a single JSON file you can back up or move to another device.`
  String get settings_import_export_info_export_body {
    return Intl.message(
      'Saves the sections you pick — reading history, library, categories, extension sources and settings — into a single JSON file you can back up or move to another device.',
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

  /// `Loads a previously exported JSON file and merges the sections you pick with what you already have — existing entries are updated and new ones are added, nothing is deleted.`
  String get settings_import_export_info_import_body {
    return Intl.message(
      'Loads a previously exported JSON file and merges the sections you pick with what you already have — existing entries are updated and new ones are added, nothing is deleted.',
      name: 'settings_import_export_info_import_body',
      desc: '',
      args: [],
    );
  }

  /// `Imported {imported} of {total} items`
  String settings_import_success(Object imported, Object total) {
    return Intl.message(
      'Imported $imported of $total items',
      name: 'settings_import_success',
      desc: '',
      args: [imported, total],
    );
  }

  /// `Import failed`
  String get settings_import_error {
    return Intl.message(
      'Import failed',
      name: 'settings_import_error',
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

  /// `Downloads`
  String get downloads_title {
    return Intl.message(
      'Downloads',
      name: 'downloads_title',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get downloads_order_newest {
    return Intl.message(
      'Newest first',
      name: 'downloads_order_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest first`
  String get downloads_order_oldest {
    return Intl.message(
      'Oldest first',
      name: 'downloads_order_oldest',
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

  /// `Export data`
  String get settings_export_data_button {
    return Intl.message(
      'Export data',
      name: 'settings_export_data_button',
      desc: '',
      args: [],
    );
  }

  /// `Import data`
  String get settings_import_data_button {
    return Intl.message(
      'Import data',
      name: 'settings_import_data_button',
      desc: '',
      args: [],
    );
  }

  /// `Export data`
  String get settings_export_sheet_title {
    return Intl.message(
      'Export data',
      name: 'settings_export_sheet_title',
      desc: '',
      args: [],
    );
  }

  /// `Import data`
  String get settings_import_sheet_title {
    return Intl.message(
      'Import data',
      name: 'settings_import_sheet_title',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get settings_export_sheet_confirm {
    return Intl.message(
      'Export',
      name: 'settings_export_sheet_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get settings_import_sheet_confirm {
    return Intl.message(
      'Import',
      name: 'settings_import_sheet_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get settings_export_select_all {
    return Intl.message(
      'Select all',
      name: 'settings_export_select_all',
      desc: '',
      args: [],
    );
  }

  /// `Exporting`
  String get settings_export_progress_title {
    return Intl.message(
      'Exporting',
      name: 'settings_export_progress_title',
      desc: '',
      args: [],
    );
  }

  /// `Importing`
  String get settings_import_progress_title {
    return Intl.message(
      'Importing',
      name: 'settings_import_progress_title',
      desc: '',
      args: [],
    );
  }

  /// `Preparing…`
  String get settings_progress_preparing {
    return Intl.message(
      'Preparing…',
      name: 'settings_progress_preparing',
      desc: '',
      args: [],
    );
  }

  /// `Export complete`
  String get settings_export_notification_complete {
    return Intl.message(
      'Export complete',
      name: 'settings_export_notification_complete',
      desc: '',
      args: [],
    );
  }

  /// `Import complete`
  String get settings_import_notification_complete {
    return Intl.message(
      'Import complete',
      name: 'settings_import_notification_complete',
      desc: '',
      args: [],
    );
  }

  /// `Import & export`
  String get settings_transfer_notification_channel_name {
    return Intl.message(
      'Import & export',
      name: 'settings_transfer_notification_channel_name',
      desc: '',
      args: [],
    );
  }

  /// `This file has nothing to import`
  String get settings_import_nothing_to_import {
    return Intl.message(
      'This file has nothing to import',
      name: 'settings_import_nothing_to_import',
      desc: '',
      args: [],
    );
  }

  /// `{count} skipped`
  String settings_import_skipped(Object count) {
    return Intl.message(
      '$count skipped',
      name: 'settings_import_skipped',
      desc: '',
      args: [count],
    );
  }

  /// `Reading history`
  String get export_section_history {
    return Intl.message(
      'Reading history',
      name: 'export_section_history',
      desc: '',
      args: [],
    );
  }

  /// `Chapters read and episodes watched`
  String get export_section_history_subtitle {
    return Intl.message(
      'Chapters read and episodes watched',
      name: 'export_section_history_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get export_section_library {
    return Intl.message(
      'Library',
      name: 'export_section_library',
      desc: '',
      args: [],
    );
  }

  /// `Titles you added to your library`
  String get export_section_library_subtitle {
    return Intl.message(
      'Titles you added to your library',
      name: 'export_section_library_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get export_section_categories {
    return Intl.message(
      'Categories',
      name: 'export_section_categories',
      desc: '',
      args: [],
    );
  }

  /// `Library categories`
  String get export_section_categories_subtitle {
    return Intl.message(
      'Library categories',
      name: 'export_section_categories_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Extension sources`
  String get export_section_sources {
    return Intl.message(
      'Extension sources',
      name: 'export_section_sources',
      desc: '',
      args: [],
    );
  }

  /// `Repositories you added`
  String get export_section_sources_subtitle {
    return Intl.message(
      'Repositories you added',
      name: 'export_section_sources_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get export_section_settings {
    return Intl.message(
      'Settings',
      name: 'export_section_settings',
      desc: '',
      args: [],
    );
  }

  /// `Theme, reader mode and toggles`
  String get export_section_settings_subtitle {
    return Intl.message(
      'Theme, reader mode and toggles',
      name: 'export_section_settings_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Page translations`
  String get export_section_translations {
    return Intl.message(
      'Page translations',
      name: 'export_section_translations',
      desc: '',
      args: [],
    );
  }

  /// `Translated pages, so they don't need to be translated again`
  String get export_section_translations_subtitle {
    return Intl.message(
      'Translated pages, so they don\'t need to be translated again',
      name: 'export_section_translations_subtitle',
      desc: '',
      args: [],
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

  /// `Library updates`
  String get updates_notification_channel_name {
    return Intl.message(
      'Library updates',
      name: 'updates_notification_channel_name',
      desc: '',
      args: [],
    );
  }

  /// `{count} new items`
  String updates_notification_title(Object count) {
    return Intl.message(
      '$count new items',
      name: 'updates_notification_title',
      desc: '',
      args: [count],
    );
  }

  /// `Across {count} titles`
  String updates_notification_summary(Object count) {
    return Intl.message(
      'Across $count titles',
      name: 'updates_notification_summary',
      desc: '',
      args: [count],
    );
  }

  /// `{title} · {count} new`
  String updates_notification_line(Object title, Object count) {
    return Intl.message(
      '$title · $count new',
      name: 'updates_notification_line',
      desc: '',
      args: [title, count],
    );
  }

  /// `and {count} more titles`
  String updates_notification_more(Object count) {
    return Intl.message(
      'and $count more titles',
      name: 'updates_notification_more',
      desc: '',
      args: [count],
    );
  }

  /// `Updates`
  String get updates_title {
    return Intl.message('Updates', name: 'updates_title', desc: '', args: []);
  }

  /// `No new updates`
  String get updates_empty_title {
    return Intl.message(
      'No new updates',
      name: 'updates_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `New chapters and episodes for titles in your library will appear here`
  String get updates_empty_message {
    return Intl.message(
      'New chapters and episodes for titles in your library will appear here',
      name: 'updates_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as seen`
  String get updates_mark_all_seen {
    return Intl.message(
      'Mark all as seen',
      name: 'updates_mark_all_seen',
      desc: '',
      args: [],
    );
  }

  /// `Clear updates`
  String get updates_clear {
    return Intl.message(
      'Clear updates',
      name: 'updates_clear',
      desc: '',
      args: [],
    );
  }

  /// `Checking for updates…`
  String get updates_checking {
    return Intl.message(
      'Checking for updates…',
      name: 'updates_checking',
      desc: '',
      args: [],
    );
  }

  /// `{count} sources could not be checked`
  String updates_check_failed(Object count) {
    return Intl.message(
      '$count sources could not be checked',
      name: 'updates_check_failed',
      desc: '',
      args: [count],
    );
  }

  /// `No new updates found`
  String get updates_check_none {
    return Intl.message(
      'No new updates found',
      name: 'updates_check_none',
      desc: '',
      args: [],
    );
  }

  /// `{count} new items found`
  String updates_check_found(Object count) {
    return Intl.message(
      '$count new items found',
      name: 'updates_check_found',
      desc: '',
      args: [count],
    );
  }

  /// `{source} needs you to sign in`
  String updates_attention_sign_in(Object source) {
    return Intl.message(
      '$source needs you to sign in',
      name: 'updates_attention_sign_in',
      desc: '',
      args: [source],
    );
  }

  /// `{source} needs you to sign in again`
  String updates_attention_sign_in_again(Object source) {
    return Intl.message(
      '$source needs you to sign in again',
      name: 'updates_attention_sign_in_again',
      desc: '',
      args: [source],
    );
  }

  /// `{source} needs a quick check in the browser`
  String updates_attention_browser_check(Object source) {
    return Intl.message(
      '$source needs a quick check in the browser',
      name: 'updates_attention_browser_check',
      desc: '',
      args: [source],
    );
  }

  /// `{count} sources need your attention`
  String updates_attention_many(Object count) {
    return Intl.message(
      '$count sources need your attention',
      name: 'updates_attention_many',
      desc: '',
      args: [count],
    );
  }

  /// `Sources need attention`
  String get updates_attention_sheet_title {
    return Intl.message(
      'Sources need attention',
      name: 'updates_attention_sheet_title',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get updates_attention_action_open {
    return Intl.message(
      'Open',
      name: 'updates_attention_action_open',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get updates_attention_action_review {
    return Intl.message(
      'Review',
      name: 'updates_attention_action_review',
      desc: '',
      args: [],
    );
  }

  /// `Session saved for {source}. Pull to refresh to check again`
  String updates_attention_session_saved(Object source) {
    return Intl.message(
      'Session saved for $source. Pull to refresh to check again',
      name: 'updates_attention_session_saved',
      desc: '',
      args: [source],
    );
  }

  /// `{source} has no browser sign-in`
  String updates_attention_unavailable(Object source) {
    return Intl.message(
      '$source has no browser sign-in',
      name: 'updates_attention_unavailable',
      desc: '',
      args: [source],
    );
  }

  /// `Sign in needed: {sources}`
  String updates_attention_notification_sign_in_title(Object sources) {
    return Intl.message(
      'Sign in needed: $sources',
      name: 'updates_attention_notification_sign_in_title',
      desc: '',
      args: [sources],
    );
  }

  /// `Browser check needed: {sources}`
  String updates_attention_notification_browser_title(Object sources) {
    return Intl.message(
      'Browser check needed: $sources',
      name: 'updates_attention_notification_browser_title',
      desc: '',
      args: [sources],
    );
  }

  /// `Update checks are paused for these sources. Pull to refresh your library to fix it.`
  String get updates_attention_notification_body {
    return Intl.message(
      'Update checks are paused for these sources. Pull to refresh your library to fix it.',
      name: 'updates_attention_notification_body',
      desc: '',
      args: [],
    );
  }

  /// `Clear saved session`
  String get extension_clear_session {
    return Intl.message(
      'Clear saved session',
      name: 'extension_clear_session',
      desc: '',
      args: [],
    );
  }

  /// `Saved session for {source} cleared`
  String extension_clear_session_done(Object source) {
    return Intl.message(
      'Saved session for $source cleared',
      name: 'extension_clear_session_done',
      desc: '',
      args: [source],
    );
  }

  /// `Just now`
  String get updates_time_now {
    return Intl.message(
      'Just now',
      name: 'updates_time_now',
      desc: '',
      args: [],
    );
  }

  /// `{count}m ago`
  String updates_time_minutes(Object count) {
    return Intl.message(
      '${count}m ago',
      name: 'updates_time_minutes',
      desc: '',
      args: [count],
    );
  }

  /// `{count}h ago`
  String updates_time_hours(Object count) {
    return Intl.message(
      '${count}h ago',
      name: 'updates_time_hours',
      desc: '',
      args: [count],
    );
  }

  /// `{count}d ago`
  String updates_time_days(Object count) {
    return Intl.message(
      '${count}d ago',
      name: 'updates_time_days',
      desc: '',
      args: [count],
    );
  }

  /// `Check for updates`
  String get library_track_updates {
    return Intl.message(
      'Check for updates',
      name: 'library_track_updates',
      desc: '',
      args: [],
    );
  }

  /// `Mute notifications`
  String get library_mute_notifications {
    return Intl.message(
      'Mute notifications',
      name: 'library_mute_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Unmute notifications`
  String get library_unmute_notifications {
    return Intl.message(
      'Unmute notifications',
      name: 'library_unmute_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Updates`
  String get settings_updates_section {
    return Intl.message(
      'Updates',
      name: 'settings_updates_section',
      desc: '',
      args: [],
    );
  }

  /// `Check library for updates`
  String get settings_check_updates {
    return Intl.message(
      'Check library for updates',
      name: 'settings_check_updates',
      desc: '',
      args: [],
    );
  }

  /// `Periodically look for new chapters and episodes in the background`
  String get settings_check_updates_subtitle {
    return Intl.message(
      'Periodically look for new chapters and episodes in the background',
      name: 'settings_check_updates_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Update notifications`
  String get settings_update_notifications {
    return Intl.message(
      'Update notifications',
      name: 'settings_update_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Show a notification when new items are found`
  String get settings_update_notifications_subtitle {
    return Intl.message(
      'Show a notification when new items are found',
      name: 'settings_update_notifications_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Check frequency`
  String get settings_update_frequency {
    return Intl.message(
      'Check frequency',
      name: 'settings_update_frequency',
      desc: '',
      args: [],
    );
  }

  /// `Every {hours} hours`
  String settings_update_frequency_value(Object hours) {
    return Intl.message(
      'Every $hours hours',
      name: 'settings_update_frequency_value',
      desc: '',
      args: [hours],
    );
  }

  /// `Page translation`
  String get settings_page_translation_title {
    return Intl.message(
      'Page translation',
      name: 'settings_page_translation_title',
      desc: '',
      args: [],
    );
  }

  /// `Experimental · recognize and translate text on pages`
  String get settings_page_translation_subtitle {
    return Intl.message(
      'Experimental · recognize and translate text on pages',
      name: 'settings_page_translation_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Page translation`
  String get page_translation_settings_title {
    return Intl.message(
      'Page translation',
      name: 'page_translation_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Experimental`
  String get page_translation_settings_experimental {
    return Intl.message(
      'Experimental',
      name: 'page_translation_settings_experimental',
      desc: '',
      args: [],
    );
  }

  /// `Enable page translation`
  String get page_translation_settings_enable {
    return Intl.message(
      'Enable page translation',
      name: 'page_translation_settings_enable',
      desc: '',
      args: [],
    );
  }

  /// `Adds a translate button to the reader. Text is recognized and translated on your device.`
  String get page_translation_settings_enable_subtitle {
    return Intl.message(
      'Adds a translate button to the reader. Text is recognized and translated on your device.',
      name: 'page_translation_settings_enable_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get page_translation_settings_languages_section {
    return Intl.message(
      'Languages',
      name: 'page_translation_settings_languages_section',
      desc: '',
      args: [],
    );
  }

  /// `Translate to`
  String get page_translation_settings_target {
    return Intl.message(
      'Translate to',
      name: 'page_translation_settings_target',
      desc: '',
      args: [],
    );
  }

  /// `Language packs`
  String get page_translation_settings_packs_section {
    return Intl.message(
      'Language packs',
      name: 'page_translation_settings_packs_section',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get page_translation_settings_pack_downloaded {
    return Intl.message(
      'Downloaded',
      name: 'page_translation_settings_pack_downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Not downloaded · about 30 MB`
  String get page_translation_settings_pack_missing {
    return Intl.message(
      'Not downloaded · about 30 MB',
      name: 'page_translation_settings_pack_missing',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get page_translation_settings_download_pack {
    return Intl.message(
      'Download',
      name: 'page_translation_settings_download_pack',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get page_translation_settings_delete_pack {
    return Intl.message(
      'Delete',
      name: 'page_translation_settings_delete_pack',
      desc: '',
      args: [],
    );
  }

  /// `Download on Wi-Fi only`
  String get page_translation_settings_wifi_only {
    return Intl.message(
      'Download on Wi-Fi only',
      name: 'page_translation_settings_wifi_only',
      desc: '',
      args: [],
    );
  }

  /// `Text recognition`
  String get page_translation_settings_ocr_title {
    return Intl.message(
      'Text recognition',
      name: 'page_translation_settings_ocr_title',
      desc: '',
      args: [],
    );
  }

  /// `Japanese, Korean and Chinese recognition is provided by Google Play services and downloads automatically the first time it is used.`
  String get page_translation_settings_ocr_note {
    return Intl.message(
      'Japanese, Korean and Chinese recognition is provided by Google Play services and downloads automatically the first time it is used.',
      name: 'page_translation_settings_ocr_note',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get page_translation_settings_storage_section {
    return Intl.message(
      'Storage',
      name: 'page_translation_settings_storage_section',
      desc: '',
      args: [],
    );
  }

  /// `Clear translated pages`
  String get page_translation_settings_clear_cache {
    return Intl.message(
      'Clear translated pages',
      name: 'page_translation_settings_clear_cache',
      desc: '',
      args: [],
    );
  }

  /// `{count} pages saved`
  String page_translation_settings_clear_cache_subtitle(Object count) {
    return Intl.message(
      '$count pages saved',
      name: 'page_translation_settings_clear_cache_subtitle',
      desc: '',
      args: [count],
    );
  }

  /// `Clear translated pages?`
  String get page_translation_settings_clear_cache_confirm_title {
    return Intl.message(
      'Clear translated pages?',
      name: 'page_translation_settings_clear_cache_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Pages will be translated again the next time you open them.`
  String get page_translation_settings_clear_cache_confirm_message {
    return Intl.message(
      'Pages will be translated again the next time you open them.',
      name: 'page_translation_settings_clear_cache_confirm_message',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get page_translation_settings_clear_cache_confirm_ok {
    return Intl.message(
      'Clear',
      name: 'page_translation_settings_clear_cache_confirm_ok',
      desc: '',
      args: [],
    );
  }

  /// `Download language packs`
  String get page_translation_models_title {
    return Intl.message(
      'Download language packs',
      name: 'page_translation_models_title',
      desc: '',
      args: [],
    );
  }

  /// `Translating {source} to {target} needs on-device language packs, about 30 MB each. They are downloaded once, and pages are then translated entirely on your device.`
  String page_translation_models_message(Object source, Object target) {
    return Intl.message(
      'Translating $source to $target needs on-device language packs, about 30 MB each. They are downloaded once, and pages are then translated entirely on your device.',
      name: 'page_translation_models_message',
      desc: '',
      args: [source, target],
    );
  }

  /// `Downloads wait for Wi-Fi. You can change this in Settings → Page translation.`
  String get page_translation_models_wifi_note {
    return Intl.message(
      'Downloads wait for Wi-Fi. You can change this in Settings → Page translation.',
      name: 'page_translation_models_wifi_note',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get page_translation_models_download {
    return Intl.message(
      'Download',
      name: 'page_translation_models_download',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get page_translation_models_cancel {
    return Intl.message(
      'Not now',
      name: 'page_translation_models_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Downloading language packs…`
  String get page_translation_models_downloading {
    return Intl.message(
      'Downloading language packs…',
      name: 'page_translation_models_downloading',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't download language packs`
  String get page_translation_models_failed {
    return Intl.message(
      'Couldn\'t download language packs',
      name: 'page_translation_models_failed',
      desc: '',
      args: [],
    );
  }

  /// `Translating page…`
  String get page_translation_status_translating {
    return Intl.message(
      'Translating page…',
      name: 'page_translation_status_translating',
      desc: '',
      args: [],
    );
  }

  /// `Translation failed · tap to retry`
  String get page_translation_status_failed {
    return Intl.message(
      'Translation failed · tap to retry',
      name: 'page_translation_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Preparing translation…`
  String get page_translation_status_preparing {
    return Intl.message(
      'Preparing translation…',
      name: 'page_translation_status_preparing',
      desc: '',
      args: [],
    );
  }

  /// `Older translation · tap to update`
  String get page_translation_status_outdated {
    return Intl.message(
      'Older translation · tap to update',
      name: 'page_translation_status_outdated',
      desc: '',
      args: [],
    );
  }

  /// `Retranslate`
  String get page_translation_retranslate {
    return Intl.message(
      'Retranslate',
      name: 'page_translation_retranslate',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get page_translation_edit {
    return Intl.message(
      'Edit',
      name: 'page_translation_edit',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get page_translation_copy {
    return Intl.message(
      'Copy',
      name: 'page_translation_copy',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't retranslate this bubble`
  String get page_translation_retranslate_failed {
    return Intl.message(
      'Couldn\'t retranslate this bubble',
      name: 'page_translation_retranslate_failed',
      desc: '',
      args: [],
    );
  }

  /// `No text found in the selected area`
  String get page_translation_region_empty {
    return Intl.message(
      'No text found in the selected area',
      name: 'page_translation_region_empty',
      desc: '',
      args: [],
    );
  }

  /// `Hold to see the original page`
  String get page_translation_peek_hint {
    return Intl.message(
      'Hold to see the original page',
      name: 'page_translation_peek_hint',
      desc: '',
      args: [],
    );
  }

  /// `Fix recognition mistakes, then retranslate`
  String get page_translation_original_edit_hint {
    return Intl.message(
      'Fix recognition mistakes, then retranslate',
      name: 'page_translation_original_edit_hint',
      desc: '',
      args: [],
    );
  }

  /// `Remove older translations`
  String get page_translation_settings_remove_outdated {
    return Intl.message(
      'Remove older translations',
      name: 'page_translation_settings_remove_outdated',
      desc: '',
      args: [],
    );
  }

  /// `{count} pages from an older version`
  String page_translation_settings_remove_outdated_subtitle(int count) {
    return Intl.message(
      '$count pages from an older version',
      name: 'page_translation_settings_remove_outdated_subtitle',
      desc: '',
      args: [count],
    );
  }

  /// `Google Play services is downloading text recognition…`
  String get page_translation_status_model_pending {
    return Intl.message(
      'Google Play services is downloading text recognition…',
      name: 'page_translation_status_model_pending',
      desc: '',
      args: [],
    );
  }

  /// `Original`
  String get page_translation_original_label {
    return Intl.message(
      'Original',
      name: 'page_translation_original_label',
      desc: '',
      args: [],
    );
  }

  /// `Translation`
  String get page_translation_translation_label {
    return Intl.message(
      'Translation',
      name: 'page_translation_translation_label',
      desc: '',
      args: [],
    );
  }

  /// `Copy original`
  String get page_translation_copy_original {
    return Intl.message(
      'Copy original',
      name: 'page_translation_copy_original',
      desc: '',
      args: [],
    );
  }

  /// `Copy translation`
  String get page_translation_copy_translation {
    return Intl.message(
      'Copy translation',
      name: 'page_translation_copy_translation',
      desc: '',
      args: [],
    );
  }

  /// `Show original`
  String get page_translation_show_original {
    return Intl.message(
      'Show original',
      name: 'page_translation_show_original',
      desc: '',
      args: [],
    );
  }

  /// `Show translation`
  String get page_translation_show_translation {
    return Intl.message(
      'Show translation',
      name: 'page_translation_show_translation',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get page_translation_copied {
    return Intl.message(
      'Copied',
      name: 'page_translation_copied',
      desc: '',
      args: [],
    );
  }

  /// `Default for titles you translate for the first time. Each title remembers its own languages.`
  String get page_translation_settings_target_subtitle {
    return Intl.message(
      'Default for titles you translate for the first time. Each title remembers its own languages.',
      name: 'page_translation_settings_target_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Translation languages`
  String get page_translation_languages_title {
    return Intl.message(
      'Translation languages',
      name: 'page_translation_languages_title',
      desc: '',
      args: [],
    );
  }

  /// `Saved for this title only.`
  String get page_translation_languages_subtitle {
    return Intl.message(
      'Saved for this title only.',
      name: 'page_translation_languages_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Text on pages`
  String get page_translation_languages_from {
    return Intl.message(
      'Text on pages',
      name: 'page_translation_languages_from',
      desc: '',
      args: [],
    );
  }

  /// `Translate to`
  String get page_translation_languages_to {
    return Intl.message(
      'Translate to',
      name: 'page_translation_languages_to',
      desc: '',
      args: [],
    );
  }

  /// `Translate`
  String get page_translation_languages_start {
    return Intl.message(
      'Translate',
      name: 'page_translation_languages_start',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get page_translation_languages_save {
    return Intl.message(
      'Save',
      name: 'page_translation_languages_save',
      desc: '',
      args: [],
    );
  }

  /// `Downloading language packs {current}/{total}…`
  String page_translation_models_downloading_progress(
    Object current,
    Object total,
  ) {
    return Intl.message(
      'Downloading language packs $current/$total…',
      name: 'page_translation_models_downloading_progress',
      desc: '',
      args: [current, total],
    );
  }

  /// `Language packs`
  String get language_packs_title {
    return Intl.message(
      'Language packs',
      name: 'language_packs_title',
      desc: '',
      args: [],
    );
  }

  /// `Each pack is about 30 MB. You only need the languages you translate from and to.`
  String get language_packs_hint {
    return Intl.message(
      'Each pack is about 30 MB. You only need the languages you translate from and to.',
      name: 'language_packs_hint',
      desc: '',
      args: [],
    );
  }

  /// `Each pack is about 30 MB. You only need the languages you translate from and to. Downloads wait for Wi-Fi.`
  String get language_packs_hint_wifi {
    return Intl.message(
      'Each pack is about 30 MB. You only need the languages you translate from and to. Downloads wait for Wi-Fi.',
      name: 'language_packs_hint_wifi',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get language_packs_downloaded_section {
    return Intl.message(
      'Downloaded',
      name: 'language_packs_downloaded_section',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get language_packs_available_section {
    return Intl.message(
      'Available',
      name: 'language_packs_available_section',
      desc: '',
      args: [],
    );
  }

  /// `Downloading {current} of {total}`
  String language_packs_queue_progress(Object current, Object total) {
    return Intl.message(
      'Downloading $current of $total',
      name: 'language_packs_queue_progress',
      desc: '',
      args: [current, total],
    );
  }

  /// `Queued · #{position}`
  String language_packs_queued(Object position) {
    return Intl.message(
      'Queued · #$position',
      name: 'language_packs_queued',
      desc: '',
      args: [position],
    );
  }

  /// `Download failed`
  String get language_packs_failed {
    return Intl.message(
      'Download failed',
      name: 'language_packs_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get language_packs_retry {
    return Intl.message(
      'Retry',
      name: 'language_packs_retry',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get language_packs_cancel {
    return Intl.message(
      'Cancel',
      name: 'language_packs_cancel',
      desc: '',
      args: [],
    );
  }

  /// `{count} downloaded`
  String language_packs_downloaded_count(Object count) {
    return Intl.message(
      '$count downloaded',
      name: 'language_packs_downloaded_count',
      desc: '',
      args: [count],
    );
  }

  /// `Downloading AI model {progress}%`
  String page_translation_ai_model_downloading(Object progress) {
    return Intl.message(
      'Downloading AI model $progress%',
      name: 'page_translation_ai_model_downloading',
      desc: '',
      args: [progress],
    );
  }

  /// `Translating chapter {done}/{total}`
  String page_translation_status_chapter(Object done, Object total) {
    return Intl.message(
      'Translating chapter $done/$total',
      name: 'page_translation_status_chapter',
      desc: '',
      args: [done, total],
    );
  }

  /// `Translate whole chapter`
  String get page_translation_translate_chapter {
    return Intl.message(
      'Translate whole chapter',
      name: 'page_translation_translate_chapter',
      desc: '',
      args: [],
    );
  }

  /// `Download the AI model`
  String get page_translation_ai_model_title {
    return Intl.message(
      'Download the AI model',
      name: 'page_translation_ai_model_title',
      desc: '',
      args: [],
    );
  }

  /// `{model} needs a one-time {size} GB download. Use Wi-Fi: the model is stored on your phone and translation then runs fully offline.`
  String page_translation_ai_model_message(String model, String size) {
    return Intl.message(
      '$model needs a one-time $size GB download. Use Wi-Fi: the model is stored on your phone and translation then runs fully offline.',
      name: 'page_translation_ai_model_message',
      desc: '',
      args: [model, size],
    );
  }

  /// `Translation engine`
  String get translation_engine_section {
    return Intl.message(
      'Translation engine',
      name: 'translation_engine_section',
      desc: '',
      args: [],
    );
  }

  /// `ML Kit`
  String get translation_engine_mlkit {
    return Intl.message(
      'ML Kit',
      name: 'translation_engine_mlkit',
      desc: '',
      args: [],
    );
  }

  /// `Fast and light · works on every phone · literal translations`
  String get translation_engine_mlkit_subtitle {
    return Intl.message(
      'Fast and light · works on every phone · literal translations',
      name: 'translation_engine_mlkit_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Gemma 4 E2B · on-device AI`
  String get translation_engine_gemma {
    return Intl.message(
      'Gemma 4 E2B · on-device AI',
      name: 'translation_engine_gemma',
      desc: '',
      args: [],
    );
  }

  /// `Natural translations that fix text-recognition mistakes · 2.6 GB · 8 GB RAM`
  String get translation_engine_gemma_subtitle {
    return Intl.message(
      'Natural translations that fix text-recognition mistakes · 2.6 GB · 8 GB RAM',
      name: 'translation_engine_gemma_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Gemma 4 E4B · on-device AI`
  String get translation_engine_gemma_e4b {
    return Intl.message(
      'Gemma 4 E4B · on-device AI',
      name: 'translation_engine_gemma_e4b',
      desc: '',
      args: [],
    );
  }

  /// `Better translations, about twice as slow · 3.7 GB · 12 GB RAM`
  String get translation_engine_gemma_e4b_subtitle {
    return Intl.message(
      'Better translations, about twice as slow · 3.7 GB · 12 GB RAM',
      name: 'translation_engine_gemma_e4b_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `DeepL · online`
  String get translation_engine_deepl {
    return Intl.message(
      'DeepL · online',
      name: 'translation_engine_deepl',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get translation_engine_change {
    return Intl.message(
      'Change',
      name: 'translation_engine_change',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get page_translation_appearance_section {
    return Intl.message(
      'Appearance',
      name: 'page_translation_appearance_section',
      desc: '',
      args: [],
    );
  }

  /// `Names & terms`
  String get page_translation_glossary_title {
    return Intl.message(
      'Names & terms',
      name: 'page_translation_glossary_title',
      desc: '',
      args: [],
    );
  }

  /// `Keep character names and terms consistent in this title. Used by DeepL and Gemma.`
  String get page_translation_glossary_subtitle {
    return Intl.message(
      'Keep character names and terms consistent in this title. Used by DeepL and Gemma.',
      name: 'page_translation_glossary_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `ML Kit can't use names & terms. Switch to DeepL or Gemma in Page translation settings.`
  String get page_translation_glossary_unsupported {
    return Intl.message(
      'ML Kit can\'t use names & terms. Switch to DeepL or Gemma in Page translation settings.',
      name: 'page_translation_glossary_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Add name`
  String get page_translation_glossary_add {
    return Intl.message(
      'Add name',
      name: 'page_translation_glossary_add',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get page_translation_glossary_save {
    return Intl.message(
      'Save',
      name: 'page_translation_glossary_save',
      desc: '',
      args: [],
    );
  }

  /// `Save & retranslate chapter`
  String get page_translation_glossary_save_retranslate {
    return Intl.message(
      'Save & retranslate chapter',
      name: 'page_translation_glossary_save_retranslate',
      desc: '',
      args: [],
    );
  }

  /// `None yet`
  String get page_translation_glossary_empty {
    return Intl.message(
      'None yet',
      name: 'page_translation_glossary_empty',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 name} other{{count} names}}`
  String page_translation_glossary_count(int count) {
    return Intl.plural(
      count,
      one: '1 name',
      other: '$count names',
      name: 'page_translation_glossary_count',
      desc: '',
      args: [count],
    );
  }

  /// `Text size`
  String get page_translation_text_size {
    return Intl.message(
      'Text size',
      name: 'page_translation_text_size',
      desc: '',
      args: [],
    );
  }

  /// `Largest size translated text may use on screen`
  String get page_translation_text_size_subtitle {
    return Intl.message(
      'Largest size translated text may use on screen',
      name: 'page_translation_text_size_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get page_translation_text_size_auto {
    return Intl.message(
      'Auto',
      name: 'page_translation_text_size_auto',
      desc: '',
      args: [],
    );
  }

  /// `Up to {size} px`
  String page_translation_text_size_pixels(int size) {
    return Intl.message(
      'Up to $size px',
      name: 'page_translation_text_size_pixels',
      desc: '',
      args: [size],
    );
  }

  /// `Font`
  String get page_translation_font {
    return Intl.message(
      'Font',
      name: 'page_translation_font',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get page_translation_font_system {
    return Intl.message(
      'System',
      name: 'page_translation_font_system',
      desc: '',
      args: [],
    );
  }

  /// `Comic`
  String get page_translation_font_comic {
    return Intl.message(
      'Comic',
      name: 'page_translation_font_comic',
      desc: '',
      args: [],
    );
  }

  /// `Label background`
  String get page_translation_label_background {
    return Intl.message(
      'Label background',
      name: 'page_translation_label_background',
      desc: '',
      args: [],
    );
  }

  /// `For text outside speech bubbles`
  String get page_translation_label_background_subtitle {
    return Intl.message(
      'For text outside speech bubbles',
      name: 'page_translation_label_background_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `What are you doing here?!`
  String get page_translation_preview_bubble {
    return Intl.message(
      'What are you doing here?!',
      name: 'page_translation_preview_bubble',
      desc: '',
      args: [],
    );
  }

  /// `Meanwhile, in Tokyo…`
  String get page_translation_preview_label {
    return Intl.message(
      'Meanwhile, in Tokyo…',
      name: 'page_translation_preview_label',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get engine_tag_offline {
    return Intl.message(
      'Offline',
      name: 'engine_tag_offline',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get engine_tag_online {
    return Intl.message(
      'Online',
      name: 'engine_tag_online',
      desc: '',
      args: [],
    );
  }

  /// `Fast`
  String get engine_tag_fast {
    return Intl.message('Fast', name: 'engine_tag_fast', desc: '', args: []);
  }

  /// `Literal`
  String get engine_tag_literal {
    return Intl.message(
      'Literal',
      name: 'engine_tag_literal',
      desc: '',
      args: [],
    );
  }

  /// `Natural`
  String get engine_tag_natural {
    return Intl.message(
      'Natural',
      name: 'engine_tag_natural',
      desc: '',
      args: [],
    );
  }

  /// `Best quality`
  String get engine_tag_best {
    return Intl.message(
      'Best quality',
      name: 'engine_tag_best',
      desc: '',
      args: [],
    );
  }

  /// `{size} GB`
  String engine_tag_size(String size) {
    return Intl.message(
      '$size GB',
      name: 'engine_tag_size',
      desc: '',
      args: [size],
    );
  }

  /// `Best quality · sends the recognised text to DeepL · needs a free API key`
  String get translation_engine_deepl_subtitle {
    return Intl.message(
      'Best quality · sends the recognised text to DeepL · needs a free API key',
      name: 'translation_engine_deepl_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Not available on this device`
  String get translation_engine_gemma_unavailable_platform {
    return Intl.message(
      'Not available on this device',
      name: 'translation_engine_gemma_unavailable_platform',
      desc: '',
      args: [],
    );
  }

  /// `Needs Android 11 or newer`
  String get translation_engine_gemma_unavailable_android {
    return Intl.message(
      'Needs Android 11 or newer',
      name: 'translation_engine_gemma_unavailable_android',
      desc: '',
      args: [],
    );
  }

  /// `Needs a 64-bit phone`
  String get translation_engine_gemma_unavailable_64bit {
    return Intl.message(
      'Needs a 64-bit phone',
      name: 'translation_engine_gemma_unavailable_64bit',
      desc: '',
      args: [],
    );
  }

  /// `Needs {need} GB of RAM (this phone has {ram} GB)`
  String translation_engine_gemma_unavailable_ram(int need, int ram) {
    return Intl.message(
      'Needs $need GB of RAM (this phone has $ram GB)',
      name: 'translation_engine_gemma_unavailable_ram',
      desc: '',
      args: [need, ram],
    );
  }

  /// `AI model`
  String get translation_ai_model_title {
    return Intl.message(
      'AI model',
      name: 'translation_ai_model_title',
      desc: '',
      args: [],
    );
  }

  /// `{model} · {size} GB · ready`
  String translation_ai_model_installed(String model, String size) {
    return Intl.message(
      '$model · $size GB · ready',
      name: 'translation_ai_model_installed',
      desc: '',
      args: [model, size],
    );
  }

  /// `Download failed · try again on Wi-Fi`
  String get translation_ai_model_failed {
    return Intl.message(
      'Download failed · try again on Wi-Fi',
      name: 'translation_ai_model_failed',
      desc: '',
      args: [],
    );
  }

  /// `Not downloaded · {size} GB`
  String translation_ai_model_missing(String size) {
    return Intl.message(
      'Not downloaded · $size GB',
      name: 'translation_ai_model_missing',
      desc: '',
      args: [size],
    );
  }

  /// `Delete the AI model?`
  String get translation_ai_model_delete_title {
    return Intl.message(
      'Delete the AI model?',
      name: 'translation_ai_model_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `This frees {size} GB. You can download it again at any time.`
  String translation_ai_model_delete_message(String size) {
    return Intl.message(
      'This frees $size GB. You can download it again at any time.',
      name: 'translation_ai_model_delete_message',
      desc: '',
      args: [size],
    );
  }

  /// `Downloaded models`
  String get translation_models_title {
    return Intl.message(
      'Downloaded models',
      name: 'translation_models_title',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{No AI models downloaded} =1{1 AI model · {size} GB} other{{count} AI models · {size} GB}}`
  String translation_models_summary(int count, String size) {
    return Intl.plural(
      count,
      zero: 'No AI models downloaded',
      one: '1 AI model · $size GB',
      other: '$count AI models · $size GB',
      name: 'translation_models_summary',
      desc: '',
      args: [count, size],
    );
  }

  /// `On-device AI`
  String get translation_models_ai_section {
    return Intl.message(
      'On-device AI',
      name: 'translation_models_ai_section',
      desc: '',
      args: [],
    );
  }

  /// `ML Kit`
  String get translation_models_packs_section {
    return Intl.message(
      'ML Kit',
      name: 'translation_models_packs_section',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{No language packs yet} =1{1 language pack downloaded} other{{count} language packs downloaded}}`
  String translation_models_packs_count(int count) {
    return Intl.plural(
      count,
      zero: 'No language packs yet',
      one: '1 language pack downloaded',
      other: '$count language packs downloaded',
      name: 'translation_models_packs_count',
      desc: '',
      args: [count],
    );
  }

  /// `Downloaded · {size} GB`
  String translation_models_downloaded(String size) {
    return Intl.message(
      'Downloaded · $size GB',
      name: 'translation_models_downloaded',
      desc: '',
      args: [size],
    );
  }

  /// `Not supported on this phone`
  String get translation_models_unsupported {
    return Intl.message(
      'Not supported on this phone',
      name: 'translation_models_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Not downloaded · {size} GB · choose it as the engine to download`
  String translation_models_pick_first(String size) {
    return Intl.message(
      'Not downloaded · $size GB · choose it as the engine to download',
      name: 'translation_models_pick_first',
      desc: '',
      args: [size],
    );
  }

  /// `DeepL API key`
  String get deepl_key_title {
    return Intl.message(
      'DeepL API key',
      name: 'deepl_key_title',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get deepl_key_missing {
    return Intl.message(
      'Not set',
      name: 'deepl_key_missing',
      desc: '',
      args: [],
    );
  }

  /// `Key ••••{ending}`
  String deepl_key_masked(String ending) {
    return Intl.message(
      'Key ••••$ending',
      name: 'deepl_key_masked',
      desc: '',
      args: [ending],
    );
  }

  /// `used this month`
  String get deepl_usage_used {
    return Intl.message(
      'used this month',
      name: 'deepl_usage_used',
      desc: '',
      args: [],
    );
  }

  /// `{count} left`
  String deepl_usage_left(String count) {
    return Intl.message(
      '$count left',
      name: 'deepl_usage_left',
      desc: '',
      args: [count],
    );
  }

  /// `{used} of {limit} characters`
  String deepl_usage_characters(String used, String limit) {
    return Intl.message(
      '$used of $limit characters',
      name: 'deepl_usage_characters',
      desc: '',
      args: [used, limit],
    );
  }

  /// `Usage is unavailable right now`
  String get deepl_usage_unavailable {
    return Intl.message(
      'Usage is unavailable right now',
      name: 'deepl_usage_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `{speed} MB/s`
  String download_speed_megabytes(String speed) {
    return Intl.message(
      '$speed MB/s',
      name: 'download_speed_megabytes',
      desc: '',
      args: [speed],
    );
  }

  /// `{time} left`
  String download_time_left(String time) {
    return Intl.message(
      '$time left',
      name: 'download_time_left',
      desc: '',
      args: [time],
    );
  }

  /// `{hours} h {minutes} min`
  String duration_hours_minutes(int hours, int minutes) {
    return Intl.message(
      '$hours h $minutes min',
      name: 'duration_hours_minutes',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `{minutes} min`
  String duration_minutes(int minutes) {
    return Intl.message(
      '$minutes min',
      name: 'duration_minutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `{seconds} s`
  String duration_seconds(int seconds) {
    return Intl.message(
      '$seconds s',
      name: 'duration_seconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `Add a DeepL API key in Page translation settings first`
  String get deepl_key_needed {
    return Intl.message(
      'Add a DeepL API key in Page translation settings first',
      name: 'deepl_key_needed',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get deepl_key_change {
    return Intl.message('Change', name: 'deepl_key_change', desc: '', args: []);
  }

  /// `Remove`
  String get deepl_key_remove {
    return Intl.message('Remove', name: 'deepl_key_remove', desc: '', args: []);
  }

  /// `Create a free DeepL API account and paste its authentication key here. The free plan includes a monthly character allowance; you can see it here once the key is saved. The key is stored only on this phone.`
  String get deepl_key_dialog_message {
    return Intl.message(
      'Create a free DeepL API account and paste its authentication key here. The free plan includes a monthly character allowance; you can see it here once the key is saved. The key is stored only on this phone.',
      name: 'deepl_key_dialog_message',
      desc: '',
      args: [],
    );
  }

  /// `Paste your API key`
  String get deepl_key_hint {
    return Intl.message(
      'Paste your API key',
      name: 'deepl_key_hint',
      desc: '',
      args: [],
    );
  }

  /// `Get a free key`
  String get deepl_key_get {
    return Intl.message(
      'Get a free key',
      name: 'deepl_key_get',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get deepl_key_save {
    return Intl.message('Save', name: 'deepl_key_save', desc: '', args: []);
  }

  /// `Cancel`
  String get deepl_key_cancel {
    return Intl.message('Cancel', name: 'deepl_key_cancel', desc: '', args: []);
  }

  /// `DeepL did not accept this key`
  String get deepl_key_invalid {
    return Intl.message(
      'DeepL did not accept this key',
      name: 'deepl_key_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Could not reach DeepL. Check your connection.`
  String get deepl_key_network {
    return Intl.message(
      'Could not reach DeepL. Check your connection.',
      name: 'deepl_key_network',
      desc: '',
      args: [],
    );
  }

  /// `Gemma 4 runs entirely on your phone. It reads the whole page at once, fixes text-recognition mistakes and translates naturally. E4B translates noticeably better than E2B but is about twice as slow. Nothing leaves your device.`
  String get translation_engine_info_intro {
    return Intl.message(
      'Gemma 4 runs entirely on your phone. It reads the whole page at once, fixes text-recognition mistakes and translates naturally. E4B translates noticeably better than E2B but is about twice as slow. Nothing leaves your device.',
      name: 'translation_engine_info_intro',
      desc: '',
      args: [],
    );
  }

  /// `Requirements`
  String get translation_engine_info_requirements {
    return Intl.message(
      'Requirements',
      name: 'translation_engine_info_requirements',
      desc: '',
      args: [],
    );
  }

  /// `Android 11 or newer`
  String get translation_engine_req_android {
    return Intl.message(
      'Android 11 or newer',
      name: 'translation_engine_req_android',
      desc: '',
      args: [],
    );
  }

  /// `64-bit (arm64) processor`
  String get translation_engine_req_64bit {
    return Intl.message(
      '64-bit (arm64) processor',
      name: 'translation_engine_req_64bit',
      desc: '',
      args: [],
    );
  }

  /// `This phone: {model} · {ram} GB RAM`
  String translation_engine_info_this_phone(Object model, Object ram) {
    return Intl.message(
      'This phone: $model · $ram GB RAM',
      name: 'translation_engine_info_this_phone',
      desc: '',
      args: [model, ram],
    );
  }

  /// `Speed by phone (estimated)`
  String get translation_engine_info_examples {
    return Intl.message(
      'Speed by phone (estimated)',
      name: 'translation_engine_info_examples',
      desc: '',
      args: [],
    );
  }

  /// `Fast · about 4–10 s per page`
  String get translation_engine_tier_fast {
    return Intl.message(
      'Fast · about 4–10 s per page',
      name: 'translation_engine_tier_fast',
      desc: '',
      args: [],
    );
  }

  /// `Galaxy S24 / S25, Pixel 9 / 10, OnePlus 12 / 13, Xiaomi 14 / 15 and other 2024+ flagships with 12 GB RAM`
  String get translation_engine_tier_fast_phones {
    return Intl.message(
      'Galaxy S24 / S25, Pixel 9 / 10, OnePlus 12 / 13, Xiaomi 14 / 15 and other 2024+ flagships with 12 GB RAM',
      name: 'translation_engine_tier_fast_phones',
      desc: '',
      args: [],
    );
  }

  /// `Usable · noticeably slower`
  String get translation_engine_tier_ok {
    return Intl.message(
      'Usable · noticeably slower',
      name: 'translation_engine_tier_ok',
      desc: '',
      args: [],
    );
  }

  /// `Galaxy S22 / S23, Pixel 8, Galaxy A55 and other phones with 8 GB RAM`
  String get translation_engine_tier_ok_phones {
    return Intl.message(
      'Galaxy S22 / S23, Pixel 8, Galaxy A55 and other phones with 8 GB RAM',
      name: 'translation_engine_tier_ok_phones',
      desc: '',
      args: [],
    );
  }

  /// `Not supported`
  String get translation_engine_tier_no {
    return Intl.message(
      'Not supported',
      name: 'translation_engine_tier_no',
      desc: '',
      args: [],
    );
  }

  /// `Phones with less than 8 GB RAM, 32-bit phones and Android 10 or older`
  String get translation_engine_tier_no_phones {
    return Intl.message(
      'Phones with less than 8 GB RAM, 32-bit phones and Android 10 or older',
      name: 'translation_engine_tier_no_phones',
      desc: '',
      args: [],
    );
  }

  /// `≈4–10 s per page`
  String get engine_tag_speed_e2b {
    return Intl.message(
      '≈4–10 s per page',
      name: 'engine_tag_speed_e2b',
      desc: '',
      args: [],
    );
  }

  /// `≈20–45 s per page`
  String get engine_tag_speed_e4b {
    return Intl.message(
      '≈20–45 s per page',
      name: 'engine_tag_speed_e4b',
      desc: '',
      args: [],
    );
  }

  /// `{ram} GB of RAM or more`
  String translation_engine_req_ram_model(int ram) {
    return Intl.message(
      '$ram GB of RAM or more',
      name: 'translation_engine_req_ram_model',
      desc: '',
      args: [ram],
    );
  }

  /// `About {size} GB of free storage`
  String translation_engine_req_storage_model(String size) {
    return Intl.message(
      'About $size GB of free storage',
      name: 'translation_engine_req_storage_model',
      desc: '',
      args: [size],
    );
  }

  /// `About 20–45 s per page`
  String get translation_engine_tier_e4b {
    return Intl.message(
      'About 20–45 s per page',
      name: 'translation_engine_tier_e4b',
      desc: '',
      args: [],
    );
  }

  /// `Phones with less than 12 GB RAM`
  String get translation_engine_tier_e4b_no_phones {
    return Intl.message(
      'Phones with less than 12 GB RAM',
      name: 'translation_engine_tier_e4b_no_phones',
      desc: '',
      args: [],
    );
  }

  /// `Speeds are estimates; the fast tier was measured on a Galaxy S24 Ultra. Translating ahead while you read, and translating downloaded chapters in advance, hides most of the wait.`
  String get translation_engine_info_footer {
    return Intl.message(
      'Speeds are estimates; the fast tier was measured on a Galaxy S24 Ultra. Translating ahead while you read, and translating downloaded chapters in advance, hides most of the wait.',
      name: 'translation_engine_info_footer',
      desc: '',
      args: [],
    );
  }

  /// `{count} chapters queued for translation`
  String chapter_translation_queued(Object count) {
    return Intl.message(
      '$count chapters queued for translation',
      name: 'chapter_translation_queued',
      desc: '',
      args: [count],
    );
  }

  /// `Stop translating`
  String get chapter_translation_cancel {
    return Intl.message(
      'Stop translating',
      name: 'chapter_translation_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Translate chapter`
  String get chapter_translation_translate {
    return Intl.message(
      'Translate chapter',
      name: 'chapter_translation_translate',
      desc: '',
      args: [],
    );
  }

  /// `Translate all downloaded chapters`
  String get chapter_translation_translate_all {
    return Intl.message(
      'Translate all downloaded chapters',
      name: 'chapter_translation_translate_all',
      desc: '',
      args: [],
    );
  }

  /// `Waiting to translate`
  String get chapter_translation_queued_status {
    return Intl.message(
      'Waiting to translate',
      name: 'chapter_translation_queued_status',
      desc: '',
      args: [],
    );
  }

  /// `Preparing translation…`
  String get chapter_translation_preparing {
    return Intl.message(
      'Preparing translation…',
      name: 'chapter_translation_preparing',
      desc: '',
      args: [],
    );
  }

  /// `Translating {done}/{total}`
  String chapter_translation_progress(Object done, Object total) {
    return Intl.message(
      'Translating $done/$total',
      name: 'chapter_translation_progress',
      desc: '',
      args: [done, total],
    );
  }

  /// `Translated`
  String get chapter_translation_done {
    return Intl.message(
      'Translated',
      name: 'chapter_translation_done',
      desc: '',
      args: [],
    );
  }

  /// `Translated · {failed} pages failed`
  String chapter_translation_done_partial(Object failed) {
    return Intl.message(
      'Translated · $failed pages failed',
      name: 'chapter_translation_done_partial',
      desc: '',
      args: [failed],
    );
  }

  /// `Translation failed`
  String get chapter_translation_failed {
    return Intl.message(
      'Translation failed',
      name: 'chapter_translation_failed',
      desc: '',
      args: [],
    );
  }

  /// `Downloading, then translating`
  String get chapter_translation_waiting_download {
    return Intl.message(
      'Downloading, then translating',
      name: 'chapter_translation_waiting_download',
      desc: '',
      args: [],
    );
  }

  /// `Translate`
  String get concrete_selection_translate {
    return Intl.message(
      'Translate',
      name: 'concrete_selection_translate',
      desc: '',
      args: [],
    );
  }

  /// `Translate every page in the background`
  String get page_translation_translate_chapter_hint {
    return Intl.message(
      'Translate every page in the background',
      name: 'page_translation_translate_chapter_hint',
      desc: '',
      args: [],
    );
  }

  /// `Cancel all`
  String get chapter_translation_cancel_all {
    return Intl.message(
      'Cancel all',
      name: 'chapter_translation_cancel_all',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get chapter_translation_pause {
    return Intl.message(
      'Pause',
      name: 'chapter_translation_pause',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get chapter_translation_resume {
    return Intl.message(
      'Resume',
      name: 'chapter_translation_resume',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get chapter_translation_notification_paused {
    return Intl.message(
      'Paused',
      name: 'chapter_translation_notification_paused',
      desc: '',
      args: [],
    );
  }

  /// `{count} chapters left`
  String chapter_translation_notification_remaining(Object count) {
    return Intl.message(
      '$count chapters left',
      name: 'chapter_translation_notification_remaining',
      desc: '',
      args: [count],
    );
  }

  /// `Chapter translation`
  String get chapter_translation_notification_channel {
    return Intl.message(
      'Chapter translation',
      name: 'chapter_translation_notification_channel',
      desc: '',
      args: [],
    );
  }

  /// `Translation finished`
  String get chapter_translation_notification_done_title {
    return Intl.message(
      'Translation finished',
      name: 'chapter_translation_notification_done_title',
      desc: '',
      args: [],
    );
  }

  /// `{count} chapters translated`
  String chapter_translation_notification_done_body(Object count) {
    return Intl.message(
      '$count chapters translated',
      name: 'chapter_translation_notification_done_body',
      desc: '',
      args: [count],
    );
  }

  /// `Translation queue`
  String get chapter_translation_queue_title {
    return Intl.message(
      'Translation queue',
      name: 'chapter_translation_queue_title',
      desc: '',
      args: [],
    );
  }

  /// `Titles`
  String get library_tab_titles {
    return Intl.message(
      'Titles',
      name: 'library_tab_titles',
      desc: '',
      args: [],
    );
  }

  /// `Automatic backups`
  String get settings_auto_backup_title {
    return Intl.message(
      'Automatic backups',
      name: 'settings_auto_backup_title',
      desc: '',
      args: [],
    );
  }

  /// `Off · use Export to save a backup yourself`
  String get settings_auto_backup_off {
    return Intl.message(
      'Off · use Export to save a backup yourself',
      name: 'settings_auto_backup_off',
      desc: '',
      args: [],
    );
  }

  /// `Daily to Download/Wakaranai · no backup yet`
  String get settings_auto_backup_never {
    return Intl.message(
      'Daily to Download/Wakaranai · no backup yet',
      name: 'settings_auto_backup_never',
      desc: '',
      args: [],
    );
  }

  /// `Daily to Download/Wakaranai · last {time}`
  String settings_auto_backup_last(String time) {
    return Intl.message(
      'Daily to Download/Wakaranai · last $time',
      name: 'settings_auto_backup_last',
      desc: '',
      args: [time],
    );
  }

  /// `The last backup failed · tap Back up now to retry`
  String get settings_auto_backup_failed {
    return Intl.message(
      'The last backup failed · tap Back up now to retry',
      name: 'settings_auto_backup_failed',
      desc: '',
      args: [],
    );
  }

  /// `Back up now`
  String get settings_auto_backup_now {
    return Intl.message(
      'Back up now',
      name: 'settings_auto_backup_now',
      desc: '',
      args: [],
    );
  }

  /// `Backup saved to Download/Wakaranai`
  String get settings_auto_backup_saved {
    return Intl.message(
      'Backup saved to Download/Wakaranai',
      name: 'settings_auto_backup_saved',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get web_browser_back {
    return Intl.message('Back', name: 'web_browser_back', desc: '', args: []);
  }

  /// `Forward`
  String get web_browser_forward {
    return Intl.message(
      'Forward',
      name: 'web_browser_forward',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get web_browser_reload {
    return Intl.message(
      'Reload',
      name: 'web_browser_reload',
      desc: '',
      args: [],
    );
  }

  /// `Stop loading`
  String get web_browser_stop {
    return Intl.message(
      'Stop loading',
      name: 'web_browser_stop',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get web_browser_more {
    return Intl.message('More', name: 'web_browser_more', desc: '', args: []);
  }

  /// `Copy link`
  String get web_browser_copy_link {
    return Intl.message(
      'Copy link',
      name: 'web_browser_copy_link',
      desc: '',
      args: [],
    );
  }

  /// `Link copied`
  String get web_browser_link_copied {
    return Intl.message(
      'Link copied',
      name: 'web_browser_link_copied',
      desc: '',
      args: [],
    );
  }

  /// `Open in external browser`
  String get web_browser_open_external {
    return Intl.message(
      'Open in external browser',
      name: 'web_browser_open_external',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't open an external browser`
  String get web_browser_open_external_failed {
    return Intl.message(
      'Couldn\'t open an external browser',
      name: 'web_browser_open_external_failed',
      desc: '',
      args: [],
    );
  }

  /// `Clear cookies for this site`
  String get web_browser_clear_cookies {
    return Intl.message(
      'Clear cookies for this site',
      name: 'web_browser_clear_cookies',
      desc: '',
      args: [],
    );
  }

  /// `Cookies cleared for {host}`
  String web_browser_cookies_cleared(Object host) {
    return Intl.message(
      'Cookies cleared for $host',
      name: 'web_browser_cookies_cleared',
      desc: '',
      args: [host],
    );
  }

  /// `Looks good — continue`
  String get web_browser_looks_good {
    return Intl.message(
      'Looks good — continue',
      name: 'web_browser_looks_good',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load this page`
  String get web_browser_error_title {
    return Intl.message(
      'Couldn\'t load this page',
      name: 'web_browser_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get web_browser_retry {
    return Intl.message('Retry', name: 'web_browser_retry', desc: '', args: []);
  }

  /// `Close window`
  String get web_browser_popup_close {
    return Intl.message(
      'Close window',
      name: 'web_browser_popup_close',
      desc: '',
      args: [],
    );
  }

  /// `This source needs a quick check in the browser`
  String get browser_check_required_title {
    return Intl.message(
      'This source needs a quick check in the browser',
      name: 'browser_check_required_title',
      desc: '',
      args: [],
    );
  }

  /// `Its protection page didn't clear on its own. Finish the check in the browser, then tap Done to continue.`
  String get browser_check_required_message {
    return Intl.message(
      'Its protection page didn\'t clear on its own. Finish the check in the browser, then tap Done to continue.',
      name: 'browser_check_required_message',
      desc: '',
      args: [],
    );
  }

  /// `Open browser`
  String get browser_check_open_button {
    return Intl.message(
      'Open browser',
      name: 'browser_check_open_button',
      desc: '',
      args: [],
    );
  }

  /// `Reconnecting to the source…`
  String get browser_check_reconnecting {
    return Intl.message(
      'Reconnecting to the source…',
      name: 'browser_check_reconnecting',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get browser_check_dismiss {
    return Intl.message(
      'Dismiss',
      name: 'browser_check_dismiss',
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
