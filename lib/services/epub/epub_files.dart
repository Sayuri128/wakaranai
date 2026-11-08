import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

abstract class EpubFiles {
  Iterable<String> get paths;

  List<int>? read(String path);

  String? readText(String path) {
    final List<int>? bytes = read(path);
    if (bytes == null) {
      return null;
    }
    return decodeEpubText(bytes);
  }

  bool contains(String path) => resolve(path) != null;

  String? resolve(String path);
}

class ArchiveEpubFiles extends EpubFiles {
  ArchiveEpubFiles(Archive archive) {
    for (final ArchiveFile file in archive.files) {
      if (!file.isFile) {
        continue;
      }
      final String name = normalizeEpubPath(file.name);
      if (name.isEmpty) {
        continue;
      }
      _files[name] = file;
      _lowercase.putIfAbsent(name.toLowerCase(), () => name);
    }
  }

  final Map<String, ArchiveFile> _files = <String, ArchiveFile>{};
  final Map<String, String> _lowercase = <String, String>{};

  @override
  Iterable<String> get paths => _files.keys;

  @override
  String? resolve(String path) {
    final String normalized = normalizeEpubPath(path);
    if (_files.containsKey(normalized)) {
      return normalized;
    }
    return _lowercase[normalized.toLowerCase()];
  }

  @override
  List<int>? read(String path) {
    final String? resolved = resolve(path);
    if (resolved == null) {
      return null;
    }
    try {
      return _files[resolved]!.content as List<int>;
    } catch (_) {
      return null;
    }
  }
}

String decodeEpubText(List<int> bytes) {
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return _decodeUtf16(bytes.sublist(2), littleEndian: true);
  }
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return _decodeUtf16(bytes.sublist(2), littleEndian: false);
  }
  final String text = utf8.decode(bytes, allowMalformed: true);
  if (text.startsWith('﻿')) {
    return text.substring(1);
  }
  return text;
}

String _decodeUtf16(List<int> bytes, {required bool littleEndian}) {
  final List<int> units = <int>[];
  for (int index = 0; index + 1 < bytes.length; index += 2) {
    final int low = littleEndian ? bytes[index] : bytes[index + 1];
    final int high = littleEndian ? bytes[index + 1] : bytes[index];
    units.add((high << 8) | low);
  }
  return String.fromCharCodes(units);
}

String normalizeEpubPath(String path) {
  String cleaned = path.replaceAll('\\', '/');
  while (cleaned.startsWith('/')) {
    cleaned = cleaned.substring(1);
  }
  if (cleaned.isEmpty) {
    return '';
  }
  final String normalized = p.posix.normalize(cleaned);
  if (normalized == '.' || normalized.startsWith('../') || normalized == '..') {
    return '';
  }
  return normalized;
}

String epubDirectoryOf(String path) {
  final String directory = p.posix.dirname(path);
  if (directory == '.') {
    return '';
  }
  return directory;
}

bool _hasScheme(String href) {
  return RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(href);
}

String _decodePercent(String value) {
  if (!value.contains('%')) {
    return value;
  }
  try {
    return Uri.decodeFull(value);
  } on ArgumentError {
    return value;
  } on FormatException {
    return value;
  }
}

String? resolveEpubHref(String baseFile, String href) {
  String target = href.trim();
  final int fragment = target.indexOf('#');
  if (fragment >= 0) {
    target = target.substring(0, fragment);
  }
  final int query = target.indexOf('?');
  if (query >= 0) {
    target = target.substring(0, query);
  }
  if (target.isEmpty || _hasScheme(target)) {
    return null;
  }
  target = _decodePercent(target);
  if (target.startsWith('/')) {
    final String rooted = normalizeEpubPath(target);
    return rooted.isEmpty ? null : rooted;
  }
  final String directory = epubDirectoryOf(baseFile);
  final String joined =
      directory.isEmpty ? target : p.posix.join(directory, target);
  final String normalized = normalizeEpubPath(joined);
  if (normalized.isEmpty) {
    return null;
  }
  return normalized;
}
