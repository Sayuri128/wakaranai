import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/migration/migration_title_match.dart';

class _Candidate {
  const _Candidate(this.source, this.title);

  final String source;
  final String title;
}

List<MigrationCandidateScore<_Candidate>> _rank(
  List<String> subject,
  List<_Candidate> candidates,
) {
  return rankMigrationCandidates<_Candidate>(
    subjectTitles: subject,
    candidates: candidates,
    titleOf: (_Candidate candidate) => candidate.title,
    groupKeyOf: (_Candidate candidate) => candidate.source,
  );
}

void main() {
  group('normalizeMigrationTitle', () {
    test('drops case, punctuation and repeated spaces', () {
      expect(
        normalizeMigrationTitle('  Re:Zero  -  Starting Life! '),
        're zero starting life',
      );
    });

    test('keeps non-latin letters and digits', () {
      expect(normalizeMigrationTitle('Атака Титанів: 2'), 'атака титанів 2');
    });
  });

  group('migrationTitleSimilarity', () {
    test('is 1 for titles that only differ in punctuation', () {
      expect(migrationTitleSimilarity('One-Punch Man', 'one punch man'), 1);
    });

    test('is high for close titles and low for unrelated ones', () {
      final double close =
          migrationTitleSimilarity('Solo Leveling', 'Solo Leveling: Ragnarok');
      final double unrelated =
          migrationTitleSimilarity('Solo Leveling', 'Kaguya-sama');
      expect(close, greaterThan(0.6));
      expect(unrelated, lessThan(0.2));
    });

    test('ignores a bracketed suffix when it helps', () {
      expect(
        migrationTitleSimilarity('Berserk (Manga)', 'Berserk'),
        greaterThan(0.95),
      );
    });

    test('is 0 for empty titles', () {
      expect(migrationTitleSimilarity('', 'Berserk'), 0);
    });
  });

  group('rankMigrationCandidates', () {
    test('puts exact matches first, then the closest titles', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Vinland Saga'],
        const <_Candidate>[
          _Candidate('a', 'Vinland Saga Side Story'),
          _Candidate('a', 'Saga of Tanya'),
          _Candidate('b', 'Vinland saga'),
        ],
      );
      expect(ranked.first.candidate.title, 'Vinland saga');
      expect(ranked.first.exact, isTrue);
      expect(ranked[1].candidate.title, 'Vinland Saga Side Story');
    });

    test('scores against alternative titles too', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Shingeki no Kyojin', 'Attack on Titan'],
        const <_Candidate>[_Candidate('a', 'Attack on Titan')],
      );
      expect(ranked.single.exact, isTrue);
      expect(ranked.single.score, 1);
    });
  });

  group('bestMigrationCandidate', () {
    test('does not highlight a weak match', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Monster'],
        const <_Candidate>[_Candidate('a', 'Pluto')],
      );
      expect(bestMigrationCandidate(ranked), isNull);
    });

    test('highlights the top match', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Monster'],
        const <_Candidate>[
          _Candidate('a', 'Pluto'),
          _Candidate('a', 'Monster Perfect Edition'),
        ],
      );
      expect(
        bestMigrationCandidate(ranked)?.candidate.title,
        'Monster Perfect Edition',
      );
    });
  });

  group('autoPickExactCandidate', () {
    test('picks the single exact match of the first source that has one', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Dorohedoro'],
        const <_Candidate>[
          _Candidate('b', 'Dorohedoro'),
          _Candidate('a', 'Dorohedoro'),
          _Candidate('a', 'Dorohedoro Extra'),
        ],
      );
      final MigrationCandidateScore<_Candidate>? pick =
          autoPickExactCandidate(ranked, groupOrder: <String>['a', 'b']);
      expect(pick?.candidate.source, 'a');
    });

    test('gives up when a source has two exact matches', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Blame!'],
        const <_Candidate>[
          _Candidate('a', 'BLAME'),
          _Candidate('a', 'Blame!'),
        ],
      );
      expect(autoPickExactCandidate(ranked, groupOrder: <String>['a']), isNull);
    });

    test('gives up without an exact match', () {
      final List<MigrationCandidateScore<_Candidate>> ranked = _rank(
        <String>['Blame!'],
        const <_Candidate>[_Candidate('a', 'Blame Academy')],
      );
      expect(autoPickExactCandidate(ranked, groupOrder: <String>['a']), isNull);
    });
  });
}
