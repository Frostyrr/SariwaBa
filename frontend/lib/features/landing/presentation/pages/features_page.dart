import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/web_navbar.dart';

/// Features Page
/// Highlights Core AI capabilities: Cornea clarity, gill spectrometry, offline classification, and audit logging.
class FeaturesPage extends ConsumerWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: SariwaColors.bgAbyssDark,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        useBlurredAsset: true,
        child: Column(
          children: [
            WebNavbar(
              activeTab: 'Features',
              onHome: () => authController.goToLanding(),
              onFeatures: () {},
              onHowItWorks: () => authController.goToHowItWorks(),
              onDownloads: () => authController.goToDownloads(),
              onGetStarted: () => authController.goToDownloads(),
              onLogIn: () => authController.goToLogin(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: SariwaColors.surfaceGlass,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: SariwaColors.brandGlow.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'CAPABILITIES',
                              style: AppTypography.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: SariwaColors.brandGlow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Engineered for Precision Grading.',
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Text(
                              'Standardize seafood inspection across markets, harbors, and cold storage with clinical computer vision.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLarge.copyWith(
                                color: SariwaColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Features 2x2 Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isDesktop = constraints.maxWidth >= 768;
                              return Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: [
                                  SizedBox(
                                    width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                                    child: _buildFeatureCard(
                                      icon: Icons.remove_red_eye_outlined,
                                      title: 'Cornea Optical Clarity',
                                      desc: 'Analyzes pupil transparency and lens convexity to detect post-mortem cloudiness within milliseconds.',
                                    ),
                                  ),
                                  SizedBox(
                                    width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                                    child: _buildFeatureCard(
                                      icon: Icons.bloodtype_outlined,
                                      title: 'Branchial Gill Pigmentation',
                                      desc: 'Measures RGB redness variance and discoloration across gill arches to separate fresh catch from oxidized fish.',
                                    ),
                                  ),
                                  SizedBox(
                                    width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                                    child: _buildFeatureCard(
                                      icon: Icons.offline_bolt_outlined,
                                      title: 'Offline Edge Inference',
                                      desc: 'Runs lightweight MobileNetV3 quantized neural networks locally on your mobile device without internet.',
                                    ),
                                  ),
                                  SizedBox(
                                    width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                                    child: _buildFeatureCard(
                                      icon: Icons.history_edu_outlined,
                                      title: 'Quality Audit Trails',
                                      desc: 'Seamlessly synchronizes inspection records and classification telemetry with PostgreSQL and Google Auth.',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return SariwaGlassCard(
      padding: const EdgeInsets.all(26),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SariwaColors.brandGlow.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(icon, color: SariwaColors.brandLight, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.5,
              color: SariwaColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
