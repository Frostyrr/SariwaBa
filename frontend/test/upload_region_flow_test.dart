import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';
import 'package:frontend/services/classification/classification_service.dart';

import 'widget_test.dart'
    show
        FakeAuthRepository,
        FakeGoogleSignInService,
        FakeClassificationRepository,
        kValidPngBytes;

class _SlowEyeService extends FakeClassificationRepository
    implements EyeProposalService {
  int eyeRequests = 0;
  final pendingEyes = Completer<EyeProposalResult>();

  @override
  Future<EyeProposalResult> findEyes(Uint8List bytes, String filename) {
    eyeRequests++;
    return pendingEyes.future;
  }
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'upload opens editor without eye lookup and submits Gill at width $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final service = _SlowEyeService();
        final auth = FakeAuthRepository()
          ..mockUser = const UserModel(
            id: 'inspector',
            email: 'inspector@example.com',
            firstName: 'Test',
            lastName: 'Inspector',
            username: 'inspector',
          );
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            googleSignInServiceProvider.overrideWithValue(
              FakeGoogleSignInService(),
            ),
            classificationRepositoryProvider.overrideWithValue(service),
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
        final controller = container.read(
          classificationControllerProvider.notifier,
        );
        expect(controller.canFindEyes, isTrue);
        controller.setSelectedImage(
          bytes: kValidPngBytes,
          filename: 'gill.png',
        );
        await tester.pumpAndSettle();

        expect(service.eyeRequests, 0);
        expect(service.classifyCallCount, 0);
        expect(find.byKey(const Key('roi_cropper_modal')), findsOneWidget);
        expect(find.text('Checking the photo…'), findsNothing);
        expect(find.text('Find Eye'), findsOneWidget);

        final gill = find.byKey(const Key('region_option_gill'));
        await tester.ensureVisible(gill);
        await tester.tap(gill);
        await tester.pumpAndSettle();
        expect(
          container.read(classificationControllerProvider).selectedRegion,
          AnatomicalRegion.gill,
        );
        expect(find.text('Find Eye'), findsNothing);
        final fullImage = find.byKey(const Key('confirm_full_image_button'));
        await tester.ensureVisible(fullImage);
        await tester.tap(fullImage);
        await tester.pumpAndSettle();
        final classify = find.byKey(const Key('validate_and_classify_button'));
        await tester.ensureVisible(classify);
        await tester.tap(classify);
        await tester.pumpAndSettle();

        expect(service.eyeRequests, 0);
        expect(service.classifyCallCount, 1);
        expect(service.lastSubmittedRegionType, 'gill');
        expect(service.lastSubmittedBytes, kValidPngBytes);
        expect(
          container.read(classificationControllerProvider).errorCode,
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
