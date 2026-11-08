class EpubChapter {
  const EpubChapter({required this.title, required this.documents});

  final String title;
  final List<String> documents;

  String get firstDocument => documents.first;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'documents': documents,
      };

  factory EpubChapter.fromJson(Map<String, dynamic> json) {
    return EpubChapter(
      title: _string(json['title']),
      documents: _strings(json['documents']),
    );
  }
}

class EpubBook {
  const EpubBook({
    required this.title,
    required this.creators,
    required this.description,
    required this.language,
    required this.coverPath,
    required this.chapters,
  });

  final String title;
  final List<String> creators;
  final String description;
  final String language;
  final String? coverPath;
  final List<EpubChapter> chapters;

  EpubChapter? chapterStartingAt(String document) {
    for (final EpubChapter chapter in chapters) {
      if (chapter.firstDocument == document) {
        return chapter;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'creators': creators,
        'description': description,
        'language': language,
        'coverPath': coverPath,
        'chapters':
            chapters.map((EpubChapter chapter) => chapter.toJson()).toList(),
      };

  factory EpubBook.fromJson(Map<String, dynamic> json) {
    final Object? rawChapters = json['chapters'];
    final List<EpubChapter> chapters = <EpubChapter>[];
    if (rawChapters is List) {
      for (final Object? chapter in rawChapters) {
        if (chapter is Map) {
          chapters.add(EpubChapter.fromJson(chapter.cast<String, dynamic>()));
        }
      }
    }
    final Object? cover = json['coverPath'];
    return EpubBook(
      title: _string(json['title']),
      creators: _strings(json['creators']),
      description: _string(json['description']),
      language: _string(json['language']),
      coverPath: cover is String && cover.isNotEmpty ? cover : null,
      chapters: chapters,
    );
  }
}

String _string(Object? value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

List<String> _strings(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value.map((Object? item) => _string(item)).toList(growable: false);
}
