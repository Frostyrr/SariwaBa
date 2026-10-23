import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_theme.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/common/ambient_glow_background.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/navigation/web_footer.dart';
import '../../widgets/navigation/web_navbar.dart';

/// Downloads Page
/// Directly inspired by the reference layout:
/// Top section: "DOWNLOAD" pill tag, "Get SariwaBa.", subtitle,
/// 3 platform cards (iPhone & iPad, Android, Web) with feature checklists and download CTA pills.
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: SariwaColors.bgAbyssDark,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        useBlurredAsset: true,
        child: Column(
          children: [
            // Sticky Top Web Navbar
            WebNavbar(
              activeTab: 'Downloads',
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

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
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
                                    color: SariwaColors.surfaceGlass,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: SariwaColors.brandGlow.withValues(alpha: 0.4),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    'DOWNLOAD',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: SariwaColors.brandGlow,
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
                                  style: AppTypography.displayLarge.copyWith(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Subtitle
                              StaggeredReveal(
                                staggerIndex: 2,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 620),
                                  child: Text(
                                    'Free on Android and iOS. Evaluate seafood freshness on your phone with zero delay. Or launch directly in your browser without installing anything.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontSize: 16,
                                      color: SariwaColors.textSecondaryLight,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Platform Cards Grid (iOS, Android, Web)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isDesktop = constraints.maxWidth >= 900;

                                  if (isDesktop) {
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
                                child: Text(
                                  'SariwaBa scans fish freshness directly on your device. An internet connection is only needed to sync your saved scan history.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 12.5,
                                    color: SariwaColors.textMutedLight,
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
          ],
        ),
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
          color: const Color(0xFF007AFF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF007AFF).withValues(alpha: 0.35),
          ),
        ),
        child: const Icon(
          Icons.apple_rounded,
          color: Color(0xFF38BDF8),
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
          color: const Color(0xFF3DDC84).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3DDC84).withValues(alpha: 0.35),
          ),
        ),
        child: const Icon(
          Icons.android_rounded,
          color: Color(0xFF34D399),
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
          color: SariwaColors.brandGlow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SariwaColors.brandGlow.withValues(alpha: 0.35),
          ),
        ),
        child: const Icon(
          Icons.laptop_chromebook_rounded,
          color: SariwaColors.brandLight,
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

/// Common Platform Card Widget
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
    return SariwaGlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      borderColor: isPrimaryPlatform
          ? SariwaColors.brandGlow.withValues(alpha: 0.5)
          : SariwaColors.borderGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          icon,
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.45,
              color: SariwaColors.textSecondaryLight,
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
                    Icons.check_rounded,
                    size: 18,
                    color: SariwaColors.statusFresh,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feat,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        color: SariwaColors.textPrimaryLight,
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
