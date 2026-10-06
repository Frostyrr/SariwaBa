import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/controllers/auth_state.dart';
import 'features/auth/presentation/pages/resend_auth_view.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/landing/presentation/pages/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SariwaBaApp(),
    ),
  );
}

class SariwaBaApp extends ConsumerWidget {
  const SariwaBaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    Widget getRootScreen() {
      switch (authState.viewStatus) {
        case AuthViewStatus.landing:
          return const LandingPage(key: ValueKey('landing_page'));
        case AuthViewStatus.login:
          return const ResendAuthView(key: ValueKey('resend_auth_view'));
        case AuthViewStatus.authenticated:
        case AuthViewStatus.guestMode:
          return const HomePage(key: ValueKey('home_page'));
      }
    }

    return MaterialApp(
      title: 'SariwaBa? — Fish Freshness Classification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.015, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: getRootScreen(),
      ),
    );
  }
}
