import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import 'hero_scanner_card.dart';

/// Features Section Widget for Unified Smooth Scroll Landing Page
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Engineered for Precision Grading',
          style: AppTypography.displayLarge.copyWith(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 40),
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

/// How It Works Section Widget for Unified Smooth Scroll Landing Page
class HowItWorksSection extends StatelessWidget {
  final VoidCallback onDownload;

  const HowItWorksSection({
    super.key,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Three Steps to Quality Assurance',
          style: AppTypography.displayLarge.copyWith(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 40),
        _buildStepRow(
          stepNumber: '01',
          title: 'Capture Key Sensory Landmarks',
          description:
              'Open the live camera viewfinder and frame either the fish eyes or gill cavity. Real-time guides ensure optimal lighting and angle.',
          icon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 18),
        _buildStepRow(
          stepNumber: '02',
          title: 'Instant MobileNetV3 Neural Inference',
          description:
              'Our lightweight quantized model evaluates texture, color saturation, and corneal diffusion in under 30 milliseconds on your device.',
          icon: Icons.memory_outlined,
        ),
        const SizedBox(height: 18),
        _buildStepRow(
          stepNumber: '03',
          title: 'Standardized Tier Verdict (Sariwa / Moderate / Spoiled)',
          description:
              'Receive confidence metrics and actionable freshness classifications to guarantee safe consumption and fair trade pricing.',
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: 36),
        AppButton.primary(
          label: 'Get the App',
          icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
          width: 180,
          height: 48,
          borderRadius: 24,
          onPressed: onDownload,
        ),
      ],
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
