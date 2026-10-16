import 'package:flutter/material.dart';
import '../controllers/auth/auth_state.dart';
import '../pages/auth/auth_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/downloads/downloads_page.dart';
import '../pages/home/home_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String downloads = '/downloads';

  /// Maps the current [AuthViewStatus] to its corresponding page widget
  /// with a stable [ValueKey] for smooth [AnimatedSwitcher] transitions.
  static Widget resolveScreen(AuthViewStatus status) {
    switch (status) {
      case AuthViewStatus.initializing:
        return const Scaffold(
          key: ValueKey('splash_loading'),
          backgroundColor: Color(0xFF060B12),
          body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
        );
      case AuthViewStatus.authenticated:
        return const DashboardPage(key: ValueKey('dashboard_page'));
      case AuthViewStatus.landing:
      case AuthViewStatus.features:
      case AuthViewStatus.howItWorks:
      case AuthViewStatus.guestMode:
        return const HomePage(key: ValueKey('home_page'));
      case AuthViewStatus.downloads:
        return const DownloadsPage(key: ValueKey('downloads_page'));
      case AuthViewStatus.login:
        return const AuthPage(key: ValueKey('auth_page'));
    }
  }
}
