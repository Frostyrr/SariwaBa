import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Desktop web landing renders navbar, clean hero, and navigates to Resend auth',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: SariwaBaApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Web Navbar links & buttons
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Methodology'), findsOneWidget);
    expect(find.text('Standards'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Verify clean Hero buttons: "Get Started" (white primary) and "How it works" (secondary)
    expect(find.text('Get Started'), findsNWidgets(2)); // navbar & hero
    expect(find.text('How it works'), findsOneWidget);

    // Verify AI slop is removed
    expect(find.text('AI SEAFOOD INSPECTION PLATFORM'), findsNothing);
    expect(find.text('Computer Vision Freshness Grading'), findsNothing);
    expect(find.text('24ms Inference'), findsNothing);

    // Tap "Get Started" in the Hero section
    await tester.tap(find.text('Get Started').last);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Resend-style Auth View is presented
    expect(find.text('Log in to SariwaBa'), findsOneWidget);
    expect(find.text('Log in with Google'), findsOneWidget);
    expect(find.text('Last used'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    // Tap "< Home" to verify back navigation to landing
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    // Back on landing page
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('Resend auth view signs in with Google directly to Home',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: SariwaBaApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Tap "Log in" in the navbar
    await tester.tap(find.text('Log in'));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap "Log in with Google"
    await tester.tap(find.text('Log in with Google'));
    await tester.pump(const Duration(milliseconds: 700));

    // Successfully arrives at Home authenticated
    expect(find.text('Hello, Juan Dela Cruz 👋'), findsOneWidget);
    expect(find.text('Instant AI Seafood Scan'), findsOneWidget);
  });

  testWidgets('Mobile landing renders responsive hero and guest mode access',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: SariwaBaApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify mobile buttons
    expect(find.text('Get Started'), findsNWidgets(2));
    expect(find.text('How it works'), findsOneWidget);

    // Tap "Get Started"
    await tester.tap(find.text('Get Started').last);
    await tester.pump(const Duration(milliseconds: 300));

    // Tap "Continue as Guest"
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump(const Duration(milliseconds: 300));

    // Arrives at Home in Guest mode
    expect(find.text('Guest Evaluation Mode'), findsOneWidget);
    expect(find.text('Connect with Google'), findsOneWidget);
  });
}
