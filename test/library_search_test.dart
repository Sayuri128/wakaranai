import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';

LibraryEntryDomain _entry(String title) => LibraryEntryDomain(
      id: 0,
      uid: title,
      extensionUid: 'ext',
      title: title,
      createdAt: DateTime.now(),
    );

void main() {
  final List<LibraryEntryDomain> entries = <LibraryEntryDomain>[
    _entry('Berserk'),
    _entry('Vinland Saga'),
    _entry('berserk of gluttony'),
  ];

  test('an empty query matches every entry', () {
    const LibraryState state = LibraryState();

    expect(state.searching, isFalse);
    expect(entries.where(state.matchesSearch).length, 3);
  });

  test('matching is case insensitive and matches substrings', () {
    const LibraryState state = LibraryState(searchQuery: 'BERSERK');

    expect(state.searching, isTrue);
    expect(
      entries.where(state.matchesSearch).map((LibraryEntryDomain e) => e.title),
      <String>['Berserk', 'berserk of gluttony'],
    );
  });

  test('a query matching nothing yields no entries', () {
    const LibraryState state = LibraryState(searchQuery: 'nonexistent');

    expect(entries.where(state.matchesSearch), isEmpty);
  });

  test('search combines with sorting', () {
    const LibraryState state = LibraryState(
      searchQuery: 'berserk',
      sort: LibrarySort.title,
    );

    final List<LibraryEntryDomain> visible =
        state.sortedEntries(entries.where(state.matchesSearch).toList());

    expect(visible.map((LibraryEntryDomain e) => e.title),
        <String>['Berserk', 'berserk of gluttony']);
  });
}
