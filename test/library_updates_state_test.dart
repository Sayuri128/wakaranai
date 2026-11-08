import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';

LibraryUpdateDomain _update(
  String uid, {
  required String entry,
  bool seen = false,
}) {
  return LibraryUpdateDomain(
    id: 0,
    uid: uid,
    libraryEntryUid: entry,
    extensionUid: 'ext',
    title: 'Chapter $uid',
    concreteTitle: 'Title $entry',
    mediaType: UpdateMediaType.manga,
    seen: seen,
    createdAt: DateTime(2026),
  );
}

void main() {
  final LibraryUpdatesState state = LibraryUpdatesState(
    updates: <LibraryUpdateDomain>[
      _update('c1', entry: 'a'),
      _update('c2', entry: 'a'),
      _update('c3', entry: 'a', seen: true),
      _update('c4', entry: 'b'),
    ],
  );

  test('a chapter is new only while its update is unseen', () {
    expect(state.isUnseen('c1'), isTrue);
    expect(state.isUnseen('c3'), isFalse);
    expect(state.isUnseen('unknown'), isFalse);
  });

  test('counts unseen updates per library entry', () {
    expect(state.unseenForEntry('a'), 2);
    expect(state.unseenForEntry('b'), 1);
    expect(state.unseenForEntry('c'), 0);
  });
}
