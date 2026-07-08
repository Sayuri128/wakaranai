import 'dart:io';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';

const String _script = '''
import "manga_models";

function getPages(uid, data) {
    return buildPages({"uid": uid, "value": ["data:image/png;base64,iVBORw0KGgo="]});
}

function getImageHeaders(uid, data) { return {}; }
''';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.docs);

  final String docs;

  @override
  Future<String?> getApplicationDocumentsPath() async => docs;
}

class _RecordingNotifications extends DownloadNotificationService {
  final List<String> queueLabels = <String>[];
  int completed = -1;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> showProgress({
    required String title,
    required String chapterTitle,
    required int progress,
    required int max,
    int queueIndex = 0,
    int queueTotal = 0,
  }) async {
    queueLabels.add('$queueIndex/$queueTotal');
  }

  @override
  Future<void> showComplete(int count) async {
    completed = count;
  }

  @override
  Future<void> cancelProgress() async {}
}

Future<void> _enqueue(
  DownloadManagerCubit cubit,
  MangaApiClient client,
  String uid, {
  required bool autoStart,
}) {
  return cubit.enqueueChapter(
    client: client,
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Some Manga',
    concreteCover: null,
    chapterUid: uid,
    title: 'Chapter $uid',
    data: const <String, dynamic>{},
    autoStart: autoStart,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late WakaranaiDatabase db;
  late DownloadRepository repository;
  late _RecordingNotifications notifications;
  late DownloadManagerCubit cubit;
  late MangaApiClient client;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wakaranai_downloads');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);

    db = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    repository = DownloadRepository(database: db);
    notifications = _RecordingNotifications();
    cubit = DownloadManagerCubit(
      downloadRepository: repository,
      notificationService: notifications,
    );
    client = MangaApiClient(code: _script);
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      return;
    }
  });

  test('a batch enqueued before the queue starts counts 1/3, 2/3, 3/3',
      () async {
    for (final String uid in <String>['a', 'b', 'c']) {
      await _enqueue(cubit, client, uid, autoStart: false);
    }
    cubit.startQueue();

    await _settle(notifications);

    expect(notifications.queueLabels, contains('1/3'));
    expect(notifications.queueLabels, contains('2/3'));
    expect(notifications.queueLabels, contains('3/3'));
    expect(notifications.queueLabels, everyElement(endsWith('/3')));
    expect(notifications.completed, 3);
  });

  test('a single download reports a total of 1 so no counter is rendered',
      () async {
    await _enqueue(cubit, client, 'solo', autoStart: true);

    await _settle(notifications);

    expect(notifications.queueLabels, isNotEmpty);
    expect(notifications.queueLabels, everyElement('1/1'));
    expect(notifications.completed, 1);
  });
}

Future<void> _settle(_RecordingNotifications notifications) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 15));
  while (notifications.completed < 0 && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
