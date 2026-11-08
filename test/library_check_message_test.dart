import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';
import 'package:wakaranai/ui/home/library_page/library_entries_view.dart';

LibraryEntryDomain _entry(String uid) {
  return LibraryEntryDomain(
    id: 0,
    uid: uid,
    extensionUid: 'ext',
    title: 'Title $uid',
    createdAt: DateTime(2026),
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('removed titles and failed sources are both reported', () {
    final String? message = libraryCheckProblemsMessage(
      LibraryUpdateCheckResult(
        removedFromSource: <LibraryEntryDomain>[_entry('a'), _entry('b')],
        failed: 3,
      ),
    );

    expect(
      message,
      '2 titles were removed from their sources\n'
      '3 sources could not be checked',
    );
  });

  test('each problem is reported on its own', () {
    expect(
      libraryCheckProblemsMessage(LibraryUpdateCheckResult(
        removedFromSource: <LibraryEntryDomain>[_entry('a')],
      )),
      '1 title was removed from its source',
    );
    expect(
      libraryCheckProblemsMessage(const LibraryUpdateCheckResult(failed: 2)),
      '2 sources could not be checked',
    );
    expect(libraryCheckProblemsMessage(const LibraryUpdateCheckResult()),
        isNull);
  });
}
