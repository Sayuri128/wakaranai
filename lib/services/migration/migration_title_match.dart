final RegExp _bracketed = RegExp(r'[\(\[\{][^\)\]\}]*[\)\]\}]');
final RegExp _separators = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

const double kMigrationHighlightThreshold = 0.4;

String normalizeMigrationTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(_separators, ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String _withoutBrackets(String title) {
  return normalizeMigrationTitle(title.replaceAll(_bracketed, ' '));
}

List<String> _bigrams(String text) {
  final String compact = text.replaceAll(' ', '');
  if (compact.length < 2) {
    return <String>[compact];
  }
  return <String>[
    for (int index = 0; index < compact.length - 1; index++)
      compact.substring(index, index + 2),
  ];
}

double _dice(String first, String second) {
  if (first.isEmpty || second.isEmpty) {
    return 0;
  }
  if (first == second) {
    return 1;
  }
  final List<String> firstPairs = _bigrams(first);
  final List<String> secondPairs = _bigrams(second);
  final Map<String, int> remaining = <String, int>{};
  for (final String pair in secondPairs) {
    remaining[pair] = (remaining[pair] ?? 0) + 1;
  }
  int shared = 0;
  for (final String pair in firstPairs) {
    final int available = remaining[pair] ?? 0;
    if (available > 0) {
      shared++;
      remaining[pair] = available - 1;
    }
  }
  return (2 * shared) / (firstPairs.length + secondPairs.length);
}

double migrationTitleSimilarity(String first, String second) {
  final String normalizedFirst = normalizeMigrationTitle(first);
  final String normalizedSecond = normalizeMigrationTitle(second);
  if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) {
    return 0;
  }
  if (normalizedFirst == normalizedSecond) {
    return 1;
  }
  final double full = _dice(normalizedFirst, normalizedSecond);
  final double stripped =
      _dice(_withoutBrackets(first), _withoutBrackets(second));
  if (stripped > full) {
    return stripped * 0.98;
  }
  return full;
}

bool isExactMigrationTitle(Iterable<String> subjectTitles, String candidate) {
  final String normalizedCandidate = normalizeMigrationTitle(candidate);
  if (normalizedCandidate.isEmpty) {
    return false;
  }
  return subjectTitles.any(
    (String title) => normalizeMigrationTitle(title) == normalizedCandidate,
  );
}

class MigrationCandidateScore<T> {
  const MigrationCandidateScore({
    required this.candidate,
    required this.groupKey,
    required this.score,
    required this.exact,
  });

  final T candidate;
  final String groupKey;
  final double score;
  final bool exact;

  bool get highlightable => score >= kMigrationHighlightThreshold;
}

List<MigrationCandidateScore<T>> rankMigrationCandidates<T>({
  required List<String> subjectTitles,
  required List<T> candidates,
  required String Function(T candidate) titleOf,
  required String Function(T candidate) groupKeyOf,
}) {
  final List<String> titles = subjectTitles
      .where((String title) => title.trim().isNotEmpty)
      .toList(growable: false);
  final List<MigrationCandidateScore<T>> scored =
      <MigrationCandidateScore<T>>[];
  for (final T candidate in candidates) {
    final String title = titleOf(candidate);
    double best = 0;
    for (final String subject in titles) {
      final double similarity = migrationTitleSimilarity(subject, title);
      if (similarity > best) {
        best = similarity;
      }
    }
    scored.add(MigrationCandidateScore<T>(
      candidate: candidate,
      groupKey: groupKeyOf(candidate),
      score: best,
      exact: isExactMigrationTitle(titles, title),
    ));
  }
  final List<MigrationCandidateScore<T>> ordered =
      List<MigrationCandidateScore<T>>.of(scored);
  ordered.sort((MigrationCandidateScore<T> a, MigrationCandidateScore<T> b) {
    if (a.exact != b.exact) {
      return a.exact ? -1 : 1;
    }
    final int byScore = b.score.compareTo(a.score);
    if (byScore != 0) {
      return byScore;
    }
    return scored.indexOf(a).compareTo(scored.indexOf(b));
  });
  return ordered;
}

MigrationCandidateScore<T>? bestMigrationCandidate<T>(
  List<MigrationCandidateScore<T>> ranked,
) {
  if (ranked.isEmpty) {
    return null;
  }
  final MigrationCandidateScore<T> best = ranked.first;
  if (!best.exact && !best.highlightable) {
    return null;
  }
  return best;
}

MigrationCandidateScore<T>? autoPickExactCandidate<T>(
  List<MigrationCandidateScore<T>> ranked, {
  required List<String> groupOrder,
}) {
  final List<MigrationCandidateScore<T>> exact = ranked
      .where((MigrationCandidateScore<T> score) => score.exact)
      .toList(growable: false);
  if (exact.isEmpty) {
    return null;
  }
  for (final String group in groupOrder) {
    final List<MigrationCandidateScore<T>> inGroup = exact
        .where((MigrationCandidateScore<T> score) => score.groupKey == group)
        .toList(growable: false);
    if (inGroup.isEmpty) {
      continue;
    }
    if (inGroup.length == 1) {
      return inGroup.single;
    }
    return null;
  }
  return null;
}
