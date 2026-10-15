import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/data/google_sign_in_service.dart';
import 'package:frontend/features/auth/domain/models/user_model.dart';
import 'package:frontend/features/classification/data/classification_repository.dart';
import 'package:frontend/features/classification/domain/models/classification_result.dart';
import 'package:frontend/features/landing/presentation/widgets/web_navbar.dart';
import 'package:frontend/main.dart';

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

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    return const ClassificationResult(
      scanId: 101,
      label: 'Fresh',
      confidence: 0.96,
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

    // Verify Web Navbar links & buttons
    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('Features')), findsOneWidget);
    expect(find.descendant(of: find.byType(WebNavbar), matching: find.text('How it Works')), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Verify hero text
    expect(find.text('SariwaBa? See for yourself.'), findsOneWidget);
    expect(find.text('A smarter way to assess fish freshness through AI.'), findsOneWidget);

    // Verify Download App buttons
    expect(find.text('Download App'), findsAtLeast(2));

    // Tap "Download App" -> navigates to Downloads Page
    await tester.tap(find.text('Download App').first);
    await tester.pumpAndSettle();

    // Verify Downloads Page loaded with platform cards
    expect(find.text('Get SariwaBa.'), findsOneWidget);
    expect(find.text('iPhone & iPad'), findsOneWidget);
    expect(find.text('Android'), findsOneWidget);
    expect(find.text('Web'), findsOneWidget);

    // From downloads, tap "Open the web app" to go to Auth Page
    await tester.ensureVisible(find.text('Open the web app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open the web app'));
    await tester.pumpAndSettle();

    // Verify simplified Auth Page matching wireframe
    expect(find.text('SariwaBa'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Log In'), findsNothing);

    // Tap "< Home" to verify back navigation to landing
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Back on landing page (Features is in WebNavbar and WebFooter)
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

    // Tap "Log in" in mobile navbar
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    // Tap "Continue as Guest"
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    // Arrives at Home in Guest mode
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

    // Authenticated user should see the Dashboard greeting and not "Log in"
    expect(find.text('Welcome back, Juan!'), findsOneWidget);
    expect(find.text('Live Freshness Inspection'), findsOneWidget);
    expect(find.text('Audit History'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);

    // Navbar shows user avatar with name
    expect(find.text('Juan'), findsOneWidget);
  });
}
