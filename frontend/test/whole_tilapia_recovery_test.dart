import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/widgets/dashboard/scanner_workstation_card.dart';

class _DummyClassificationService implements ClassificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWholeTilapiaController extends ClassificationController {
  _FakeWholeTilapiaController(ClassificationState initialState)
      : super(_DummyClassificationService()) {
    state = initialState;
  }
}

void main() {
  testWidgets(
    'WHOLE_TILAPIA_CLOSE_UP_REQUIRED shows Close-Up Required, recovery guidance, and no freshness result',
    (tester) async {
      final state = ClassificationState(
        selectedImageBytes: Uint8List.fromList([1, 2, 3, 4]),
        selectedImageName: 'whole_tilapia.png',
        selectedRegion: AnatomicalRegion.eye,
        isInputRejection: true,
        errorCode: 'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
        errorMessage:
            'This appears to be a whole Tilapia. Take a close-up of its eye or exposed gill to assess freshness.',
      );
      final controller = _FakeWholeTilapiaController(state);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScannerWorkstationCard(
                state: state,
                controller: controller,
                isCropModalOpen: false,
                onOpenCropModal: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Close-Up Required'), findsOneWidget);
      expect(
        find.text(
          'Take a close-up of one eye or the exposed gill, then select its matching region.',
        ),
        findsWidgets,
      );
      expect(find.text('Fresh'), findsNothing);
      expect(find.text('Not Fresh'), findsNothing);
      expect(find.text('Edit Crop'), findsWidgets);
    },
  );
}
