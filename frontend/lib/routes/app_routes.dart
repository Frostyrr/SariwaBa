import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth/auth_controller.dart';
import '../controllers/auth/auth_state.dart';
import '../screens/auth/auth_page.dart';
import '../screens/dashboard/dashboard_page.dart';
import '../screens/downloads/downloads_page.dart';
import '../screens/home/home_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(
    ref.read(authControllerProvider),
  );

  ref.onDispose(authNotifier.dispose);

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: AppRoutes.pathForStatus(authNotifier.value.viewStatus),
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final targetPath = AppRoutes.pathForStatus(authNotifier.value.viewStatus);
      if (state.matchedLocation != targetPath) {
        return targetPath;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => AppRoutes._buildTransitionPage(
          key: state.pageKey,
          child: const Scaffold(
            key: ValueKey('splash_loading'),
            backgroundColor: Color(0xFF060B12),
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => AppRoutes._buildTransitionPage(
          key: state.pageKey,
          child: const HomePage(key: ValueKey('home_page')),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => AppRoutes._buildTransitionPage(
          key: state.pageKey,
          child: const AuthPage(key: ValueKey('auth_page')),
        ),
      ),
      GoRoute(
        path: AppRoutes.downloads,
        pageBuilder: (context, state) => AppRoutes._buildTransitionPage(
          key: state.pageKey,
          child: const DownloadsPage(key: ValueKey('downloads_page')),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (context, state) => AppRoutes._buildTransitionPage(
          key: state.pageKey,
          child: const DashboardPage(key: ValueKey('dashboard_page')),
        ),
      ),
    ],
  );
});

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String downloads = '/downloads';

  /// Maps the current [AuthViewStatus] to its corresponding route path.
  static String pathForStatus(AuthViewStatus status) {
    switch (status) {
      case AuthViewStatus.initializing:
        return splash;
      case AuthViewStatus.authenticated:
      case AuthViewStatus.guestMode:
        return dashboard;
      case AuthViewStatus.landing:
      case AuthViewStatus.features:
      case AuthViewStatus.howItWorks:
        return home;
      case AuthViewStatus.downloads:
        return downloads;
      case AuthViewStatus.login:
        return login;
    }
  }

  /// Builds a smooth 240ms fade + subtle slide transition page for [GoRouter].
  static CustomTransitionPage<void> _buildTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: SelectionArea(child: child),
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.015, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
