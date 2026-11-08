import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/image_headers.dart';

void main() {
  test('scripts without getImageHeaders get no headers instead of an error', () async {
    final AnimeApiClient client = AnimeApiClient(code: '''
      function getGallery(page, query, filters) {
        return [];
      }
    ''');
    expect(
      await client.imageHeadersOrEmpty(uid: 'a', data: <String, dynamic>{}),
      isEmpty,
    );
  });

  test('scripts with getImageHeaders still provide them', () async {
    final MangaApiClient client = MangaApiClient(code: '''
      function getImageHeaders(uid, data) {
        return {"Referer": "https://example.com/" + uid};
      }
    ''');
    expect(
      await client.imageHeadersOrEmpty(uid: 'a', data: <String, dynamic>{}),
      <String, String>{'Referer': 'https://example.com/a'},
    );
  });
}
