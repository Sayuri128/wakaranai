import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';

VideoTrack _track(String id, int? height, int? bitrate) {
  return VideoTrack(id: id, isSelected: false, height: height, bitrate: bitrate);
}

final List<PlayerRendition> _moonanimeLadder = distinctRenditions(<VideoTrack>[
  _track('0_2', 480, 1200000),
  _track('0_0', 1080, 5000000),
  _track('0_1', 720, 2800000),
]);

List<String> _labels(List<QualityOption> options) {
  return options.map((QualityOption option) => option.label).toList();
}

void main() {
  group('distinct renditions', () {
    test('are sorted from the highest quality down', () {
      expect(
        _moonanimeLadder.map((PlayerRendition rendition) => rendition.id),
        <String>['0_0', '0_1', '0_2'],
      );
    });

    test('collapse identical height and bitrate', () {
      final List<PlayerRendition> ashdi = distinctRenditions(<VideoTrack>[
        _track('0_0', 480, 900000),
        _track('0_1', 480, 900000),
        _track('0_2', 480, 900000),
      ]);

      expect(ashdi, hasLength(1));
      final List<QualityGroup> groups = buildQualityGroups(
        streamLabels: <String>['Source 1'],
        currentStreamIndex: 0,
        renditions: ashdi,
        autoLabel: 'Auto',
      );
      expect(groups.single.options, isEmpty);
      expect(selectableQualityCount(groups), 1);
    });

    test('add the bitrate only when heights collide', () {
      final List<PlayerRendition> renditions = distinctRenditions(<VideoTrack>[
        _track('0_0', 1080, 6000000),
        _track('0_1', 1080, 3500000),
        _track('0_2', 720, 2000000),
      ]);

      expect(
        renditions.map(
          (PlayerRendition rendition) => renditionLabel(rendition, renditions),
        ),
        <String>['1080p · 6.0 Mbps', '1080p · 3.5 Mbps', '720p'],
      );
    });
  });

  group('quality groups', () {
    test('a single stream with renditions lists Auto and each rendition', () {
      final List<QualityGroup> groups = buildQualityGroups(
        streamLabels: <String>['Source 1'],
        currentStreamIndex: 0,
        renditions: _moonanimeLadder,
        autoLabel: 'Auto',
      );

      expect(
        _labels(groups.single.selectableOptions),
        <String>['Auto', '1080p', '720p', '480p'],
      );
      expect(selectableQualityCount(groups), 4);
    });

    test('a single stream without renditions has nothing to pick', () {
      final List<QualityGroup> groups = buildQualityGroups(
        streamLabels: <String>['Source 1'],
        currentStreamIndex: 0,
        renditions: const <PlayerRendition>[],
        autoLabel: 'Auto',
      );

      expect(selectableQualityCount(groups), 1);
    });

    test('several streams only expand the current one', () {
      final List<QualityGroup> groups = buildQualityGroups(
        streamLabels: <String>['Auto', 'Auto (H.264)'],
        currentStreamIndex: 1,
        renditions: _moonanimeLadder,
        autoLabel: 'Auto',
      );

      expect(groups.first.options, isEmpty);
      expect(
        groups.first.selectableOptions.single.kind,
        QualityOptionKind.stream,
      );
      expect(
        _labels(groups.last.options),
        <String>['Auto', '1080p', '720p', '480p'],
      );
      expect(
        groups.last.options.every(
          (QualityOption option) => option.streamIndex == 1,
        ),
        isTrue,
      );
      expect(selectableQualityCount(groups), 5);
    });

    test('selection follows the stream and the chosen rendition', () {
      final List<QualityGroup> groups = buildQualityGroups(
        streamLabels: <String>['Auto', 'Auto (H.264)'],
        currentStreamIndex: 1,
        renditions: _moonanimeLadder,
        autoLabel: 'Auto',
      );

      expect(
        currentQualityLabel(
          groups,
          currentStreamIndex: 1,
          selectedRenditionId: null,
        ),
        'Auto',
      );
      expect(
        currentQualityLabel(
          groups,
          currentStreamIndex: 1,
          selectedRenditionId: '0_1',
        ),
        '720p',
      );
      expect(
        groups.first.selectableOptions.single.isSelected(
          currentStreamIndex: 1,
          selectedRenditionId: null,
        ),
        isFalse,
      );
    });
  });

  group('remembered quality', () {
    test('matches the exact rendition label', () {
      expect(matchRendition(_moonanimeLadder, '720p')?.id, '0_1');
      expect(matchRendition(_moonanimeLadder, ' 1080P ')?.id, '0_0');
    });

    test('falls back to the closest lower height', () {
      expect(matchRendition(_moonanimeLadder, '900p')?.id, '0_1');
      expect(matchRendition(_moonanimeLadder, '2160p')?.id, '0_0');
    });

    test('picks the lowest rendition when nothing is lower', () {
      expect(matchRendition(_moonanimeLadder, '360p')?.id, '0_2');
    });

    test('ignores labels without a height', () {
      expect(matchRendition(_moonanimeLadder, 'Source 2'), isNull);
    });

    test('recognises Auto in any case', () {
      expect(isAutoQualityLabel('auto'), isTrue);
      expect(isAutoQualityLabel('Auto'), isTrue);
      expect(isAutoQualityLabel('720p'), isFalse);
    });

    test('picks the remembered rendition inside the remembered stream', () {
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference(
            streamLabel: 'Auto (H.264)',
            renditionLabel: '720p',
          ),
          currentStreamLabel: 'Auto (H.264)',
        )?.id,
        '0_1',
      );
    });

    test('stays adaptive for Auto, no label or a single rendition', () {
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference(renditionLabel: 'auto'),
          currentStreamLabel: null,
        ),
        isNull,
      );
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference(streamLabel: 'Main'),
          currentStreamLabel: 'Main',
        ),
        isNull,
      );
      expect(
        preferredRendition(
          renditions: _moonanimeLadder.take(1).toList(),
          preference: const QualityPreference(renditionLabel: '1080p'),
          currentStreamLabel: null,
        ),
        isNull,
      );
    });

    test('a legacy label naming the stream keeps it adaptive', () {
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference.legacy('1080p'),
          currentStreamLabel: '1080p',
        ),
        isNull,
      );
    });

    test('a legacy label naming a rendition still picks it', () {
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference.legacy('720p'),
          currentStreamLabel: null,
        )?.id,
        '0_1',
      );
    });

    test('a new rendition label matching the stream label is still applied',
        () {
      expect(
        preferredRendition(
          renditions: _moonanimeLadder,
          preference: const QualityPreference(
            streamLabel: '1080p',
            renditionLabel: '1080p',
          ),
          currentStreamLabel: '1080p',
        )?.id,
        '0_0',
      );
    });
  });

  testWidgets('the picker groups renditions under their stream',
      (WidgetTester tester) async {
    final List<QualityGroup> groups = buildQualityGroups(
      streamLabels: <String>['Main', 'Backup'],
      currentStreamIndex: 0,
      renditions: _moonanimeLadder,
      autoLabel: 'Auto',
    );
    QualityOption? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showQualityPicker(
                  context,
                  groups: groups,
                  currentStreamIndex: 0,
                  selectedRenditionId: null,
                  onSelected: (QualityOption option) => picked = option,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('480p'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('720p'));
    await tester.pumpAndSettle();
    expect(picked?.rendition?.id, '0_1');
  });
}
