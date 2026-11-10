import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/widgets/classification/roi_cropper_widget.dart';
import 'package:frontend/widgets/navigation/web_navbar.dart';
import 'package:frontend/main.dart';

/// Minimal valid 1x1 PNG byte array with valid PNG signature
final Uint8List kValidPngBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

/// Second distinct valid PNG byte array for testing cropped vs original bytes and image replacement
final Uint8List kDistinctCroppedPngBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x72, 0xB6, 0x0D,
  0x24, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class FakeAuthRepository implements AuthRepository {
  UserModel? mockUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel> authenticateWithGoogleToken(String idToken) async {
    return mockUser ??
        const UserModel(
          id: 'test-user-1',
          email: 'fisherman@sariwaba.ph',
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          username: 'juandc',
        );
  }

  @override
  Future<UserModel?> getProfile() async {
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    mockUser = null;
  }
}

class FakeGoogleSignInService implements GoogleSignInService {
  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => const Stream.empty();

  @override
  Future<GoogleSignInAccount?> signIn() async {
    return null;
  }

  @override
  Future<GoogleSignInAccount?> signInSilently({bool reAuthenticate = false}) async {
    return null;
  }

  @override
  Future<void> signOut() async {}
}

class FakeClassificationRepository implements ClassificationRepository {
  List<ClassificationResult> mockHistory = [];
  Uint8List? lastSubmittedBytes;
  String? lastSubmittedFilename;
  String? lastSubmittedRegionType;
  int classifyCallCount = 0;
  Exception? errorToThrow;
  Completer<ClassificationResult>? pendingCompleter;
  ClassificationResult? resultToReturn;

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
    String regionType = 'eye',
  }) async {
    classifyCallCount++;
    lastSubmittedBytes = bytes;
    lastSubmittedFilename = filename;
    lastSubmittedRegionType = regionType;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    if (resultToReturn != null) {
      return resultToReturn!;
    }

    return ClassificationResult(
      scanId: 101,
      label: 'Fresh',
      confidence: 0.96,
      regionType: regionType,
      species: 'Tilapia',
      saved: true,
    );
  }

  @override
  Future<List<ClassificationResult>> fetchHistory() async {
    return mockHistory;
  }

  @override
  Future<void> deleteScan(int scanId) async {
    mockHistory.removeWhere((s) => s.scanId == scanId);
  }
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets(
      'Desktop web landing renders navbar, clean hero, and navigates to auth page',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository();
    final fakeGoogleService = FakeGoogleSignInService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
          googleSignInServiceProvider
              .overrideWithValue(fakeGoogleService as dynamic),
        ],
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('Features')), findsOneWidget);
    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('How it Works')), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    expect(find.text('SariwaBa? See for yourself.'), findsOneWidget);
    expect(find.text('A smarter way to assess fish freshness through AI.'), findsOneWidget);
    expect(find.text('Download App'), findsAtLeast(2));

    await tester.tap(find.text('Download App').first);
    await tester.pumpAndSettle();

    expect(find.text('Get SariwaBa.'), findsOneWidget);
    expect(find.text('iPhone & iPad'), findsOneWidget);
    expect(find.text('Android'), findsOneWidget);
    expect(find.text('Web'), findsOneWidget);

    await tester.ensureVisible(find.text('Open the web app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open the web app'));
    await tester.pumpAndSettle();

    expect(find.text('SariwaBa'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('Features')), findsOneWidget);
  });

  testWidgets(
      'Mobile landing renders responsive hero and guest mode access',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository();
    final fakeGoogleService = FakeGoogleSignInService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
          googleSignInServiceProvider
              .overrideWithValue(fakeGoogleService as dynamic),
        ],
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Guest Evaluation Mode'), findsOneWidget);
    expect(find.text('Connect with Google'), findsOneWidget);
  });

  testWidgets(
      'Authenticated user is redirected to Dashboard with off-white background, avatar, and classification workstation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository();
    fakeRepo.mockUser = const UserModel(
      id: 'usr-42',
      email: 'fisherman@sariwaba.ph',
      firstName: 'Juan',
      lastName: 'Dela Cruz',
      username: 'juandc',
      role: 'user',
      profilePicture: 'https://example.com/avatar.jpg',
    );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
          googleSignInServiceProvider
              .overrideWithValue(fakeGoogleService as dynamic),
          classificationRepositoryProvider
              .overrideWithValue(fakeClassRepo as dynamic),
        ],
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Juan!'), findsOneWidget);
    expect(find.text('Live Freshness Inspection'), findsOneWidget);
    expect(find.text('Audit History'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
    expect(find.text('Juan'), findsOneWidget);
  });

  testWidgets(
      'Workflow: guards unconfirmed submission, confirms full close-up or cropped bytes, invalidates on region/image change, and displays truthful result wording',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-99',
        email: 'inspector@sariwaba.ph',
        firstName: 'Maria',
        lastName: 'Santos',
        username: 'mariasantos',
      );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository();

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final controller =
        container.read(classificationControllerProvider.notifier);

    // 1. Select valid PNG image -> interactive ROI cropper and Eye/Gill guidance appear
    controller.setSelectedImage(
      bytes: kValidPngBytes,
      filename: 'tilapia_whole.png',
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Eye: Select the fish's visible eye and surrounding area."),
      findsOneWidget,
    );
    expect(
      find.text('Gill: Select exposed gill tissue, not the external gill cover.'),
      findsOneWidget,
    );

    // 2. Eye is pre-selected by default when an image is uploaded; jargon like PostgreSQL is absent
    expect(
      container.read(classificationControllerProvider).selectedRegion,
      equals(AnatomicalRegion.eye),
    );
    expect(
      container.read(classificationControllerProvider).workflowStage,
      equals(ClassificationWorkflowStage.regionSelected),
    );
    expect(find.textContaining('PostgreSQL'), findsNothing);
    expect(fakeClassRepo.lastSubmittedBytes, isNull);

    // 3. Select Gill region; direct controller.classify() before confirmation is guarded
    await tester.ensureVisible(find.byKey(const Key('region_option_gill')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('region_option_gill')));
    await tester.pumpAndSettle();
    expect(
      container.read(classificationControllerProvider).workflowStage,
      equals(ClassificationWorkflowStage.regionSelected),
    );

    await controller.classify();
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Please confirm your selected anatomical region (crop the region or confirm full close-up) before classifying.',
      ),
      findsOneWidget,
    );
    expect(fakeClassRepo.lastSubmittedBytes, isNull);

    // 4. Confirm full close-up image -> Confirmed Region Preview shown
    await tester.ensureVisible(find.byKey(const Key('confirm_full_image_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_full_image_button')));
    await tester.pumpAndSettle();

    expect(
      container.read(classificationControllerProvider).workflowStage,
      equals(ClassificationWorkflowStage.cropConfirmed),
    );
    expect(find.byKey(const Key('confirmed_region_preview')), findsOneWidget);
    expect(find.text('Confirmed Gill Region Ready'), findsOneWidget);
    expect(find.text('Full Close-Up'), findsOneWidget);
    expect(
      container.read(classificationControllerProvider).confirmedImageBytes,
      same(kValidPngBytes),
    );

    // 5. Changing region after confirmation invalidates stale confirmation
    await tester.ensureVisible(find.byKey(const Key('region_option_eye')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('region_option_eye')));
    await tester.pumpAndSettle();

    expect(
      container.read(classificationControllerProvider).isCropConfirmed,
      isFalse,
    );
    expect(
      container.read(classificationControllerProvider).confirmedImageBytes,
      isNull,
    );
    expect(find.byKey(const Key('confirmed_region_preview')), findsNothing);

    // 6. Confirm cropped region with distinct cropped bytes and verify those exact bytes are uploaded
    controller.confirmCroppedRegion(
      kDistinctCroppedPngBytes,
      normalizedCropRect: const Rect.fromLTWH(0.15, 0.20, 0.60, 0.60),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirmed Eye Region Ready'), findsOneWidget);
    expect(find.text('Cropped Photo'), findsOneWidget);

    // 7. Submit classification and verify truthful "Analyzing image..." state + duplicate submit prevention
    final completer = Completer<ClassificationResult>();
    fakeClassRepo.pendingCompleter = completer;

    await tester.ensureVisible(find.text('Validate & Classify Freshness'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Validate & Classify Freshness'));
    await tester.pump();

    expect(container.read(classificationControllerProvider).isClassifying, isTrue);
    expect(
      container.read(classificationControllerProvider).workflowStage,
      equals(ClassificationWorkflowStage.processing),
    );
    expect(find.byKey(const Key('analyzing_image_status')), findsOneWidget);
    expect(find.text('Analyzing image...'), findsOneWidget);

    // Duplicate call while classifying is ignored
    await controller.classify();
    expect(fakeClassRepo.classifyCallCount, equals(1));

    completer.complete(
      const ClassificationResult(
        scanId: 305,
        label: 'Fresh',
        confidence: 0.942,
        regionType: 'eye',
        species: 'Tilapia',
        saved: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(classificationControllerProvider).workflowStage,
      equals(ClassificationWorkflowStage.classificationSuccess),
    );

    // Verify the confirmed cropped bytes (not the original full image bytes) were uploaded
    expect(
      fakeClassRepo.lastSubmittedBytes,
      same(kDistinctCroppedPngBytes),
    );
    expect(
      fakeClassRepo.lastSubmittedBytes,
      isNot(same(kValidPngBytes)),
    );
    expect(fakeClassRepo.lastSubmittedRegionType, equals('eye'));

    // Verify truthful result wording (Selected region, Assessment scope, confidence note, save status, disclaimer)
    expect(find.byKey(const Key('classification_result_view')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('classification_result_view')),
        matching: find.text('Selected region: Eye'),
      ),
      findsOneWidget,
    );
    expect(find.text('Assessment scope: Tilapia'), findsOneWidget);
    expect(find.text('Model Confidence: 94.2%'), findsOneWidget);
    expect(
      find.text('Confidence is a model prediction score, not a freshness percentage.'),
      findsOneWidget,
    );
    expect(find.text('Saved to History (Scan #305)'), findsOneWidget);
    expect(
      find.text(
        'This is a preliminary visual freshness assessment and does not guarantee food safety.',
      ),
      findsOneWidget,
    );
    // Ensure fabricated grades / body-part claims are absent
    expect(find.textContaining('Clear cornea'), findsNothing);
    expect(find.textContaining('Ruby red'), findsNothing);

    // 8. Replacing the image invalidates confirmation and clears previous result
    controller.setSelectedImage(
      bytes: kValidPngBytes,
      filename: 'new_tilapia.png',
    );
    await tester.pumpAndSettle();
    expect(container.read(classificationControllerProvider).isCropConfirmed, isFalse);
    expect(container.read(classificationControllerProvider).latestResult, isNull);
    expect(find.byKey(const Key('classification_result_view')), findsNothing);
  });

  test(
      'Crop geometry math accurately maps viewport reticle across portrait, landscape, square, zoom, pan, and different viewport sizes',
      () {
    // 1. Square image (1000x1000) in square viewport (300x300) at identity transform (1.0x)
    final squareNorm = RoiCropperWidget.computeNormalizedCropRect(
      viewportSize: const Size(300, 300),
      imageSize: const Size(1000, 1000),
      transform: Matrix4.identity(),
      cropWindowFraction: 0.76,
    );
    expect(squareNorm.left, closeTo(0.12, 0.001));
    expect(squareNorm.top, closeTo(0.12, 0.001));
    expect(squareNorm.width, closeTo(0.76, 0.001));
    expect(squareNorm.height, closeTo(0.76, 0.001));

    // 2. Landscape image (1200x600, 2:1) in wider viewport (400x300)
    // BoxFit.contain fits 1200x600 into 400x300 as 400x200 centered vertically (top=50, bottom=250).
    // Crop window is min(400,300)*0.76 = 228x228 centered at (200,150).
    // Horizontally: 228 / 400 = 0.57 width (left = 0.215, right = 0.785).
    // Vertically: 228 exceeds 200 displayed height -> clamped to [0.0, 1.0].
    final landscapeNorm = RoiCropperWidget.computeNormalizedCropRect(
      viewportSize: const Size(400, 300),
      imageSize: const Size(1200, 600),
      transform: Matrix4.identity(),
      cropWindowFraction: 0.76,
    );
    expect(landscapeNorm.left, closeTo(0.215, 0.005));
    expect(landscapeNorm.right, closeTo(0.785, 0.005));
    expect(landscapeNorm.top, closeTo(0.0, 0.001));
    expect(landscapeNorm.bottom, closeTo(1.0, 0.001));

    // 3. Portrait image (600x1200, 1:2) in compact mobile viewport (320x260)
    // BoxFit.contain fits 600x1200 into 320x260 as 130x260 centered horizontally.
    // Vertically: cropSide = 260 * 0.76 = 197.6 -> normalized height = 0.76 (top=0.12, bottom=0.88).
    final portraitNorm = RoiCropperWidget.computeNormalizedCropRect(
      viewportSize: const Size(320, 260),
      imageSize: const Size(600, 1200),
      transform: Matrix4.identity(),
      cropWindowFraction: 0.76,
    );
    expect(portraitNorm.top, closeTo(0.12, 0.005));
    expect(portraitNorm.bottom, closeTo(0.88, 0.005));
    expect(portraitNorm.left, closeTo(0.0, 0.001));
    expect(portraitNorm.right, closeTo(1.0, 0.001));

    // 4. Zoom 2.0x around center of a 300x300 viewport with 1000x1000 image -> halves normalized crop width/height
    const center = Offset(150, 150);
    final zoom2xMatrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0.0, 1.0)
      ..scaleByDouble(2.0, 2.0, 1.0, 1.0)
      ..translateByDouble(-center.dx, -center.dy, 0.0, 1.0);

    final zoomedNorm = RoiCropperWidget.computeNormalizedCropRect(
      viewportSize: const Size(300, 300),
      imageSize: const Size(1000, 1000),
      transform: zoom2xMatrix,
      cropWindowFraction: 0.76,
    );
    expect(zoomedNorm.width, closeTo(0.38, 0.005));
    expect(zoomedNorm.height, closeTo(0.38, 0.005));
    expect(zoomedNorm.center.dx, closeTo(0.50, 0.005));
    expect(zoomedNorm.center.dy, closeTo(0.50, 0.005));

    // 5. Pan after zoom shifts the normalized source rectangle in the opposite direction of image drag
    final zoomAndPanMatrix = zoom2xMatrix.clone()
      ..translateByDouble(-30.0, -15.0, 0.0, 1.0);
    final pannedSrcRect = RoiCropperWidget.computeSourceCropRect(
      viewportSize: const Size(300, 300),
      imageSize: const Size(1000, 1000),
      transform: zoomAndPanMatrix,
      cropWindowFraction: 0.76,
    );
    expect(pannedSrcRect.left, greaterThan(zoomedNorm.left * 1000));
    expect(pannedSrcRect.top, greaterThan(zoomedNorm.top * 1000));
  });

  testWidgets(
      'Future Model A backend rejection codes (UNSUPPORTED_IMAGE, REGION_MISMATCH, CONTENT_UNCERTAIN, POOR_IMAGE_QUALITY) preserve selection, omit prediction/history, and support Edit Crop / Replace Image / Retry',
      (WidgetTester tester) async {
    // NOTE: These tests use clearly identified mocks for FUTURE Model A backend rejection codes.
    // The current Django backend does not yet emit Model A content/quality rejection codes.
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-55',
        email: 'tester@sariwaba.ph',
        firstName: 'Carlo',
        lastName: 'Ramos',
        username: 'carloramos',
      );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository();

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final controller =
        container.read(classificationControllerProvider.notifier);

    controller.setSelectedImage(
      bytes: kValidPngBytes,
      filename: 'tilapia_candidate.png',
    );
    controller.selectRegion(AnatomicalRegion.eye);
    controller.confirmCroppedRegion(kDistinctCroppedPngBytes);
    await tester.pumpAndSettle();

    final futureRejectionMocks = <Map<String, String>>[
      {
        'code': 'UNSUPPORTED_IMAGE',
        'message': 'Mock future Model A: Image does not contain a Tilapia eye or gill.',
      },
      {
        'code': 'REGION_MISMATCH',
        'message': 'Mock future Model A: Selected Eye, but cropped region appears to be gill tissue.',
      },
      {
        'code': 'CONTENT_UNCERTAIN',
        'message': 'Mock future Model A: Anatomical region could not be verified with sufficient confidence.',
      },
      {
        'code': 'POOR_IMAGE_QUALITY',
        'message': 'Mock future Model A: Cropped region is too blurry or underexposed.',
      },
    ];

    for (final mock in futureRejectionMocks) {
      fakeClassRepo.errorToThrow = ClassificationApiException(
        code: mock['code']!,
        message: mock['message']!,
        statusCode: 422,
      );

      await controller.classify();
      await tester.pumpAndSettle();

      final state = container.read(classificationControllerProvider);
      expect(state.isInputRejection, isTrue);
      expect(
        state.workflowStage,
        equals(ClassificationWorkflowStage.validationRejected),
      );
      expect(state.errorCode, equals(mock['code']));
      expect(state.selectedImageBytes, same(kValidPngBytes));
      expect(state.selectedRegion, equals(AnatomicalRegion.eye));
      expect(state.latestResult, isNull);
      expect(state.history, isEmpty);

      // Dedicated Image Rejection State Card is displayed
      expect(find.byKey(const Key('image_rejection_card')), findsOneWidget);
      expect(find.text('Image Not Supported'), findsOneWidget);
      expect(
        find.text(
          'The uploaded image could not be verified as a supported fish eye or exposed-gill photograph.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Input Rejected (${mock['code']})'), findsOneWidget);
      expect(find.text(mock['message']!), findsWidgets);
      expect(find.byKey(const Key('classification_result_view')), findsNothing);

      // Recovery actions are offered on the rejection card and banner
      expect(find.byKey(const Key('rejection_edit_crop_button')), findsOneWidget);
      expect(find.byKey(const Key('rejection_change_region_button')), findsOneWidget);
      expect(find.byKey(const Key('rejection_replace_image_button')), findsOneWidget);
      expect(find.byKey(const Key('rejection_try_again_button')), findsOneWidget);
    }

    // Test "Try Again" recovery action when backend succeeds on retry
    fakeClassRepo.errorToThrow = null;
    fakeClassRepo.resultToReturn = const ClassificationResult(
      scanId: 501,
      label: 'Not Fresh',
      confidence: 0.89,
      regionType: 'eye',
      species: 'Tilapia',
      saved: true,
    );

    await tester.ensureVisible(find.byKey(const Key('rejection_try_again_button')));
    await tester.tap(find.byKey(const Key('rejection_try_again_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('classification_result_view')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('classification_result_view')),
        matching: find.text('Selected region: Eye'),
      ),
      findsOneWidget,
    );

    // Test "Change Region" and "Edit Crop" recovery actions after another rejection
    fakeClassRepo.errorToThrow = const ClassificationApiException(
      code: 'REGION_MISMATCH',
      message: 'Mock future Model A: Region mismatch.',
      statusCode: 422,
    );
    await controller.classify();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('rejection_change_region_button')));
    await tester.tap(find.byKey(const Key('rejection_change_region_button')));
    await tester.pumpAndSettle();

    expect(
      container.read(classificationControllerProvider).selectedRegion,
      equals(AnatomicalRegion.gill),
    );
    expect(container.read(classificationControllerProvider).isCropConfirmed, isFalse);
    expect(find.byKey(const Key('interactive_crop_viewport')), findsOneWidget);
  });

  test(
      'Stale in-flight classification response is ignored if user replaces image or changes region before completion',
      () async {
    final fakeClassRepo = FakeClassificationRepository();
    final staleCompleter = Completer<ClassificationResult>();
    fakeClassRepo.pendingCompleter = staleCompleter;

    final controller = ClassificationController(fakeClassRepo);

    // Select first image, confirm, and start classify()
    controller.setSelectedImage(bytes: kValidPngBytes, filename: 'first.png');
    controller.selectRegion(AnatomicalRegion.eye);
    controller.confirmFullImageAsCloseUp();

    final firstFuture = controller.classify();
    expect(controller.state.isClassifying, isTrue);

    // Replace image while first request is still in flight
    controller.setSelectedImage(
      bytes: kDistinctCroppedPngBytes,
      filename: 'second.png',
    );
    expect(controller.state.isClassifying, isFalse);
    expect(controller.state.selectedImageName, equals('second.png'));

    // Now the stale first request completes
    staleCompleter.complete(
      const ClassificationResult(
        scanId: 999,
        label: 'Fresh',
        confidence: 0.99,
        regionType: 'eye',
        species: 'Tilapia',
        saved: true,
      ),
    );
    await firstFuture;

    // Stale response must NOT overwrite the state for the new image or enter history
    expect(controller.state.latestResult, isNull);
    expect(controller.state.history, isEmpty);
    expect(controller.state.selectedImageName, equals('second.png'));
  });

  testWidgets(
      'Guest vs Authenticated save status and older history records without region_type metadata',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-77',
        email: 'audit@sariwaba.ph',
        firstName: 'Liza',
        lastName: 'Gomez',
        username: 'lizagomez',
      );
    final fakeGoogleService = FakeGoogleSignInService();

    // Older history record created before region_type existed (region_type: null)
    final legacyRecord = ClassificationResult.fromJson({
      'scan_id': 12,
      'classification': 'Fresh',
      'confidence': 0.91,
      'region_type': null,
      'species': 'Tilapia',
      'saved': true,
    });
    expect(legacyRecord.regionType, isNull);
    expect(legacyRecord.anatomicalRegion, isNull);
    expect(legacyRecord.regionDisplayName, isNull);

    final fakeClassRepo = FakeClassificationRepository()
      ..mockHistory = [legacyRecord]
      ..resultToReturn = const ClassificationResult(
        scanId: null,
        label: 'Not Fresh',
        confidence: 0.84,
        regionType: 'gill',
        species: 'Tilapia',
        saved: false,
      );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify legacy history record renders without inventing "Selected region: Eye" or "Gill"
    expect(find.text('Audit Scan #12'), findsOneWidget);
    expect(find.text('Selected region: Eye'), findsNothing);
    expect(find.text('Selected region: Gill'), findsNothing);

    // Run a guest-style response (saved: false, scan_id: null)
    final controller =
        container.read(classificationControllerProvider.notifier);
    controller.setSelectedImage(bytes: kValidPngBytes, filename: 'guest_gill.png');
    controller.selectRegion(AnatomicalRegion.gill);
    controller.confirmFullImageAsCloseUp();
    await controller.classify();
    await tester.pumpAndSettle();

    expect(find.text('Selected region: Gill'), findsOneWidget);
    expect(find.text('Not Saved to History (Guest Session)'), findsOneWidget);
    // Guest result must not be added to history list
    expect(container.read(classificationControllerProvider).history.length, equals(1));
  });

  test(
      'ClassificationServiceImpl parses structured API errors and hides raw DioException details on network failure',
      () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'SocketException: Connection refused (OS Error 111)',
            ),
          );
        },
      ),
    );

    final service = ClassificationServiceImpl(dio);
    expect(
      () => service.classifyImage(
        bytes: kValidPngBytes,
        filename: 'test.png',
        regionType: 'eye',
      ),
      throwsA(
        isA<ClassificationApiException>()
            .having((e) => e.code, 'code', 'NETWORK_ERROR')
            .having((e) => e.isTechnicalFailure, 'isTechnicalFailure', isTrue)
            .having(
              (e) => e.message.contains('DioException') ||
                  e.message.contains('SocketException'),
              'exposes raw exception',
              isFalse,
            ),
      ),
    );
  });

  testWidgets(
      'Classification controller handles oversized images, technical errors without fake results, and mobile 375px layout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-100',
        email: 'mobile@sariwaba.ph',
        firstName: 'Ana',
        lastName: 'Reyes',
        username: 'anareyes',
      );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository()
      ..errorToThrow = const ClassificationApiException(
        code: 'MODEL_UNAVAILABLE',
        message: 'Trained MobileNetV3 checkpoint not found.',
        statusCode: 503,
      );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final controller =
        container.read(classificationControllerProvider.notifier);

    // 1. Oversized > 5 MB image rejected on client
    final oversizedBytes = Uint8List(5 * 1024 * 1024 + 16);
    controller.setSelectedImage(
      bytes: oversizedBytes,
      filename: 'oversized.png',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Image size exceeds 5 MB. Please select a smaller photo.'),
      findsWidgets,
    );
    expect(find.byKey(const Key('image_rejection_card')), findsOneWidget);

    // 2. Select valid PNG, select Gill, confirm close-up, and trigger API error
    controller.setSelectedImage(
      bytes: kValidPngBytes,
      filename: 'gill_closeup.png',
    );
    controller.selectRegion(AnatomicalRegion.gill);
    controller.confirmFullImageAsCloseUp();
    await tester.pumpAndSettle();

    await controller.classify();
    await tester.pumpAndSettle();

    // Verify technical error message is displayed and no fabricated result is produced
    expect(
      find.text('Trained MobileNetV3 checkpoint not found.'),
      findsWidgets,
    );
    expect(find.byKey(const Key('technical_error_card')), findsOneWidget);
    expect(find.text('Request Error (MODEL_UNAVAILABLE)'), findsOneWidget);
    expect(container.read(classificationControllerProvider).latestResult, isNull);
    expect(find.byKey(const Key('classification_result_view')), findsNothing);
  });

  testWidgets(
      'Audit History supports All / Fresh / Not Fresh filters, meaningful empty states, and confirmation before deletion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-88',
        email: 'history@sariwaba.ph',
        firstName: 'Marco',
        lastName: 'Diaz',
        username: 'marcodiaz',
      );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository()
      ..mockHistory = [
        ClassificationResult(
          scanId: 41,
          label: 'Fresh',
          confidence: 0.95,
          regionType: 'eye',
          species: 'Tilapia',
          saved: true,
          createdAt: DateTime.utc(2026, 5, 10, 8, 30),
        ),
      ];

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Filter by 'Not Fresh' when only a Fresh scan exists -> shows 'No Not Fresh results'
    await tester.tap(find.byKey(const Key('history_filter_not_fresh')));
    await tester.pumpAndSettle();
    expect(find.text('No Not Fresh results'), findsOneWidget);

    // 2. Switch back to 'All' -> shows Scan #41
    await tester.tap(find.byKey(const Key('history_filter_all')));
    await tester.pumpAndSettle();
    expect(find.text('Selected region: Eye'), findsOneWidget);

    // 3. Tap delete button -> shows confirmation dialog before deletion
    await tester.tap(find.byTooltip('Delete scan'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Scan Record?'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // History is now empty -> shows 'No classification history'
    expect(find.text('No classification history'), findsOneWidget);
    expect(find.text('Scan #41 permanently removed.'), findsOneWidget);
  });

  testWidgets(
      'iOS ROI Modal opens on image selection (including HEIC), auto-accepts crop position when pressing Validate & Classify Freshness, and re-opens on Edit Crop',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = FakeAuthRepository()
      ..mockUser = const UserModel(
        id: 'usr-101',
        email: 'modal@sariwaba.ph',
        firstName: 'Paolo',
        lastName: 'Reyes',
        username: 'paoloreyes',
      );
    final fakeGoogleService = FakeGoogleSignInService();
    final fakeClassRepo = FakeClassificationRepository()
      ..resultToReturn = const ClassificationResult(
        scanId: 777,
        label: 'Fresh',
        confidence: 0.96,
        regionType: 'eye',
        species: 'Tilapia',
        saved: true,
      );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo as dynamic),
        googleSignInServiceProvider
            .overrideWithValue(fakeGoogleService as dynamic),
        classificationRepositoryProvider
            .overrideWithValue(fakeClassRepo as dynamic),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SariwaBaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final controller =
        container.read(classificationControllerProvider.notifier);

    // 1. Selecting an iOS HEIC image (ISO Base Media 'ftypheic' header) is accepted and opens the ROI Modal
    final validHeicBytes = Uint8List.fromList([
      0x00, 0x00, 0x00, 0x18, // box size
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x68, 0x65, 0x69, 0x63, // 'heic' major brand
      0x00, 0x00, 0x00, 0x00,
      0x6D, 0x69, 0x66, 0x31, // 'mif1'
      0x68, 0x65, 0x69, 0x63, // 'heic'
    ]);
    controller.setSelectedImage(
      bytes: validHeicBytes,
      filename: 'iphone_tilapia.heic',
    );
    await tester.pumpAndSettle();

    expect(
      container.read(classificationControllerProvider).hasSelectedImage,
      isTrue,
    );
    expect(find.byKey(const Key('roi_cropper_modal')), findsOneWidget);
    // Ensure old redundant buttons and STEP badges are gone
    expect(find.byKey(const Key('crop_and_classify_button')), findsNothing);
    expect(find.byKey(const Key('full_image_and_classify_button')), findsNothing);
    expect(find.text('STEP 1'), findsNothing);
    expect(find.text('STEP 2'), findsNothing);
    expect(find.text('STEP 3'), findsNothing);
    expect(find.text('STEP 4'), findsNothing);

    // 2. Dismissing the modal via close button shows the compact pending card with Adjust Crop button
    await tester.tap(find.byKey(const Key('close_crop_modal_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('roi_cropper_modal')), findsNothing);
    expect(find.byKey(const Key('open_crop_modal_button')), findsOneWidget);

    // 3. Re-open the modal via 'Adjust Crop' button
    await tester.ensureVisible(find.byKey(const Key('open_crop_modal_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_crop_modal_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('roi_cropper_modal')), findsOneWidget);

    // 4. Eye is already pre-selected by default; press 'Validate & Classify Freshness' directly in 1 tap
    expect(
      container.read(classificationControllerProvider).selectedRegion,
      equals(AnatomicalRegion.eye),
    );
    await tester.ensureVisible(
      find.byKey(const Key('validate_and_classify_button')),
    );
    await tester.tap(find.byKey(const Key('validate_and_classify_button')));
    await tester.pumpAndSettle();

    // Pressing 'Validate & Classify Freshness' automatically accepted the crop position, closed the modal, and classified!
    expect(find.byKey(const Key('roi_cropper_modal')), findsNothing);
    expect(find.byKey(const Key('confirmed_region_preview')), findsOneWidget);
    expect(find.byKey(const Key('classification_result_view')), findsOneWidget);
    expect(fakeClassRepo.classifyCallCount, equals(1));

    // 5. Clicking 'Edit Crop' on the dashboard re-opens the ROI Modal
    await tester.ensureVisible(find.byKey(const Key('edit_crop_button')));
    await tester.tap(find.byKey(const Key('edit_crop_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('roi_cropper_modal')), findsOneWidget);
  });
}
