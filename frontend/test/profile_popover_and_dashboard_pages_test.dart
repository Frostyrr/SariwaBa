import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/constants/content/faq_data.dart';
import 'package:frontend/constants/content/workflow_steps_data.dart';
import 'package:frontend/controllers/auth/auth_controller.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/pages/dashboard/sections/account_settings_page_section.dart';
import 'package:frontend/pages/dashboard/sections/help_faq_dashboard_section.dart';
import 'package:frontend/pages/dashboard/sections/how_it_works_dashboard_section.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/services/storage/guest_history_cache.dart';
import 'package:frontend/widgets/dashboard/profile_popover_menu.dart';

class MockAuthRepository extends Fake implements AuthService {
  bool deleteAccountCalled = false;
  Exception? errorOnDelete;

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
    if (errorOnDelete != null) {
      throw errorOnDelete!;
    }
  }

  @override
  Future<UserModel?> getProfile() async => null;

  @override
  Future<void> signOut() async {}
}

class MockClassificationRepository extends Fake
    implements ClassificationService {
  bool clearAllHistoryCalled = false;
  Exception? errorOnClear;

  @override
  Future<void> clearAllHistory() async {
    clearAllHistoryCalled = true;
    if (errorOnClear != null) {
      throw errorOnClear!;
    }
  }

  @override
  Future<List<ClassificationResult>> fetchHistory() async => [];
}

class MockGoogleSignInService extends Fake implements GoogleSignInService {
  final _controller = StreamController<GoogleSignInAccount?>.broadcast();

  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _controller.stream;

  @override
  Future<void> signOut() async {}
}

class MockGuestCache extends Fake implements GuestHistoryCache {
  bool clearCacheCalled = false;

  @override
  Future<List<ClassificationResult>> getCachedHistory() async => [];

  @override
  Future<void> clearCache() async {
    clearCacheCalled = true;
  }
}

