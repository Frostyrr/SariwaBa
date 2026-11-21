import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/pages/dashboard/dashboard_page.dart';
import 'package:frontend/screens/auth/auth_page.dart';
import 'package:frontend/widgets/dashboard/organoleptic_guidelines_dialog.dart';

Future<void> _saveScreenshot(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String outputPath,
) async {
  await tester.pump(const Duration(milliseconds: 500));
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}

void main() {
  const outDir =
      r'C:\Users\Marc\.gemini\antigravity\brain\f2998732-1713-41fc-aade-40282048856b\scratch';

  testWidgets('Capture mobile screenshots', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // 1. AuthPage (Mobile)
    final authKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(key: authKey, child: const AuthPage()),
        ),
      ),
    );
    await _saveScreenshot(tester, authKey, '$outDir\\mobile_auth.png');

    // 2. DashboardPage (Mobile Inspection Tab)
    final dashKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(key: dashKey, child: const DashboardPage()),
        ),
      ),
    );
    await _saveScreenshot(tester, dashKey, '$outDir\\mobile_dashboard.png');

    // 3. OrganolepticGuidelinesDialog (Mobile Bottom Sheet)
    final sheetKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: sheetKey,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => OrganolepticGuidelinesDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await _saveScreenshot(tester, sheetKey, '$outDir\\mobile_guidelines_sheet.png');
  });
}
