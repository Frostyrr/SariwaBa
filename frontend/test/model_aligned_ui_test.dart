import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/widgets/classification/classification_result_card.dart';
import 'package:frontend/screens/dashboard/sections/grade_breakdown_section.dart';
import 'package:frontend/screens/dashboard/sections/freshness_trends_section.dart';
import 'package:frontend/widgets/landing/hero_scanner_card.dart';

void main() {
  test('missing and unrecognised labels cannot become Fresh', () {
    expect(ClassificationResult.fromJson({}).isFresh, isFalse);
    for (final label in ['NonFresh', 'Not Fresh', 'non-fresh']) {
      final result = ClassificationResult(label: label, confidence: .8);
      expect(result.isFresh, isFalse);
      expect(result.isNotFresh, isTrue);
    }
    const unknown = ClassificationResult(label: 'Unknown', confidence: .9);
    expect(unknown.isNotFresh, isFalse);
    expect(
      const ClassificationResult(label: 'Fresh', confidence: .8).isFresh,
      isTrue,
    );
  });

  final history = [
    ClassificationResult(
      label: 'Fresh',
      confidence: .9,
      createdAt: DateTime(2026, 10, 2),
    ),
    ClassificationResult(
      label: 'Not Fresh',
      confidence: .8,
      createdAt: DateTime(2026, 10, 3),
    ),
    const ClassificationResult(label: 'Unknown', confidence: .7),
  ];

  for (final width in [375.0, 768.0, 1024.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('accurate summaries fit width $width text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      ClassificationResultCard(result: history.first),
                      GradeBreakdownSection(history: history),
                      FreshnessTrendsSection(history: history),
                      const HeroScannerCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text('Fresh: 1 of 3 scans'), findsOneWidget);
        expect(find.text('Not Fresh: 1 of 3 scans'), findsOneWidget);
        expect(find.text('Unknown label: 1 of 3 scans'), findsOneWidget);
        expect(find.text('Average model confidence: 80.0%'), findsOneWidget);
        expect(
          find.text('1 scans without a timestamp are excluded.'),
          findsOneWidget,
        );
        expect(find.text('Example result'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('empty history contains no invented metrics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradeBreakdownSection(history: [])),
      ),
    );
    expect(
      find.text('No scans yet. Classify an image to see your summary.'),
      findsOneWidget,
    );
    expect(find.textContaining('Average model confidence:'), findsNothing);
  });
}