void main() {
  const testUser = UserModel(
    id: 'user-101',
    email: 'inspector@sariwaba.ph',
    firstName: 'Maria',
    lastName: 'Santos',
    role: 'inspector',
    isAdmin: false,
    dateJoined: null,
  );

  const adminUser = UserModel(
    id: 'user-admin',
    email: 'admin@sariwaba.ph',
    firstName: 'Admin',
    lastName: 'Chief',
    role: 'admin',
    isAdmin: true,
    dateJoined: null,
  );

  group('ProfilePopoverButton', () {
    testWidgets('renders user avatar and triggers upward anchored popover menu',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? selectedNav;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 250,
                child: ProfilePopoverButton(
                  user: testUser,
                  isGuestUser: false,
                  isCollapsed: false,
                  onNavSelected: (nav) => selectedNav = nav,
                  onSignOut: () {},
                  onSignIn: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('inspector@sariwaba.ph'), findsOneWidget);

      // Tap to open popover
      await tester.tap(find.text('Maria Santos'));
      await tester.pumpAndSettle();

      // Verify popover options appear
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Help & FAQs'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      // Tap 'Account Settings'
      await tester.tap(find.text('Account Settings'));
      await tester.pumpAndSettle();

      expect(selectedNav, 'Settings');
      // Popover should be dismissed after selection
      expect(find.byKey(const Key('popover_account_settings')), findsNothing);
    });

    testWidgets('triggers Log Out action from popover', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool signOutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 250,
                child: ProfilePopoverButton(
                  user: testUser,
                  isGuestUser: false,
                  isCollapsed: false,
                  onNavSelected: (_) {},
                  onSignOut: () => signOutCalled = true,
                  onSignIn: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Maria Santos'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(signOutCalled, isTrue);
    });

    testWidgets('shows Guest mode indicator and Sign In option for guests',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool signInCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 250,
                child: ProfilePopoverButton(
                  user: null,
                  isGuestUser: true,
                  isCollapsed: false,
                  onNavSelected: (_) {},
                  onSignOut: () {},
                  onSignIn: () => signInCalled = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Evaluator'), findsOneWidget);
      await tester.tap(find.text('Evaluator'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In with Google'), findsOneWidget);
      await tester.tap(find.text('Sign In with Google'));
      await tester.pumpAndSettle();

      expect(signInCalled, isTrue);
    });
  });

  group('HowItWorksDashboardSection', () {
    testWidgets('renders all 5 workflow steps and disclaimer banner',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool inspectionStarted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HowItWorksDashboardSection(
            isDesktop: true,
            onStartInspection: () => inspectionStarted = true,
          ),
        ),
      );

      // Verify header & disclaimer
      expect(find.text('How SariwaBa? Works'), findsOneWidget);
      expect(
        find.text('Before you use your result'),
        findsOneWidget,
      );

      // Verify all 5 steps exist
      for (final step in WorkflowStepsData.steps) {
        expect(find.text(step.title), findsOneWidget);
      }

      // Verify CTA button
      final ctaFinder = find.text('Start New Inspection');
      await tester.ensureVisible(ctaFinder);
      await tester.tap(ctaFinder);
      await tester.pump();

      expect(inspectionStarted, isTrue);
    });
  });

  group('HelpFaqDashboardSection', () {
    testWidgets('renders FAQ items and filters by search query and category',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpFaqDashboardSection(isDesktop: true),
        ),
      );

      expect(find.text('Help & Frequently Asked Questions'), findsOneWidget);

      // Verify first FAQ is rendered
      final firstFaq = FaqData.items.first;
      expect(find.text(firstFaq.question), findsOneWidget);

      // Accordion expansion test: tap first question
      await tester.tap(find.text(firstFaq.question));
      await tester.pumpAndSettle();
      expect(find.text(firstFaq.answer), findsOneWidget);

      // Search filtering test: enter specific search keyword
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'evaluate');
      await tester.pumpAndSettle();

      // Questions or answers containing 'evaluate' should be displayed
      expect(find.text(firstFaq.question), findsOneWidget);

      // Filter by category chip
      final categoryChip = find.text('Troubleshooting');
      await tester.ensureVisible(categoryChip);
      await tester.tap(categoryChip);
      await tester.pumpAndSettle();

      expect(find.text('Troubleshooting'), findsWidgets);
    });
  });

  group('AccountSettingsPageSection', () {
    testWidgets('displays profile information and clears history upon confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuthRepo = MockAuthRepository();
      final fakeClassRepo = MockClassificationRepository();
      final fakeGoogleService = MockGoogleSignInService();
      final fakeGuestCache = MockGuestCache();

      final authController = AuthController(
        repository: fakeAuthRepo,
        googleService: fakeGoogleService,
      );
      final classController = ClassificationController(
        fakeClassRepo,
        isAuthenticated: true,
        guestCache: fakeGuestCache,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountSettingsPageSection(
              user: testUser,
              isGuestUser: false,
              isDesktop: true,
              authController: authController,
              classificationController: classController,
              onSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('inspector@sariwaba.ph'), findsOneWidget);
      expect(find.text('Inspector'), findsOneWidget);

      // Tap Clear All History button
      final clearBtn = find.byKey(const Key('btn_clear_all_history'));
      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog should be open
      expect(find.text('Clear All History?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete All Records'));
      await tester.pumpAndSettle();

      expect(fakeClassRepo.clearAllHistoryCalled, isTrue);
      expect(
        find.text('Your scan history has been deleted.'),
        findsOneWidget,
      );
    });

    testWidgets('invokes delete account upon confirmation', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuthRepo = MockAuthRepository();
      final fakeClassRepo = MockClassificationRepository();
      final fakeGoogleService = MockGoogleSignInService();
      final fakeGuestCache = MockGuestCache();

      final authController = AuthController(
        repository: fakeAuthRepo,
        googleService: fakeGoogleService,
      );
      final classController = ClassificationController(
        fakeClassRepo,
        isAuthenticated: true,
        guestCache: fakeGuestCache,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountSettingsPageSection(
              user: testUser,
              isGuestUser: false,
              isDesktop: true,
              authController: authController,
              classificationController: classController,
              onSignIn: () {},
            ),
          ),
        ),
      );

      final deleteBtn = find.byKey(const Key('btn_delete_account'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delete SariwaBa Account?'), findsOneWidget);

      await tester.tap(find.text('Yes, Delete My Account'));
      await tester.pumpAndSettle();

      expect(fakeAuthRepo.deleteAccountCalled, isTrue);
    });

    testWidgets('handles last active admin deletion prohibition safely',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuthRepo = MockAuthRepository();
      fakeAuthRepo.errorOnDelete =
          Exception('Cannot delete the last active administrator account.');

      final fakeClassRepo = MockClassificationRepository();
      final fakeGoogleService = MockGoogleSignInService();
      final fakeGuestCache = MockGuestCache();

      final authController = AuthController(
        repository: fakeAuthRepo,
        googleService: fakeGoogleService,
      );
      final classController = ClassificationController(
        fakeClassRepo,
        isAuthenticated: true,
        guestCache: fakeGuestCache,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountSettingsPageSection(
              user: adminUser,
              isGuestUser: false,
              isDesktop: true,
              authController: authController,
              classificationController: classController,
              onSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.text('Admin Chief'), findsOneWidget);
      expect(find.text('Administrator'), findsOneWidget);

      final deleteBtn = find.byKey(const Key('btn_delete_account'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes, Delete My Account'));
      await tester.pumpAndSettle();

      // Error dialog should appear informing the user that deletion was prohibited
      expect(find.text('Unable to Delete Account'), findsOneWidget);
      expect(
        find.text('Cannot delete the last active administrator account.'),
        findsWidgets,
      );
    });
  });
}
