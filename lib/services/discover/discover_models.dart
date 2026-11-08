enum DiscoverCategory {
  seasonAnime,
  trendingAnime,
  trendingManga,
  popularNovels
}

enum DiscoverSeasonName { winter, spring, summer, fall }

class DiscoverSeason {
  const DiscoverSeason({required this.name, required this.year});

  final DiscoverSeasonName name;
  final int year;

  factory DiscoverSeason.of(DateTime date) {
    final int month = date.month;
    if (month == DateTime.december) {
      return DiscoverSeason(
          name: DiscoverSeasonName.winter, year: date.year + 1);
    }
    if (month <= DateTime.february) {
      return DiscoverSeason(name: DiscoverSeasonName.winter, year: date.year);
    }
    if (month <= DateTime.may) {
      return DiscoverSeason(name: DiscoverSeasonName.spring, year: date.year);
    }
    if (month <= DateTime.august) {
      return DiscoverSeason(name: DiscoverSeasonName.summer, year: date.year);
    }
    return DiscoverSeason(name: DiscoverSeasonName.fall, year: date.year);
  }

  String get apiName => name.name.toUpperCase();
}

class DiscoverMedia {
  const DiscoverMedia({
    required this.id,
    this.type,
    this.format,
    this.status,
    this.romajiTitle,
    this.englishTitle,
    this.nativeTitle,
    this.synonyms = const <String>[],
    this.cover,
    this.coverColor,
    this.description,
    this.genres = const <String>[],
    this.averageScore,
    this.episodes,
    this.chapters,
    this.year,
  });

  final int id;
  final String? type;
  final String? format;
  final String? status;
  final String? romajiTitle;
  final String? englishTitle;
  final String? nativeTitle;
  final List<String> synonyms;
  final String? cover;
  final String? coverColor;
  final String? description;
  final List<String> genres;
  final int? averageScore;
  final int? episodes;
  final int? chapters;
  final int? year;

  bool get isAnime => type == 'ANIME';

  String get displayTitle {
    return englishTitle ?? romajiTitle ?? nativeTitle ?? '';
  }

  List<String> get searchTitles {
    final List<String> titles = <String>[];
    final Set<String> seen = <String>{};
    for (final String? title in <String?>[
      romajiTitle,
      englishTitle,
      nativeTitle,
    ]) {
      if (title == null) {
        continue;
      }
      if (seen.add(title.toLowerCase())) {
        titles.add(title);
      }
    }
    return titles;
  }

  String get bestSearchTitle {
    final List<String> titles = searchTitles;
    if (titles.isEmpty) {
      return '';
    }
    return titles.first;
  }

  factory DiscoverMedia.fromJson(Map<String, Object?> json) {
    final Map<String, Object?> title = _map(json['title']);
    final Map<String, Object?> cover = _map(json['coverImage']);
    final Map<String, Object?> startDate = _map(json['startDate']);
    return DiscoverMedia(
      id: json['id']! as int,
      type: _text(json['type']),
      format: _text(json['format']),
      status: _text(json['status']),
      romajiTitle: _text(title['romaji']),
      englishTitle: _text(title['english']),
      nativeTitle: _text(title['native']),
      synonyms: _texts(json['synonyms']),
      cover: _text(cover['extraLarge']) ?? _text(cover['large']),
      coverColor: _text(cover['color']),
      description: cleanDescription(json['description'] as String?),
      genres: _texts(json['genres']),
      averageScore: json['averageScore'] as int?,
      episodes: json['episodes'] as int?,
      chapters: json['chapters'] as int?,
      year: json['seasonYear'] as int? ?? startDate['year'] as int?,
    );
  }

  static final RegExp _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final RegExp _tag = RegExp(r'<[^>]+>');
  static final RegExp _extraBlankLines = RegExp(r'\n{3,}');
  static const Map<String, String> _entities = <String, String>{
    '&amp;': '&',
    '&quot;': '"',
    '&#039;': "'",
    '&apos;': "'",
    '&lt;': '<',
    '&gt;': '>',
    '&nbsp;': ' ',
    '&mdash;': '—',
    '&ndash;': '–',
    '&hellip;': '…',
  };

  static String? cleanDescription(String? raw) {
    if (raw == null) {
      return null;
    }
    String text = raw.replaceAll('\r', '').replaceAll(_lineBreak, '\n');
    text = text.replaceAll(_tag, '');
    for (final MapEntry<String, String> entity in _entities.entries) {
      text = text.replaceAll(entity.key, entity.value);
    }
    text = text
        .split('\n')
        .map((String line) => line.trim())
        .join('\n')
        .replaceAll(_extraBlankLines, '\n\n')
        .trim();
    if (text.isEmpty) {
      return null;
    }
    return text;
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    return const <String, Object?>{};
  }

  static String? _text(Object? value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static List<String> _texts(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return value.map(_text).whereType<String>().toList(growable: false);
  }
}

class DiscoverMediaPage {
  const DiscoverMediaPage({
    required this.media,
    required this.page,
    required this.hasNextPage,
  });

  final List<DiscoverMedia> media;
  final int page;
  final bool hasNextPage;

  factory DiscoverMediaPage.fromResponse(Object? body, {required int page}) {
    final Map<String, Object?> root = DiscoverMedia._map(body);
    final Object? errors = root['errors'];
    final Map<String, Object?> data = DiscoverMedia._map(root['data']);
    if (data.isEmpty && errors is List && errors.isNotEmpty) {
      throw DiscoverException(_errorMessage(errors.first));
    }
    final Map<String, Object?> pageJson = DiscoverMedia._map(data['Page']);
    if (pageJson.isEmpty) {
      throw const DiscoverException('AniList returned no page');
    }
    final Map<String, Object?> info = DiscoverMedia._map(pageJson['pageInfo']);
    final Object? items = pageJson['media'];
    final List<DiscoverMedia> media = <DiscoverMedia>[];
    if (items is List) {
      for (final Object? item in items) {
        if (item is Map && item['id'] is int) {
          media.add(DiscoverMedia.fromJson(item.cast<String, Object?>()));
        }
      }
    }
    return DiscoverMediaPage(
      media: media,
      page: info['currentPage'] as int? ?? page,
      hasNextPage: info['hasNextPage'] as bool? ?? false,
    );
  }

  static String _errorMessage(Object? error) {
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return error.toString();
  }
}

class DiscoverException implements Exception {
  const DiscoverException(this.message);

  final String message;

  @override
  String toString() => 'DiscoverException: $message';
}
