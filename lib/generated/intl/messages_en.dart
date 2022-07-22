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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "download_again":
            MessageLookupByLibrary.simpleMessage("Download again"),
        "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Manga"),
        "left_to_right_read_mode":
            MessageLookupByLibrary.simpleMessage("Left to right"),
        "right_to_left_read_mode":
            MessageLookupByLibrary.simpleMessage("Right to left"),
        "service_viewer_search_field_hint_text":
            MessageLookupByLibrary.simpleMessage("Search"),
        "settings_default_reader_mode_title":
            MessageLookupByLibrary.simpleMessage("Default reader mode"),
        "webtoon": MessageLookupByLibrary.simpleMessage("Webtoon")
      };
}
