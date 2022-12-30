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

  static String m0(date) => "Last visit: ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "download_again":
            MessageLookupByLibrary.simpleMessage("Download again"),
        "history_last_visit": m0,
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
        "right_to_left_read_mode":
            MessageLookupByLibrary.simpleMessage("Right to left"),
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
