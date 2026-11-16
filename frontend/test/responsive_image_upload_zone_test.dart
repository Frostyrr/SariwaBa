import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/services/storage/guest_history_cache.dart';
import 'package:frontend/widgets/classification/responsive_image_upload_zone.dart';

class MockClassificationService extends Fake
    implements ClassificationService {
  @override
  Future<List<ClassificationResult>> fetchHistory() async => [];
}

class MockGuestCache extends Fake implements GuestHistoryCache {
  @override
  Future<List<ClassificationResult>> getCachedHistory() async => [];
}

class MockImagePicker extends Fake implements ImagePicker {
  ImageSource? lastSource;
  XFile? mockFileToReturn;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    return mockFileToReturn;
  }
}

void main() {
  late MockImagePicker mockPicker;
  late ClassificationController controller;

  setUp(() {
    mockPicker = MockImagePicker();
    controller = ClassificationController(
      MockClassificationService(),
      picker: mockPicker,
      guestCache: MockGuestCache(),
    );
  });

  Widget buildTestableWidget({
    required Widget child,
    Size size = const Size(1280, 800),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('ResponsiveImageUploadZone', () {
    testWidgets(
      'Desktop Wide: renders dropzone text, format constraints, desktop footer row with Use Camera and Region selector',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestableWidget(
            child: ResponsiveImageUploadZone(
              state: controller.state,
              controller: controller,
            ),
            size: const Size(800, 400),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Dropzone content
        expect(
          find.text('Drop an image here, or click to browse'),
          findsOneWidget,
        );
        expect(
          find.text('JPG, JPEG, PNG, HEIC · Max 5 MB'),
          findsOneWidget,
        );
        expect(find.byIcon(CupertinoIcons.arrow_up_doc), findsOneWidget);

        // 2. Desktop footer row controls
        expect(find.text('Inspection Region:'), findsOneWidget);
        expect(find.text('Use Camera'), findsOneWidget);
        expect(find.byKey(const Key('use_camera_button')), findsOneWidget);
        expect(find.byKey(const Key('region_option_eye')), findsOneWidget);
        expect(find.byKey(const Key('region_option_gill')), findsOneWidget);

        // Eye selected by default
        expect(controller.state.selectedRegion, AnatomicalRegion.eye);

        // 3. Click anywhere in upload zone opens gallery picker
        await tester.tap(find.byKey(const Key('empty_upload_dropzone')));
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.gallery);

        // 4. Click Use Camera opens camera picker
        await tester.tap(find.byKey(const Key('use_camera_button')));
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.camera);

        // 5. Toggle region selector to Gill and back to Eye
        await tester.tap(find.byKey(const Key('region_option_gill')));
        await tester.pumpAndSettle();
        expect(controller.state.selectedRegion, AnatomicalRegion.gill);

        await tester.tap(find.byKey(const Key('region_option_eye')));
        await tester.pumpAndSettle();
        expect(controller.state.selectedRegion, AnatomicalRegion.eye);
      },
    );

    testWidgets(
      'Mobile 375px: renders mobile tap instruction, full-width Take a Photo, full-width segmented selector without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestableWidget(
            child: ResponsiveImageUploadZone(
              state: controller.state,
              controller: controller,
            ),
            size: const Size(375, 600),
          ),
        );
        await tester.pumpAndSettle();

        // Mobile copy
        expect(find.text('Tap to select an image'), findsOneWidget);
        expect(find.text('Drop an image here, or click to browse'), findsNothing);
        expect(find.text('Take a Photo'), findsOneWidget);
        expect(find.text('Inspection Region'), findsOneWidget);

        // Tap mobile dropzone opens gallery
        await tester.tap(find.byKey(const Key('empty_upload_dropzone')));
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.gallery);

        // Tap mobile Take a Photo button opens camera
        await tester.tap(find.byKey(const Key('use_camera_button')));
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.camera);

        // Tap mobile Gill segment
        await tester.tap(find.byKey(const Key('region_option_gill')));
        await tester.pumpAndSettle();
        expect(controller.state.selectedRegion, AnatomicalRegion.gill);
      },
    );

    testWidgets(
      'Tablet 768px: adapts cleanly without overflow or awkward stretching',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestableWidget(
            child: ResponsiveImageUploadZone(
              state: controller.state,
              controller: controller,
            ),
            size: const Size(700, 500),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Drop an image here, or click to browse'),
          findsOneWidget,
        );
        expect(find.text('Use Camera'), findsOneWidget);
        expect(find.text('Inspection Region:'), findsOneWidget);
      },
    );

    testWidgets(
      'Keyboard accessibility: Enter and Space keys trigger file selection',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveImageUploadZone(
                state: controller.state,
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Focus dropzone and send Enter key
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        mockPicker.lastSource = null;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.gallery);

        // Send Space key
        mockPicker.lastSource = null;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(mockPicker.lastSource, ImageSource.gallery);
      },
    );

    testWidgets(
      'Accessibility: Semantics labels and button roles present',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            child: ResponsiveImageUploadZone(
              state: controller.state,
              controller: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.byKey(const Key('empty_upload_dropzone'))),
          matchesSemantics(
            isButton: true,
            hasTapAction: true,
            hasEnabledState: true,
            isEnabled: true,
            hasFocusAction: true,
            isFocusable: true,
            label:
                'Fish specimen upload dropzone. Drop an image here or press Enter to browse files.',
          ),
        );

        expect(
          tester.getSemantics(find.byKey(const Key('region_option_eye'))),
          matchesSemantics(
            isButton: true,
            isSelected: true,
            hasSelectedState: true,
            hasTapAction: true,
            label: 'Eye (Mata) region',
          ),
        );

        expect(
          tester.getSemantics(find.byKey(const Key('region_option_gill'))),
          matchesSemantics(
            isButton: true,
            isSelected: false,
            hasSelectedState: true,
            hasTapAction: true,
            label: 'Gill (Hasang) region',
          ),
        );
      },
    );

    test('DashedBorderPainter: paints cleanly and handles repaint checks', () {
      const painter = DashedBorderPainter(
        color: Colors.teal,
        strokeWidth: 1.5,
        dashLength: 7.0,
        dashGap: 5.0,
        borderRadius: 20.0,
      );

      expect(painter.shouldRepaint(painter), isFalse);

      const differentColor = DashedBorderPainter(
        color: Colors.red,
        strokeWidth: 1.5,
      );
      expect(painter.shouldRepaint(differentColor), isTrue);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(200, 100));
      painter.paint(canvas, Size.zero); // Should safely no-op for zero size
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}
