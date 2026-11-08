import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_items_view.dart';
import 'package:wakaranai/ui/common/title_status.dart';

GalleryItem _item({
  String? status,
  int? year,
  String? latestChapter,
}) {
  return GalleryItem(
    uid: 'u',
    title: 't',
    cover: '',
    headers: const <String, String>{},
    onTap: () async {},
    status: status,
    year: year,
    latestChapter: latestChapter,
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('joins year, status and latest chapter in that order', () {
    final GalleryItem item = _item(
      status: 'ONGOING',
      year: 2021,
      latestChapter: 'Ch. 120',
    );
    expect(galleryItemMetaLine(item), '2021 · Ongoing · Ch. 120');
  });

  test('skips missing and undefined parts', () {
    expect(galleryItemMetaLine(_item(status: 'UNDEFINED')), isNull);
    expect(galleryItemMetaLine(_item(latestChapter: 'Ep. 3')), 'Ep. 3');
  });

  test('formats whole ratings without a decimal', () {
    expect(formatGalleryRating(8), '8');
    expect(formatGalleryRating(8.0), '8');
    expect(formatGalleryRating(8.46), '8.5');
  });

  test('maps every known status name to a label', () {
    for (final String status in <String>[
      'RELEASED',
      'ONGOING',
      'PAUSED',
      'ANNOUNCE',
      'CANCELED',
    ]) {
      expect(titleStatusLabel(status), isNotNull);
    }
    expect(titleStatusLabel(null), isNull);
  });
}
