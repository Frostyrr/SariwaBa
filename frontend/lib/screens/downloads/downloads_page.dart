import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/common/ambient_glow_background.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/navigation/web_footer.dart';
import '../../widgets/navigation/web_navbar.dart';

/// Downloads Page
/// Cohesive with the Home Page aesthetic:
/// Features the atmospheric ocean-mint gradient background, floating glass pill navbar,
/// high-contrast slate typography, and elevated white platform cards (iOS, Android, Web).
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      body: Stack(
        children: [
          // Content Area with Ambient Gradient Background
          Positioned.fill(
            child: AmbientGlowBackground(
              showTopRightGlow: true,
              showBottomGlow: false,
              useLightAtmospheric: true,
              nextSectionColor: const Color(0xFFF0F7F6),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top spacer compensating for sticky floating glass pill WebNavbar
                    const SizedBox(height: 84),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Eyebrow Tag: "DOWNLOAD"
                              StaggeredReveal(
                                staggerIndex: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F7F5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFCCEAE6),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'DOWNLOAD',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.25,
                                      color: SariwaColors.brandPrimary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Heading: "Get SariwaBa."
                              StaggeredReveal(
                                staggerIndex: 1,
                                child: Text(
                                  'Get SariwaBa.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: isDesktop ? 48 : 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.25,
                                    color: const Color(0xFF0A2229),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Subtitle
                              StaggeredReveal(
                                staggerIndex: 2,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 620),
                                  child: const Text(
                                    'Free on Android and iOS. Evaluate seafood freshness on your phone with zero delay. Or launch directly in your browser without installing anything.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 16,
                                      color: Color(0xFF475569),
                                      height: 1.5,
                                      letterSpacing: -0.25,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Platform Cards Grid (iOS, Android, Web)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >= 900;

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 3,
                                            child: _buildIosCard(context),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 4,
                                            child: _buildAndroidCard(context),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 5,
                                            child: _buildWebCard(context, authController),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        StaggeredReveal(
                                          staggerIndex: 3,
                                          child: _buildIosCard(context),
                                        ),
                                        const SizedBox(height: 20),
                                        StaggeredReveal(
                                          staggerIndex: 4,
                                          child: _buildAndroidCard(context),
                                        ),
                                        const SizedBox(height: 20),
                                        StaggeredReveal(
                                          staggerIndex: 5,
                                          child: _buildWebCard(context, authController),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),

                              const SizedBox(height: 60),

                              // Bottom Disclaimer Note
                              StaggeredReveal(
                                staggerIndex: 6,
                                child: const Text(
                                  'SariwaBa scans fish freshness directly on your device. An internet connection is only needed to sync your saved scan history.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12.5,
                                    letterSpacing: -0.25,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 64),
                            ],
                          ),
                        ),
                      ),
                    ),
                    WebFooter(
                      onHome: () => authController.goToLanding(),
                      onFeatures: () => authController.goToLanding(),
                      onHowItWorks: () => authController.goToLanding(),
                      onDownloads: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Top Floating Glass Pill Web Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebNavbar(
              activeTab: 'Downloads',
              isLight: true,
              user: authState.user,
              onHome: () => authController.goToLanding(),
              onFeatures: () => authController.goToFeatures(),
              onHowItWorks: () => authController.goToHowItWorks(),
              onDashboard: () => authController.goToDashboard(),
              onSignOut: () => authController.signOut(),
              onDownloads: () {},
              onGetStarted: () {},
              onLogIn: () => authController.goToLogin(),
            ),
          ),
        ],
      ),
    );
  }

  /// Platform 1: iPhone & iPad
  Widget _buildIosCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBAE6FD),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.apple_rounded,
          color: Color(0xFF0284C7),
          size: 28,
        ),
      ),
      title: 'iPhone & iPad',
      description: 'One universal app with a live camera scanner and offline freshness checking.',
      features: const [
        'iOS 16.0 or later',
        'iPhone and iPad supported',
        'Camera live scanner mode',
      ],
      buttonLabel: 'Get it on App Store',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('iOS build coming soon to TestFlight & App Store!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Platform 2: Android
  Widget _buildAndroidCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFA7F3D0),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.android_rounded,
          color: Color(0xFF059669),
          size: 28,
        ),
      ),
      title: 'Android',
      description: 'Phones and tablets with instant AI freshness grading and Google Sign-in.',
      features: const [
        'Android 8.0 or later',
        'Google Play Services',
        'Google Sign-in integrated',
      ],
      buttonLabel: 'Get it on Google Play',
      isPrimaryPlatform: true,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Android APK available in release artifacts & Google Play.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Platform 3: Web
  Widget _buildWebCard(BuildContext context, AuthController authController) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F7F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCCEAE6),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.laptop_chromebook_rounded,
          color: SariwaColors.brandPrimary,
          size: 26,
        ),
      ),
      title: 'Web',
      description: 'Instant quality audits in any desktop or mobile browser. Nothing to install.',
      features: const [
        'Any modern browser (Chrome, Safari, Edge)',
        'Zero installation required',
        'Responsive inspection dashboard',
      ],
      buttonLabel: 'Open the web app',
      onPressed: () => authController.goToLogin(),
    );
  }
}

/// Common Elevated Platform Card Widget
class _PlatformCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isPrimaryPlatform;

  const _PlatformCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.buttonLabel,
    required this.onPressed,
    this.isPrimaryPlatform = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimaryPlatform
              ? SariwaColors.brandPrimary.withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
          width: isPrimaryPlatform ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimaryPlatform
                ? const Color(0x1414B8A6)
                : const Color(0x0A0A2229),
            blurRadius: isPrimaryPlatform ? 24 : 18,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          icon,
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.25,
              color: Color(0xFF0A2229),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              height: 1.45,
              letterSpacing: -0.25,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 24),

          // Checklist
          ...features.map(
            (feat) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF168077),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feat,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.25,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          AppButton.primary(
            label: buttonLabel,
            width: double.infinity,
            height: 48,
            borderRadius: 24,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
