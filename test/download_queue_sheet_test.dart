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
import 'package:wakaranai/ui/home/downloads_page/download_queue_sheet.dart';
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

  final List<String> calls = <String>[];

  void show(List<DownloadDomain> downloads) {
    emit(state.copyWith(downloads: downloads));
  }

  @override
  Future<void> pauseDownload(String uid) async => calls.add('pause:$uid');

  @override
  Future<void> resumeDownload(String uid) async => calls.add('resume:$uid');

  @override
  Future<void> downloadNext(String uid) async => calls.add('next:$uid');

  @override
  Future<void> reorderQueue(List<String> orderedUids) async =>
      calls.add('reorder:${orderedUids.join(',')}');

  @override
  Future<void> pauseAll() async => calls.add('pauseAll');

  @override
  Future<void> resumeAll() async => calls.add('resumeAll');
}

DownloadDomain _download(
  String uid, {
  int id = 1,
  DownloadStatus status = DownloadStatus.queued,
  int queuePosition = 0,
  int downloadedPages = 0,
  int totalPages = 0,
}) {
  return DownloadDomain(
    id: id,
    uid: uid,
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Title',
    title: 'Episode $uid',
    status: status,
    downloadedPages: downloadedPages,
    totalPages: totalPages,
    dirPath: '/downloads/$uid',
    kind: DownloadKind.episode,
    queuePosition: queuePosition,
    createdAt: DateTime(2026),
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  late WakaranaiDatabase database;
  late _RecordingDownloadManager manager;

  setUp(() {
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    manager = _RecordingDownloadManager(database);
  });

  tearDown(() async {
    await manager.close();
    await database.close();
  });

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
        ],
        home: BlocProvider<DownloadManagerCubit>.value(
          value: manager,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('paused downloads', () {
    test('a paused download keeps its progress in the label', () {
      expect(
        downloadStatusLabel(_download(
          'e1',
          status: DownloadStatus.paused,
          downloadedPages: 4,
          totalPages: 10,
        )),
        'Paused · Segment 4/10',
      );
      expect(
        downloadStatusLabel(_download('e1', status: DownloadStatus.paused)),
        'Paused',
      );
    });

    test('tapping a paused download resumes it', () {
      expect(
        downloadTapActionFor(_download('e1', status: DownloadStatus.paused)),
        DownloadTapAction.resume,
      );
    });

    testWidgets('the tile pauses a queued download and resumes a paused one',
        (WidgetTester tester) async {
      await pump(tester, DownloadTile(download: _download('e1')));
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();

      await pump(
        tester,
        DownloadTile(
          download: _download(
            'e2',
            status: DownloadStatus.paused,
            downloadedPages: 4,
            totalPages: 10,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      expect(manager.calls, <String>['pause:e1', 'resume:e2']);
    });
  });

  group('queue sheet', () {
    test('a moved uid lands at the reported index', () {
      expect(
        reorderedUids(<String>['a', 'b', 'c', 'd'], 0, 2),
        <String>['b', 'c', 'a', 'd'],
      );
      expect(
        reorderedUids(<String>['a', 'b', 'c', 'd'], 3, 0),
        <String>['d', 'a', 'b', 'c'],
      );
    });

    testWidgets('pins the in-flight download and lists the rest in order',
        (WidgetTester tester) async {
      manager.show(<DownloadDomain>[
        _download('done', id: 1, status: DownloadStatus.done),
        _download('third', id: 2, queuePosition: 4),
        _download('active', id: 3, status: DownloadStatus.downloading,
            queuePosition: 9),
        _download('second', id: 4, status: DownloadStatus.paused,
            queuePosition: 2),
      ]);
      await pump(tester, DownloadQueueSheet());

      expect(find.textContaining('Downloading now'), findsOneWidget);
      expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));
      expect(find.text('Episode done'), findsNothing);

      final double active = tester.getTopLeft(find.text('Episode active')).dy;
      final double second = tester.getTopLeft(find.text('Episode second')).dy;
      final double third = tester.getTopLeft(find.text('Episode third')).dy;
      expect(active, lessThan(second));
      expect(second, lessThan(third));

      await tester.tap(find.byIcon(Icons.vertical_align_top_rounded).last);
      await tester.pump();
      await tester.tap(find.text('Pause all'));
      await tester.pump();
      await tester.tap(find.text('Resume all'));
      await tester.pump();

      expect(
        manager.calls,
        <String>['next:third', 'pauseAll', 'resumeAll'],
      );
    });

    testWidgets('the screen controls open the queue and pause or resume all',
        (WidgetTester tester) async {
      manager.show(<DownloadDomain>[
        _download('a', id: 1, status: DownloadStatus.downloading),
        _download('b', id: 2, status: DownloadStatus.paused),
      ]);
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: DownloadQueueControls(state: manager.state),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Pause all'));
      await tester.tap(find.text('Resume all'));
      await tester.pump();
      expect(manager.calls, <String>['pauseAll', 'resumeAll']);

      await tester.tap(find.text('Queue (2)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Downloading now'), findsOneWidget);
    });

    testWidgets('dragging a handle stores the new order',
        (WidgetTester tester) async {
      manager.show(<DownloadDomain>[
        _download('a', id: 1, queuePosition: 1),
        _download('b', id: 2, queuePosition: 2),
        _download('c', id: 3, queuePosition: 3),
      ]);
      await pump(tester, DownloadQueueSheet());

      final Finder handles = find.byIcon(Icons.drag_indicator_rounded);
      final TestGesture drag =
          await tester.startGesture(tester.getCenter(handles.first));
      await drag.moveBy(const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 100));
      await drag.up();
      await tester.pumpAndSettle();

      expect(manager.calls, <String>['reorder:b,c,a']);
      final double b = tester.getTopLeft(find.text('Episode b')).dy;
      final double a = tester.getTopLeft(find.text('Episode a')).dy;
      expect(b, lessThan(a));
    });
  });
}
