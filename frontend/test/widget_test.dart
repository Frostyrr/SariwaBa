import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/data/google_sign_in_service.dart';
import 'package:frontend/features/auth/domain/models/user_model.dart';
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
  Future<GoogleSignInAccount?> signInSilently() async {
    return null;
  }

  @override
  Future<void> signOut() async {}
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
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Methodology'), findsOneWidget);
    expect(find.text('Standards'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Verify clean Hero buttons
    expect(find.text('Get Started'), findsNWidgets(2));
    expect(find.text('How it works'), findsOneWidget);

    // Tap "Get Started" in Hero
    await tester.tap(find.text('Get Started').last);
    await tester.pumpAndSettle();

    // Verify simplified Auth Page without fake email field
    expect(find.text('Sign in to SariwaBa'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Log In'), findsNothing);

    // Tap "< Home" to verify back navigation to landing
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Back on landing page
    expect(find.text('Overview'), findsOneWidget);
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

    // Tap "Get Started"
    await tester.tap(find.text('Get Started').last);
    await tester.pumpAndSettle();

    // Tap "Continue as Guest"
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    // Arrives at Home in Guest mode
    expect(find.text('Guest Evaluation Mode'), findsOneWidget);
    expect(find.text('Connect with Google'), findsOneWidget);
  });
}
