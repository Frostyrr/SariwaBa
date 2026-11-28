import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:frontend/controllers/auth/auth_controller.dart';
import 'package:frontend/controllers/auth/auth_state.dart';
import 'package:frontend/screens/auth/mobile_welcome_page.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';

class _IdleAuthController extends AuthController {
  _IdleAuthController({
    required super.repository,
    required super.googleService,
  }) {
    state = const AuthState(viewStatus: AuthViewStatus.login, isLoading: false);
  }

  @override
  Future<void> bootstrap() async {
    state = const AuthState(viewStatus: AuthViewStatus.login, isLoading: false);
  }
}

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    required Size size,
    bool disableAnimations = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => _IdleAuthController(
              repository: ref.read(authServiceProvider),
              googleService: ref.read(googleSignInServiceProvider),
            ),
          ),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              disableAnimations: disableAnimations,
            ),
            child: const MobileWelcomePage(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('renders monochrome welcome screen cleanly at 390x844', (
    tester,
  ) async {
    await pumpWelcome(tester, size: const Size(390, 844));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF5F5F7));

    expect(find.text('SariwaBa'), findsOneWidget);
    expect(find.text('Fresh · 75.8%'), findsOneWidget);
    expect(find.text('Check fish freshness\nin a snap.'), findsOneWidget);
    expect(
      find.text(
        'Snap a close-up eye or gill photo for an instant freshness reading.',
      ),
      findsOneWidget,
    );
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(
      find.text(
        'Sign in to sync across devices, or scan locally as a guest.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on compact 360x640 with reduced motion', (
    tester,
  ) async {
    await pumpWelcome(
      tester,
      size: const Size(360, 640),
      disableAnimations: true,
    );

    expect(find.text('SariwaBa'), findsOneWidget);
    expect(find.text('Fresh · 75.8%'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
