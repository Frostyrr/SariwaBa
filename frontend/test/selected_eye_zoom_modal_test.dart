import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/widgets/dashboard/current_scan_panel.dart';
import 'package:frontend/widgets/dashboard/scanner_workstation_card.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_test.dart' show FakeClassificationRepository, kValidPngBytes;

void main() {
  testWidgets(
    'Hovering selected eye shows zoom affordance and clicking opens zoom modal with carousel & scale controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final controller = ClassificationController(
        FakeClassificationRepository(),
        isAuthenticated: false,
      );
      addTearDown(controller.dispose);

      final List<EyeCropProposal> proposals = [
        (
          bytes: kValidPngBytes,
          rect: const Rect.fromLTWH(0.15, 0.20, 0.18, 0.18),
          eyeCenter: const Offset(0.24, 0.29),
        ),
        (
          bytes: kValidPngBytes,
          rect: const Rect.fromLTWH(0.60, 0.30, 0.18, 0.18),
          eyeCenter: const Offset(0.69, 0.39),
        ),
      ];

      // Seed state with two detected eye proposals and Eye #1 selected
      controller.state = ClassificationState(
        selectedImageBytes: kValidPngBytes,
        selectedImageName: 'tilapia_whole.png',
        confirmedImageBytes: kValidPngBytes,
        isCropConfirmed: true,
        eyeProposals: proposals,
        selectedEyeProposalIndex: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<ClassificationState>(
              stream: controller.stream,
              initialData: controller.state,
              builder: (context, snap) {
                final st = snap.data!;
                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ScannerWorkstationCard(
                          state: st,
                          controller: controller,
                          isCropModalOpen: false,
                          onOpenCropModal: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CurrentScanPanel(
                          state: st,
                          controller: controller,
                          isWide: true,
                          onAdjustCrop: () {},
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Hover over the selected eye tile (#1) in the filmstrip
      final tile0 = find.byKey(const Key('eye_proposal_tile_0'));
      expect(tile0, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(tile0));
      await tester.pumpAndSettle();

      final hoverOverlay = tester.widget<AnimatedOpacity>(
        find.byKey(const Key('eye_proposal_hover_zoom_0')),
      );
      expect(hoverOverlay.opacity, 1.0);

      // 2. Click the selected eye tile to open the zoom modal
      await tester.tap(tile0);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('eye_zoom_modal')), findsOneWidget);
      expect(find.text('Selected Eye #1'), findsOneWidget);
      expect(find.text('Eye 1 of 2'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // 3. Test Zoom In (+50% -> 150%) and Reset (-> 100%)
      await tester.tap(find.byKey(const Key('eye_zoom_in_button')));
      await tester.pumpAndSettle();
      expect(find.text('150%'), findsOneWidget);

      await tester.tap(find.byKey(const Key('eye_zoom_reset_pill')));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);

      // 4. Click Next Arrow (->) to navigate to Eye 2 of 2 and verify selection syncs
      await tester.tap(find.byKey(const Key('eye_zoom_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Selected Eye #2'), findsOneWidget);
      expect(find.text('Eye 2 of 2'), findsOneWidget);
      expect(controller.state.selectedEyeProposalIndex, 1);

      // 5. Close modal and verify CurrentScanPanel thumbnail also opens zoom modal
      await tester.tap(find.byKey(const Key('eye_zoom_close_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('eye_zoom_modal')), findsNothing);

      final panelThumb = find.byKey(
        const Key('selected_eye_preview_thumbnail'),
      );
      expect(panelThumb, findsOneWidget);
      await tester.tap(panelThumb);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('eye_zoom_modal')), findsOneWidget);
      expect(find.text('Eye 2 of 2'), findsOneWidget);
    },
  );
}
