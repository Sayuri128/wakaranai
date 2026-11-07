import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/downloads_page/download_runtime_banner.dart';

DownloadDomain _queued() {
  return DownloadDomain(
    id: 1,
    uid: 'e1',
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Title',
    title: 'Episode 1',
    status: DownloadStatus.queued,
    downloadedPages: 0,
    totalPages: 0,
    dirPath: '/downloads/e1',
    kind: DownloadKind.episode,
    createdAt: DateTime(2026),
  );
}

Future<void> _pump(WidgetTester tester, DownloadManagerState state) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: DownloadRuntimeBanner(state: state)),
    ),
  );
}

void main() {
  late S strings;

  setUpAll(() async {
    strings = await S.load(const Locale('en'));
  });

  testWidgets('shows nothing while downloads run normally',
      (WidgetTester tester) async {
    await _pump(
      tester,
      DownloadManagerState(
        downloads: <DownloadDomain>[_queued()],
        runtimeStatus: DownloadRuntimeStatus.active,
      ),
    );
    await tester.pump();

    expect(find.text(strings.downloads_runtime_waiting_for_wifi), findsNothing);
    expect(
      find.text(strings.downloads_runtime_app_must_stay_open),
      findsNothing,
    );
  });

  testWidgets('explains a queue held for Wi-Fi', (WidgetTester tester) async {
    await _pump(
      tester,
      DownloadManagerState(
        downloads: <DownloadDomain>[_queued()],
        hold: DownloadQueueHold.waitingForWifi,
      ),
    );
    await tester.pump();

    expect(
      find.text(strings.downloads_runtime_waiting_for_wifi),
      findsOneWidget,
    );
    expect(
      find.text(strings.downloads_runtime_waiting_for_wifi_message),
      findsOneWidget,
    );
  });

  testWidgets('warns when downloads only run while the app is open',
      (WidgetTester tester) async {
    await _pump(
      tester,
      DownloadManagerState(
        downloads: <DownloadDomain>[_queued()],
        runtimeStatus: DownloadRuntimeStatus.timedOut,
      ),
    );
    await tester.pump();

    expect(
      find.text(strings.downloads_runtime_app_must_stay_open),
      findsOneWidget,
    );
  });

  testWidgets('hides the foreground warning once nothing is queued',
      (WidgetTester tester) async {
    await _pump(
      tester,
      const DownloadManagerState(
        runtimeStatus: DownloadRuntimeStatus.startNotAllowed,
      ),
    );
    await tester.pump();

    expect(
      find.text(strings.downloads_runtime_app_must_stay_open),
      findsNothing,
    );
  });
}
