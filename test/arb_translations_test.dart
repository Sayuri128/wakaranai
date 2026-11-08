import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class IcuArguments {
  final Set<String> names = <String>{};
  final Map<String, Set<String>> pluralForms = <String, Set<String>>{};
}

IcuArguments parseIcuArguments(String message) {
  final IcuArguments arguments = IcuArguments();
  _parseMessage(message, 0, arguments);
  return arguments;
}

int _parseMessage(String text, int start, IcuArguments arguments) {
  int index = start;
  while (index < text.length) {
    final String char = text[index];
    if (char == '}') {
      return index;
    }
    if (char == '{') {
      index = _parseArgument(text, index + 1, arguments);
    } else {
      index++;
    }
  }
  return index;
}

int _parseArgument(String text, int start, IcuArguments arguments) {
  final RegExp separator = RegExp('[,}]');
  final int nameEnd = text.indexOf(separator, start);
  final String name = text.substring(start, nameEnd).trim();
  arguments.names.add(name);
  if (text[nameEnd] == '}') {
    return nameEnd + 1;
  }
  final int typeEnd = text.indexOf(separator, nameEnd + 1);
  final String type = text.substring(nameEnd + 1, typeEnd).trim();
  if (text[typeEnd] == '}') {
    return typeEnd + 1;
  }
  final Set<String> forms = <String>{};
  int index = typeEnd + 1;
  while (index < text.length) {
    final int open = text.indexOf('{', index);
    final int close = text.indexOf('}', index);
    if (close != -1 && (open == -1 || close < open)) {
      if (type == 'plural') {
        arguments.pluralForms[name] = forms;
      }
      return close + 1;
    }
    forms.add(text.substring(index, open).trim());
    index = _parseMessage(text, open + 1, arguments) + 1;
  }
  return index;
}

Map<String, String> readMessages(String path) {
  final Map<String, dynamic> decoded =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final Map<String, String> messages = <String, String>{};
  decoded.forEach((String key, dynamic value) {
    if (!key.startsWith('@')) {
      messages[key] = value as String;
    }
  });
  return messages;
}

void main() {
  final Map<String, String> english = readMessages('lib/l10n/intl_en.arb');
  final Map<String, String> ukrainian = readMessages('lib/l10n/intl_uk.arb');

  test('the placeholder parser reads plain, plural and nested arguments', () {
    final IcuArguments arguments = parseIcuArguments(
      '{count, plural, =0{Nothing} one{{count} file in {path}} '
      'other{{count} files}} for {name}',
    );

    expect(arguments.names, <String>{'count', 'path', 'name'});
    expect(arguments.pluralForms['count'], <String>{'=0', 'one', 'other'});
  });

  test('every English key has a Ukrainian translation', () {
    final List<String> missing = english.keys
        .where((String key) => !ukrainian.containsKey(key))
        .toList();

    expect(missing, isEmpty);
  });

  test('the Ukrainian file has no keys that English no longer has', () {
    final List<String> stale = ukrainian.keys
        .where((String key) => !english.containsKey(key))
        .toList();

    expect(stale, isEmpty);
  });

  test('every translation keeps the English placeholders', () {
    final Map<String, String> mismatches = <String, String>{};
    english.forEach((String key, String source) {
      final String? translation = ukrainian[key];
      if (translation == null) {
        return;
      }
      final Set<String> expected = parseIcuArguments(source).names;
      final Set<String> actual = parseIcuArguments(translation).names;
      if (expected.length != actual.length || !expected.containsAll(actual)) {
        mismatches[key] = 'expected $expected, got $actual';
      }
    });

    expect(mismatches, isEmpty);
  });

  test('Ukrainian plurals cover the one, few, many and other forms', () {
    final Map<String, String> incomplete = <String, String>{};
    ukrainian.forEach((String key, String translation) {
      final IcuArguments arguments = parseIcuArguments(translation);
      arguments.pluralForms.forEach((String name, Set<String> forms) {
        const Set<String> required = <String>{'one', 'few', 'many', 'other'};
        if (!forms.containsAll(required)) {
          incomplete[key] = '$name has $forms';
        }
      });
    });

    expect(incomplete, isEmpty);
  });
}
