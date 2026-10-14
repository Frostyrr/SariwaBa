import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/web_navbar.dart';

/// How It Works Page
/// Detailed 3-step walkthrough: Capture, AI Analysis, and Standardized Grading.
class HowItWorksPage extends ConsumerWidget {
  const HowItWorksPage({super.key});

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
              activeTab: 'How it Works',
              onHome: () => authController.goToLanding(),
              onFeatures: () => authController.goToFeatures(),
              onHowItWorks: () {},
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
                      constraints: const BoxConstraints(maxWidth: 1040.0),
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
                              'METHODOLOGY',
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
                            'Three Steps to Quality Assurance.',
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Text(
                              'Eliminate subjective guesswork with real-time sensory classification aligned with international seafood grading standards.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLarge.copyWith(
                                color: SariwaColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Step 1
                          _buildStepRow(
                            stepNumber: '01',
                            title: 'Capture Key Sensory Landmarks',
                            description:
                                'Open the live camera viewfinder and frame either the fish eyes or gill cavity. Real-time guides ensure optimal lighting and angle.',
                            icon: Icons.camera_alt_outlined,
                          ),
                          const SizedBox(height: 20),

                          // Step 2
                          _buildStepRow(
                            stepNumber: '02',
                            title: 'Instant MobileNetV3 Neural Inference',
                            description:
                                'Our lightweight quantized model evaluates texture, color saturation, and corneal diffusion in under 30 milliseconds on your device.',
                            icon: Icons.memory_outlined,
                          ),
                          const SizedBox(height: 20),

                          // Step 3
                          _buildStepRow(
                            stepNumber: '03',
                            title: 'Standardized Tier Verdict (Sariwa / Moderate / Spoiled)',
                            description:
                                'Receive confidence metrics and actionable freshness classifications to guarantee safe consumption and fair trade pricing.',
                            icon: Icons.verified_outlined,
                          ),

                          const SizedBox(height: 48),

                          AppButton.primary(
                            label: 'Get the App',
                            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                            width: 180,
                            height: 48,
                            borderRadius: 24,
                            onPressed: () => authController.goToDownloads(),
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

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return SariwaGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stepNumber,
              style: AppTypography.monoMetric.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: SariwaColors.brandLight, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: SariwaColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
