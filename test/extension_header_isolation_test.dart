import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const String _publisher = '''
import "http";

function publish() {
    useHeaders({"headers": {"user-agent": "Mozilla/5.0 (Linux; Android 13) Chrome/110"}});
    return 1;
}
''';

const String _reader = '''
import "http";

function readHeaders() { return getHeaders(); }
''';

MangaApiClient _build(String code) => MangaApiClient(code: code);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('headers published by one extension do not reach another', () async {
    final MangaApiClient publisher = _build(_publisher);
    final MangaApiClient reader = _build(_reader);

    await publisher.interpreter.runFunction('publish');

    expect(await reader.interpreter.runFunction('readHeaders'), isEmpty);
    expect(reader.getProtectorHeaders(), isEmpty);
    expect(publisher.getProtectorHeaders(),
        containsPair('user-agent', anything));
  });

  test('isolation holds for clients built through compute()', () async {
    final MangaApiClient publisher = await compute(_build, _publisher);
    final MangaApiClient reader = await compute(_build, _reader);

    await publisher.interpreter.runFunction('publish');

    expect(await reader.interpreter.runFunction('readHeaders'), isEmpty);
    expect(reader.getProtectorHeaders(), isEmpty);
  });
}
