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
        "app_name": MessageLookupByLibrary.simpleMessage("HReader"),
        "bottom_navigation_gallery_menu_title":
            MessageLookupByLibrary.simpleMessage("Gallery"),
        "bottom_navigation_settings_menu_title":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "copied_to_clipboard_message":
            MessageLookupByLibrary.simpleMessage("Copied to clipboard!"),
        "doujinshi_pages_count": MessageLookupByLibrary.simpleMessage("Pages:"),
        "doujinshi_uploaded": MessageLookupByLibrary.simpleMessage("Uploaded:"),
        "settings_cache_clear_dialog_title":
            MessageLookupByLibrary.simpleMessage(
                "Are your sure want to clear image cache?"),
        "settings_cache_clear_title":
            MessageLookupByLibrary.simpleMessage("Clear image cache"),
        "settings_caching_images_title":
            MessageLookupByLibrary.simpleMessage("Image caching"),
        "settings_caching_period_dialog_title":
            MessageLookupByLibrary.simpleMessage("Caching period"),
        "settings_caching_period_forever":
            MessageLookupByLibrary.simpleMessage("Forever"),
        "settings_caching_period_one_day":
            MessageLookupByLibrary.simpleMessage("Day"),
        "settings_caching_period_one_month":
            MessageLookupByLibrary.simpleMessage("Month"),
        "settings_caching_period_one_week":
            MessageLookupByLibrary.simpleMessage("Week"),
        "settings_caching_section_title":
            MessageLookupByLibrary.simpleMessage("Cache"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Settings")
      };
}