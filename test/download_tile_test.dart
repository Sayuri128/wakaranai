import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';

class _SilentNotifications extends DownloadNotificationService {
  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> showComplete(int count) async {}

  @override
  Future<void> cancelProgress() async {}
}

class _RecordingDownloadManager extends DownloadManagerCubit {
  _RecordingDownloadManager(WakaranaiDatabase database)
      : super(
          downloadRepository: DownloadRepository(database: database),
          notificationService: _SilentNotifications(),
        );

  final List<String> retried = <String>[];

  @override
  Future<void> retryDownload(DownloadDomain download) async {
    retried.add(download.uid);
  }
}

DownloadDomain _download({
  DownloadKind kind = DownloadKind.episode,
  DownloadStatus status = DownloadStatus.done,
  int downloadedPages = 0,
  int totalPages = 0,
  int downloadedBytes = 0,
  int totalBytes = 0,
}) {
  return DownloadDomain(
    id: 1,
    uid: 'item',
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Title',
    title: 'Episode 1',
    status: status,
    downloadedPages: downloadedPages,
    totalPages: totalPages,
    dirPath: '/downloads/item',
    kind: kind,
    downloadedBytes: downloadedBytes,
    totalBytes: totalBytes,
    createdAt: DateTime(2026),
  );
}

const int _megabyte = 1024 * 1024;

void main() {
  setUpAll(() => S.load(const Locale('en')));

  group('status labels', () {
    test('chapters keep counting pages', () {
      expect(
        downloadStatusLabel(_download(
          kind: DownloadKind.chapter,
          status: DownloadStatus.downloading,
          downloadedPages: 3,
          totalPages: 20,
        )),
        '3/20 pages',
      );
      expect(
        downloadStatusLabel(_download(
          kind: DownloadKind.chapter,
          totalPages: 20,
        )),
        '20/20 pages',
      );
    });

    test('hls episodes count segments while downloading', () {
      expect(
        downloadStatusLabel(_download(
          status: DownloadStatus.downloading,
          downloadedPages: 12,
          totalPages: 240,
        )),
        'Segment 12/240',
      );
    });

    test('mp4 episodes show a percentage and sizes', () {
      expect(
        downloadStatusLabel(_download(
          status: DownloadStatus.downloading,
          downloadedBytes: 50 * _megabyte,
          totalBytes: 200 * _megabyte,
        )),
        '25% · 50.0 MB of 200.0 MB',
      );
    });

    test('episodes with an unknown size show what has arrived', () {
      expect(
        downloadStatusLabel(_download(
          status: DownloadStatus.downloading,
          downloadedBytes: 3 * _megabyte,
        )),
        '3.0 MB downloaded',
      );
      expect(
        downloadStatusLabel(_download(status: DownloadStatus.downloading)),
        'Preparing video…',
      );
    });

    test('finished episodes say they are ready instead of counting pages', () {
      expect(downloadStatusLabel(_download()), 'Ready to watch offline');
      expect(
        downloadStatusLabel(_download(totalBytes: 1536 * _megabyte)),
        'Ready to watch offline · 1.50 GB',
      );
    });

    test('queued and failed are shared by both kinds', () {
      expect(
        downloadStatusLabel(_download(status: DownloadStatus.queued)),
        'Queued',
      );
      expect(
        downloadStatusLabel(_download(
          kind: DownloadKind.chapter,
          status: DownloadStatus.failed,
        )),
        'Failed',
      );
    });
  });

  group('tap actions', () {
    test('finished downloads open the reader or the player by kind', () {
      expect(
        downloadTapActionFor(_download(kind: DownloadKind.chapter)),
        DownloadTapAction.readChapter,
      );
      expect(
        downloadTapActionFor(_download()),
        DownloadTapAction.playEpisode,
      );
    });

    test('failed downloads of either kind retry', () {
      expect(
        downloadTapActionFor(_download(
          kind: DownloadKind.chapter,
          status: DownloadStatus.failed,
        )),
        DownloadTapAction.retry,
      );
      expect(
        downloadTapActionFor(_download(status: DownloadStatus.failed)),
        DownloadTapAction.retry,
      );
    });

    test('active downloads ignore taps', () {
      expect(
        downloadTapActionFor(_download(status: DownloadStatus.queued)),
        DownloadTapAction.none,
      );
      expect(
        downloadTapActionFor(_download(status: DownloadStatus.downloading)),
        DownloadTapAction.none,
      );
    });
  });

  group('episode tile', () {
    late WakaranaiDatabase database;
    late _RecordingDownloadManager manager;
    late List<String> played;

    setUp(() {
      database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
      manager = _RecordingDownloadManager(database);
      played = <String>[];
    });

    tearDown(() async {
      await manager.close();
      await database.close();
    });

    Future<void> pumpTile(WidgetTester tester, DownloadDomain download) {
      return tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DownloadManagerCubit>.value(
            value: manager,
            child: Scaffold(
              body: DownloadTile(
                download: download,
                playEpisode: (BuildContext context, DownloadDomain item) async {
                  played.add(item.uid);
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('tapping a finished episode plays it offline',
        (WidgetTester tester) async {
      await pumpTile(tester, _download());

      await tester.tap(find.text('Episode 1'));
      await tester.pump();

      expect(played, <String>['item']);
      expect(manager.retried, isEmpty);
    });

    testWidgets('a failed episode retries from a tap or the retry button',
        (WidgetTester tester) async {
      await pumpTile(tester, _download(status: DownloadStatus.failed));

      await tester.tap(find.text('Episode 1'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      expect(manager.retried, <String>['item', 'item']);
      expect(played, isEmpty);
    });

    testWidgets('a downloading episode shows progress without a retry button',
        (WidgetTester tester) async {
      await pumpTile(
        tester,
        _download(
          status: DownloadStatus.downloading,
          downloadedPages: 5,
          totalPages: 10,
        ),
      );

      expect(find.text('Segment 5/10'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsNothing);
      expect(find.byIcon(Icons.translate_rounded), findsNothing);
    });
  });
}
